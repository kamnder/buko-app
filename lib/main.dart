import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart' as buko_service;

const green = Color(0xFF22C55E);
const blue = Color(0xFF2563EB);
const navy = Color(0xFF07131E);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BukoApp());
}

class BukoApp extends StatelessWidget {
  const BukoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BUKO',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: navy,
          colorScheme: ColorScheme.fromSeed(seedColor: green, brightness: Brightness.dark),
          cardTheme: const CardThemeData(color: Color(0xFF102434)),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            labelStyle: TextStyle(color: Colors.black54),
            hintStyle: TextStyle(color: Colors.black45),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: const AuthGate(),
      );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<auth.User?>(
        stream: buko_service.buko_service.FirebaseService.instance.authState,
        builder: (_, snap) => snap.data == null ? const PhoneAuthPage() : const HomeShell(),
      );
}

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});
  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final phone = TextEditingController();
  final code = TextEditingController();
  String? verificationId;
  bool loading = false;
  String error = '';

  @override
  void dispose() {
    phone.dispose();
    code.dispose();
    super.dispose();
  }

  String normalize(String value) {
    var p = value.trim().replaceAll(' ', '');
    if (p.startsWith('00249')) p = '+${p.substring(2)}';
    if (p.startsWith('249')) p = '+$p';
    return p;
  }

  Future<void> sendCode() async {
    final p = normalize(phone.text);
    if (!RegExp(r'^\+249\d{9}$').hasMatch(p)) {
      setState(() => error = 'استخدم رقم السودان: +249XXXXXXXXX');
      return;
    }
    setState(() { loading = true; error = ''; });
    await auth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: p,
      verificationCompleted: (credential) async => auth.FirebaseAuth.instance.signInWithCredential(credential),
      verificationFailed: (e) => setState(() { loading = false; error = e.message ?? 'تعذر إرسال رمز التحقق'; }),
      codeSent: (id, _) => setState(() { verificationId = id; loading = false; }),
      codeAutoRetrievalTimeout: (id) => verificationId = id,
    );
  }

  Future<void> verify() async {
    if (verificationId == null || code.text.trim().length < 6) {
      setState(() => error = 'أدخل رمز التحقق المرسل للهاتف');
      return;
    }
    setState(() { loading = true; error = ''; });
    try {
      final credential = auth.PhoneAuthProvider.credential(verificationId: verificationId!, smsCode: code.text.trim());
      await auth.FirebaseAuth.instance.signInWithCredential(credential);
      await buko_service.buko_service.FirebaseService.instance.saveUserProfile(
        uid: auth.FirebaseAuth.instance.currentUser!.uid,
        name: 'مستخدم BUKO',
        phone: normalize(phone.text),
        role: 'buyer',
      );
    } on auth.FirebaseAuthException catch (e) {
      setState(() { loading = false; error = e.message ?? 'رمز التحقق غير صحيح'; });
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(children: [
                    const Icon(Icons.directions_car, size: 76, color: green),
                    const SizedBox(height: 12),
                    const Text('BUKO', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    const Text('سوق السيارات السوداني', style: TextStyle(fontSize: 17)),
                    const SizedBox(height: 30),
                    Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
                      TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف السوداني', hintText: '+249XXXXXXXXX', prefixIcon: Icon(Icons.phone))),
                      const SizedBox(height: 12),
                      if (verificationId != null) TextField(controller: code, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'رمز التحقق SMS', prefixIcon: Icon(Icons.sms))),
                      const SizedBox(height: 16),
                      SizedBox(width: double.infinity, child: FilledButton.icon(
                        onPressed: loading ? null : (verificationId == null ? sendCode : verify),
                        icon: Icon(verificationId == null ? Icons.sms_outlined : Icons.verified_outlined),
                        label: Text(loading ? 'جارٍ التنفيذ...' : verificationId == null ? 'إرسال رمز التحقق' : 'تأكيد وتسجيل الدخول'),
                      )),
                      if (error.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center)),
                    ]))),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [const HomePage(), const ExplorePage(), const SellPage(), const FavoritesPage(), const AccountPage()];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(child: pages[tab]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'استكشاف'),
            NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'بيع'),
            NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'المفضلة'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: buko_service.buko_service.FirebaseService.instance.watchCars(),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          return ListView(padding: const EdgeInsets.all(16), children: [
            const Text('أهلاً بك في BUKO 👋', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8), const Text('ابحث عن سيارتك أو اعرض سيارتك للبيع.'), const SizedBox(height: 20),
            if (snap.hasError) const Text('تعذر تحميل السيارات. تأكد من إعداد Firestore.', style: TextStyle(color: Colors.orangeAccent)),
            if (docs.isEmpty && !snap.hasError) const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('لا توجد إعلانات منشورة بعد. كن أول من يضيف سيارة!'))),
            ...docs.map((d) => CarCard(data: d.data(), id: d.id)),
          ]);
        },
      );
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});
  @override State<ExplorePage> createState() => _ExplorePageState();
}
class _ExplorePageState extends State<ExplorePage> {
  String query = '';
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: buko_service.buko_service.FirebaseService.instance.watchCars(),
    builder: (_, snap) {
      final docs = (snap.data?.docs ?? []).where((d) {
        final q = query.toLowerCase(); final x = d.data();
        return q.isEmpty || '${x['name']} ${x['city']} ${x['type']}'.toLowerCase().contains(q);
      }).toList();
      return ListView(padding: const EdgeInsets.all(16), children: [
        const Text('استكشاف السيارات', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), const SizedBox(height: 14),
        TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(hintText: 'ابحث بالاسم أو المدينة أو النوع', prefixIcon: Icon(Icons.search))),
        const SizedBox(height: 14), ...docs.map((d) => CarCard(data: d.data(), id: d.id)),
      ]);
    });
}

