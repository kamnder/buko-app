import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final List<String> images;
  Car(this.name, this.year, this.price, this.city, this.type,
      {this.seller = 'BUKO', this.images = const []});
}

class PurchaseRequest {
  final User buyer;
  final Car car;
  PurchaseRequest(this.buyer, this.car);
}

enum BukoTheme { midnight, emerald, royal }

ThemeData bukoTheme(BukoTheme theme) {
  final seed = theme == BukoTheme.royal ? blue : green;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: navy,
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    cardTheme: const CardThemeData(color: Color(0xFF102434)),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: Colors.black54),
      hintStyle: TextStyle(color: Colors.black45),
      prefixIconColor: Colors.black54,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

void main() => runApp(const BukoApp());

class BukoApp extends StatefulWidget {
  const BukoApp({super.key});
  @override
  State<BukoApp> createState() => _BukoAppState();
}

class _BukoAppState extends State<BukoApp> {
  BukoTheme theme = BukoTheme.midnight;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BUKO',
      theme: bukoTheme(theme),
      home: AuthScreen(onTheme: (value) => setState(() => theme = value)),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final ValueChanged<BukoTheme> onTheme;
  const AuthScreen({super.key, required this.onTheme});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
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
  User? user;
  int tab = 0;

  void login(User value) => setState(() => user = value);
  void logout() => setState(() {
        user = null;
        tab = 0;
      });

