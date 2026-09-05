import 'package:flutter/material.dart';

const adminCode = 'BUKO-ADMIN-2026';
const navy = Color(0xFF0B1B2A);
const green = Color(0xFF22C55E);
const yellow = Color(0xFFFFC107);
const blue = Color(0xFF2563EB);

class Car {
  final String name;
  final int year;
  final String price;
  final String city;
  final String type;
  final String seller;

  const Car(this.name, this.year, this.price, this.city, this.type, {this.seller = 'BUKO'});
}

class User {
  final String name;
  final String email;
  final String password;
  final String role;

  User(this.name, this.email, this.password, this.role);
}

class PendingAd {
  final Car car;
  PendingAd(this.car);
}

const seedCars = <Car>[
  Car('مرسيدس C 180', 2020, '880,000 ج.م', 'القاهرة', 'سيدان'),
  Car('كيا سبورتاج', 2019, '720,000 ج.م', 'الجيزة', 'دفع رباعي'),
  Car('هيونداي النترا', 2021, '690,000 ج.م', 'الإسكندرية', 'سيدان'),
  Car('تويوتا كورولا', 2020, '760,000 ج.م', 'القاهرة', 'سيدان'),
  Car('BMW X3', 2021, '1,600,000 ج.م', 'الجيزة', 'دفع رباعي'),
];

void main() => runApp(const BukoApp());

