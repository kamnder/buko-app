import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const adminCode = 'BUKO-ADMIN-2026';
const green = Color(0xFF16A34A);
const lightGreen = Color(0xFF39C86A);
const navy = Color(0xFF071A2A);

void main() => runApp(const BukoApp());

class Car {
  final String name;
  final int year;
  final String price;
  final String city;
  final String type;
  final String seller;
  const Car(this.name, this.year, this.price, this.city, this.type, {this.seller = 'بائع BUKO'});
}

class PendingAd {
  final Car car;
  final String seller;
  PendingAd(this.car, this.seller);
}

class AppUser {
  final String name;
  final String email;
  final String password;
  final String role;
  AppUser({required this.name, required this.email, required this.password, required this.role});
}

const seedCars = <Car>[
  Car('تويوتا هايلوكس', 2019, '85,000,000 ج.س', 'أم درمان', 'بيك أب'),
  Car('تويوتا برادو', 2018, '120,000,000 ج.س', 'بحري', 'دفع رباعي'),
  Car('هيونداي النترا', 2021, '45,000,000 ج.س', 'الخرطوم', 'سيدان'),
  Car('كيا سبورتاج', 2020, '68,000,000 ج.س', 'الخرطوم', 'دفع رباعي'),
];

class BukoApp extends StatelessWidget {
  const BukoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BUKO',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: green, brightness: Brightness.dark),
          scaffoldBackgroundColor: navy,
        ),
        home: const SplashPage(),
      );
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    });
  }
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: controller, curve: Curves.easeIn),
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: green.withOpacity(.18), blurRadius: 35, spreadRadius: 5)]),
                  child: SvgPicture.asset('assets/images/buko_logo.svg', width: 330, height: 230, fit: BoxFit.contain),
                ),
                const SizedBox(height: 22),
                const Text('حبابك عشرة', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('أهلاً بك في BUKO', style: TextStyle(fontSize: 17, color: Colors.white70)),
                const SizedBox(height: 26),
                const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3, color: lightGreen)),
              ]),
            ),
          ),
        ),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  String query = '';
  String selectedType = 'الكل';
  String selectedCity = 'الكل';
  AppUser? currentUser;
  final cars = <Car>[...seedCars];
  final favorites = <int>{};
  final pendingAds = <PendingAd>[];
  final users = <AppUser>[];

  bool get isLoggedIn => currentUser != null;
  bool get isSeller => currentUser?.role == 'seller';

  List<int> get filtered => List.generate(cars.length, (i) => i).where((i) {
        final c = cars[i];
        final q = query.trim().toLowerCase();
        final text = '${c.name} ${c.city} ${c.type}'.toLowerCase();
        return (q.isEmpty || text.contains(q)) && (selectedType == 'الكل' || c.type == selectedType) && (selectedCity == 'الكل' || c.city == selectedCity);
      }).toList();

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _homePage(),
      _explorePage(),
      SellPage(isSeller: isSeller, userName: currentUser?.name, onSubmit: _submitAd),
      _favoritesPage(),
      AccountPage(user: currentUser, onLogin: _login, onRegister: _register, onAdmin: _adminLogin, onLogout: _logout),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(child: pages[tab]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (v) => setState(() => tab = v),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.search), label: 'استكشاف'),
            NavigationDestination(icon: Icon(Icons.sell_outlined), selectedIcon: Icon(Icons.sell), label: 'بيع'),
            NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'المفضلة'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }

  Widget _homePage() => ListView(padding: const EdgeInsets.all(18), children: [
        const LogoHeader(),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF102C40), Color(0xFF061521)])),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('السوق الأول للسيارات المستعملة في السودان', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 10),
            Text('إبحث عن سيارتك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            Text('بكل سهولة في السودان', style: TextStyle(fontSize: 21, color: lightGreen, fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(height: 14),
        _searchField(),
        const SizedBox(height: 18),
        const Text('البحث المتقدم', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        Card(color: Colors.white, child: ListTile(onTap: _showFilters, leading: const Icon(Icons.tune, color: green), title: const Text('فلترة حسب النوع والمدينة', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), trailing: const Icon(Icons.chevron_left, color: Colors.black54))),
        const SizedBox(height: 16),
        const Text('السيارات المميزة', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...filtered.take(4).map(_carCard),
        FilledButton.icon(onPressed: () => setState(() => tab = 1), icon: const Icon(Icons.grid_view), label: const Text('عرض كل السيارات')),
      ]);

  Widget _explorePage() => ListView(padding: const EdgeInsets.all(18), children: [
        const Text('استكشاف السيارات', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _searchField(),
        const SizedBox(height: 12),
        Row(children: [Chip(label: Text(selectedType)), const SizedBox(width: 8), Chip(label: Text(selectedCity)), const Spacer(), IconButton.filled(onPressed: _showFilters, icon: const Icon(Icons.filter_list))]),
        Text('${filtered.length} سيارة متاحة', style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        ...filtered.map(_carCard),
      ]);

  Widget _favoritesPage() {
    final ids = favorites.where((i) => i >= 0 && i < cars.length).toList();
    return ListView(padding: const EdgeInsets.all(18), children: [
      const Text('المفضلة', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('السيارات التي حفظتها', style: TextStyle(color: Colors.white70)),
      const SizedBox(height: 18),
      if (ids.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('لم تحفظ أي سيارة بعد'))),
      ...ids.map(_carCard),
    ]);
  }

  Widget _searchField() => TextField(
        onChanged: (v) => setState(() => query = v),
        onSubmitted: (_) => setState(() => tab = 1),
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(filled: true, fillColor: Colors.white, hintText: 'إبحث عن ماركة أو موديل...', hintStyle: const TextStyle(color: Colors.black54), prefixIcon: const Icon(Icons.search, color: Colors.black54), suffixIcon: IconButton(onPressed: _showFilters, icon: const Icon(Icons.tune, color: green)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
      );

  Widget _carCard(int index) {
    final car = cars[index];
    final fav = favorites.contains(index);
    return Card(color: Colors.white, margin: const EdgeInsets.only(bottom: 10), child: ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsPage(car: car, isFavorite: fav, onFavorite: () => _toggleFavorite(index)))),
      leading: const CircleAvatar(backgroundColor: Color(0xFFE8F7ED), child: Icon(Icons.directions_car, color: green)),
      title: Text(car.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      subtitle: Text('${car.year} • ${car.city}\n${car.price}', style: const TextStyle(color: Colors.black54)),
      trailing: IconButton(onPressed: () => _toggleFavorite(index), icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: green)),
    ));
  }

  void _toggleFavorite(int i) => setState(() => favorites.contains(i) ? favorites.remove(i) : favorites.add(i));

  void _submitAd(Car car) {
    if (!isLoggedIn || !isSeller) {
      _message('يجب تسجيل الدخول بحساب بائع أولاً');
      return;
    }
    setState(() => pendingAds.add(PendingAd(car, currentUser!.name)));
    _message('تم إرسال الإعلان للمراجعة. لن يظهر للعامة حتى موافقة الإدارة.');
  }

  void _approveAd(int i) {
    if (i < 0 || i >= pendingAds.length) return;
    final p = pendingAds.removeAt(i);
    setState(() => cars.add(p.car));
    _message('تمت الموافقة على إعلان ${p.car.name} ونشره');
  }

  void _rejectAd(int i) {
    if (i < 0 || i >= pendingAds.length) return;
    final p = pendingAds.removeAt(i);
    setState(() {});
    _message('تم رفض إعلان ${p.car.name}');
  }

  Future<void> _login() async {
    final result = await showDialog<AppUser>(context: context, builder: (_) => LoginDialog(users: users));
    if (result == null) return;
    setState(() => currentUser = result);
    _message('مرحباً ${result.name}');
  }

  Future<void> _register() async {
    final result = await showDialog<AppUser>(context: context, builder: (_) => const RegisterDialog());
    if (result == null) return;
    if (users.any((u) => u.email.toLowerCase() == result.email.toLowerCase())) {
      _message('هذا البريد مسجل مسبقاً');
      return;
    }
    setState(() { users.add(result); currentUser = result; });
    _message(result.role == 'seller' ? 'تم إنشاء حساب بائع. يمكنك إرسال الإعلانات للمراجعة.' : 'تم إنشاء حساب مشتري.');
  }

  Future<void> _adminLogin() async {
    final code = await showDialog<String>(context: context, builder: (_) => const AdminCodeDialog());
    if (code == null) return;
    if (code != adminCode) {
      _message('رمز الإدارة غير صحيح');
      return;
    }
    await Navigator.push(context, MaterialPageRoute(builder: (_) => AdminControlPage(pendingAds: pendingAds, users: users, onApprove: _approveAd, onReject: _rejectAd, onAddDemo: _addDemoUser)));
    if (mounted) setState(() {});
  }

  void _addDemoUser() => setState(() => users.add(AppUser(name: 'مستخدم تجريبي', email: 'user-${users.length + 1}@buko.app', password: 'demo', role: 'buyer')));
  void _logout() => setState(() => currentUser = null);

  Future<void> _showFilters() async {
    var type = selectedType;
    var city = selectedCity;
    await showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('البحث المتقدم'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'نوع السيارة'), items: const ['الكل', 'سيدان', 'بيك أب', 'دفع رباعي'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => type = v ?? 'الكل'),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: city, decoration: const InputDecoration(labelText: 'المدينة'), items: const ['الكل', 'الخرطوم', 'بحري', 'أم درمان'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => city = v ?? 'الكل'),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')), FilledButton(onPressed: () { setState(() { selectedType = type; selectedCity = city; tab = 1; }); Navigator.pop(dialogContext); }, child: const Text('تطبيق'))],
    ));
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
}

