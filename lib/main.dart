import 'package:flutter/material.dart';

const adminCode = 'BUKO-ADMIN-2026';
const green = Color(0xFF22C55E);
const blue = Color(0xFF2563EB);
const yellow = Color(0xFFFFC107);
const navy = Color(0xFF07131E);

class User {
  final String name, phone, password, role;
  User(this.name, this.phone, this.password, this.role);
}

class Car {
  final String name, price, city, type, seller;
  final int year;
  Car(this.name, this.year, this.price, this.city, this.type, {this.seller = 'BUKO'});
}

class PurchaseRequest {
  final User buyer;
  final Car car;
  PurchaseRequest(this.buyer, this.car);
}

enum BukoTheme { midnight, emerald, royal }

ThemeData bukoTheme(BukoTheme t) {
  final seed = t == BukoTheme.royal ? blue : green;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    scaffoldBackgroundColor: navy,
    cardColor: const Color(0xFF102434),
  );
}

void main() => runApp(const BukoApp());

class BukoApp extends StatefulWidget {
  const BukoApp({super.key});
  @override State<BukoApp> createState() => _BukoAppState();
}

class _BukoAppState extends State<BukoApp> {
  BukoTheme theme = BukoTheme.midnight;
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'BUKO', theme: bukoTheme(theme), home: AuthPage(onTheme: (v) => setState(() => theme = v)));
  }
}

class AuthPage extends StatefulWidget {
  final ValueChanged<BukoTheme> onTheme;
  const AuthPage({super.key, required this.onTheme});
  @override State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final users = <User>[];
  final cars = <Car>[
    Car('تويوتا كورولا', 2020, '760,000 ج.س', 'الخرطوم', 'سيدان'),
    Car('كيا سبورتاج', 2021, '1,200,000 ج.س', 'أم درمان', 'دفع رباعي'),
    Car('هيونداي النترا', 2022, '980,000 ج.س', 'بحري', 'سيدان'),
  ];
  final pending = <Car>[];
  final requests = <PurchaseRequest>[];
  User? user;
  int tab = 0;

  void login(User u) => setState(() => user = u);
  void logout() => setState(() => user = null);
  void buy(Car c) {
    requests.add(PurchaseRequest(user!, c));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب الشراء للإدارة')));
  }

