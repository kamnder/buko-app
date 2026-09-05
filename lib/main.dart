import 'package:flutter/material.dart';

const adminCode = 'BUKO-ADMIN-2026';
const green = Color(0xFF22C55E);
const blue = Color(0xFF2563EB);
const yellow = Color(0xFFFFC107);
const navy = Color(0xFF07131E);

class User {
  final String name;
  final String phone;
  final String password;
  final String role;
  User(this.name, this.phone, this.password, this.role);
}

class Car {
  final String name;
  final int year;
  final String price;
  final String city;
  final String type;
  final String seller;
  Car(this.name, this.year, this.price, this.city, this.type, {this.seller = 'BUKO'});
}

class PurchaseRequest {
  final User buyer;
  final Car car;
  PurchaseRequest(this.buyer, this.car);
}

enum BukoTheme { midnight, emerald, royal }

ThemeData makeTheme(BukoTheme theme) {
  final seed = theme == BukoTheme.royal ? blue : green;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    scaffoldBackgroundColor: navy,
    cardTheme: const CardThemeData(color: Color(0xFF102434)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.black54),
      hintStyle: const TextStyle(color: Colors.black45),
      prefixIconColor: Colors.black54,
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide.none),
    ),
  );
}

void main() => runApp(const BukoApp());

class BukoApp extends StatefulWidget {
  const BukoApp({super.key});
  @override State<BukoApp> createState() => _BukoAppState();
}

class _BukoAppState extends State<BukoApp> {
  BukoTheme theme = BukoTheme.midnight;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BUKO',
      theme: makeTheme(theme),
      home: AuthScreen(onTheme: (value) => setState(() => theme = value)),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final ValueChanged<BukoTheme> onTheme;
  const AuthScreen({super.key, required this.onTheme});
  @override State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final users = <User>[];
  final cars = <Car>[
    Car('تويوتا كورولا', 2020, '760,000 ج.س', 'الخرطوم', 'سيدان'),
    Car('كيا سبورتاج', 2021, '1,200,000 ج.س', 'أم درمان', 'دفع رباعي'),
    Car('هيونداي النترا', 2022, '980,000 ج.س', 'بحري', 'سيدان'),
  ];
  final pending = <Car>[];
  final requests = <PurchaseRequest>[];
  User? currentUser;
  int tab = 0;

  void login(User user) => setState(() => currentUser = user);
  void logout() => setState(() { currentUser = null; tab = 0; });

  void buy(Car car) {
    if (currentUser == null) return;
    requests.add(PurchaseRequest(currentUser!, car));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب الشراء للإدارة')));
  }