class LogoHeader extends StatelessWidget {
  const LogoHeader({super.key});
  @override
  Widget build(BuildContext context) => Column(children: [SvgPicture.asset('assets/images/buko_logo.svg', height: 100, fit: BoxFit.contain), const SizedBox(height: 4), const Text('حبابك عشرة', style: TextStyle(color: lightGreen, fontWeight: FontWeight.bold))]);
}

class CarDetailsPage extends StatefulWidget {
  final Car car;
  final bool isFavorite;
  final VoidCallback onFavorite;
  const CarDetailsPage({super.key, required this.car, required this.isFavorite, required this.onFavorite});
  @override State<CarDetailsPage> createState() => _CarDetailsPageState();
}
class _CarDetailsPageState extends State<CarDetailsPage> {
  late bool favorite;
  @override void initState() { super.initState(); favorite = widget.isFavorite; }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('تفاصيل السيارة')), body: ListView(padding: const EdgeInsets.all(18), children: [
    Container(height: 190, decoration: BoxDecoration(color: const Color(0xFF102C40), borderRadius: BorderRadius.circular(22)), child: SvgPicture.asset('assets/images/buko_logo.svg', fit: BoxFit.contain)),
    const SizedBox(height: 18), Text(widget.car.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), Text(widget.car.price, style: const TextStyle(fontSize: 23, color: lightGreen, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16), Card(color: Colors.white, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [_row('السنة', '${widget.car.year}'), _row('المدينة', widget.car.city), _row('النوع', widget.car.type), _row('البائع', widget.car.seller)]))),
    const SizedBox(height: 14), FilledButton.icon(onPressed: () { setState(() => favorite = !favorite); widget.onFavorite(); }, icon: Icon(favorite ? Icons.favorite : Icons.favorite_border), label: Text(favorite ? 'إزالة من المفضلة' : 'حفظ في المفضلة')),
    OutlinedButton.icon(onPressed: () => showDialog<void>(context: context, builder: (_) => const AlertDialog(title: Text('التواصل مع البائع'), content: Text('سيتم ربط الاتصال والرسائل بخدمة حقيقية في مرحلة الخادم.'))), icon: const Icon(Icons.phone), label: const Text('التواصل مع البائع')),
  ]));
  Widget _row(String a, String b) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Expanded(child: Text(a, style: const TextStyle(color: Colors.black54))), Text(b, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))]));
}