class BukoApp extends StatelessWidget {
  const BukoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BUKO',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: navy,
        colorScheme: ColorScheme.fromSeed(seedColor: green, brightness: Brightness.dark),
      ),
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('BUKO', style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 5)),
            SizedBox(height: 10),
            Text('حبابك عشرة', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: green)),
            SizedBox(height: 24),
            CircularProgressIndicator(color: green),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  String query = '';
  String selectedType = 'الكل';
  String selectedCity = 'الكل';
  User? currentUser;
  final cars = <Car>[...seedCars];
  final favorites = <int>{};
  final pending = <PendingAd>[];
  final users = <User>[];

  bool get isSeller => currentUser?.role == 'seller';

  List<int> get filtered {
    final q = query.trim().toLowerCase();
    return List.generate(cars.length, (i) => i).where((i) {
      final car = cars[i];
      final text = '${car.name} ${car.city} ${car.type}'.toLowerCase();
      return (q.isEmpty || text.contains(q)) &&
          (selectedType == 'الكل' || car.type == selectedType) &&
          (selectedCity == 'الكل' || car.city == selectedCity);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _home(),
      _explore(),
      SellPage(isSeller: isSeller, onSubmit: _submitSellerAd),
      _favorites(),
      _account(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(child: pages[tab]),
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.white,
          selectedIndex: tab,
          onDestinationSelected: (value) => setState(() => tab = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined, color: Colors.black54), selectedIcon: Icon(Icons.home, color: green), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.search, color: Colors.black54), selectedIcon: Icon(Icons.search, color: green), label: 'استكشاف'),
            NavigationDestination(icon: Icon(Icons.add_circle_outline, color: Colors.black54), selectedIcon: Icon(Icons.add_circle, color: green), label: 'بيع سيارتك'),
            NavigationDestination(icon: Icon(Icons.favorite_border, color: Colors.black54), selectedIcon: Icon(Icons.favorite, color: Colors.red), label: 'المفضلة'),
            NavigationDestination(icon: Icon(Icons.person_outline, color: Colors.black54), selectedIcon: Icon(Icons.person, color: green), label: 'حسابي'),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Text('BUKO', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const Spacer(),
        IconButton(onPressed: () => setState(() => tab = 4), icon: const Icon(Icons.menu)),
      ],
    );
  }

  Widget _home() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header(),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [Color(0xFF18384D), Color(0xFF07131E)]),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('السوق الذكي للسيارات', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 8),
              Text('اعثر على سيارتك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              Text('المستعملة بثقة', style: TextStyle(fontSize: 23, color: yellow, fontWeight: FontWeight.w900)),
              SizedBox(height: 8),
              Text('آلاف السيارات بانتظارك', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _searchField(),
        const SizedBox(height: 14),
        _advancedBox(),
        _sectionTitle('السيارات المميزة'),
        SizedBox(height: 205, child: ListView(scrollDirection: Axis.horizontal, children: filtered.take(4).map(_featuredCard).toList())),
        _sectionTitle('أحدث السيارات'),
        ...filtered.take(4).map(_carCard),
      ],
    );
  }

  Widget _searchField() {
    return TextField(
      onChanged: (value) => setState(() => query = value),
      onSubmitted: (_) => setState(() => tab = 1),
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.search, color: Colors.black54),
        suffixIcon: IconButton(onPressed: _showFilters, icon: const Icon(Icons.tune, color: navy)),
        hintText: 'إبحث عن ماركة أو موديل أو كلمة مفتاحية...',
        hintStyle: const TextStyle(color: Colors.black45),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _advancedBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF14283A), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(children: [const Text('بحث متقدم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Spacer(), IconButton(onPressed: _showFilters, icon: const Icon(Icons.tune))]),
          Row(children: [Expanded(child: _filterBox('النوع', selectedType)), const SizedBox(width: 8), Expanded(child: _filterBox('المحافظة', selectedCity))]),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _showFilters, icon: const Icon(Icons.search), label: const Text('بحث'), style: FilledButton.styleFrom(backgroundColor: yellow, foregroundColor: Colors.black))),
        ],
      ),
    );
  }

  Widget _filterBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.black54, fontSize: 11)),
        Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 9),
      child: Row(children: [Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), const Spacer(), TextButton(onPressed: () => setState(() => tab = 1), child: const Text('عرض الكل'))]),
    );
  }

  Widget _featuredCard(int index) {
    final car = cars[index];
    return GestureDetector(
      onTap: () => _details(index),
      child: Container(
        width: 190,
        margin: const EdgeInsets.only(left: 9),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 105,
            decoration: const BoxDecoration(color: Color(0xFFE8EEF2), borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
            child: Stack(children: [
              const Center(child: Icon(Icons.directions_car, size: 70, color: navy)),
              Positioned(top: 7, right: 7, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), color: yellow, child: const Text('مميز', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)))),
              Positioned(left: 0, top: 0, child: IconButton(onPressed: () => _toggleFavorite(index), icon: Icon(favorites.contains(index) ? Icons.favorite : Icons.favorite_border, color: Colors.red))),
            ]),
          ),
          Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(car.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            Text('${car.year} • ${car.city}', style: const TextStyle(color: Colors.black54, fontSize: 11)),
            Text(car.price, style: const TextStyle(color: blue, fontWeight: FontWeight.w900)),
          ])),
        ]),
      ),
    );
  }

  Widget _carCard(int index) {
    final car = cars[index];
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        onTap: () => _details(index),
        leading: const CircleAvatar(backgroundColor: Color(0xFFE8F7ED), child: Icon(Icons.directions_car, color: green)),
        title: Text(car.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        subtitle: Text('${car.year} • ${car.city} • ${car.type}\n${car.price}', style: const TextStyle(color: Colors.black54)),
        trailing: IconButton(onPressed: () => _toggleFavorite(index), icon: Icon(favorites.contains(index) ? Icons.favorite : Icons.favorite_border, color: Colors.red)),
      ),
    );
  }

  Widget _explore() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('استكشاف السيارات', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 12),
      _searchField(),
      const SizedBox(height: 10),
      Row(children: [Chip(label: Text(selectedType)), const SizedBox(width: 8), Chip(label: Text(selectedCity)), const Spacer(), IconButton.filled(onPressed: _showFilters, icon: const Icon(Icons.filter_list))]),
      Text('${filtered.length} سيارة متاحة', style: const TextStyle(color: Colors.white70)),
      const SizedBox(height: 8),
      ...filtered.map(_carCard),
    ]);
  }

  Widget _favorites() {
    final ids = favorites.where((i) => i >= 0 && i < cars.length).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('المفضلة', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('السيارات التي حفظتها', style: TextStyle(color: Colors.white70)),
      const SizedBox(height: 14),
      if (ids.isEmpty) const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('لم تحفظ أي سيارة بعد'))),
      ...ids.map(_carCard),
    ]);
  }

  Widget _account() {
    if (currentUser == null) {
      return ListView(padding: const EdgeInsets.all(18), children: [
        const Text('حسابي', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('سجّل دخولك أو أنشئ حساباً جديداً', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 22),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _login, icon: const Icon(Icons.login), label: const Text('تسجيل الدخول'))),
        OutlinedButton.icon(onPressed: _register, icon: const Icon(Icons.person_add), label: const Text('إنشاء حساب')),
      ]);
    }

    return ListView(padding: const EdgeInsets.all(18), children: [
      const Text('حسابي', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(currentUser!.name), subtitle: Text(currentUser!.email))),
      Card(child: ListTile(leading: Icon(isSeller ? Icons.storefront : Icons.shopping_bag, color: green), title: Text(isSeller ? 'حساب بائع' : 'حساب مشتري'), subtitle: Text(isSeller ? 'إعلاناتك تمر بمراجعة الإدارة.' : 'استكشف السيارات واحفظ المفضلة.'))),
      ListTile(leading: const Icon(Icons.logout), title: const Text('تسجيل الخروج'), onTap: () => setState(() => currentUser = null)),
    ]);
  }

  void _toggleFavorite(int index) {
    setState(() {
      if (favorites.contains(index)) {
        favorites.remove(index);
      } else {
        favorites.add(index);
      }
    });
  }

  void _details(int index) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsPage(car: cars[index], favorite: favorites.contains(index), onFavorite: () => _toggleFavorite(index))));
  }

  void _submitSellerAd(Car car) {
    if (!isSeller) {
      _message('أنشئ حساب بائع أولاً');
      return;
    }
    setState(() => pending.add(PendingAd(car)));
    _message('تم إرسال الإعلان للمراجعة ولن يظهر للعامة حتى الموافقة.');
  }

  Future<void> _login() async {
    final result = await showDialog<dynamic>(context: context, builder: (_) => LoginDialog(users: users));
    if (!mounted || result == null) return;
    if (result == adminCode) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPage(pending: pending, users: users, cars: cars, onApprove: _approve, onReject: _reject, onPost: _adminPost)));
    } else if (result is User) {
      setState(() => currentUser = result);
    }
  }

  Future<void> _register() async {
    final result = await showDialog<User>(context: context, builder: (_) => const RegisterDialog());
    if (!mounted || result == null) return;
    if (users.any((u) => u.email.toLowerCase() == result.email.toLowerCase())) {
      _message('البريد الإلكتروني مسجل مسبقاً');
      return;
    }
    setState(() {
      users.add(result);
      currentUser = result;
    });
  }

  void _approve(int index) {
    if (index < 0 || index >= pending.length) return;
    final ad = pending.removeAt(index);
    setState(() => cars.insert(0, ad.car));
  }

  void _reject(int index) {
    if (index < 0 || index >= pending.length) return;
    setState(() => pending.removeAt(index));
  }

  void _adminPost(Car car) {
    setState(() => cars.insert(0, car));
    _message('تم نشر المنشور مباشرة بواسطة الإدارة');
  }

  Future<void> _showFilters() async {
    var type = selectedType;
    var city = selectedCity;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('البحث المتقدم'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(
            value: type,
            decoration: const InputDecoration(labelText: 'نوع السيارة'),
            items: const ['الكل', 'سيدان', 'دفع رباعي', 'بيك أب'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (value) => type = value ?? type,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: city,
            decoration: const InputDecoration(labelText: 'المحافظة'),
            items: const ['الكل', 'القاهرة', 'الجيزة', 'الإسكندرية'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (value) => city = value ?? city,
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(onPressed: () { setState(() { selectedType = type; selectedCity = city; }); Navigator.pop(dialogContext); }, child: const Text('تطبيق')),
        ],
      ),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }
}

class LoginDialog extends StatefulWidget {
  final List<User> users;
  const LoginDialog({super.key, required this.users});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final id = TextEditingController();
  final password = TextEditingController();
  String role = 'buyer';
  String error = '';

  @override
  void dispose() {
    id.dispose();
    password.dispose();
    super.dispose();
  }

  void submit() {
    final value = id.text.trim();
    if (value == adminCode) {
      Navigator.pop(context, adminCode);
      return;
    }
    for (final user in widget.users) {
      if (user.email.toLowerCase() == value.toLowerCase() && user.password == password.text && user.role == role) {
        Navigator.pop(context, user);
        return;
      }
    }
    setState(() => error = 'بيانات الدخول غير صحيحة');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تسجيل الدخول'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: id, decoration: const InputDecoration(labelText: 'البريد الإلكتروني أو رمز الإدارة')),
        TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور')),
        DropdownButtonFormField<String>(value: role, items: const [DropdownMenuItem(value: 'buyer', child: Text('مشتري')), DropdownMenuItem(value: 'seller', child: Text('بائع'))], onChanged: (v) => setState(() => role = v ?? role)),
        if (error.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error, style: const TextStyle(color: Colors.red))),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), FilledButton(onPressed: submit, child: const Text('دخول'))],
    );
  }
}

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  String role = 'buyer';

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void submit() {
    if (name.text.trim().isEmpty || email.text.trim().isEmpty || password.text.isEmpty) return;
    Navigator.pop(context, User(name.text.trim(), email.text.trim(), password.text, role));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إنشاء حساب'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'الاسم')),
        TextField(controller: email, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
        TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور')),
        DropdownButtonFormField<String>(value: role, items: const [DropdownMenuItem(value: 'buyer', child: Text('مشتري')), DropdownMenuItem(value: 'seller', child: Text('بائع'))], onChanged: (v) => setState(() => role = v ?? role)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), FilledButton(onPressed: submit, child: const Text('إنشاء'))],
    );
  }
}

