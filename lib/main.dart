import 'package:flutter/material.dart';

void main() => runApp(const BukoApp());

class Car {
  final String name;
  final int year;
  final String price;
  final String city;
  final String type;
  const Car(this.name, this.year, this.price, this.city, this.type);
}

const carsSeed = <Car>[
  Car('تويوتا هايلوكس', 2019, '85,000,000 ج.س', 'أم درمان', 'بيك أب'),
  Car('تويوتا برادو', 2018, '120,000,000 ج.س', 'بحري', 'دفع رباعي'),
  Car('هيونداي النترا', 2021, '45,000,000 ج.س', 'الخرطوم', 'سيدان'),
  Car('كيا سبورتاج', 2020, '68,000,000 ج.س', 'الخرطوم', 'دفع رباعي'),
];

class BukoApp extends StatelessWidget {
  const BukoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BUKO',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16A34A), brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF071A2A),
      ),
      home: const BukoHome(),
    );
  }
}

class BukoHome extends StatefulWidget {
  const BukoHome({super.key});
  @override
  State<BukoHome> createState() => _BukoHomeState();
}

class _BukoHomeState extends State<BukoHome> {
  int tab = 0;
  String search = '';
  String type = 'الكل';
  String city = 'الكل';
  final cars = <Car>[...carsSeed];
  final favorites = <int>{};

  List<int> get filtered {
    final q = search.trim().toLowerCase();
    return List<int>.generate(cars.length, (i) => i).where((i) {
      final c = cars[i];
      final text = '${c.name} ${c.city} ${c.type}'.toLowerCase();
      return (q.isEmpty || text.contains(q)) && (type == 'الكل' || c.type == type) && (city == 'الكل' || c.city == city);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[_home(), _explore(), _sell(), _favorites(), const AccountPage()];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(child: pages[tab]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (value) => setState(() => tab = value),
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

  Widget _home() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const _Logo(),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF102C40), Color(0xFF061521)])),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('السوق الأول للسيارات المستعملة في السودان', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 10),
            Text('إبحث عن سيارتك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            Text('بكل سهولة في السودان', style: TextStyle(fontSize: 21, color: Color(0xFF39C86A), fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(height: 14),
        _searchBox(),
        const SizedBox(height: 18),
        const Text('البحث المتقدم', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        Card(color: Colors.white, child: ListTile(onTap: _filters, leading: const Icon(Icons.tune, color: Color(0xFF16A34A)), title: const Text('فلترة حسب النوع والمدينة', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), trailing: const Icon(Icons.chevron_left, color: Colors.black54))),
        const SizedBox(height: 16),
        const Text('السيارات المميزة', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...filtered.take(4).map(_card),
        FilledButton.icon(onPressed: () => setState(() => tab = 1), icon: const Icon(Icons.grid_view), label: const Text('عرض كل السيارات')),
      ],
    );
  }