class SellPage extends StatefulWidget {
  final bool isSeller;
  final String? userName;
  final ValueChanged<Car> onSubmit;
  const SellPage({super.key, required this.isSeller, required this.userName, required this.onSubmit});
  @override State<SellPage> createState() => _SellPageState();
}
class _SellPageState extends State<SellPage> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final year = TextEditingController(text: '2022');
  final price = TextEditingController();
  final city = TextEditingController(text: 'الخرطوم');
  String type = 'سيدان';
  @override void dispose() { name.dispose(); year.dispose(); price.dispose(); city.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (!widget.isSeller) return Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.storefront, size: 70, color: lightGreen), const SizedBox(height: 12), const Text('قسم البيع مخصص لحسابات البائعين', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center), const SizedBox(height: 8), const Text('أنشئ حساب بائع من صفحة حسابي حتى تتمكن من إرسال إعلان للمراجعة.', textAlign: TextAlign.center)])));
    return ListView(padding: const EdgeInsets.all(18), children: [const Text('بيع سيارتك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text('البائع: ${widget.userName}', style: const TextStyle(color: Colors.white70)), const SizedBox(height: 8), const Card(child: ListTile(leading: Icon(Icons.verified_user, color: green), title: Text('كل إعلان يخضع لموافقة الإدارة'), subtitle: Text('لن يظهر الإعلان للعامة قبل الموافقة.'))), const SizedBox(height: 14), Form(key: formKey, child: Column(children: [_field(name, 'الماركة والموديل'), _field(year, 'سنة الصنع', number: true), _field(price, 'السعر'), _field(city, 'المدينة'), DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'نوع السيارة'), items: const ['سيدان', 'بيك أب', 'دفع رباعي'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => type = v ?? type)), const SizedBox(height: 22), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.send), label: const Text('إرسال للمراجعة')))])]);
  }
  Widget _field(TextEditingController c, String label, {bool number = false}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: c, keyboardType: number ? TextInputType.number : TextInputType.text, validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null, decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.white12)));
  void _submit() { if (!formKey.currentState!.validate()) return; final y = int.tryParse(year.text.trim()); if (y == null || y < 1900 || y > DateTime.now().year + 1) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل سنة صحيحة'))); return; } widget.onSubmit(Car(name.text.trim(), y, price.text.trim(), city.text.trim(), type, seller: widget.userName ?? 'بائع')); }
}

