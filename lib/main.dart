import 'package:flutter/material.dart';

void main() => runApp(const BukoApp());

class BukoApp extends StatelessWidget {
  const BukoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'BUKO',
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: const Color(0xFF071A2A), colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16A34A), brightness: Brightness.dark)),
    home: const HomePage(),
  );
}

class Car {
  final String name, year, price, city, type, fuel;
  const Car(this.name, this.year, this.price, this.city, this.type, [this.fuel = 'بنزين']);
}

const seedCars = <Car>[
  Car('تويوتا هايلوكس', '2019', '85,000,000 ج.س', 'أم درمان', 'بيك أب'),
  Car('تويوتا برادو', '2018', '120,000,000 ج.س', 'بحري', 'دفع رباعي'),
  Car('هيونداي النترا', '2021', '45,000,000 ج.س', 'الخرطوم', 'سيدان'),
  Car('كيا سبورتاج', '2020', '68,000,000 ج.س', 'الخرطوم', 'دفع رباعي'),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  String query = '', selectedType = 'الكل', selectedCity = 'الكل';
  final favorites = <int>{};
  final listings = <Car>[...seedCars];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[_home(), _explore(), _sell(), _favorites(), const AccountPage()];
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'استكشاف'),
          NavigationDestination(icon: Icon(Icons.sell_outlined), selectedIcon: Icon(Icons.sell), label: 'بيع'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'المفضلة'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    ));
  }

  Widget _home() {
    final indexes = List.generate(listings.length, (i) => i).where((i) {
      final c = listings[i];
      return query.isEmpty || '${c.name} ${c.city} ${c.type}'.toLowerCase().contains(query.toLowerCase());
    }).take(4).toList();
    return ListView(padding: const EdgeInsets.all(18), children: [
      const Logo(), const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF102C40), Color(0xFF061521)])), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('السوق الأول للسيارات المستعملة في السودان', style: TextStyle(color: Colors.white70)), SizedBox(height: 12),
        Text('إبحث عن سيارتك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        Text('بكل سهولة في السودان', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF39C86A))),
      ])),
      const SizedBox(height: 14),
      TextField(onChanged: (v) => setState(() => query = v.trim()), onSubmitted: (_) => setState(() => tab = 1), decoration: InputDecoration(filled: true, fillColor: Colors.white, hintText: 'إبحث عن ماركة أو موديل أو كلمة مفتاحية...', hintStyle: const TextStyle(color: Colors.black54), prefixIcon: const Icon(Icons.search, color: Color(0xFF102030)), suffixIcon: IconButton(color: const Color(0xFF16A34A), icon: const Icon(Icons.tune), onPressed: _showFilters), border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)), style: const TextStyle(color: Colors.black87)),
      const SizedBox(height: 16), _section('البحث المتقدم'),
      Card(color: Colors.white, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: _showFilters, child: const Padding(padding: EdgeInsets.all(14), child: Row(children: [CircleAvatar(backgroundColor: Color(0xFFE8F7ED), child: Icon(Icons.tune, color: Color(0xFF16A34A))), SizedBox(width: 12), Expanded(child: Text('فلترة حسب النوع والمدينة', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))), Icon(Icons.chevron_left, color: Colors.black54)])))),
      const SizedBox(height: 16), _section('السيارات المميزة'),
      if (indexes.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('لا توجد سيارات مطابقة للبحث'))),
      ...indexes.map(_carCard), const SizedBox(height: 8),
      FilledButton.icon(onPressed: () => setState(() => tab = 1), icon: const Icon(Icons.grid_view), label: const Text('عرض كل السيارات')),
    ]);
  }

  Widget _explore() {
    final indexes = List.generate(listings.length, (i) => i).where((i) {
      final c = listings[i]; final text = '${c.name} ${c.city} ${c.type} ${c.fuel}'.toLowerCase();
      return (query.isEmpty || text.contains(query.toLowerCase())) && (selectedType == 'الكل' || c.type == selectedType) && (selectedCity == 'الكل' || c.city == selectedCity);
    }).toList();
    return ListView(padding: const EdgeInsets.all(18), children: [
      const Text('استكشاف السيارات', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 6),
      const Text('اختر السيارة المناسبة لك', style: TextStyle(color: Colors.white70)), const SizedBox(height: 16),
      Row(children: [Expanded(child: TextField(onChanged: (v) => setState(() => query = v.trim()), decoration: InputDecoration(filled: true, fillColor: Colors.white, hintText: 'بحث...', hintStyle: const TextStyle(color: Colors.black54), prefixIcon: const Icon(Icons.search, color: Colors.black54), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)), style: const TextStyle(color: Colors.black87))), const SizedBox(width: 8), IconButton.filled(onPressed: _showFilters, icon: const Icon(Icons.filter_list))]),
      const SizedBox(height: 14), Wrap(spacing: 8, children: [Chip(label: Text(selectedType)), Chip(label: Text(selectedCity)), if (query.isNotEmpty) InputChip(label: Text(query), onDeleted: () => setState(() => query = ''))]),
      const SizedBox(height: 8), Text('${indexes.length} سيارة متاحة', style: const TextStyle(color: Colors.white70)), const SizedBox(height: 8), ...indexes.map(_carCard),
    ]);
  }

  Widget _sell() => SellPage(onAdd: (car) { setState(() { listings.add(car); tab = 0; }); _snack('تم نشر إعلانك بنجاح'); });

  Widget _favorites() {
    final valid = favorites.where((i) => i >= 0 && i < listings.length).toList();
    return ListView(padding: const EdgeInsets.all(18), children: [
      const Text('المفضلة', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      const Text('السيارات التي حفظتها للرجوع إليها لاحقاً', style: TextStyle(color: Colors.white70)), const SizedBox(height: 16),
      if (valid.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(35), child: Text('لم تحفظ أي سيارة بعد'))), ...valid.map(_carCard),
    ]);
  }

  Widget _carCard(int index) {
    final car = listings[index], fav = favorites.contains(index);
    return Card(color: Colors.white, margin: const EdgeInsets.only(bottom: 10), child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsPage(car: car, favorite: fav, onFavorite: () => setState(() { if (fav) favorites.remove(index); else favorites.add(index); }))), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), leading: const CircleAvatar(backgroundColor: Color(0xFFE8F7ED), child: Icon(Icons.directions_car, color: Color(0xFF16A34A))), title: Text(car.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), subtitle: Text('${car.year} • ${car.city}\n${car.price}', style: const TextStyle(color: Colors.black54)), trailing: IconButton(onPressed: () => setState(() { if (fav) favorites.remove(index); else favorites.add(index); }), icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: const Color(0xFF16A34A))))));
  }

  Widget _section(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)));

  Future<void> _showFilters() async {
    var type = selectedType, city = selectedCity;
    await showDialog<void>(context: context, builder: (dialogContext) => Directionality(textDirection: TextDirection.rtl, child: AlertDialog(title: const Text('البحث المتقدم'), content: Column(mainAxisSize: MainAxisSize.min, children: [
      DropdownButtonFormField<String>(initialValue: type, decoration: const InputDecoration(labelText: 'نوع السيارة'), items: const ['الكل', 'سيدان', 'بيك أب', 'دفع رباعي'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => type = v ?? 'الكل'),
      const SizedBox(height: 12), DropdownButtonFormField<String>(initialValue: city, decoration: const InputDecoration(labelText: 'المدينة'), items: const ['الكل', 'الخرطوم', 'بحري', 'أم درمان'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => city = v ?? 'الكل'),
    ]), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')), FilledButton(onPressed: () { setState(() { selectedType = type; selectedCity = city; tab = 1; }); Navigator.pop(dialogContext); }, child: const Text('تطبيق'))])));
  }
  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
}

class Logo extends StatelessWidget {
  const Logo({super.key});
  @override Widget build(BuildContext context) => const Row(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(radius: 24, backgroundColor: Color(0xFF16A34A), child: Icon(Icons.directions_car, color: Colors.white)), SizedBox(width: 10), Text('BUKO', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900))]);
}

class CarDetailsPage extends StatefulWidget {
  final Car car; final bool favorite; final VoidCallback onFavorite;
  const CarDetailsPage({super.key, required this.car, required this.favorite, required this.onFavorite});
  @override State<CarDetailsPage> createState() => _CarDetailsPageState();
}
class _CarDetailsPageState extends State<CarDetailsPage> {
  late bool fav;
  @override void initState() { super.initState(); fav = widget.favorite; }
  @override Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(appBar: AppBar(title: const Text('تفاصيل السيارة')), body: ListView(padding: const EdgeInsets.all(18), children: [
    Container(height: 190, decoration: BoxDecoration(color: const Color(0xFF102C40), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.directions_car, size: 100, color: Color(0xFF39C86A))), const SizedBox(height: 18),
    Text(widget.car.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), Text(widget.car.price, style: const TextStyle(fontSize: 23, color: Color(0xFF39C86A), fontWeight: FontWeight.bold)), const SizedBox(height: 18),
    Card(color: Colors.white, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [_info('السنة', widget.car.year), _info('المدينة', widget.car.city), _info('النوع', widget.car.type), _info('الوقود', widget.car.fuel)]))), const SizedBox(height: 16),
    FilledButton.icon(onPressed: () { setState(() => fav = !fav); widget.onFavorite(); }, icon: Icon(fav ? Icons.favorite : Icons.favorite_border), label: Text(fav ? 'إزالة من المفضلة' : 'حفظ في المفضلة')), const SizedBox(height: 10),
    OutlinedButton.icon(onPressed: () => showDialog<void>(context: context, builder: (_) => const AlertDialog(title: Text('التواصل مع البائع'), content: Text('سيتم ربط الاتصال والرسائل بخدمة حقيقية عند إضافة الخادم.'))), icon: const Icon(Icons.phone), label: const Text('التواصل مع البائع')),
  ])));
  Widget _info(String title, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Expanded(child: Text(title, style: const TextStyle(color: Colors.black54))), Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold))]));
}

