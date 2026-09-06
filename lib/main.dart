import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'admin_login_page.dart';
import 'firebase_options.dart';
import 'phone_password_auth_page.dart';
import 'services/firebase_service.dart' as buko_service;

const gold = Color(0xFFFFB51B);
const ink = Color(0xFF080B10);
const panel = Color(0xFF11161E);
const muted = Color(0xFF9BA6B5);

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
          scaffoldBackgroundColor: ink,
          colorScheme: ColorScheme.fromSeed(seedColor: gold, brightness: Brightness.dark),
          cardTheme: const CardThemeData(color: panel, elevation: 0),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: panel,
            prefixIconColor: gold,
            hintStyle: const TextStyle(color: muted),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: gold)),
          ),
        ),
        home: const AuthGate(),
      );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<auth.User?>(
        stream: buko_service.FirebaseService.instance.authState,
        builder: (context, snapshot) => snapshot.data == null ? const PhonePasswordAuthPage() : const HomeShell(),
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
    const pages = <Widget>[HomePage(), ExplorePage(), SellPage(), FavoritesPage(), AccountPage()];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(child: AnimatedSwitcher(duration: const Duration(milliseconds: 280), child: KeyedSubtree(key: ValueKey(tab), child: pages[tab]))),
        bottomNavigationBar: NavigationBar(
          backgroundColor: const Color(0xFF0C1016),
          indicatorColor: gold.withOpacity(.16),
          selectedIndex: tab,
          onDestinationSelected: (index) => setState(() => tab = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: gold), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.search), selectedIcon: Icon(Icons.search, color: gold), label: 'استكشاف'),
            NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle, color: gold), label: 'بيع'),
            NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite, color: gold), label: 'المفضلة'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: gold), label: 'حسابي'),
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
        stream: buko_service.FirebaseService.instance.watchCars(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? const [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              const _TopBar(),
              const SizedBox(height: 14),
              const AnimatedMarketHero(),
              const SizedBox(height: 20),
              const Text('ماذا تبحث اليوم؟', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              _SearchBox(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExplorePage()))),
              const SizedBox(height: 20),
              _SectionTitle('تصفح حسب النوع', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExplorePage()))),
              const SizedBox(height: 10),
              SizedBox(height: 94, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                _Cat(Icons.directions_car_filled, 'سيدان'),
                _Cat(Icons.directions_car, 'دفع رباعي'),
                _Cat(Icons.local_shipping, 'بيك أب'),
                _Cat(Icons.directions_bus, 'باص'),
              ]))),
              const SizedBox(height: 20),
              _SectionTitle('أحدث السيارات', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExplorePage()))),
              const SizedBox(height: 10),
              if (snapshot.hasError) const _Info('تعذر تحميل السيارات حالياً.'),
              if (docs.isEmpty && !snapshot.hasError) const _Info('لا توجد إعلانات منشورة بعد. كن أول من يضيف سيارة!'),
              ...docs.map((doc) => CarCard(data: doc.data(), id: doc.id)),
            ],
          );
        },
      );
}

class _TopBar extends StatefulWidget {
  const _TopBar();
  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  int taps = 0;
  DateTime? lastTap;
  void hiddenAdminEntry() {
    final now = DateTime.now();
    if (lastTap == null || now.difference(lastTap!) > const Duration(seconds: 3)) taps = 0;
    lastTap = now;
    taps++;
    if (taps >= 7) {
      taps = 0;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminLoginPage()));
    }
  }
  @override
  Widget build(BuildContext context) => Row(children: [
        GestureDetector(onTap: hiddenAdminEntry, child: Container(width: 50, height: 50, decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.key, color: Colors.black, size: 28))),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('BUKO', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
          Text('سيارات مستعملة بثقة وسهولة', style: TextStyle(fontSize: 12, color: muted)),
        ])),
        IconButton(
          tooltip: 'الإشعارات',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا توجد إشعارات جديدة'))),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ]);
}

class _SearchBox extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBox({required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(height: 58, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)), child: const Row(children: [Icon(Icons.search, color: gold), SizedBox(width: 12), Expanded(child: Text('ابحث عن ماركة، موديل أو مدينة', style: TextStyle(color: muted))), Icon(Icons.tune_rounded, color: Colors.white70)])),
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const _SectionTitle(this.title, {this.onTap});
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
        if (onTap != null)
          TextButton(onPressed: onTap, child: const Text('عرض الكل', style: TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.w700))),
      ]);
}