  Widget _searchBox() => TextField(
    onChanged: (v) => setState(() => search = v),
    onSubmitted: (_) => setState(() => tab = 1),
    style: const TextStyle(color: Colors.black87),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: 'إبحث عن ماركة أو موديل...',
      hintStyle: const TextStyle(color: Colors.black54),
      prefixIcon: const Icon(Icons.search, color: Colors.black54),
      suffixIcon: IconButton(onPressed: _filters, icon: const Icon(Icons.tune, color: Color(0xFF16A34A))),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
    ),
  );

  Widget _explore() => ListView(padding: const EdgeInsets.all(18), children: [
    const Text('استكشاف السيارات', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    _searchBox(),
    const SizedBox(height: 12),
    Row(children: [Chip(label: Text(type)), const SizedBox(width: 8), Chip(label: Text(city)), const Spacer(), IconButton.filled(onPressed: _filters, icon: const Icon(Icons.filter_list))]),
    const SizedBox(height: 8),
    Text('${filtered.length} سيارة متاحة', style: const TextStyle(color: Colors.white70)),
    const SizedBox(height: 8),
    ...filtered.map(_card),
  ]);

  Widget _sell() => SellPage(onPublish: (car) {
    setState(() {
      cars.add(car);
      tab = 0;
    });
    _message('تم نشر الإعلان داخل التطبيق');
  });

  Widget _favorites() {
    final ids = favorites.where((i) => i < cars.length).toList();
    return ListView(padding: const EdgeInsets.all(18), children: [
      const Text('المفضلة', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('السيارات التي حفظتها', style: TextStyle(color: Colors.white70)),
      const SizedBox(height: 18),
      if (ids.isEmpty) const Center(child: Text('لم تحفظ أي سيارة بعد')),
      ...ids.map(_card),
    ]);
  }

  Widget _card(int index) {
    final car = cars[index];
    final isFav = favorites.contains(index);
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarPage(car: car, favorite: isFav, onFavorite: () => setState(() {
          if (isFav) {
            favorites.remove(index);
          } else {
            favorites.add(index);
          }
        }))),
        leading: const CircleAvatar(backgroundColor: Color(0xFFE8F7ED), child: Icon(Icons.directions_car, color: Color(0xFF16A34A))),
        title: Text(car.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        subtitle: Text('${car.year} • ${car.city}\n${car.price}', style: const TextStyle(color: Colors.black54)),
        trailing: IconButton(onPressed: () => setState(() {
          if (isFav) {
            favorites.remove(index);
          } else {
            favorites.add(index);
          }
        }), icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: const Color(0xFF16A34A))),
      ),
    );
  }

  Future<void> _filters() async {
    var newType = type;
    var newCity = city;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('البحث المتقدم'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(value: newType, decoration: const InputDecoration(labelText: 'نوع السيارة'), items: const ['الكل', 'سيدان', 'بيك أب', 'دفع رباعي'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => newType = v ?? 'الكل'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: newCity, decoration: const InputDecoration(labelText: 'المدينة'), items: const ['الكل', 'الخرطوم', 'بحري', 'أم درمان'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => newCity = v ?? 'الكل'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(onPressed: () {
            setState(() {
              type = newType;
              city = newCity;
              tab = 1;
            });
            Navigator.pop(dialogContext);
          }, child: const Text('تطبيق')),
        ],
      ),
    );
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
}

class _Logo extends StatelessWidget {
  const _Logo();
  @override
  Widget build(BuildContext context) => const Row(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(radius: 24, backgroundColor: Color(0xFF16A34A), child: Icon(Icons.directions_car, color: Colors.white)), SizedBox(width: 10), Text('BUKO', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900))]);
}

class CarPage extends StatefulWidget {
  final Car car;
  final bool favorite;
  final VoidCallback onFavorite;
  const CarPage({super.key, required this.car, required this.favorite, required this.onFavorite});
  @override
  State<CarPage> createState() => _CarPageState();
}

class _CarPageState extends State<CarPage> {
  late bool favorite;
  @override
  void initState() {
    super.initState();
    favorite = widget.favorite;
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تفاصيل السيارة')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Container(height: 190, decoration: BoxDecoration(color: const Color(0xFF102C40), borderRadius: BorderRadius.circular(22)), child: const Icon(Icons.directions_car, size: 100, color: Color(0xFF39C86A))),
      const SizedBox(height: 18),
      Text(widget.car.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      Text(widget.car.price, style: const TextStyle(fontSize: 23, color: Color(0xFF39C86A), fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      Card(color: Colors.white, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        _row('السنة', '${widget.car.year}'), _row('المدينة', widget.car.city), _row('النوع', widget.car.type),
      ]))),
      const SizedBox(height: 14),
      FilledButton.icon(onPressed: () {
        setState(() => favorite = !favorite);
        widget.onFavorite();
      }, icon: Icon(favorite ? Icons.favorite : Icons.favorite_border), label: Text(favorite ? 'إزالة من المفضلة' : 'حفظ في المفضلة')),
      OutlinedButton.icon(onPressed: () => showDialog<void>(context: context, builder: (_) => const AlertDialog(title: Text('التواصل مع البائع'), content: Text('سيتم ربط الاتصال والرسائل بخدمة حقيقية في مرحلة الخادم.'))), icon: const Icon(Icons.phone), label: const Text('التواصل مع البائع')),
    ]),
  );
  Widget _row(String a, String b) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Expanded(child: Text(a, style: const TextStyle(color: Colors.black54))), Text(b, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))]));
}

class SellPage extends StatefulWidget {
  final ValueChanged<Car> onPublish;
  const SellPage({super.key, required this.onPublish});
  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final keyForm = GlobalKey<FormState>();
  final name = TextEditingController();
  final year = TextEditingController(text: '2022');
  final price = TextEditingController();
  final city = TextEditingController(text: 'الخرطوم');
  String type = 'سيدان';