class CarCard extends StatelessWidget {
  final Map<String, dynamic> data; final String id;
  const CarCard({super.key, required this.data, required this.id});
  @override
  Widget build(BuildContext context) {
    final images = List<String>.from(data['imageUrls'] ?? const []);
    return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
      leading: images.isEmpty ? const CircleAvatar(child: Icon(Icons.directions_car)) : ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(images.first, width: 62, height: 62, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.directions_car))),
      title: Text('${data['name'] ?? 'سيارة'} • ${data['year'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${data['price'] ?? ''} • ${data['city'] ?? ''}\n${data['type'] ?? ''}'), isThreeLine: true,
      trailing: IconButton(icon: const Icon(Icons.shopping_bag_outlined), onPressed: () async {
        final seller = data['sellerId']; if (seller == null) return;
        try {
          await buko_service.buko_service.FirebaseService.instance.createPurchaseRequest(carId: id, sellerId: seller);
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب الشراء ✓')));
        } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر إرسال الطلب: $e'))); }
      }),
    ));
  }
}

class SellPage extends StatefulWidget { const SellPage({super.key}); @override State<SellPage> createState() => _SellPageState(); }
class _SellPageState extends State<SellPage> {
  final name = TextEditingController(), year = TextEditingController(), price = TextEditingController(), city = TextEditingController();
  final picker = ImagePicker(); String type = 'سيدان'; bool loading = false, picking = false; final List<XFile> selectedImages = [];
  @override void dispose() { name.dispose(); year.dispose(); price.dispose(); city.dispose(); super.dispose(); }
  Future<void> pickImages() async {
    if (picking) return; setState(() => picking = true);
    try {
      final images = await picker.pickMultiImage(imageQuality: 82, maxWidth: 1600); if (!mounted) return;
      setState(() { for (final image in images) { if (selectedImages.length >= 8) break; if (!selectedImages.any((x) => x.path == image.path)) selectedImages.add(image); } });
      if (images.length > 8 && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الحد الأقصى 8 صور للإعلان')));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر اختيار الصور: $e'))); }
    finally { if (mounted) setState(() => picking = false); }
  }
  void removeImage(int index) => setState(() => selectedImages.removeAt(index));
  Future<List<String>> uploadImages() async {
    final urls = <String>[];
    for (var i = 0; i < selectedImages.length; i++) {
      final bytes = await selectedImages[i].readAsBytes();
      urls.add(await buko_service.buko_service.FirebaseService.instance.uploadCarImage(bytes, '${DateTime.now().millisecondsSinceEpoch}_$i.jpg'));
    }
    return urls;
  }
  Future<void> submit() async {
    if (name.text.trim().isEmpty || int.tryParse(year.text) == null || price.text.trim().isEmpty || city.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أكمل بيانات السيارة أولاً'))); return; }
    if (selectedImages.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أضف صورة واحدة على الأقل للسيارة'))); return; }
    setState(() => loading = true);
    try {
      final urls = await uploadImages();
      await buko_service.buko_service.FirebaseService.instance.submitCar(name: name.text, year: int.parse(year.text), price: price.text, city: city.text, type: type, imageUrls: urls);
      if (mounted) { name.clear(); year.clear(); price.clear(); city.clear(); setState(() => selectedImages.clear()); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الإعلان للمراجعة ✓'))); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر نشر الإعلان: $e'))); }
    finally { if (mounted) setState(() => loading = false); }
  }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('بيع سيارتك', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), const SizedBox(height: 16),
    TextField(controller: name, decoration: const InputDecoration(labelText: 'الماركة والموديل')), const SizedBox(height: 10),
    TextField(controller: year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سنة الصنع')), const SizedBox(height: 10),
    TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر')), const SizedBox(height: 10),
    TextField(controller: city, decoration: const InputDecoration(labelText: 'المدينة')), const SizedBox(height: 10),
    DropdownButtonFormField<String>(value: type, items: const ['سيدان', 'دفع رباعي', 'هاتشباك', 'بيك أب', 'باص'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => type = v ?? type), decoration: const InputDecoration(labelText: 'نوع السيارة')), const SizedBox(height: 16),
    OutlinedButton.icon(onPressed: picking ? null : pickImages, icon: const Icon(Icons.photo_library_outlined), label: Text(picking ? 'جارٍ اختيار الصور...' : 'اختيار صور السيارة (حتى 8)')),
    if (selectedImages.isNotEmpty) ...[const SizedBox(height: 12), SizedBox(height: 100, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: selectedImages.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(selectedImages[i].path), width: 100, height: 100, fit: BoxFit.cover)), Positioned(top: 2, right: 2, child: InkWell(onTap: () => removeImage(i), child: const CircleAvatar(radius: 12, child: Icon(Icons.close, size: 15))))]))),],
    const SizedBox(height: 18), FilledButton.icon(onPressed: loading ? null : submit, icon: const Icon(Icons.publish), label: Text(loading ? 'جارٍ رفع الإعلان...' : 'نشر الإعلان للمراجعة')),
  ]);
}

class FavoritesPage extends StatelessWidget { const FavoritesPage({super.key}); @override Widget build(BuildContext context) => const Center(child: Text('المفضلة — ستتم مزامنتها مع Firebase في الخطوة التالية')); }
class AccountPage extends StatelessWidget { const AccountPage({super.key}); @override Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.person, size: 64), const SizedBox(height: 12), const Text('حساب BUKO', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 16), FilledButton.tonalIcon(onPressed: () => buko_service.buko_service.FirebaseService.instance.signOut(), icon: const Icon(Icons.logout), label: const Text('تسجيل الخروج'))])); }