class _Cat extends StatelessWidget {
  final IconData icon;
  final String title;
  const _Cat(this.icon, this.title);
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExplorePage(initialQuery: title))),
          borderRadius: BorderRadius.circular(18),
          child: Container(width: 108, margin: const EdgeInsets.only(left: 10), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: gold, size: 28), const SizedBox(height: 7), Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))])),
        ),
      );
}

class _Info extends StatelessWidget {
  final String text;
  const _Info(this.text);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(20)), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: muted)));
}

class AnimatedMarketHero extends StatefulWidget {
  const AnimatedMarketHero({super.key});
  @override
  State<AnimatedMarketHero> createState() => _AnimatedMarketHeroState();
}

class _AnimatedMarketHeroState extends State<AnimatedMarketHero> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat();
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(28), child: SizedBox(height: 285, child: Stack(fit: StackFit.expand, children: [
        AnimatedBuilder(animation: controller, builder: (_, __) => CustomPaint(painter: _ScenePainter(controller.value))),
        const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xD9000000)]))),
        const Positioned(top: 18, right: 18, child: _Pill()),
        const Positioned(right: 18, left: 18, bottom: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('عربيتك الجاية\nيمكن تكون هنا', style: TextStyle(fontSize: 28, height: 1.02, fontWeight: FontWeight.w900)),
          SizedBox(height: 6),
          Text('ابحث • قارن • تواصل مباشرة مع المالك', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ])),
      ])));
}

class _Pill extends StatelessWidget {
  const _Pill();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white24)), child: const Text('من السودان للسودان 🇸🇩', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)));
}

class _ScenePainter extends CustomPainter {
  final double t;
  _ScenePainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final bg = Paint()..shader = const LinearGradient(colors: [Color(0xFF203447), Color(0xFFB96D39), Color(0xFF10151A)]).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);
    canvas.drawCircle(Offset(w * .78, h * .23), 34, Paint()..color = gold.withOpacity(.55));
    final city = Paint()..color = const Color(0xFF0C1218).withOpacity(.72);
    for (var i = 0; i < 10; i++) { final bh = 34.0 + (i % 4) * 15.0; canvas.drawRect(Rect.fromLTWH(i * w / 9 - 5, h * .55 - bh, 18 + (i % 3) * 9.0, bh), city); }
    final road = Paint()..color = const Color(0xFF080B0E);
    final roadPath = Path()..moveTo(0, h * .61)..lineTo(w, h * .56)..lineTo(w, h)..lineTo(0, h)..close();
    canvas.drawPath(roadPath, road);
    final lane = Paint()..color = Colors.white12..strokeWidth = 3;
    for (var i = -1; i < 7; i++) { final x = (i * 85 + t * 170) % (w + 100) - 50; canvas.drawLine(Offset(x, h * .88), Offset(x + 34, h * .76), lane); }
    _drawCar(canvas, Offset(w * .18 + math.sin(t * math.pi * 2) * 8, h * .69), .9, false);
    _drawCar(canvas, Offset(w * .58 + math.sin(t * math.pi * 2 + 2) * 10, h * .63), .75, false);
    _drawCar(canvas, Offset(w * .82 + math.sin(t * math.pi * 2 + 4) * 12, h * .77), .6, false);
    _drawCar(canvas, Offset(w * .36, h * .83), 1.28, true);
  }
  void _drawCar(Canvas canvas, Offset p, double z, bool hero) {
    final body = Paint()..color = hero ? const Color(0xFFE7E9ED) : const Color(0xFF27313B);
    final glass = Paint()..color = const Color(0xFF17212B);
    final wheel = Paint()..color = Colors.black;
    final trim = Paint()..color = hero ? gold : Colors.white24;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(p.dx - 62 * z, p.dy - 22 * z, 124 * z, 38 * z), Radius.circular(13 * z)), body);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(p.dx - 35 * z, p.dy - 38 * z, 65 * z, 28 * z), Radius.circular(12 * z)), glass);
    canvas.drawCircle(Offset(p.dx - 40 * z, p.dy + 17 * z), 12 * z, wheel);
    canvas.drawCircle(Offset(p.dx + 40 * z, p.dy + 17 * z), 12 * z, wheel);
    canvas.drawLine(Offset(p.dx - 48 * z, p.dy - 2 * z), Offset(p.dx + 48 * z, p.dy - 2 * z), trim..strokeWidth = 3 * z);
    if (hero) {
      final skin = Paint()..color = const Color(0xFF70462F);
      final cloth = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(p.dx + 2 * z, p.dy - 47 * z), 14 * z, skin);
      canvas.drawOval(Rect.fromCenter(center: Offset(p.dx + 2 * z, p.dy - 58 * z), width: 34 * z, height: 18 * z), cloth);
      canvas.drawOval(Rect.fromCenter(center: Offset(p.dx - 4 * z, p.dy - 62 * z), width: 27 * z, height: 11 * z), cloth);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(p.dx - 18 * z, p.dy - 35 * z, 34 * z, 36 * z), Radius.circular(12 * z)), cloth);
      canvas.drawLine(Offset(p.dx + 16 * z, p.dy - 20 * z), Offset(p.dx + 38 * z, p.dy - 42 * z), skin..strokeWidth = 8 * z);
      canvas.drawCircle(Offset(p.dx + 39 * z, p.dy - 43 * z), 6 * z, skin);
    }
  }
  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) => oldDelegate.t != t;
}