  void openAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminPage(
          users: users,
          cars: cars,
          pending: pending,
          requests: requests,
          onApprove: (i) => setState(() => cars.insert(0, pending.removeAt(i))),
          onReject: (i) => setState(() => pending.removeAt(i)),
          onPost: (car) => setState(() => cars.insert(0, car)),
        ),
      ),
    );
  }

  void buy(Car car) {
    if (user == null) return;
    requests.add(PurchaseRequest(user!, car));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال طلب الشراء للإدارة')),
    );
  }

  void details(Car car) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => DetailsPage(car: car, onBuy: () => buy(car)),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget page() {
    switch (tab) {
      case 1:
        return ExplorePage(cars: cars, onTap: details);
      case 2:
        return SellPage(
          onSubmit: (car) {
            setState(() => pending.add(car));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إرسال إعلانك للمراجعة')),
            );
          },
        );
      case 3:
        return const Center(
          child: Text('المفضلة\nاحفظ سياراتك المفضلة هنا', textAlign: TextAlign.center),
        );
      case 4:
        return AccountPage(user: user!, onLogout: logout, onTheme: widget.onTheme);
      default:
        return HomePage(cars: cars, onTap: details);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return AuthForm(users: users, onLogin: login, onAdmin: openAdmin);
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: KeyedSubtree(key: ValueKey(tab), child: page()),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (value) => setState(() => tab = value),
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

class AuthForm extends StatefulWidget {
  final List<User> users;
  final ValueChanged<User> onLogin;
  final VoidCallback onAdmin;
  const AuthForm({super.key, required this.users, required this.onLogin, required this.onAdmin});
  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool loginMode = true;
  String role = 'buyer';
  String error = '';
  final name = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  String normalize(String value) {
    var p = value.trim().replaceAll(' ', '');
    if (p.startsWith('00249')) p = '+${p.substring(2)}';
    if (p.startsWith('249')) p = '+$p';
    return p;
  }

  bool validSudanPhone(String value) => RegExp(r'^\+249\d{9}$').hasMatch(value);

  void submit() {
    if (loginMode && password.text.trim() == adminCode) {
      widget.onAdmin();
      return;
    }
    final p = normalize(phone.text);
    if (!validSudanPhone(p)) {
      setState(() => error = 'استخدم رقم السودان فقط: +249XXXXXXXXX');
      return;
    }
    if (password.text.length < 6) {
      setState(() => error = 'كلمة المرور 6 أحرف على الأقل');
      return;
    }
    if (loginMode) {
      for (final u in widget.users) {
        if (u.phone == p && u.password == password.text && u.role == role) {
          widget.onLogin(u);
          return;
        }
      }
      setState(() => error = 'بيانات الدخول غير صحيحة');
      return;
    }
    if (name.text.trim().isEmpty) {
      setState(() => error = 'اكتب الاسم الكامل');
      return;
    }
    if (widget.users.any((u) => u.phone == p)) {
      setState(() => error = 'رقم الهاتف مسجل مسبقًا');
      return;
    }
    final value = User(name.text.trim(), p, password.text, role);
    widget.users.add(value);
    widget.onLogin(value);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(top: -90, left: -80, child: _orb(green, 250)),
            Positioned(bottom: -120, right: -90, child: _orb(blue, 290)),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 470),
                    child: Column(
                      children: [
                        _logo(),
                        const SizedBox(height: 28),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: _modeButton('دخول', loginMode)),
                                    Expanded(child: _modeButton('حساب جديد', !loginMode)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                if (!loginMode)
                                  TextField(
                                    controller: name,
                                    decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline)),
                                  ),
                                if (!loginMode) const SizedBox(height: 12),
                                TextField(
                                  controller: phone,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(labelText: 'رقم الهاتف السوداني', hintText: '+249XXXXXXXXX', prefixIcon: Icon(Icons.phone_iphone)),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: password,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'كلمة المرور',
                                    hintText: loginMode ? 'كود الإدارة يُكتب هنا للدخول كأدمن' : 'أدخل كلمة مرور حسابك',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SegmentedButton<String>(
                                  segments: const [
                                    ButtonSegment(value: 'buyer', label: Text('مشتري'), icon: Icon(Icons.shopping_bag_outlined)),
                                    ButtonSegment(value: 'seller', label: Text('بائع'), icon: Icon(Icons.storefront_outlined)),
                                  ],
                                  selected: {role},
                                  onSelectionChanged: (value) => setState(() => role = value.first),
                                ),
                                if (error.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(error, style: const TextStyle(color: Colors.redAccent)),
                                ],
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: FilledButton.icon(
                                    onPressed: submit,
                                    icon: Icon(loginMode ? Icons.login : Icons.person_add_alt_1),
                                    label: Text(loginMode ? 'دخول إلى BUKO' : 'إنشاء الحساب'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('BUKO • منصة سيارات عصرية', style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(String text, bool active) {
    return InkWell(
      onTap: () => setState(() {
        loginMode = text == 'دخول';
        error = '';
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: active ? green : Colors.transparent, borderRadius: BorderRadius.circular(14)),
        child: Center(child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _logo() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: green.withAlpha(60), blurRadius: 35, spreadRadius: 4)]),
          child: const Center(child: Text('B', style: TextStyle(fontSize: 62, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(height: 12),
        const Text('BUKO', style: TextStyle(fontSize: 43, fontWeight: FontWeight.w900, letterSpacing: 5)),
        const Text('حبابك عشرة', style: TextStyle(color: green, fontSize: 17, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _orb(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withAlpha(22), boxShadow: [BoxShadow(color: color.withAlpha(30), blurRadius: 90, spreadRadius: 20)]),
      );
}

class HomePage extends StatelessWidget {
  final List<Car> cars;
  final ValueChanged<Car> onTap;
  const HomePage({super.key, required this.cars, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Row(children: [Icon(Icons.auto_awesome, color: yellow), SizedBox(width: 8), Text('BUKO', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900))]),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF123D38), navy])),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('اكتشف بثقة', style: TextStyle(color: green, fontWeight: FontWeight.bold)), SizedBox(height: 7), Text('سيارتك القادمة\nتبدأ من هنا', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), SizedBox(height: 8), Text('تصفح • قارن • اطلب', style: TextStyle(color: Colors.white70))]),
        ),
        const SizedBox(height: 15),
        const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث عن سيارة أو موديل', suffixIcon: Icon(Icons.tune))),
        const SizedBox(height: 22),
        const Text('سيارات مميزة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        SizedBox(height: 245, child: ListView(scrollDirection: Axis.horizontal, children: cars.map((car) => CarTile(car: car, onTap: () => onTap(car))).toList())),
        const SizedBox(height: 18),
        const Text('الأحدث', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        ...cars.map((car) => CarList(car: car, onTap: () => onTap(car))),
      ],
    );
  }
}

class ExplorePage extends StatelessWidget {
  final List<Car> cars;
  final ValueChanged<Car> onTap;
  const ExplorePage({super.key, required this.cars, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('استكشاف', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ابحث ثم صفِّ النتائج')),
        const SizedBox(height: 14),
        const Wrap(spacing: 8, children: [Chip(label: Text('الأحدث')), Chip(label: Text('السعر')), Chip(label: Text('سيدان')), Chip(label: Text('دفع رباعي'))]),
        const SizedBox(height: 10),
        ...cars.map((car) => CarList(car: car, onTap: () => onTap(car))),
      ],
    );
  }
}

class CarTile extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;
  const CarTile({super.key, required this.car, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: CarImage(images: car.images)),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(car.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 16)),
              Text('${car.year} • ${car.city}', style: const TextStyle(color: Colors.black54)),
              Text(car.price, style: const TextStyle(color: blue, fontWeight: FontWeight.w900, fontSize: 16)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class CarList extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;
  const CarList({super.key, required this.car, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        onTap: onTap,
        leading: SizedBox(width: 65, height: 55, child: ClipRRect(borderRadius: BorderRadius.circular(12), child: CarImage(images: car.images))),
        title: Text(car.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        subtitle: Text('${car.year} • ${car.city} • ${car.price}', style: const TextStyle(color: Colors.black54)),
        trailing: const Icon(Icons.chevron_left, color: Colors.black54),
      ),
    );
  }
}

class CarImage extends StatelessWidget {
  final List<String> images;
  const CarImage({super.key, required this.images});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE8EEF2), Color(0xFFD8E4EA)])),
      child: images.isEmpty
          ? const Center(child: Icon(Icons.directions_car_filled, size: 72, color: navy))
          : Image.file(File(images.first), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
    );
  }
}