class AccountPage extends StatelessWidget {
  final AppUser? user;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onAdmin;
  final VoidCallback onLogout;
  const AccountPage({super.key, required this.user, required this.onLogin, required this.onRegister, required this.onAdmin, required this.onLogout});
  @override
  Widget build(BuildContext context) {
    if (user == null) return ListView(padding: const EdgeInsets.all(18), children: [const Text('مركز الحساب', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('سجل دخولك أو أنشئ حساباً جديداً', style: TextStyle(color: Colors.white70)), const SizedBox(height: 24), _button(Icons.login, 'تسجيل الدخول', onLogin), _button(Icons.person_add, 'إنشاء حساب جديد', onRegister), const SizedBox(height: 18), const Divider(), ListTile(leading: const Icon(Icons.admin_panel_settings_outlined), title: const Text('دخول إدارة التطبيق'), subtitle: const Text('للمدير فقط'), onTap: onAdmin)]);
    final roleText = user!.role == 'seller' ? 'حساب بائع' : 'حساب مشتري';
    return ListView(padding: const EdgeInsets.all(18), children: [const Text('مركز الحساب', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 18), Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(user!.name), subtitle: Text(user!.email))), Card(child: ListTile(leading: Icon(user!.role == 'seller' ? Icons.storefront : Icons.shopping_bag, color: green), title: Text(roleText), subtitle: Text(user!.role == 'seller' ? 'إعلاناتك تنتظر موافقة الإدارة قبل النشر.' : 'يمكنك استكشاف السيارات وحفظ المفضلة.'))), ListTile(leading: const Icon(Icons.notifications_outlined), title: const Text('الإشعارات'), onTap: () => _info(context, 'الإشعارات', 'لا توجد إشعارات جديدة.')), ListTile(leading: const Icon(Icons.help_outline), title: const Text('المساعدة'), onTap: () => _info(context, 'المساعدة', 'يمكنك التسجيل كمشتري أو بائع. إعلانات البائعين تحتاج موافقة الإدارة.')), ListTile(leading: const Icon(Icons.admin_panel_settings_outlined), title: const Text('تحكم بالتطبيق وبياناته والمستخدمين'), onTap: onAdmin), ListTile(leading: const Icon(Icons.logout), title: const Text('تسجيل الخروج'), onTap: onLogout)]);
  }
  Widget _button(IconData icon, String text, VoidCallback action) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: action, icon: Icon(icon), label: Text(text))));
  void _info(BuildContext c, String t, String x) => showDialog<void>(context: c, builder: (_) => AlertDialog(title: Text(t), content: Text(x), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('حسناً'))]));
}