class SellPage extends StatefulWidget {
  final bool isSeller;
  final ValueChanged<Car> onSubmit;
  const SellPage({super.key, required this.isSeller, required this.onSubmit});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final name = TextEditingController();
  final year = TextEditingController(text: '2022');
  final price = TextEditingController();
  String city = 'القاهرة';
  String type = 'سيدان';

  @override
  void dispose() {
    name.dispose();
    year.dispose();
    price.dispose();
    super.dispose();
  }

  void submit() {
    final y = int.tryParse(year.text.trim());
    if (name.text.trim().isEmpty || price.text.trim().isEmpty || y == null) return;
    widget.onSubmit(Car(name.text.trim(), y, price.text.trim(), city, type, seller: 'بائع'));
    name.clear();
    price.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isSeller) {
      return Center(child: Padding(padding: const EdgeInsets.all(25), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.lock_outline, size: 60, color: yellow), const SizedBox(height: 14), const Text('بيع سيارتك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 8), const Text('هذه الميزة متاحة لحسابات البائعين فقط.'), const SizedBox(height: 18), const Text('سجّل حساب بائع من صفحة حسابي.')]));
    }

    return ListView(padding: const EdgeInsets.all(18), children: [
      const Text('إضافة إعلان', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      const Text('سيتم إرسال الإعلان للإدارة للمراجعة قبل النشر.', style: TextStyle(color: Colors.white70)),
      const SizedBox(height: 18),
      TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم السيارة', filled: true, fillColor: Colors.white)),
      const SizedBox(height: 10),
      TextField(controller: year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السنة', filled: true, fillColor: Colors.white)),
      const SizedBox(height: 10),
      TextField(controller: price, decoration: const InputDecoration(labelText: 'السعر', filled: true, fillColor: Colors.white)),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'النوع'), items: const ['سيدان', 'دفع رباعي', 'بيك أب'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => type = v ?? type)),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(value: city, decoration: const InputDecoration(labelText: 'المحافظة'), items: const ['القاهرة', 'الجيزة', 'الإسكندرية'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => city = v ?? city)),
      const SizedBox(height: 18),
      FilledButton.icon(onPressed: submit, icon: const Icon(Icons.send), label: const Text('إرسال للمراجعة')),
    ]);
  }
}

class DetailsPage extends StatefulWidget {
  final Car car;
  final bool favorite;
  final VoidCallback onFavorite;
  const DetailsPage({super.key, required this.car, required this.favorite, required this.onFavorite});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late bool favorite;