class ExplorePage extends StatefulWidget {
  final String initialQuery;
  const ExplorePage({super.key, this.initialQuery = ''});
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late String query = widget.initialQuery;
  late final TextEditingController controller = TextEditingController(text: widget.initialQuery);
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: buko_service.FirebaseService.instance.watchCars(),
        builder: (context, snapshot) {
          final docs = (snapshot.data?.docs ?? const []).where((doc) {
            final data = doc.data();
            final text = '${data['name'] ?? ''} ${data['city'] ?? ''} ${data['type'] ?? ''}'.toLowerCase();
            return query.trim().isEmpty || text.contains(query.trim().toLowerCase());
          }).toList();
          return ListView(padding: const EdgeInsets.all(16), children: [
            const Text('استكشاف السيارات', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('اختار عربيتك من الإعلانات الموثوقة', style: TextStyle(color: muted)),
            const SizedBox(height: 16),
            TextField(controller: controller, onChanged: (value) => setState(() => query = value), decoration: const InputDecoration(hintText: 'الماركة أو المدينة أو النوع', prefixIcon: Icon(Icons.search))),
            const SizedBox(height: 16),
            if (snapshot.hasError) const _Info('تعذر تحميل السيارات حالياً.'),
            if (docs.isEmpty && !snapshot.hasError) const _Info('لا توجد سيارات مطابقة للبحث.'),
            ...docs.map((doc) => CarCard(data: doc.data(), id: doc.id)),
          ]);
        },
      );
}

class FavoriteStore {
  static final ValueNotifier<Map<String, Map<String, dynamic>>> items = ValueNotifier({});

  static bool contains(String id) => items.value.containsKey(id);

  static void toggle(String id, Map<String, dynamic> data) {
    final next = Map<String, Map<String, dynamic>>.from(items.value);
    if (next.containsKey(id)) {
      next.remove(id);
    } else {
      next[id] = Map<String, dynamic>.from(data);
    }
    items.value = next;
  }
}

class CarCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String id;
  const CarCard({super.key, required this.data, required this.id});
  @override
  Widget build(BuildContext context) {
    final rawImages = data['imageUrls'];
    final images = rawImages is List ? rawImages.whereType<String>().toList() : <String>[];
    final seller = data['sellerId'];
    final isOwnCar = seller != null && seller.toString() == buko_service.FirebaseService.instance.currentUser?.uid;
    return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)), child: ListTile(
      contentPadding: const EdgeInsets.all(9),
      leading: ClipRRect(borderRadius: BorderRadius.circular(14), child: images.isEmpty ? Container(width: 76, height: 76, color: const Color(0xFF1B222C), child: const Icon(Icons.directions_car, color: gold, size: 30)) : Image.network(images.first, width: 76, height: 76, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 76, height: 76, color: const Color(0xFF1B222C), child: const Icon(Icons.directions_car, color: gold)))),
      title: Text('${data['name'] ?? 'سيارة'} • ${data['year'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text('${data['price'] ?? ''} • ${data['city'] ?? ''}\n${data['type'] ?? ''}', style: const TextStyle(color: muted, height: 1.45))),
      trailing: SizedBox(
        width: 96,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          ValueListenableBuilder<Map<String, Map<String, dynamic>>>(
            valueListenable: FavoriteStore.items,
            builder: (_, __, ___) => IconButton(
              tooltip: FavoriteStore.contains(id) ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
              style: IconButton.styleFrom(backgroundColor: gold.withOpacity(.12)),
              icon: Icon(FavoriteStore.contains(id) ? Icons.favorite : Icons.favorite_border, color: gold),
              onPressed: () => FavoriteStore.toggle(id, data),
            ),
          ),
          IconButton(
            tooltip: isOwnCar ? 'لا يمكنك طلب شراء سيارتك' : 'طلب شراء',
            style: IconButton.styleFrom(backgroundColor: gold.withOpacity(.12)),
            icon: const Icon(Icons.shopping_bag_outlined, color: gold),
            onPressed: seller == null || isOwnCar ? null : () async {
              try {
                await buko_service.FirebaseService.instance.createPurchaseRequest(carId: id, sellerId: seller.toString());
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب الشراء ✓')));
              } catch (error) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر إرسال الطلب: $error')));
              }
            },
          ),
        ]),
      ),
    ));
  }
}