class LoginDialog extends StatefulWidget {
  final List<AppUser> users;
  const LoginDialog({super.key, required this.users});
  @override State<LoginDialog> createState() => _LoginDialogState();
}
class _LoginDialogState extends State<LoginDialog> {
  final email = TextEditingController();
  final password = TextEditingController();
  String role = 'buyer';
  String? error;
  @override void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(title: const Text('تسجيل الدخول'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [_input(email, 'البريد الإلكتروني'), _input(password, 'كلمة المرور', secret: true), DropdownButtonFormField<String>(value: role, decoration: const InputDecoration(labelText: 'نوع الحساب'), items: const [DropdownMenuItem(value: 'buyer', child: Text('مشتري')), DropdownMenuItem(value: 'seller', child: Text('بائع'))], onChanged: (v) => setState(() => role = v ?? role)), if (error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: Colors.redAccent)))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), FilledButton(onPressed: _submit, child: const Text('دخول'))]);
  Widget _input(TextEditingController c, String l, {bool secret = false}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: c, obscureText: secret, keyboardType: secret ? TextInputType.text : TextInputType.emailAddress, decoration: InputDecoration(labelText: l)));
  void _submit() { final e = email.text.trim().toLowerCase(); final p = password.text; final user = widget.users.cast<AppUser?>().firstWhere((u) => u!.email.toLowerCase() == e && u.password == p && u.role == role, orElse: () => null); if (user == null) { setState(() => error = 'البريد أو كلمة المرور أو نوع الحساب غير صحيح'); return; } Navigator.pop(context, user); }
}

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key});
  @override State<RegisterDialog> createState() => _RegisterDialogState();
}
class _RegisterDialogState extends State<RegisterDialog> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  String role = 'buyer';
  @override void dispose() { name.dispose(); email.dispose(); password.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(title: const Text('إنشاء حساب'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [_input(name, 'الاسم'), _input(email, 'البريد الإلكتروني'), _input(password, 'كلمة المرور', secret: true), DropdownButtonFormField<String>(value: role, decoration: const InputDecoration(labelText: 'نوع الحساب'), items: const [DropdownMenuItem(value: 'buyer', child: Text('حساب مشتري')), DropdownMenuItem(value: 'seller', child: Text('حساب بائع'))], onChanged: (v) => setState(() => role = v ?? role)), const SizedBox(height: 8), const Text('حساب البائع يستطيع إرسال الإعلانات، لكنها تبقى قيد المراجعة حتى موافقة الإدارة.', style: TextStyle(fontSize: 12, color: Colors.white70))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), FilledButton(onPressed: () { if (name.text.trim().length < 2 || !email.text.contains('@') || password.text.length < 4) return; Navigator.pop(context, AppUser(name: name.text.trim(), email: email.text.trim(), password: password.text, role: role)); }, child: const Text('إنشاء الحساب'))]);
  Widget _input(TextEditingController c, String l, {bool secret = false}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: c, obscureText: secret, decoration: InputDecoration(labelText: l)));
}

class AdminCodeDialog extends StatefulWidget {
  const AdminCodeDialog({super.key});
  @override State<AdminCodeDialog> createState() => _AdminCodeDialogState();
}
class _AdminCodeDialogState extends State<AdminCodeDialog> {
  final code = TextEditingController();
  @override void dispose() { code.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AlertDialog(title: const Text('دخول الإدارة'), content: TextField(controller: code, obscureText: true, decoration: const InputDecoration(labelText: 'رمز الإدارة', hintText: 'أدخل رمز المدير')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(context, code.text.trim()), child: const Text('دخول'))]);
}