  @override Widget build(BuildContext context) {
    if (user == null) {
      return AuthScreen(users: users, onLogin: login, onAdmin: () => _admin(), onTheme: widget.onTheme);
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(child: _page()),
        bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.search), label: 'استكشاف'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'بيع'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'المفضلة'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'حسابي'),
        ]),
      ),
    );
  }

  Widget _page() {
    if (tab == 1) return _explore();
    if (tab == 2) return SellPage(isSeller: user!.role == 'seller', onSubmit: (c) { pending.add(c); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الإعلان للمراجعة'))); });
    if (tab == 3) return const Center(child: Text('المفضلة\nاحفظ السيارات التي تعجبك', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)));
    if (tab == 4) return _account();
    return _home();
  }

  Widget _logo() => Row(children: [
    Container(width: 50, height: 50, decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(16)), child: const Center(child: Text('B', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900))),),
    const SizedBox(width: 10), const Text('BUKO', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 3)), const Spacer(),
    IconButton(onPressed: () => setState(() => tab = 4), icon: const Icon(Icons.menu)),
  ]);

  Widget _home() => ListView(padding: const EdgeInsets.all(16), children: [
    _logo(), const SizedBox(height: 16),
    Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF123D38), navy])), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('BUKO', style: TextStyle(color: green, fontWeight: FontWeight.bold)), SizedBox(height: 8), Text('سيارتك القادمة\nتبدأ من هنا', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900)), SizedBox(height: 8), Text('تصفح، قارن، واطلب بثقة.', style: TextStyle(color: Colors.white70))])),
    const SizedBox(height: 14), _search(), const SizedBox(height: 16),
    const Text('سيارات مميزة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 10),
    SizedBox(height: 230, child: ListView(scrollDirection: Axis.horizontal, children: cars.map(_featured).toList())),
    const SizedBox(height: 12), const Text('الأحدث', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), ...cars.map(_card),
  ]);

  Widget _search() => TextField(decoration: InputDecoration(filled: true, fillColor: Colors.white, prefixIcon: const Icon(Icons.search, color: Colors.black54), hintText: 'ابحث عن سيارة أو موديل', hintStyle: const TextStyle(color: Colors.black45), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)));
  Widget _featured(Car c) => GestureDetector(onTap: () => _details(c), child: Container(width: 210, margin: const EdgeInsets.only(left: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Container(decoration: const BoxDecoration(color: Color(0xFFE8EEF2), borderRadius: BorderRadius.vertical(top: Radius.circular(20))), child: const Center(child: Icon(Icons.directions_car, size: 80, color: navy)))), Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(c.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), Text('${c.year} • ${c.city}', style: const TextStyle(color: Colors.black54)), Text(c.price, style: const TextStyle(color: blue, fontWeight: FontWeight.w900))]))])));
  Widget _card(Car c) => Card(color: Colors.white, child: ListTile(onTap: () => _details(c), leading: const CircleAvatar(backgroundColor: Color(0xFFE8F7ED), child: Icon(Icons.directions_car, color: green)), title: Text(c.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), subtitle: Text('${c.year} • ${c.city} • ${c.price}', style: const TextStyle(color: Colors.black54)), trailing: const Icon(Icons.chevron_left, color: Colors.black54)));
  Widget _explore() => ListView(padding: const EdgeInsets.all(16), children: [const Text('استكشاف السيارات', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 14), _search(), const SizedBox(height: 12), ...cars.map(_card)]);
  Widget _account() => ListView(padding: const EdgeInsets.all(18), children: [const Text('حسابي', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 12), Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(user!.name), subtitle: Text('${user!.phone} • ${user!.role == 'seller' ? 'بائع' : 'مشتري'}'))), ListTile(leading: const Icon(Icons.palette_outlined), title: const Text('الثيمات'), onTap: _themes), ListTile(leading: const Icon(Icons.logout), title: const Text('تسجيل الخروج'), onTap: logout)]);

  void _details(Car c) => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsPage(car: c, onBuy: () => buy(c))));
  Future<void> _themes() async { final t = await showDialog<BukoTheme>(context: context, builder: (_) => SimpleDialog(title: const Text('ثيم BUKO'), children: [SimpleDialogOption(onPressed: () => Navigator.pop(context, BukoTheme.midnight), child: const Text('Midnight • داكن فاخر')), SimpleDialogOption(onPressed: () => Navigator.pop(context, BukoTheme.emerald), child: const Text('Emerald • أخضر احترافي')), SimpleDialogOption(onPressed: () => Navigator.pop(context, BukoTheme.royal), child: const Text('Royal • أزرق ملكي'))])); if (t != null) widget.onTheme(t); }
  Future<void> _admin() async { await Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPage(users: users, pending: pending, requests: requests, cars: cars, onApprove: (i) => setState(() => cars.insert(0, pending.removeAt(i))), onReject: (i) => setState(() => pending.removeAt(i)), onPost: (c) => setState(() => cars.insert(0, c)))); }
}