class SellPage extends StatefulWidget {
  final ValueChanged<Car> onAdd; const SellPage({super.key, required this.onAdd});
  @override State<SellPage> createState() => _SellPageState();
}
class _SellPageState extends State<SellPage> {
  final formKey = GlobalKey<FormState>(); final name = TextEditingController(); final year = TextEditingController(text: '2022'); final price = TextEditingController(); final city = TextEditingController(text: 'الخرطوم'); String type = 'سيدان', fuel = 'بنزين';
  @override void dispose() { name.dispose(); year.dispose(); price.dispose(); city.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [const Text('بيع سيارتك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 6), const Text('أنشئ إعلاناً جديداً في أقل من دقيقة', style: TextStyle(color: Colors.white70)), const SizedBox(height: 20), Form(key: formKey, child: Column(children: [
    _field(name, 'الماركة والموديل', Icons.directions_car), _field(year, 'سنة الصنع', Icons.calendar_today, keyboard: TextInputType.number), _field(price, 'السعر', Icons.payments_outlined), _field(city, 'المدينة', Icons.location_on_outlined),
    DropdownButtonFormField<String>(initialValue: type, decoration: const InputDecoration(labelText: 'نوع السيارة'), items: const ['سيدان', 'بيك أب', 'دفع رباعي'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => type = v ?? type)), const SizedBox(height: 12),
    DropdownButtonFormField<String>(initialValue: fuel, decoration: const InputDecoration(labelText: 'نوع الوقود'), items: const ['بنزين', 'ديزل', 'كهرباء', 'هجين'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => fuel = v ?? fuel)), const SizedBox(height: 22),
    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _publish, icon: const Icon(Icons.publish), label: const Padding(padding: EdgeInsets.all(12), child: Text('نشر الإعلان')))),
  ]))]);
  Widget _field(TextEditingController controller, String label, IconData icon, {TextInputType? keyboard}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: controller, keyboardType: keyboard, validator: (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon))));
  void _publish() { if (!formKey.currentState!.validate()) return; widget.onAdd(Car(name.text.trim(), year.text.trim(), '${price.text.trim()} ج.س', city.text.trim(), type, fuel)); name.clear(); price.clear(); }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [const Logo(), const SizedBox(height: 18), const Text('حسابي', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)), const SizedBox(height: 8), const Text('إدارة إعلاناتك ومفضلاتك وإعدادات الحساب', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)), const SizedBox(height: 25),
    _tile(context, Icons.person_outline, 'تسجيل الدخول', 'الوصول إلى حسابك وإعلاناتك', () => _login(context)), _tile(context, Icons.favorite_border, 'المفضلة', 'السيارات التي حفظتها', () => Navigator.popUntil(context, (route) => route.isFirst)), _tile(context, Icons.admin_panel_settings_outlined, 'لوحة تحكم الإدارة', 'إدارة الإعلانات والمستخدمين والإحصائيات', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()))), _tile(context, Icons.settings_outlined, 'الإعدادات', 'إشعارات وخصوصية وتفضيلات التطبيق', () => _settings(context))]);
  Widget _tile(BuildContext context, IconData icon, String title, String sub, VoidCallback tap) => Card(color: Colors.white, child: ListTile(onTap: tap, leading: CircleAvatar(backgroundColor: const Color(0xFFE8F7ED), child: Icon(icon, color: const Color(0xFF16A34A))), title: Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), subtitle: Text(sub, style: const TextStyle(color: Colors.black54)), trailing: const Icon(Icons.chevron_left, color: Colors.black54)));
  void _login(BuildContext context) => showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('تسجيل الدخول'), content: const Column(mainAxisSize: MainAxisSize.min, children: [TextField(decoration: InputDecoration(labelText: 'البريد الإلكتروني')), TextField(obscureText: true, decoration: InputDecoration(labelText: 'كلمة المرور'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), FilledButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل الدخول تجريبياً'))); }, child: const Text('دخول'))]));
  void _settings(BuildContext context) => showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('الإعدادات'), content: const Column(mainAxisSize: MainAxisSize.min, children: [SwitchListTile(value: true, onChanged: null, title: Text('إشعارات الإعلانات')), SwitchListTile(value: true, onChanged: null, title: Text('حفظ تفضيلات البحث'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('تم'))]));
}

class AdminDashboardPage extends StatefulWidget { const AdminDashboardPage({super.key}); @override State<AdminDashboardPage> createState() => _AdminDashboardPageState(); }
class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int pending = 7, active = 124, users = 86, reports = 3;
  @override Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(backgroundColor: const Color(0xFFF4F7F8), appBar: AppBar(title: const Text('لوحة تحكم الإدارة'), backgroundColor: const Color(0xFF071A2A), foregroundColor: Colors.white), body: ListView(padding: const EdgeInsets.all(16), children: [
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF071A2A), borderRadius: BorderRadius.circular(20)), child: const Row(children: [CircleAvatar(radius: 27, backgroundColor: Color(0xFF16A34A), child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 30)), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('مرحباً، مدير BUKO', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('مراقبة المنصة وإدارة الإعلانات', style: TextStyle(color: Colors.white70))]))])), const SizedBox(height: 18),
    GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.45, children: [_stat('إعلانات نشطة', active, Icons.directions_car, () => _snack('لديك $active إعلاناً نشطاً')), _stat('بانتظار المراجعة', pending, Icons.pending_actions, _review), _stat('المستخدمون', users, Icons.people_alt_outlined, () => _snack('إجمالي المستخدمين: $users')), _stat('بلاغات', reports, Icons.flag_outlined, _reports)]), const SizedBox(height: 20),
    const Text('إجراءات سريعة', style: TextStyle(color: Colors.black87, fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 10), _action('مراجعة الإعلانات الجديدة', Icons.fact_check_outlined, _review), _action('إدارة المستخدمين', Icons.manage_accounts_outlined, _users), _action('البلاغات والشكاوى', Icons.warning_amber_outlined, _reports), _action('إعدادات المنصة', Icons.settings_outlined, _platform), const SizedBox(height: 14), const Text('ملاحظة: البيانات الحالية محلية للنسخة التجريبية. ربط قاعدة البيانات والمصادقة والخادم هو المرحلة التالية.', style: TextStyle(color: Colors.black54)),
  ])));
  Widget _stat(String title, int value, IconData icon, VoidCallback tap) => Card(color: Colors.white, child: InkWell(onTap: tap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: const Color(0xFF16A34A), size: 30), const Spacer(), Text('$value', style: const TextStyle(color: Color(0xFF071A2A), fontSize: 42)), Text(title, style: const TextStyle(color: Colors.black54, fontSize: 15))]))));
  Widget _action(String title, IconData icon, VoidCallback tap) => Card(color: Colors.white, margin: const EdgeInsets.only(bottom: 10), child: ListTile(onTap: tap, leading: Icon(icon, color: const Color(0xFF16A34A), size: 30), title: Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), trailing: const Icon(Icons.chevron_left, color: Colors.black38)));
  void _review() => setState(() { active += pending; pending = 0; _snack('تمت مراجعة الإعلانات المعلقة'); });
  void _users() => showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('إدارة المستخدمين'), content: Text('يوجد حالياً $users مستخدماً مسجلاً في البيانات المحلية.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))]));
  void _reports() => showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('البلاغات والشكاوى'), content: Text('يوجد $reports بلاغات تحتاج إلى مراجعة.'), actions: [TextButton(onPressed: () { setState(() => reports = 0); Navigator.pop(context); _snack('تمت معالجة البلاغات'); }, child: const Text('معالجة الكل')), TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))]));
  void _platform() => showDialog<void>(context: context, builder: (_) => const AlertDialog(title: Text('إعدادات المنصة'), content: Text('من هنا سيتم التحكم في إعدادات السوق والإعلانات والإشعارات عند ربط الخادم.')));
  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
}