class AdminControlPage extends StatefulWidget {
  final List<PendingAd> pendingAds;
  final List<AppUser> users;
  final void Function(int) onApprove;
  final void Function(int) onReject;
  final VoidCallback onAddDemo;
  const AdminControlPage({super.key, required this.pendingAds, required this.users, required this.onApprove, required this.onReject, required this.onAddDemo});
  @override State<AdminControlPage> createState() => _AdminControlPageState();
}
class _AdminControlPageState extends State<AdminControlPage> {
  int section = 0;
  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(appBar: AppBar(title: const Text('تحكم بالتطبيق وبياناته والمستخدمين')), body: ListView(padding: const EdgeInsets.all(18), children: [
    const Text('مركز إدارة BUKO', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
    const SizedBox(height: 6),
    const Text('مراجعة الإعلانات وإدارة المستخدمين وأدوات التطبيق', style: TextStyle(color: Colors.white70)),
    const SizedBox(height: 18),
    Row(children: [_stat('المراجعة', widget.pendingAds.length, Icons.fact_check), const SizedBox(width: 8), _stat('المستخدمون', widget.users.length, Icons.people)]),
    const SizedBox(height: 18),
    SegmentedButton<int>(segments: const [ButtonSegment(value: 0, label: Text('طلبات الإعلانات'), icon: Icon(Icons.pending_actions)), ButtonSegment(value: 1, label: Text('المستخدمون'), icon: Icon(Icons.people)), ButtonSegment(value: 2, label: Text('أدوات'), icon: Icon(Icons.settings))], selected: {section}, onSelectionChanged: (s) => setState(() => section = s.first)),
    const SizedBox(height: 16),
    if (section == 0) _ads(),
    if (section == 1) _users(),
    if (section == 2) _tools(),
  ])));
  Widget _stat(String title, int value, IconData icon) => Expanded(child: Card(color: Colors.white, child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [Icon(icon, color: green, size: 30), const SizedBox(height: 5), Text('$value', style: const TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold)), Text(title, style: const TextStyle(color: Colors.black54))]))));
  Widget _ads() {
    if (widget.pendingAds.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(22), child: Column(children: [Icon(Icons.check_circle, color: green, size: 48), SizedBox(height: 8), Text('لا توجد طلبات معلقة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))])));
    return Column(children: List.generate(widget.pendingAds.length, (i) { final p = widget.pendingAds[i]; return Card(color: Colors.white, margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.car.name, style: const TextStyle(color: Colors.black87, fontSize: 19, fontWeight: FontWeight.bold)), Text('${p.car.year} • ${p.car.city} • ${p.car.type}', style: const TextStyle(color: Colors.black54)), Text(p.car.price, style: const TextStyle(color: green, fontWeight: FontWeight.bold)), Text('البائع: ${p.seller}', style: const TextStyle(color: Colors.black87)), const SizedBox(height: 10), Row(children: [Expanded(child: FilledButton.icon(onPressed: () { widget.onApprove(i); setState(() {}); }, icon: const Icon(Icons.check), label: const Text('موافقة ونشر'))), const SizedBox(width: 8), Expanded(child: OutlinedButton.icon(onPressed: () { widget.onReject(i); setState(() {}); }, icon: const Icon(Icons.close), label: const Text('رفض')))])]))); }));
  }
  Widget _users() => Column(children: [Card(child: ListTile(leading: const Icon(Icons.people), title: const Text('إجمالي الحسابات المسجلة'), trailing: Text('${widget.users.length}'))), if (widget.users.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('لا توجد حسابات مسجلة بعد')), ...widget.users.map((u) => Card(color: Colors.white, child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(u.name, style: const TextStyle(color: Colors.black87)), subtitle: Text('${u.email} • ${u.role == 'seller' ? 'بائع' : 'مشتري'}', style: const TextStyle(color: Colors.black54))))]);
  Widget _tools() => Column(children: [Card(child: ListTile(leading: const Icon(Icons.person_add), title: const Text('إضافة مستخدم تجريبي'), subtitle: const Text('لاختبار لوحة المستخدمين'), onTap: () { widget.onAddDemo(); setState(() {}); })), const Card(child: ListTile(leading: Icon(Icons.security), title: Text('حماية الإدارة'), subtitle: Text('رمز الدخول الحالي مخصص لنسخة الاختبار فقط.'))), const Card(child: ListTile(leading: Icon(Icons.cloud_off), title: Text('حالة البيانات'), subtitle: Text('هذه النسخة تحفظ البيانات داخل التطبيق فقط. سيتم ربط قاعدة بيانات حقيقية لاحقاً.')))]);
}