  void openAdmin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPage(
      users: users,
      pending: pending,
      requests: requests,
      cars: cars,
      onApprove: (index) => setState(() => cars.insert(0, pending.removeAt(index))),
      onReject: (index) => setState(() => pending.removeAt(index)),
      onPost: (car) => setState(() => cars.insert(0, car)),
    )));
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return AuthForm(users: users, onLogin: login, onAdmin: openAdmin);
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(child: _page()),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (index) => setState(() => tab = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.search), label: 'استكشاف'),
            NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'بيع'),
            NavigationDestination(icon: Icon(Icons.favorite_border), label: 'المفضلة'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'حسابي'),
          ],
        ),
      ),
    );
  }

  Widget _page() {
    if (tab == 1) return _explore();
    if (tab == 2) return SellPage(isSeller: currentUser!.role == 'seller', onSubmit: (car) {
      pending.add(car);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الإعلان للمراجعة')));
    });
    if (tab == 3) return const Center(child: Text('المفضلة\nاحفظ السيارات التي تعجبك', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)));
    if (tab == 4) return _account();
    return _home();
  }

  Widget logo() => Row(children: [
    Container(width: 52, height: 52, decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(17)), child: const Center(child: Text('B', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900))),),
    const SizedBox(width: 10),
    const Text('BUKO', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 3)),
  ]);

  Widget _home() => ListView(padding: const EdgeInsets.all(16), children: [
    logo(), const SizedBox(height: 18),
    Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF123D38), navy])), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('BUKO', style: TextStyle(color: green, fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      Text('اعثر على سيارتك\nالقادمة من هنا', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
      SizedBox(height: 8), Text('تصفح، قارن، واطلب بثقة.', style: TextStyle(color: Colors.white70)),
    ])),
    const SizedBox(height: 14), _search(),
    const SizedBox(height: 20), const Text('سيارات مميزة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
    const SizedBox(height: 10), SizedBox(height: 225, child: ListView(scrollDirection: Axis.horizontal, children: cars.map(_featured).toList())),
    const SizedBox(height: 18), const Text('الأحدث', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
    ...cars.map(_card),
  ]);

  Widget _search() => TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'ابحث عن سيارة أو موديل'));

  Widget _featured(Car car) => GestureDetector(
    onTap: () => _details(car),
    child: Container(width: 210, margin: const EdgeInsets.only(left: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Container(decoration: const BoxDecoration(color: Color(0xFFE8EEF2), borderRadius: BorderRadius.vertical(top: Radius.circular(20))), child: const Center(child: Icon(Icons.directions_car, size: 80, color: navy)))),
      Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(car.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        Text('${car.year} • ${car.city}', style: const TextStyle(color: Colors.black54)),
        Text(car.price, style: const TextStyle(color: blue, fontWeight: FontWeight.w900)),
      ])),
    ])),
  );

  Widget _card(Car car) => Card(color: Colors.white, child: ListTile(
    onTap: () => _details(car),
    leading: const CircleAvatar(backgroundColor: Color(0xFFE8F7ED), child: Icon(Icons.directions_car, color: green)),
    title: Text(car.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
    subtitle: Text('${car.year} • ${car.city} • ${car.price}', style: const TextStyle(color: Colors.black54)),
    trailing: const Icon(Icons.chevron_left, color: Colors.black54),
  ));

  Widget _explore() => ListView(padding: const EdgeInsets.all(16), children: [const Text('استكشاف السيارات', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 14), _search(), const SizedBox(height: 12), ...cars.map(_card)]);

  Widget _account() => ListView(padding: const EdgeInsets.all(18), children: [
    const Text('حسابي', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
    const SizedBox(height: 12),
    Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(currentUser!.name), subtitle: Text('${currentUser!.phone} • ${currentUser!.role == 'seller' ? 'بائع' : 'مشتري'}'))),
    ListTile(leading: const Icon(Icons.palette_outlined), title: const Text('الثيمات'), onTap: _themes),
    ListTile(leading: const Icon(Icons.logout), title: const Text('تسجيل الخروج'), onTap: logout),
  ]);

  Future<void> _themes() async {
    final selected = await showDialog<BukoTheme>(context: context, builder: (_) => SimpleDialog(title: const Text('ثيم BUKO'), children: [
      SimpleDialogOption(onPressed: () => Navigator.pop(context, BukoTheme.midnight), child: const Text('Midnight • داكن فاخر')),
      SimpleDialogOption(onPressed: () => Navigator.pop(context, BukoTheme.emerald), child: const Text('Emerald • أخضر احترافي')),
      SimpleDialogOption(onPressed: () => Navigator.pop(context, BukoTheme.royal), child: const Text('Royal • أزرق ملكي')),
    ]));
    if (selected != null) widget.onTheme(selected);
  }

  void _details(Car car) => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsPage(car: car, onBuy: () => buy(car))));
}

class AuthForm extends StatefulWidget {
  final List<User> users;
  final ValueChanged<User> onLogin;
  final VoidCallback onAdmin;
  const AuthForm({super.key, required this.users, required this.onLogin, required this.onAdmin});
  @override State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool loginMode = true;
  String role = 'buyer';
  String error = '';
  final name = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();

  @override void dispose() { name.dispose(); phone.dispose(); password.dispose(); super.dispose(); }

  String normalize(String value) {
    var p = value.trim().replaceAll(' ', '');
    if (p.startsWith('00249')) p = '+${p.substring(2)}';
    if (p.startsWith('249')) p = '+$p';
    return p;
  }

  bool validSudanPhone(String value) => RegExp(r'^\+249\d{9}$').hasMatch(value);