class DetailsPage extends StatefulWidget {
  final Car car;
  final VoidCallback onBuy;
  const DetailsPage({super.key, required this.car, required this.onBuy});
  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final images = widget.car.images;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل السيارة')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              height: 280,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: images.isEmpty
                    ? const CarImage(images: [])
                    : PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (value) => setState(() => index = value),
                        itemBuilder: (_, i) => Image.file(File(images[i]), fit: BoxFit.cover),
                      ),
              ),
            ),
            if (images.length > 1) Padding(padding: const EdgeInsets.only(top: 8), child: Text('${index + 1} / ${images.length}', textAlign: TextAlign.center)),
            const SizedBox(height: 18),
            Text(widget.car.name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            Text(widget.car.price, style: const TextStyle(fontSize: 25, color: green, fontWeight: FontWeight.w900)),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _row('السنة', '${widget.car.year}'),
                  _row('المدينة', widget.car.city),
                  _row('النوع', widget.car.type),
                  _row('البائع', widget.car.seller),
                ]),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(height: 54, child: FilledButton.icon(onPressed: widget.onBuy, icon: const Icon(Icons.shopping_cart_checkout), label: const Text('طلب شراء السيارة'))),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [Expanded(child: Text(label, style: const TextStyle(color: Colors.black54))), Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))]),
      );
}

class SellPage extends StatefulWidget {
  final ValueChanged<Car> onSubmit;
  const SellPage({super.key, required this.onSubmit});
  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final name = TextEditingController();
  final year = TextEditingController();
  final price = TextEditingController();
  final photos = <String>[];
  final picker = ImagePicker();
  String city = 'الخرطوم';
  String type = 'سيدان';

  @override
  void dispose() {
    name.dispose();
    year.dispose();
    price.dispose();
    super.dispose();
  }

  Future<void> pick() async {
    final selected = await picker.pickMultiImage(imageQuality: 82, maxWidth: 1800);
    if (selected.isNotEmpty) setState(() => photos.addAll(selected.map((x) => x.path)));
  }