  @override
  void initState() {
    super.initState();
    favorite = widget.favorite;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      appBar: AppBar(title: const Text('تفاصيل السيارة')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Container(height: 210, decoration: BoxDecoration(color: const Color(0xFF142E42), borderRadius: BorderRadius.circular(24)), child: const Center(child: Icon(Icons.directions_car, size: 120, color: green))),
        const SizedBox(height: 18),
        Text(widget.car.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        Text(widget.car.price, style: const TextStyle(fontSize: 23, color: yellow, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Card(color: Colors.white, child: Padding(padding: const EdgeInsets.all(15), child: Column(children: [_row('السنة', '${widget.car.year}'), _row('المحافظة', widget.car.city), _row('النوع', widget.car.type), _row('البائع', widget.car.seller)]))),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: () { setState(() => favorite = !favorite); widget.onFavorite(); }, icon: Icon(favorite ? Icons.favorite : Icons.favorite_border), label: Text(favorite ? 'إزالة من المفضلة' : 'حفظ في المفضلة')),
        OutlinedButton.icon(onPressed: () => showDialog<void>(context: context, builder: (_) => const AlertDialog(title: Text('التواصل مع البائع'), content: Text('سيتم ربط الاتصال والرسائل بخدمة حقيقية لاحقاً.'))), icon: const Icon(Icons.phone), label: const Text('التواصل مع البائع')),
      ]),
    ));
  }