  void submit() {
    if (phone.text.trim() == adminCode) { widget.onAdmin(); return; }
    final p = normalize(phone.text);
    if (!validSudanPhone(p)) { setState(() => error = 'استخدم رقم السودان فقط: +249XXXXXXXXX'); return; }
    if (password.text.length < 6) { setState(() => error = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'); return; }
    if (loginMode) {
      User? found;
      for (final user in widget.users) {
        if (user.phone == p && user.password == password.text && user.role == role) { found = user; break; }
      }
      if (found == null) { setState(() => error = 'بيانات الدخول غير صحيحة'); return; }
      widget.onLogin(found);
      return;
    }
    if (name.text.trim().isEmpty) { setState(() => error = 'اكتب الاسم الكامل'); return; }
    if (widget.users.any((user) => user.phone == p)) { setState(() => error = 'رقم الهاتف مسجل مسبقًا'); return; }
    final user = User(name.text.trim(), p, password.text, role);
    widget.users.add(user);
    widget.onLogin(user);
  }

  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(body: Stack(children: [
    Positioned(top: -100, left: -80, child: _orb(green, 240)),
    Positioned(bottom: -120, right: -80, child: _orb(blue, 280)),
    SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(22), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: Column(children: [
      Container(width: 92, height: 92, decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(28)), child: const Center(child: Text('B', style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900)))),
      const SizedBox(height: 14), const Text('BUKO', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 5)),
      const Text('حبابك عشرة', style: TextStyle(color: green, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 28),
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        Row(children: [Expanded(child: _tab('دخول', loginMode)), Expanded(child: _tab('حساب جديد', !loginMode))]),
        const SizedBox(height: 20),
        if (!loginMode) TextField(controller: name, decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline))),
        if (!loginMode) const SizedBox(height: 12),
        TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف السوداني', hintText: '+249XXXXXXXXX', prefixIcon: Icon(Icons.phone_iphone))),
        const SizedBox(height: 12),
        TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock_outline))),
        const SizedBox(height: 8),
        Row(children: [Expanded(child: RadioListTile<String>(value: 'buyer', groupValue: role, onChanged: (v) => setState(() => role = v!), title: const Text('مشتري'), dense: true)), Expanded(child: RadioListTile<String>(value: 'seller', groupValue: role, onChanged: (v) => setState(() => role = v!), title: const Text('بائع'), dense: true))]),
        if (error.isNotEmpty) Text(error, style: const TextStyle(color: Colors.redAccent)),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: submit, child: Text(loginMode ? 'دخول إلى BUKO' : 'إنشاء الحساب'))),
      ]))),
      const SizedBox(height: 14), const Text('الإدارة تدخل من نفس خانة الهاتف باستخدام رمز الإدارة', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
    ]))))),
  ])));

  Widget _tab(String text, bool active) => InkWell(onTap: () => setState(() { loginMode = text == 'دخول'; error = ''; }), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: active ? green : Colors.transparent, borderRadius: BorderRadius.circular(14)), child: Center(child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)))));
  Widget _orb(Color color, double size) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withAlpha(25), boxShadow: [BoxShadow(color: color.withAlpha(35), blurRadius: 100, spreadRadius: 20)]));
}

class DetailsPage extends StatelessWidget {
  final Car car;
  final VoidCallback onBuy;
  const DetailsPage({super.key, required this.car, required this.onBuy});
  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(appBar: AppBar(title: const Text('تفاصيل السيارة')), body: ListView(padding: const EdgeInsets.all(18), children: [
    Container(height: 220, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF193D4F), navy])), child: const Icon(Icons.directions_car, size: 120, color: green)),
    const SizedBox(height: 18), Text(car.name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), Text(car.price, style: const TextStyle(fontSize: 25, color: green, fontWeight: FontWeight.w900)),
    Card(color: Colors.white, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [_row('السنة', '${car.year}'), _row('المدينة', car.city), _row('النوع', car.type), _row('البائع', car.seller)]))),
    const SizedBox(height: 16), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onBuy, icon: const Icon(Icons.shopping_cart_checkout), label: const Text('طلب شراء السيارة'))),
  ])));
  Widget _row(String key, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Expanded(child: Text(key, style: const TextStyle(color: Colors.black54))), Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))]));
}

class SellPage extends StatefulWidget {
  final bool isSeller;
  final ValueChanged<Car> onSubmit;
  const SellPage({super.key, required this.isSeller, required this.onSubmit});
  @override State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final name = TextEditingController();
  final year = TextEditingController();
  final price = TextEditingController();
  String city = 'الخرطوم';
  String type = 'سيدان';
  @override void dispose() { name.dispose(); year.dispose(); price.dispose(); super.dispose(); }
  void submit() {
    final y = int.tryParse(year.text);
    if (name.text.trim().isEmpty || price.text.trim().isEmpty || y == null) return;
    widget.onSubmit(Car(name.text.trim(), y, price.text.trim(), city, type, seller: 'بائع'));
    name.clear(); year.clear(); price.clear();
  }
  @override
  Widget build(BuildContext context) {
    if (!widget.isSeller) return const Center(child: Text('حساب بائع مطلوب لإضافة إعلان', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)));
    return ListView(padding: const EdgeInsets.all(18), children: [
      const Text('إضافة إعلان', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8), const Text('الإعلان يذهب للإدارة للمراجعة قبل النشر.', style: TextStyle(color: Colors.white70)), const SizedBox(height: 18),
      TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم السيارة')),
      const SizedBox(height: 10), TextField(controller: year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السنة')),
      const SizedBox(height: 10), TextField(controller: price, decoration: const InputDecoration(labelText: 'السعر')),
      const SizedBox(height: 10), DropdownButtonFormField<String>(initialValue: type, decoration: const InputDecoration(labelText: 'النوع'), items: const ['سيدان', 'دفع رباعي', 'بيك أب'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => type = v!)),
      const SizedBox(height: 10), DropdownButtonFormField<String>(initialValue: city, decoration: const InputDecoration(labelText: 'المدينة'), items: const ['الخرطوم', 'أم درمان', 'بحري', 'بورتسودان'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => city = v!)),
      const SizedBox(height: 18), FilledButton.icon(onPressed: submit, icon: const Icon(Icons.send), label: const Text('إرسال للمراجعة')),
    ]);
  }
}