  void submit() {
    final y = int.tryParse(year.text);
    if (name.text.trim().isEmpty || price.text.trim().isEmpty || y == null || photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أضف بيانات السيارة وصورة واحدة على الأقل')));
      return;
    }
    widget.onSubmit(Car(name.text.trim(), y, price.text.trim(), city, type, seller: 'بائع', images: List<String>.from(photos)));
    name.clear();
    year.clear();
    price.clear();
    setState(() => photos.clear());
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('بيع سيارتك', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('أضف صورًا واضحة وبيانات السيارة ليصل إعلانك للمشترين.', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: pick,
          child: Container(
            height: 170,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: green.withAlpha(100)), gradient: const LinearGradient(colors: [Color(0xFF123D38), Color(0xFF0C2430)])),
            child: photos.isEmpty
                ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, size: 48, color: green), SizedBox(height: 8), Text('أضف صور السيارة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text('يمكنك اختيار عدة صور', style: TextStyle(color: Colors.white60))])
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    itemBuilder: (_, i) => Stack(children: [
                      Container(width: 150, margin: const EdgeInsets.all(8), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(photos[i]), fit: BoxFit.cover))),
                      Positioned(top: 10, right: 10, child: CircleAvatar(radius: 14, backgroundColor: Colors.black87, child: IconButton(padding: EdgeInsets.zero, onPressed: () => setState(() => photos.removeAt(i)), icon: const Icon(Icons.close, size: 16)))),
                    ]),
                  ),
          ),
        ),
        const SizedBox(height: 18),
        TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم السيارة', prefixIcon: Icon(Icons.directions_car))),
        const SizedBox(height: 10),
        TextField(controller: year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السنة', prefixIcon: Icon(Icons.calendar_today))),
        const SizedBox(height: 10),
        TextField(controller: price, decoration: const InputDecoration(labelText: 'السعر', prefixIcon: Icon(Icons.payments_outlined))),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: type,
          decoration: const InputDecoration(labelText: 'النوع'),
          items: const ['سيدان', 'دفع رباعي', 'بيك أب'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
          onChanged: (value) => setState(() => type = value ?? type),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: city,
          decoration: const InputDecoration(labelText: 'المدينة'),
          items: const ['الخرطوم', 'أم درمان', 'بحري', 'بورتسودان'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
          onChanged: (value) => setState(() => city = value ?? city),
        ),
        const SizedBox(height: 18),
        SizedBox(height: 52, child: FilledButton.icon(onPressed: submit, icon: const Icon(Icons.rocket_launch), label: const Text('إرسال الإعلان للمراجعة'))),
      ],
    );
  }
}

class AccountPage extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;
  final ValueChanged<BukoTheme> onTheme;
  const AccountPage({super.key, required this.user, required this.onLogout, required this.onTheme});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('حسابي', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(user.name), subtitle: Text('${user.phone} • ${user.role == 'seller' ? 'بائع' : 'مشتري'}'))),
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('الثيمات'),
          onTap: () async {
            final selected = await showDialog<BukoTheme>(
              context: context,
              builder: (dialogContext) => SimpleDialog(
                title: const Text('اختيار الثيم'),
                children: [
                  SimpleDialogOption(onPressed: () => Navigator.pop(dialogContext, BukoTheme.midnight), child: const Text('Midnight')),
                  SimpleDialogOption(onPressed: () => Navigator.pop(dialogContext, BukoTheme.emerald), child: const Text('Emerald')),
                  SimpleDialogOption(onPressed: () => Navigator.pop(dialogContext, BukoTheme.royal), child: const Text('Royal')),
                ],
              ),
            );
            if (selected != null) onTheme(selected);
          },
        ),
        ListTile(leading: const Icon(Icons.logout), title: const Text('تسجيل الخروج'), onTap: onLogout),
      ],
    );
  }
}