  Widget _row(String a, String b) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Expanded(child: Text(a, style: const TextStyle(color: Colors.black54))), Text(b, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))]));
}

class AdminPage extends StatefulWidget {
  final List<PendingAd> pending;
  final List<User> users;
  final List<Car> cars;
  final ValueChanged<int> onApprove;
  final ValueChanged<int> onReject;
  final ValueChanged<Car> onPost;

  const AdminPage({super.key, required this.pending, required this.users, required this.cars, required this.onApprove, required this.onReject, required this.onPost});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم BUKO')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF142E42), borderRadius: BorderRadius.circular(20)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('مرحباً أيها المدير', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), SizedBox(height: 5), Text('تحكم بالمنشورات والمستخدمين والمحتوى.')])),
        const SizedBox(height: 14),
        Row(children: [Expanded(child: _stat('السيارات', widget.cars.length.toString(), Icons.directions_car)), const SizedBox(width: 8), Expanded(child: _stat('المراجعة', widget.pending.length.toString(), Icons.pending_actions)), const SizedBox(width: 8), Expanded(child: _stat('المستخدمون', widget.users.length.toString(), Icons.people))]),
        const SizedBox(height: 18),
        FilledButton.icon(onPressed: _addPost, icon: const Icon(Icons.add), label: const Text('إضافة منشور جديد مباشرة')),
        const SizedBox(height: 18),
        const Text('طلبات الإعلانات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        if (widget.pending.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('لا توجد إعلانات بانتظار المراجعة.'))),
        ...List.generate(widget.pending.length, (i) => _pendingTile(i)),
        const SizedBox(height: 18),
        const Text('المستخدمون', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        ...widget.users.map((u) => Card(child: ListTile(leading: const Icon(Icons.person), title: Text(u.name), subtitle: Text('${u.email} • ${u.role}')))),
      ]),
    ));
  }

  Widget _stat(String title, String value, IconData icon) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(children: [Icon(icon, color: green), const SizedBox(height: 5), Text(value, style: const TextStyle(color: navy, fontSize: 20, fontWeight: FontWeight.w900)), Text(title, style: const TextStyle(color: Colors.black54, fontSize: 11))]));

  Widget _pendingTile(int index) {
    final car = widget.pending[index].car;
    return Card(color: Colors.white, child: ListTile(title: Text(car.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), subtitle: Text('${car.year} • ${car.city} • ${car.price}', style: const TextStyle(color: Colors.black54)), trailing: Wrap(children: [IconButton(onPressed: () { widget.onApprove(index); setState(() {}); }, icon: const Icon(Icons.check, color: green)), IconButton(onPressed: () { widget.onReject(index); setState(() {}); }, icon: const Icon(Icons.close, color: Colors.red))]));
  }

  Future<void> _addPost() async {
    final car = await showDialog<Car>(context: context, builder: (_) => const AdminPostDialog());
    if (!mounted || car == null) return;
    widget.onPost(car);
    setState(() {});
  }
}

class AdminPostDialog extends StatefulWidget {
  const AdminPostDialog({super.key});

  @override
  State<AdminPostDialog> createState() => _AdminPostDialogState();
}

class _AdminPostDialogState extends State<AdminPostDialog> {
  final name = TextEditingController();
  final year = TextEditingController(text: '2022');
  final price = TextEditingController();
  String city = 'القاهرة';
  String type = 'سيدان';

  @override
  void dispose() { name.dispose(); year.dispose(); price.dispose(); super.dispose(); }

  void submit() {
    final y = int.tryParse(year.text.trim());
    if (name.text.trim().isEmpty || price.text.trim().isEmpty || y == null) return;
    Navigator.pop(context, Car(name.text.trim(), y, price.text.trim(), city, type, seller: 'الإدارة'));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('منشور جديد من الإدارة'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم السيارة')),
        TextField(controller: year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السنة')),
        TextField(controller: price, decoration: const InputDecoration(labelText: 'السعر')),
        DropdownButtonFormField<String>(value: type, items: const ['سيدان', 'دفع رباعي', 'بيك أب'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => type = v ?? type)),
        DropdownButtonFormField<String>(value: city, items: const ['القاهرة', 'الجيزة', 'الإسكندرية'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => city = v ?? city)),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), FilledButton(onPressed: submit, child: const Text('نشر الآن'))],
    );
  }
}