  @override
  void dispose() {
    name.dispose();
    year.dispose();
    price.dispose();
    city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    const Text('بيع سيارتك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    const SizedBox(height: 6),
    const Text('أنشئ إعلاناً جديداً', style: TextStyle(color: Colors.white70)),
    const SizedBox(height: 20),
    Form(key: keyForm, child: Column(children: [
      _field(name, 'الماركة والموديل'),
      _field(year, 'سنة الصنع', number: true),
      _field(price, 'السعر'),
      _field(city, 'المدينة'),
      DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'نوع السيارة'), items: const ['سيدان', 'بيك أب', 'دفع رباعي'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => type = v ?? type)),
      const SizedBox(height: 22),
      SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _publish, icon: const Icon(Icons.publish), label: const Padding(padding: EdgeInsets.all(12), child: Text('نشر الإعلان')))),
    ])),
  ]);

  Widget _field(TextEditingController controller, String label, {bool number = false}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: controller, keyboardType: number ? TextInputType.number : TextInputType.text, validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())));

  void _publish() {
    if (keyForm.currentState?.validate() != true) {
      return;
    }
    widget.onPublish(Car(name.text.trim(), int.tryParse(year.text.trim()) ?? 2022, '${price.text.trim()} ج.س', city.text.trim(), type));
    name.clear();
    price.clear();
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    const _Logo(),
    const SizedBox(height: 18),
    const Text('حسابي', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    const SizedBox(height: 18),
    _item(context, Icons.login, 'تسجيل الدخول', 'الدخول إلى حسابك', _login),
    _item(context, Icons.admin_panel_settings_outlined, 'لوحة تحكم الإدارة', 'إدارة المنصة', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPage()))),
    _item(context, Icons.settings_outlined, 'الإعدادات', 'تفضيلات التطبيق', _settings),
  ]);

  Widget _item(BuildContext context, IconData icon, String title, String sub, VoidCallback onTap) => Card(color: Colors.white, child: ListTile(onTap: onTap, leading: Icon(icon, color: const Color(0xFF16A34A)), title: Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), subtitle: Text(sub, style: const TextStyle(color: Colors.black54)), trailing: const Icon(Icons.chevron_left, color: Colors.black45)));

  void _login(BuildContext context) => showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('تسجيل الدخول'), content: const Column(mainAxisSize: MainAxisSize.min, children: [TextField(decoration: InputDecoration(labelText: 'البريد الإلكتروني')), TextField(obscureText: true, decoration: InputDecoration(labelText: 'كلمة المرور'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), FilledButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل الدخول تجريبياً'))); }, child: const Text('دخول'))]));

  void _settings(BuildContext context) => showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('الإعدادات'), content: const Text('إعدادات الإشعارات والخصوصية والتفضيلات ستكون قابلة للحفظ بعد ربط قاعدة البيانات.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('تم'))]));
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int pending = 7;
  int reports = 3;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF4F7F8),
    appBar: AppBar(title: const Text('لوحة تحكم الإدارة'), backgroundColor: const Color(0xFF071A2A), foregroundColor: Colors.white),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      _stat('إعلانات نشطة', 124, Icons.directions_car, () => _msg('124 إعلان نشط')),
      _stat('بانتظار المراجعة', pending, Icons.pending_actions, () => setState(() { pending = 0; _msg('تمت مراجعة الإعلانات'); })),
      _stat('المستخدمون', 86, Icons.people, () => _msg('86 مستخدماً')),
      _stat('البلاغات', reports, Icons.flag, () => setState(() { reports = 0; _msg('تمت معالجة البلاغات'); })),
      const SizedBox(height: 10),
      Card(color: Colors.white, child: ListTile(onTap: () => _msg('تم فتح إدارة الإعلانات'), leading: const Icon(Icons.fact_check, color: Color(0xFF16A34A)), title: const Text('مراجعة الإعلانات', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)))),
      Card(color: Colors.white, child: ListTile(onTap: () => _msg('تم فتح إدارة المستخدمين'), leading: const Icon(Icons.manage_accounts, color: Color(0xFF16A34A)), title: const Text('إدارة المستخدمين', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)))),
    ]),
  );

  Widget _stat(String title, int value, IconData icon, VoidCallback onTap) => Card(color: Colors.white, child: ListTile(onTap: onTap, leading: Icon(icon, color: const Color(0xFF16A34A), size: 32), title: Text('$value', style: const TextStyle(color: Colors.black87, fontSize: 28, fontWeight: FontWeight.bold)), subtitle: Text(title, style: const TextStyle(color: Colors.black54)), trailing: const Icon(Icons.chevron_left, color: Colors.black45)));
  void _msg(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
}