class AdminPage extends StatefulWidget {
  final List<User> users;
  final List<Car> cars;
  final List<Car> pending;
  final List<PurchaseRequest> requests;
  final ValueChanged<int> onApprove;
  final ValueChanged<int> onReject;
  final ValueChanged<Car> onPost;
  const AdminPage({super.key, required this.users, required this.cars, required this.pending, required this.requests, required this.onApprove, required this.onReject, required this.onPost});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('BUKO ADMIN'), actions: [IconButton(onPressed: () => setState(() {}), icon: const Icon(Icons.refresh))]),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(child: ListTile(leading: const Icon(Icons.dashboard, color: green), title: const Text('لوحة التحكم'), subtitle: Text('${widget.users.length} مستخدم • ${widget.cars.length} سيارة • ${widget.pending.length} معلقة • ${widget.requests.length} طلب شراء'))),
            FilledButton.icon(onPressed: post, icon: const Icon(Icons.add_business), label: const Text('إضافة منشور مباشر')),
            const SizedBox(height: 20),
            const Text('المستخدمون', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            ...widget.users.map((u) => Card(color: Colors.white, child: ListTile(leading: const Icon(Icons.person, color: blue), title: Text(u.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), subtitle: Text('${u.phone} • ${u.role}', style: const TextStyle(color: Colors.black54)))),
            const SizedBox(height: 18),
            const Text('الإعلانات قيد المراجعة', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            if (widget.pending.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('لا توجد إعلانات معلقة', style: TextStyle(color: Colors.white60))),
            ...List.generate(widget.pending.length, (i) {
              final car = widget.pending[i];
              return Card(
                color: Colors.white,
                child: ListTile(
                  leading: SizedBox(width: 55, height: 55, child: CarImage(images: car.images)),
                  title: Text(car.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  subtitle: Text('${car.year} • ${car.city} • ${car.price}', style: const TextStyle(color: Colors.black54)),
                  trailing: Wrap(children: [
                    IconButton(onPressed: () { widget.onApprove(i); setState(() {}); }, icon: const Icon(Icons.check_circle, color: green)),
                    IconButton(onPressed: () { widget.onReject(i); setState(() {}); }, icon: const Icon(Icons.cancel, color: Colors.red)),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 18),
            const Text('طلبات الشراء', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            ...widget.requests.map((request) => Card(child: ListTile(leading: const Icon(Icons.shopping_cart, color: yellow), title: Text(request.car.name), subtitle: Text('${request.buyer.name} • ${request.buyer.phone}')))),
          ],
        ),
      ),
    );
  }

  Future<void> post() async {
    final car = await showDialog<Car>(context: context, builder: (_) => const AdminPostDialog());
    if (car != null) {
      widget.onPost(car);
      setState(() {});
    }
  }
}

class AdminPostDialog extends StatefulWidget {
  const AdminPostDialog({super.key});
  @override
  State<AdminPostDialog> createState() => _AdminPostDialogState();
}

class _AdminPostDialogState extends State<AdminPostDialog> {
  final name = TextEditingController();
  final year = TextEditingController();
  final price = TextEditingController();
  final photos = <String>[];
  final picker = ImagePicker();
  String city = 'الخرطوم';
  String type = 'سيدان';

  @override
  void dispose() {
    name.dispose();
    year.dispose();
    price.dispose();
    super.dispose();
  }

  Future<void> pick() async {
    final selected = await picker.pickMultiImage(imageQuality: 82, maxWidth: 1800);
    if (selected.isNotEmpty) setState(() => photos.addAll(selected.map((x) => x.path)));
  }

  void submit() {
    final y = int.tryParse(year.text);
    if (name.text.trim().isEmpty || price.text.trim().isEmpty || y == null) return;
    Navigator.pop(context, Car(name.text.trim(), y, price.text.trim(), city, type, images: List<String>.from(photos)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('منشور احترافي'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          GestureDetector(
            onTap: pick,
            child: SizedBox(height: 120, width: double.infinity, child: photos.isEmpty ? const Icon(Icons.add_a_photo, size: 45) : Image.file(File(photos.first), fit: BoxFit.cover)),
          ),
          const SizedBox(height: 10),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم السيارة')),
          const SizedBox(height: 8),
          TextField(controller: year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السنة')),
          const SizedBox(height: 8),
          TextField(controller: price, decoration: const InputDecoration(labelText: 'السعر')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(initialValue: type, items: const ['سيدان', 'دفع رباعي', 'بيك أب'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (value) => setState(() => type = value ?? type)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(initialValue: city, items: const ['الخرطوم', 'أم درمان', 'بحري', 'بورتسودان'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (value) => setState(() => city = value ?? city)),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(onPressed: submit, child: const Text('نشر')),
      ],
    );
  }
}