class AuthScreen extends StatefulWidget {
  final List<User> users; final ValueChanged<User> onLogin; final VoidCallback onAdmin; final ValueChanged<BukoTheme> onTheme;
  const AuthScreen({super.key, required this.users, required this.onLogin, required this.onAdmin, required this.onTheme});
  @override State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool login = true; String role = 'buyer'; String error = '';
  final name = TextEditingController(); final phone = TextEditingController(); final password = TextEditingController();
  @override void dispose() { name.dispose(); phone.dispose(); password.dispose(); super.dispose(); }
  String normalize(String x) { var p = x.trim().replaceAll(' ', ''); if (p.startsWith('00249')) p = '+${p.substring(2)}'; if (p.startsWith('249')) p = '+$p'; return p; }
  bool valid(String p) => RegExp(r'^\+249\d{9}$').hasMatch(p);
  void submit() {
    if (phone.text.trim() == adminCode) { widget.onAdmin(); return; }
    final p = normalize(phone.text);
    if (!valid(p)) { setState(() => error = 'استخدم رقم سوداني فقط: +249XXXXXXXXX'); return; }
    if (password.text.length < 6) { setState(() => error = 'كلمة المرور 6 أحرف على الأقل'); return; }
    if (login) {
      User? found;
      for (final u in widget.users) { if (u.phone == p && u.password == password.text && u.role == role) { found = u; break; } }
      if (found == null) { setState(() => error = 'بيانات الدخول غير صحيحة'); return; }
      widget.onLogin(found!);
    } else {
      if (name.text.trim().isEmpty) { setState(() => error = 'اكتب الاسم'); return; }
      if (widget.users.any((u) => u.phone == p)) { setState(() => error = 'رقم الهاتف مسجل مسبقًا'); return; }
      final u = User(name.text.trim(), p, password.text, role); widget.users.add(u); widget.onLogin(u);
    }
  }
  @override Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(body: Stack(children: [Positioned(top: -100, left: -80, child: _orb(green, 240)), Positioned(bottom: -120, right: -80, child: _orb(blue, 280)), SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(22), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: Column(children: [Container(width: 88, height: 88, decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(28)), child: const Center(child: Text('B', style: TextStyle(fontSize: 58, fontWeight: FontWeight.w900)))), const SizedBox(height: 14), const Text('BUKO', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 5)), const Text('حبابك عشرة', style: TextStyle(color: green, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 28), Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [_tabs(), const SizedBox(height: 20), if (!login) TextField(controller: name, decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline))), if (!login) const SizedBox(height: 12), TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف السوداني', hintText: '+249XXXXXXXXX', prefixIcon: Icon(Icons.phone_iphone))), const SizedBox(height: 12), TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock_outline))), const SizedBox(height: 8), Row(children: [Expanded(child: RadioListTile<String>(value: 'buyer', groupValue: role, onChanged: (v) => setState(() => role = v!), title: const Text('مشتري'), dense: true)), Expanded(child: RadioListTile<String>(value: 'seller', groupValue: role, onChanged: (v) => setState(() => role = v!), title: const Text('بائع'), dense: true))]), if (error.isNotEmpty) Text(error, style: const TextStyle(color: Colors.redAccent)), const SizedBox(height: 8), SizedBox(width: double.infinity, child: FilledButton(onPressed: submit, child: Text(login ? 'دخول إلى BUKO' : 'إنشاء الحساب'))), if (login) TextButton(onPressed: () => setState(() { login = false; error = ''; }), child: const Text('ليس لديك حساب؟ أنشئ حسابًا'))]))), const SizedBox(height: 14), const Text('الإدارة تدخل من نفس خانة رقم الهاتف باستخدام رمز الإدارة', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12))]))))])));
  Widget _tabs() => Row(children: [Expanded(child: _tab('دخول', login)), Expanded(child: _tab('حساب جديد', !login))]);
  Widget _tab(String s, bool active) => InkWell(onTap: () => setState(() { login = s == 'دخول'; error = ''; }), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: active ? green : Colors.transparent, borderRadius: BorderRadius.circular(14)), child: Center(child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)))));
  Widget _orb(Color c, double s) => Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, color: c.withAlpha(25), boxShadow: [BoxShadow(color: c.withAlpha(35), blurRadius: 100, spreadRadius: 20)]));
}

class DetailsPage extends StatelessWidget {
  final Car car; final VoidCallback onBuy;
  const DetailsPage({super.key, required this.car, required this.onBuy});
  @override Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(appBar: AppBar(title: const Text('تفاصيل السيارة')), body: ListView(padding: const EdgeInsets.all(18), children: [Container(height: 220, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF193D4F), navy])), child: const Icon(Icons.directions_car, size: 120, color: green)), const SizedBox(height: 18), Text(car.name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), Text(car.price, style: const TextStyle(fontSize: 25, color: green, fontWeight: FontWeight.w900)), Card(color: Colors.white, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [_row('السنة', '${car.year}'), _row('المدينة', car.city), _row('النوع', car.type), _row('البائع', car.seller)]))), const SizedBox(height: 16), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onBuy, icon: const Icon(Icons.shopping_cart_checkout), label: const Text('طلب شراء السيارة')))]));
  Widget _row(String a, String b) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Expanded(child: Text(a, style: const TextStyle(color: Colors.black54))), Text(b, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))]));
}

class SellPage extends StatefulWidget {
  final bool isSeller; final ValueChanged<Car> onSubmit;
  const SellPage({super.key, required this.isSeller, required this.onSubmit});
  @override State<SellPage> createState() => _SellPageState();
}
class _SellPageState extends State<SellPage> {
  final name = TextEditingController(); final year = TextEditingController(); final price = TextEditingController(); String city = 'الخرطوم'; String type = 'سيدان';
  @override void dispose() { name.dispose(); year.dispose(); price.dispose(); super.dispose(); }
  void submit() { final y = int.tryParse(year.text); if (name.text.trim().isEmpty || price.text.trim().isEmpty || y == null) return; widget.onSubmit(Car(name.text.trim(), y, price.text.trim(), city, type, seller: 'بائع')); name.clear(); year.clear(); price.clear(); }
  @override Widget build(BuildContext context) { if (!widget.isSeller) return const Center(child: Text('حساب بائع مطلوب لإضافة إعلان', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))); return ListView(padding: const EdgeInsets.all(18), children: [const Text('إضافة إعلان', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 8), const Text('الإعلان يذهب للإدارة للمراجعة قبل النشر.', style: TextStyle(color: Colors.white70)), const SizedBox(height: 18), TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم السيارة')), TextField(controller: year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السنة')), TextField(controller: price, decoration: const InputDecoration(labelText: 'السعر')), DropdownButtonFormField<String>(initialValue: type, decoration: const InputDecoration(labelText: 'النوع'), items: const ['سيدان', 'دفع رباعي', 'بيك أب'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => type = v!)), DropdownButtonFormField<String>(initialValue: city, decoration: const InputDecoration(labelText: 'المدينة'), items: const ['الخرطوم', 'أم درمان', 'بحري', 'بورتسودان'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => city = v!)), const SizedBox(height: 18), FilledButton.icon(onPressed: submit, icon: const Icon(Icons.send), label: const Text('إرسال للمراجعة'))]); }
}