class SellPage extends StatefulWidget {
  const SellPage({super.key});
  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final name = TextEditingController();
  final year = TextEditingController();
  final price = TextEditingController();
  final city = TextEditingController();
  final picker = ImagePicker();
  final images = <XFile>[];
  String type = 'سيدان';
  bool loading = false;
  @override
  void dispose() { name.dispose(); year.dispose(); price.dispose(); city.dispose(); super.dispose(); }
  Future<void> pickImages() async {
    try {
      final selected = await picker.pickMultiImage(imageQuality: 82, maxWidth: 1600);
      if (!mounted) return;
      setState(() { for (final file in selected) { if (images.length >= 8) break; if (!images.any((item) => item.path == file.path)) images.add(file); } });
    } catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر اختيار الصور: $error'))); }
  }
  Future<void> submit() async {
    final parsedYear = int.tryParse(year.text.trim());
    if (name.text.trim().isEmpty || parsedYear == null || price.text.trim().isEmpty || city.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أكمل بيانات السيارة أولاً'))); return; }
    setState(() => loading = true);
    try {
      final urls = <String>[];
      for (final image in images) urls.add(await buko_service.FirebaseService.instance.uploadCarImage(await image.readAsBytes(), image.name));
      await buko_service.FirebaseService.instance.submitCar(name: name.text, year: parsedYear, price: price.text, city: city.text, type: type, imageUrls: urls);
      if (!mounted) return;
      name.clear(); year.clear(); price.clear(); city.clear(); setState(() => images.clear());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الإعلان للمراجعة ✓')));
    } catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر نشر الإعلان: $error'))); }
    finally { if (mounted) setState(() => loading = false); }
  }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
        const Text('بيع سيارتك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('أضف بيانات سيارتك وسيتم مراجعتها قبل النشر.', style: TextStyle(color: muted)),
        const SizedBox(height: 18),
        TextField(controller: name, decoration: const InputDecoration(labelText: 'الماركة والموديل', prefixIcon: Icon(Icons.directions_car))),
        const SizedBox(height: 10),
        TextField(controller: year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سنة الصنع', prefixIcon: Icon(Icons.calendar_month))),
        const SizedBox(height: 10),
        TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر', prefixIcon: Icon(Icons.payments_outlined))),
        const SizedBox(height: 10),
        TextField(controller: city, decoration: const InputDecoration(labelText: 'المدينة', prefixIcon: Icon(Icons.location_on_outlined))),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'نوع السيارة'), items: const ['سيدان', 'دفع رباعي', 'هاتشباك', 'بيك أب', 'باص'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => setState(() => type = value ?? type)),
        const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: loading ? null : pickImages, icon: const Icon(Icons.photo_library_outlined), label: Text(images.isEmpty ? 'أضف صور السيارة' : 'الصور: ${images.length}/8')),
        const SizedBox(height: 18),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: loading ? null : submit, icon: const Icon(Icons.publish), label: Text(loading ? 'جارٍ النشر...' : 'إرسال للمراجعة'))),
      ]);
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Map<String, Map<String, dynamic>>>(
        valueListenable: FavoriteStore.items,
        builder: (_, items, __) {
          if (items.isEmpty) {
            return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.favorite_border, size: 70, color: gold), SizedBox(height: 12), Text('المفضلة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), SizedBox(height: 6), Text('اضغط ❤️ على أي سيارة لحفظها هنا', style: TextStyle(color: muted))]));
          }
          return ListView(padding: const EdgeInsets.fromLTRB(16, 18, 16, 28), children: [
            const Text('المفضلة', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            ...items.entries.map((entry) => CarCard(data: entry.value, id: entry.key)),
          ];
        },
      );
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.person, size: 70, color: gold),
        const SizedBox(height: 12),
        const Text('حساب BUKO', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 18),
        FilledButton.tonalIcon(onPressed: () => buko_service.FirebaseService.instance.signOut(), icon: const Icon(Icons.logout), label: const Text('تسجيل الخروج')),
      ]));
}
