import 'package:flutter/material.dart';

void main() => runApp(const BukoApp());

class BukoApp extends StatelessWidget {
  const BukoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'بوكو',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF071A2A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A34A),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class Car {
  final String name, year, price, city, type;
  const Car(this.name, this.year, this.price, this.city, this.type);
}

const cars = [
  Car('تويوتا هايلوكس', '2019', '85,000,000 ج.س', 'أم درمان', 'بيك أب'),
  Car('تويوتا برادو', '2018', '120,000,000 ج.س', 'بحري', 'دفع رباعي'),
  Car('هيونداي النترا', '2021', '45,000,000 ج.س', 'الخرطوم', 'سيدان'),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  String query = '';
  final favorites = <int>{};

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _home(),
      const SimplePage(
        'استكشاف',
        'ابحث عن السيارات حسب المدينة أو النوع أو السعر',
      ),
      const SimplePage(
        'بيع سيارتك',
        'أضف سيارتك بسهولة ووصل إلى مشترين في السودان',
        button: 'إضافة إعلان',
      ),
      FavoritePage(indices: favorites),
      const AccountPage(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(child: pages[tab]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'استكشاف',
            ),
            NavigationDestination(
              icon: Icon(Icons.sell_outlined),
              selectedIcon: Icon(Icons.sell),
              label: 'بيع',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'المفضلة',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }

  Widget _home() {
    final filtered = cars
        .where(
          (c) => query.isEmpty || '${c.name} ${c.city} ${c.type}'.contains(query),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Logo(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF102C40), Color(0xFF061521)],
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'السوق الأول للسيارات المستعملة في السودان',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 12),
              Text(
                'إبحث عن سيارتك',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              Text(
                'بكل سهولة في السودان',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF39C86A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          onChanged: (v) => setState(() => query = v.trim()),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'إبحث عن ماركة أو موديل أو كلمة مفتاحية...',
            hintStyle: const TextStyle(color: Colors.black54),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF102030)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 16),
        _section('البحث المتقدم'),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'فلترة السيارات',
                        style: TextStyle(
                          color: Color(0xFF138B40),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(Icons.tune, color: Color(0xFF132334)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'الماركة',
                    'الموديل',
                    'السعر',
                    'الوقود',
                    'المحافظة',
                    'نوع السيارة',
                  ].map((x) => Chip(label: Text(x))).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _section('السيارات المميزة'),
        ...filtered.map((car) {
          final index = cars.indexOf(car);
          return Card(
            color: Colors.white,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F7ED),
                child: Icon(Icons.directions_car, color: Color(0xFF16A34A)),
              ),
              title: Text(
                car.name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${car.year} • ${car.city}\n${car.price}',
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: IconButton(
                onPressed: () {
                  setState(() {
                    if (favorites.contains(index)) {
                      favorites.remove(index);
                    } else {
                      favorites.add(index);
                    }
                  });
                },
                icon: Icon(
                  favorites.contains(index)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFF16A34A),
          child: Icon(Icons.directions_car, color: Colors.white),
        ),
        SizedBox(width: 10),
        Text(
          'BUKO',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class FavoritePage extends StatelessWidget {
  final Set<int> indices;
  const FavoritePage({super.key, required this.indices});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'المفضلة',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        if (indices.isEmpty)
          const Text(
            'لم تحفظ أي سيارة بعد',
            style: TextStyle(color: Colors.white70),
          ),
        ...indices.map(
          (i) => Card(
            color: Colors.white,
            child: ListTile(
              title: Text(
                cars[i].name,
                style: const TextStyle(color: Colors.black87),
              ),
              subtitle: Text(
                cars[i].price,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Logo(),
        const SizedBox(height: 18),
        const Text(
          'حسابي',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'إدارة إعلاناتك ومفضلاتك وإعدادات الحساب',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 25),
        _tile(
          context,
          Icons.person_outline,
          'تسجيل الدخول',
          'الوصول إلى حسابك وإعلاناتك',
          () {},
        ),
        _tile(
          context,
          Icons.favorite_border,
          'المفضلة',
          'السيارات التي حفظتها',
          () {},
        ),
        _tile(
          context,
          Icons.admin_panel_settings_outlined,
          'لوحة تحكم الإدارة',
          'إدارة الإعلانات والمستخدمين والإحصائيات',
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminDashboardPage(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    VoidCallback tap,
  ) {
    return Card(
      color: Colors.white,
      child: ListTile(
        onTap: tap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8F7ED),
          child: Icon(icon, color: const Color(0xFF16A34A)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          sub,
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: const Icon(Icons.chevron_left, color: Colors.black54),
      ),
    );
  }
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int pending = 7;
  int active = 124;
  int users = 86;
  int reports = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: AppBar(
        title: const Text('لوحة تحكم الإدارة'),
        backgroundColor: const Color(0xFF071A2A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF071A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: Color(0xFF16A34A),
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً، مدير BUKO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'مراقبة المنصة وإدارة الإعلانات',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: [
              _stat('إعلانات نشطة', active, Icons.directions_car),
              _stat('بانتظار المراجعة', pending, Icons.pending_actions),
              _stat('المستخدمون', users, Icons.people_alt_outlined),
              _stat('بلاغات', reports, Icons.flag_outlined),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'إجراءات سريعة',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _action(
            'مراجعة الإعلانات الجديدة',
            Icons.fact_check_outlined,
            () {
              setState(() => pending = 0);
              _snack('تمت مراجعة الإعلانات المعلقة (وضع تجريبي)');
            },
          ),
          _action(
            'إدارة المستخدمين',
            Icons.manage_accounts_outlined,
            () => _snack('قسم إدارة المستخدمين جاهز للربط بقاعدة البيانات'),
          ),
          _action(
            'البلاغات والشكاوى',
            Icons.report_problem_outlined,
            () {
              setState(() => reports = 0);
              _snack('تم فتح مركز البلاغات (وضع تجريبي)');
            },
          ),
          _action(
            'إعدادات المنصة',
            Icons.settings_outlined,
            () => _snack('إعدادات المنصة ستكون مرتبطة بالـBackend لاحقاً'),
          ),
          const SizedBox(height: 12),
          const Text(
            'ملاحظة: هذه لوحة إدارة واجهة UI حالياً. صلاحيات الإدارة الحقيقية وتخزين البيانات والمصادقة الآمنة تحتاج Backend وقاعدة بيانات.',
            style: TextStyle(color: Colors.black54, height: 1.5, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _stat(String title, int value, IconData icon) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: const Color(0xFF16A34A), size: 28),
            Text(
              '$value',
              style: const TextStyle(
                color: Color(0xFF071A2A),
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _action(String title, IconData icon, VoidCallback tap) {
    return Card(
      color: Colors.white,
      child: ListTile(
        onTap: tap,
        leading: Icon(icon, color: const Color(0xFF16A34A)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_left),
      ),
    );
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}

class SimplePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String button;

  const SimplePage(
    this.title,
    this.subtitle, {
    super.key,
    this.button = '',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Logo(),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                if (button.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {},
                    child: Text(button),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