class AdminPage extends StatefulWidget {
  final List<User> users;
  final List<Car> pending;
  final List<PurchaseRequest> requests;
  final List<Car> cars;
  final ValueChanged<int> onApprove;
  final ValueChanged<int> onReject;
  final ValueChanged<Car> onPost;
  const AdminPage({super.key, required this.users, required this.pending, required this.requests, required this.cars, required this.onApprove, required this.onReject, required this.onPost});
  @override State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Future<void> post() async {
    final car = await showDialog<Car>(context: context, builder: (_) => const AdminPostDialog());
    if (car != null) { widget.onPost(car); setState(() {}); }
  }
  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(appBar: AppBar(title: const Text('لوحة تحكم BUKO')), body: ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: ListTile(title: const Text('نظرة عامة'), subtitle: Text('${widget.users.length} مستخدم • ${widget.cars.length} سيارة • ${widget.pending.length} معلق • ${widget.requests.length} طلب شراء'))),
    FilledButton.icon(onPressed: post, icon: const Icon(Icons.add), label: const Text('إضافة منشور مباشر')),
    const SizedBox(height: 20), const Text('المستخدمون', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
    ...widget.users.map((u) => Card(color: Colors.white, child: ListTile(title: Text(u.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), subtitle: Text('${u.phone} • ${u.role == 'seller' ? 'بائع' : 'مشتري'}', style: const TextStyle(color: Colors.black54))))),
    const SizedBox(height: 20), const Text('إعلانات بانتظار الموافقة', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
    if (widget.pending.isEmpty) const Text('لا توجد إعلانات معلقة', style: TextStyle(color: Colors.white70)),
    ...List.generate(widget.pending.length, (index) { final car = widget.pending[index]; return Card(color: Colors.white, child: ListTile(title: Text(car.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), subtitle: Text('${car.year} • ${car.city} • ${car.price}', style: const TextStyle(color: Colors.black54)), trailing: Wrap(children: [IconButton(onPressed: () { widget.onApprove(index); setState(() {}); }, icon: const Icon(Icons.check, color: green)), IconButton(onPressed: () { widget.onReject(index); setState(() {}); }, icon: const Icon(Icons.close, color: Colors.red))]))); }),
    const SizedBox(height: 20), const Text('طلبات الشراء', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
    if (widget.requests.isEmpty) const Text('لا توجد طلبات شراء بعد', style: TextStyle(color: Colors.white70)),
    ...widget.requests.map((request) => Card(child: ListTile(leading: const Icon(Icons.shopping_cart, color: yellow), title: Text(request.car.name), subtitle: Text('${request.buyer.name} • ${request.buyer.phone}')))),
  ])));
}

class AdminPostDialog extends StatefulWidget {
  const AdminPostDialog({super.key});
  @override State<AdminPostDialog> createState() => _AdminPostDialogState();
}

class _AdminPostDialogState extends State<AdminPostDialog> {
  final name = TextEditingController();
  final year = TextEditingController();
  final price = TextEditingController();
  String city = 'الخرطوم';
  String type = 'سيدان';
  @override void dispose() { name.dispose(); year.dispose(); price.dispose(); super.dispose(); }
  void submit() {
    final y = int.tryParse(year.text);
    if (name.text.trim().isEmpty || price.text.trim().isEmpty || y == null) return;
    Navigator.pop(context, Car(name.text.trim(), y, price.text.trim(), city, type, seller: 'BUKO'));
  }
  @override
  Widget build(BuildContext context) => AlertDialog(title: const Text('إضافة منشور مباشر'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
    TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم السيارة')),
    const SizedBox(height: 10), TextField(controller: year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السنة')),
    const SizedBox(height: 10), TextField(controller: price, decoration: const InputDecoration(labelText: 'السعر')),
    const SizedBox(height: 10), DropdownButtonFormField<String>(initialValue: type, decoration: const InputDecoration(labelText: 'النوع'), items: const ['سيدان', 'دفع رباعي', 'بيك أب'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => type = v!)),
    const SizedBox(height: 10), DropdownButtonFormField<String>(initialValue: city, decoration: const InputDecoration(labelText: 'المدينة'), items: const ['الخرطوم', 'أم درمان', 'بحري', 'بورتسودان'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => city = v!)),
  ])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), FilledButton(onPressed: submit, child: const Text('نشر'))]);
}
