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

const seedCars = <Car>[
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A34A),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF071A2A),
      ),
      home: const HomePage(),
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
  final cars = <Car>[...seedCars];
  final favorites = <int>{};

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
      _homePage(),
      _explorePage(),
      SellPage(onPublish: _publishCar),
      _favoritesPage(),
      AccountPage(onAdmin: _openAdmin),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(child: pages[tab]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (value) => setState(() => tab = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.search), selectedIcon: Icon(Icons.search), label: 'استكشاف'),
            NavigationDestination(icon: Icon(Icons.sell_outlined), selectedIcon: Icon(Icons.sell), label: 'بيع'),
            NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'المفضلة'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }

  Widget _homePage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const LogoHeader(),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [Color(0xFF102C40), Color(0xFF061521)]),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('السوق الأول للسيارات المستعملة في السودان', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 10),
              Text('إبحث عن سيارتك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              Text('بكل سهولة في السودان', style: TextStyle(fontSize: 21, color: Color(0xFF39C86A), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _searchField(),
        const SizedBox(height: 18),
        const Text('البحث المتقدم', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        Card(
          color: Colors.white,
          child: ListTile(
            onTap: _showFilters,
            leading: const Icon(Icons.tune, color: Color(0xFF16A34A)),
            title: const Text('فلترة حسب النوع والمدينة', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.chevron_left, color: Colors.black54),
          ),
        ),
        const SizedBox(height: 16),
        const Text('السيارات المميزة', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...filtered.take(4).map(_carCard),
        FilledButton.icon(
          onPressed: () => setState(() => tab = 1),
          icon: const Icon(Icons.grid_view),
          label: const Text('عرض كل السيارات'),
        ),
      ],
    );
  }

  Widget _explorePage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('استكشاف السيارات', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _searchField(),
        const SizedBox(height: 12),
        Row(
          children: [
            Chip(label: Text(selectedType)),
            const SizedBox(width: 8),
            Chip(label: Text(selectedCity)),
            const Spacer(),
            IconButton.filled(onPressed: _showFilters, icon: const Icon(Icons.filter_list)),
          ],
        ),
        Text('${filtered.length} سيارة متاحة', style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        ...filtered.map(_carCard),
      ],
    );
  }

  Widget _favoritesPage() {
    final ids = favorites.where((i) => i >= 0 && i < cars.length).toList();
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('المفضلة', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('السيارات التي حفظتها', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 18),
        if (ids.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('لم تحفظ أي سيارة بعد'))),
        ...ids.map(_carCard),
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
        hintText: 'إبحث عن ماركة أو موديل...',
        hintStyle: const TextStyle(color: Colors.black54),
        prefixIcon: const Icon(Icons.search, color: Colors.black54),
        suffixIcon: IconButton(onPressed: _showFilters, icon: const Icon(Icons.tune, color: Color(0xFF16A34A))),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _carCard(int index) {
    final car = cars[index];
    final isFavorite = favorites.contains(index);
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CarDetailsPage(
              car: car,
              isFavorite: isFavorite,
              onFavorite: () => _toggleFavorite(index),
            ),
          ),
        ),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8F7ED),
          child: Icon(Icons.directions_car, color: Color(0xFF16A34A)),
        ),
        title: Text(car.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        subtitle: Text('${car.year} • ${car.city}\n${car.price}', style: const TextStyle(color: Colors.black54)),
        trailing: IconButton(
          onPressed: () => _toggleFavorite(index),
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: const Color(0xFF16A34A)),
        ),
      ),
    );
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

  void _publishCar(Car car) {
    setState(() {
      cars.add(car);
      tab = 0;
    });
    _message('تم نشر الإعلان بنجاح');
  }

  void _openAdmin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPage()));
  }

  Future<void> _showFilters() async {
    var type = selectedType;
    var city = selectedCity;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('البحث المتقدم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: const InputDecoration(labelText: 'نوع السيارة'),
              items: const ['الكل', 'سيدان', 'بيك أب', 'دفع رباعي'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (value) => type = value ?? 'الكل',
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: city,
              decoration: const InputDecoration(labelText: 'المدينة'),
              items: const ['الكل', 'الخرطوم', 'بحري', 'أم درمان'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (value) => city = value ?? 'الكل',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              setState(() {
                selectedType = type;
                selectedCity = city;
                tab = 1;
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }
}

class LogoHeader extends StatelessWidget {
  const LogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(radius: 24, backgroundColor: Color(0xFF16A34A), child: Icon(Icons.directions_car, color: Colors.white)),
        SizedBox(width: 10),
        Text('BUKO', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class CarDetailsPage extends StatefulWidget {
  final Car car;
  final bool isFavorite;
  final VoidCallback onFavorite;
  const CarDetailsPage({super.key, required this.car, required this.isFavorite, required this.onFavorite});

  @override
  State<CarDetailsPage> createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> {
  late bool favorite;

  @override
  void initState() {
    super.initState();
    favorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل السيارة')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            height: 190,
            decoration: BoxDecoration(color: const Color(0xFF102C40), borderRadius: BorderRadius.circular(22)),
            child: const Icon(Icons.directions_car, size: 100, color: Color(0xFF39C86A)),
          ),
          const SizedBox(height: 18),
          Text(widget.car.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text(widget.car.price, style: const TextStyle(fontSize: 23, color: Color(0xFF39C86A), fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _detailRow('السنة', '${widget.car.year}'),
                  _detailRow('المدينة', widget.car.city),
                  _detailRow('النوع', widget.car.type),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () {
              setState(() => favorite = !favorite);
              widget.onFavorite();
            },
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
            label: Text(favorite ? 'إزالة من المفضلة' : 'حفظ في المفضلة'),
          ),
          OutlinedButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const AlertDialog(
                title: Text('التواصل مع البائع'),
                content: Text('سيتم ربط الاتصال والرسائل بخدمة حقيقية في مرحلة الخادم.'),
              ),
            ),
            icon: const Icon(Icons.phone),
            label: const Text('التواصل مع البائع'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(color: Colors.black54))),
          Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class SellPage extends StatefulWidget {
  final ValueChanged<Car> onPublish;
  const SellPage({super.key, required this.onPublish});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final yearController = TextEditingController(text: '2022');
  final priceController = TextEditingController();
  final cityController = TextEditingController(text: 'الخرطوم');
  String type = 'سيدان';

  @override
  void dispose() {
    nameController.dispose();
    yearController.dispose();
    priceController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('بيع سيارتك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('أنشئ إعلاناً جديداً', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 20),
        Form(
          key: formKey,
          child: Column(
            children: [
              _field(nameController, 'الماركة والموديل'),
              _field(yearController, 'سنة الصنع', number: true),
              _field(priceController, 'السعر'),
              _field(cityController, 'المدينة'),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'نوع السيارة'),
                items: const ['سيدان', 'بيك أب', 'دفع رباعي'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (value) => setState(() => type = value ?? type),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.publish),
                  label: const Text('نشر الإعلان'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        validator: (value) => (value == null || value.trim().isEmpty) ? 'هذا الحقل مطلوب' : null,
        decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.white12),
      ),
    );
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;
    final year = int.tryParse(yearController.text.trim());
    if (year == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل سنة صحيحة')));
      return;
    }
    widget.onPublish(Car(nameController.text.trim(), year, priceController.text.trim(), cityController.text.trim(), type));
  }
}

class AccountPage extends StatelessWidget {
  final VoidCallback onAdmin;
  const AccountPage({super.key, required this.onAdmin});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('حسابي', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        const Card(child: ListTile(leading: CircleAvatar(child: Icon(Icons.person)), title: Text('زائر BUKO'), subtitle: Text('يمكنك تصفح السيارات ونشر إعلان'))),
        const SizedBox(height: 12),
        ListTile(leading: const Icon(Icons.notifications_outlined), title: const Text('الإشعارات'), onTap: () => _info(context, 'الإشعارات', 'لا توجد إشعارات جديدة.')),
        ListTile(leading: const Icon(Icons.help_outline), title: const Text('المساعدة'), onTap: () => _info(context, 'المساعدة', 'تصفح السيارات أو استخدم قسم بيع لنشر إعلان.')),
        ListTile(leading: const Icon(Icons.admin_panel_settings_outlined), title: const Text('لوحة تحكم الإدارة'), onTap: onAdmin),
      ],
    );
  }

  void _info(BuildContext context, String title, String text) {
    showDialog<void>(context: context, builder: (_) => AlertDialog(title: Text(title), content: Text(text), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً'))]));
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int reports = 3;
  int pending = 5;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('لوحة تحكم الإدارة')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text('مرحباً بك في لوحة الإدارة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            _stat('إعلانات قيد المراجعة', pending, Icons.pending_actions),
            _stat('بلاغات المستخدمين', reports, Icons.report_outlined),
            _stat('المستخدمون', 128, Icons.people_outline),
            const SizedBox(height: 18),
            FilledButton.icon(onPressed: _reviewAds, icon: const Icon(Icons.fact_check), label: const Text('مراجعة الإعلانات')),
            OutlinedButton.icon(onPressed: _reviewReports, icon: const Icon(Icons.report), label: const Text('مراجعة البلاغات')),
          ],
        ),
      ),
    );
  }

  Widget _stat(String title, int value, IconData icon) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF16A34A)),
        title: Text(title, style: const TextStyle(color: Colors.black87)),
        trailing: Text('$value', style: const TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _reviewAds() {
    setState(() => pending = 0);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت مراجعة الإعلانات')));
  }

  void _reviewReports() {
    setState(() => reports = 0);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت مراجعة البلاغات')));
  }
}