class AdminPage extends StatefulWidget {
  final List<User> users; final List<Car> pending; final List<PurchaseRequest> requests; final List<Car> cars; final ValueChanged<int> onApprove; final ValueChanged<int> onReject; final ValueChanged<Car> onPost;
  const AdminPage({super.key, required this.users, required this.pending, required this.requests, required this.cars, required this.onApprove, required this.onReject, required this.onPost});
  @override State<AdminPage> createState() => _AdminPageState();
}
class _AdminPageState extends State<AdminPage> {
  Future<void> post() async { final c = await showDialog<Car>(context: context, builder: (_) => const AdminPostDialog()); if (c != null) { widget.onPost(c); setState(() {}); } }
  @override Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(appBar: AppBar(title: const Text('لوحة تحكم BUKO')), body: ListView(padding: const EdgeInsets.all(16), children: [Card(child: ListTile(title: const Text('نظرة عامة'), subtitle: Text('${widget.users.length} مستخدم • ${widget.cars.length} سيارة • ${widget.pending.length} إعلان معلق • ${widget.requests.length} طلب شراء'))), FilledButton.icon(onPressed: post, icon: const Icon(Icons.add), label: const Text('إضافة منشور مباشر')), const SizedBox(height: 20), const Text('المستخدمون', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), ...widget.users.map((u) => Card(color: Colors.white, child: ListTile(title: Text(u.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), subtitle: Text('${u.phone} • ${u.role == 'seller' ? 'بائع' : 'مشتري'}', style: const TextStyle(color: Colors.black54)))), const SizedBox(height: 20), const Text('إعلانات بانتظار الموافقة', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), if (widget.pending.isEmpty) const Text('لا توجد إعلانات معلقة', style: TextStyle(color: Colors.white70)), ...List.generate(widget.pending.length, (i) { final c = widget.pending[i]; return Card(color: Colors.white, child: ListTile(title: Text(c.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), subtitle: Text('${c.year} • ${c.city} • ${c.price}', style: const TextStyle(color: Colors.black54)), trailing: Wrap(children: [IconButton(onPressed: () { widget.onApprove(i); setState(() {}); }, icon: const Icon(Icons.check, color: green)), IconButton(onPressed: () { widget.onReject(i); setState(() {}); }, icon: const Icon(Icons.close, color: Colors.red))])); }), const SizedBox(height: 20), const Text('طلبات الشراء', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), if (widget.requests.isEmpty) const Text('لا توجد طلبات شراء بعد', style: TextStyle(color: Colors.white70)), ...widget.requests.map((r) => Card(child: ListTile(leading: const Icon(Icons.shopping_cart, color: yellow), title: Text(r.car.name), subtitle: Text('${r.buyer.name} • ${r.buyer.phone}'))))]));
}

class AdminPostDialog extends StatefulWidget { const AdminPostDialog({super.key}); @override State<AdminPostDialog> createState() => _AdminPostDialogState(); }
class _AdminPostDialogState extends State<AdminPostDialog> {
  final n = TextEditingController(); final y = TextEditingController(text: '2024'); final p = TextEditingController(); String t = 'سيدان'; String c = 'الخرطوم';
  @override void dispose() { n.dispose(); y.dispose(); p.dispose(); super.dispose(); }
  void submit() { final year = int.tryParse(y.text); if (n.text.trim().isEmpty || p.text.trim().isEmpty || year == null) return; Navigator.pop(context, Car(n.text.trim(), year, p.text.trim(), c, t, seller: 'الإدارة')); }
  @override Widget build(BuildContext context) => AlertDialog(title: const Text('منشور مباشر من الأدمن'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: n, decoration: const InputDecoration(labelText: 'اسم السيارة')), TextField(controller: y, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السنة')), TextField(controller: p, decoration: const InputDecoration(labelText: 'السعر')), DropdownButtonFormField<String>(initialValue: t, items: const ['سيدان', 'دفع رباعي', 'بيك أب'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => t = v!)), DropdownButtonFormField<String>(initialValue: c, items: const ['الخرطوم', 'أم درمان', 'بحري', 'بورتسودان'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => c = v!))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), FilledButton(onPressed: submit, child: const Text('نشر الآن'))]);
}
