import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_posts_page.dart';
import 'widgets/animated_background.dart';

const _gold = Color(0xFFFFB51B);
const _ink = Color(0xFF080B10);
const _panel = Color(0xFF11161E);
const _panel2 = Color(0xFF17212B);
const _muted = Color(0xFF9BA6B5);

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _db = FirebaseFirestore.instance;
  int _tab = 0;
  bool _loading = false;
  String _search = '';

  Future<void> _update(String collection, String id, String status) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await _db.collection(collection).doc(id).update({
        'status': status,
        'reviewedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status == 'approved' ? 'تمت الموافقة على العنصر ✓' : 'تم الرفض')),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      final message = e.code == 'permission-denied'
          ? 'ليس لديك صلاحية لهذا الإجراء. تأكد من صلاحية admin.'
          : 'تعذر تنفيذ العملية (${e.code}).';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setTab(int tab) => setState(() {
        _tab = tab;
        _search = '';
      });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _ink,
        body: SafeArea(
          child: BukoAnimatedBackground(
            child: Column(
              children: [
                _header(),
                Expanded(child: _body()),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _navigation(),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: _gold.withOpacity(.22), blurRadius: 18)],
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.black, size: 27),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BUKO', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  Text('لوحة تحكم الإدارة', style: TextStyle(color: _muted, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              tooltip: 'تحديث',
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
      );

  Widget _body() {
    switch (_tab) {
      case 1:
        return _adsPage();
      case 2:
        return _usersPage();
      case 3:
        return _requestsPage();
      case 4:
        return _settingsPage();
      default:
        return _dashboardPage();
    }
  }

  Widget _dashboardPage() => ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: [
          const Text('مرحباً بك، مدير النظام 👑', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('راقب الإعلانات والمستخدمين وطلبات الشراء من مكان واحد.', style: TextStyle(color: _muted)),
          const SizedBox(height: 18),
          _metricsGrid(),
          const SizedBox(height: 18),
          _sectionTitle('إجراءات سريعة'),
          const SizedBox(height: 10),
          _quickAction(Icons.directions_car_outlined, 'مراجعة الإعلانات', 'اعتماد أو رفض الإعلانات الجديدة', 1),
          _quickAction(Icons.people_outline, 'إدارة المستخدمين', 'عرض الحسابات والأدوار', 2),
          _quickAction(Icons.shopping_cart_outlined, 'طلبات الشراء', 'متابعة الطلبات وحالتها', 3),
          _quickAction(Icons.settings_outlined, 'إعدادات التطبيق', 'معلومات الإدارة والنظام', 4),
          const SizedBox(height: 18),
          _activityCard(),
        ],
      );

  Widget _metricsGrid() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.collection('cars').snapshots(),
        builder: (_, cars) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _db.collection('users').snapshots(),
          builder: (_, users) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _db.collection('purchaseRequests').snapshots(),
            builder: (_, requests) {
              final carDocs = cars.data?.docs ?? const [];
              final userDocs = users.data?.docs ?? const [];
              final requestDocs = requests.data?.docs ?? const [];
              final pendingCars = carDocs.where((d) => d.data()['status'] == 'pending').length;
              final pendingRequests = requestDocs.where((d) => d.data()['status'] == 'pending').length;
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.35,
                children: [
                  _metric(Icons.directions_car_outlined, 'إجمالي الإعلانات', '${carDocs.length}'),
                  _metric(Icons.people_outline, 'المستخدمون', '${userDocs.length}'),
                  _metric(Icons.schedule_rounded, 'بانتظار المراجعة', '$pendingCars'),
                  _metric(Icons.shopping_cart_outlined, 'طلبات الشراء', '${requestDocs.length}  •  $pendingRequests معلقة'),
                ],
              );
            },
          ),
        ),
      );

  Widget _metric(IconData icon, String title, String value) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _panel.withOpacity(.96),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: _gold, size: 24),
          const Spacer(),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: _muted, fontSize: 11)),
        ]),
      );

  Widget _quickAction(IconData icon, String title, String subtitle, int tab) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Material(
          color: _panel.withOpacity(.96),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => _setTab(tab),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(width: 43, height: 43, decoration: BoxDecoration(color: _gold.withOpacity(.12), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: _gold)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(color: _muted, fontSize: 11))])),
                const Icon(Icons.chevron_left_rounded, color: _muted),
              ]),
            ),
          ),
        ),
      );

  Widget _activityCard() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.collection('cars').orderBy('createdAt', descending: true).limit(5).snapshots(),
        builder: (_, snapshot) {
          final docs = snapshot.data?.docs ?? const [];
          return _box(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionTitle('آخر الإعلانات'),
              const SizedBox(height: 10),
              if (docs.isEmpty) const Text('لا توجد إعلانات حتى الآن.', style: TextStyle(color: _muted)),
              ...docs.map((doc) {
                final d = doc.data();
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _thumb(d['imageUrls']),
                  title: Text('${d['name'] ?? 'سيارة'} • ${d['year'] ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${d['city'] ?? '-'} • ${d['status'] ?? 'pending'}', style: const TextStyle(color: _muted, fontSize: 11)),
                  trailing: const Icon(Icons.chevron_left_rounded, color: _muted),
                  onTap: () => _setTab(1),
                );
              }),
            ]),
          );
        },
      );

  Widget _adsPage() => const AdminPostsPage();

  Widget _usersPage() => Column(children: [
        _pageTitle('إدارة المستخدمين', 'عرض الحسابات وأدوارها.'),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: _searchField('ابحث بالاسم أو الهاتف')),
        Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _db.collection('users').snapshots(),
          builder: (_, snapshot) {
            if (snapshot.hasError) return const _Error('تعذر تحميل المستخدمين.');
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs.where((d) => _matches(d.data())).toList();
            if (docs.isEmpty) return const _Empty(icon: Icons.people_outline, text: 'لا يوجد مستخدمون مطابقون');
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final d = docs[i].data();
                final role = '${d['role'] ?? 'buyer'}';
                return _box(child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundColor: _gold.withOpacity(.13), child: const Icon(Icons.person_rounded, color: _gold)),
                  title: Text('${d['name'] ?? 'مستخدم'}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${d['phone'] ?? '-'}\nUID: ${docs[i].id}', style: const TextStyle(color: _muted, fontSize: 11)),
                  trailing: _role(role),
                  onTap: () => _showUser(docs[i]),
                ));
              },
            );
          },
        )),
      ]);

  Future<void> _showUser(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final d = doc.data();
    await showDialog<void>(context: context, builder: (_) => AlertDialog(
      title: Text('${d['name'] ?? 'مستخدم'}'),
      content: Text('الهاتف: ${d['phone'] ?? '-'}\nالدور: ${d['role'] ?? 'buyer'}\nUID: ${doc.id}'),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))],
    ));
  }

  Widget _requestsPage() => Column(children: [
        _pageTitle('طلبات الشراء', 'تابع الطلبات وحالاتها.'),
        Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _db.collection('purchaseRequests').orderBy('createdAt', descending: true).snapshots(),
          builder: (_, snapshot) {
            if (snapshot.hasError) return const _Error('تعذر تحميل طلبات الشراء.');
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const _Empty(icon: Icons.shopping_bag_outlined, text: 'لا توجد طلبات شراء');
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 9),
              itemBuilder: (_, i) => _requestCard(docs[i]),
            );
          },
        )),
      ]);

  Widget _requestCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final status = '${d['status'] ?? 'pending'}';
    return _box(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [const Icon(Icons.shopping_cart_outlined, color: _gold), const SizedBox(width: 8), Expanded(child: Text('طلب شراء #${doc.id.substring(0, doc.id.length > 8 ? 8 : doc.id.length)}', style: const TextStyle(fontWeight: FontWeight.w900))), _status(status)]),
      const SizedBox(height: 10),
      Text('المشتري: ${d['buyerId'] ?? '-'}\nالبائع: ${d['sellerId'] ?? '-'}\nالسيارة: ${d['carId'] ?? '-'}', style: const TextStyle(color: _muted, fontSize: 11, height: 1.55)),
      if (status == 'pending') ...[
        const SizedBox(height: 11),
        Row(children: [
          Expanded(child: FilledButton.icon(onPressed: _loading ? null : () => _update('purchaseRequests', doc.id, 'approved'), icon: const Icon(Icons.check), label: const Text('موافقة'))),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(onPressed: _loading ? null : () => _update('purchaseRequests', doc.id, 'rejected'), icon: const Icon(Icons.close), label: const Text('رفض'))),
        ]),
      ],
    ]));
  }

  Widget _settingsPage() => ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _pageTitle('إعدادات الإدارة', 'معلومات النظام وأدوات الإدارة.'),
          _box(child: Column(children: [
            const ListTile(leading: Icon(Icons.security_outlined, color: _gold), title: Text('صلاحية الأدمن'), subtitle: Text('الوصول محمي عبر Firebase Custom Claims: admin=true', style: TextStyle(color: _muted, fontSize: 11))),
            const Divider(color: Colors.white10),
            ListTile(leading: const Icon(Icons.cloud_done_outlined, color: _gold), title: const Text('قاعدة البيانات'), subtitle: const Text('Firebase Firestore', style: TextStyle(color: _muted, fontSize: 11)), onTap: () => _info('قاعدة البيانات', 'تُستخدم Firestore للإعلانات والمستخدمين وطلبات الشراء.')),
            const Divider(color: Colors.white10),
            ListTile(leading: const Icon(Icons.info_outline, color: _gold), title: const Text('عن لوحة BUKO'), subtitle: const Text('نسخة الإدارة', style: TextStyle(color: _muted, fontSize: 11)), onTap: () => _info('لوحة تحكم BUKO', 'إدارة الإعلانات والمستخدمين وطلبات الشراء في مكان واحد.')),
          ])),
        ],
      );

  Future<void> _info(String title, String message) async {
    await showDialog<void>(context: context, builder: (_) => AlertDialog(title: Text(title), content: Text(message), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً'))]));
  }

  Widget _navigation() => NavigationBar(
        backgroundColor: const Color(0xFF0C1016),
        indicatorColor: _gold.withOpacity(.15),
        selectedIndex: _tab,
        onDestinationSelected: _setTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: _gold), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.directions_car_outlined), selectedIcon: Icon(Icons.directions_car, color: _gold), label: 'الإعلانات'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people, color: _gold), label: 'المستخدمون'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart, color: _gold), label: 'الطلبات'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings, color: _gold), label: 'الإعدادات'),
        ],
      );

  Widget _pageTitle(String title, String subtitle) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
        child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: _muted, fontSize: 11))]))]),
      );

  Widget _sectionTitle(String text) => Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900));

  Widget _searchField(String hint) => TextField(
        onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
        decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: hint, suffixIcon: _search.isEmpty ? null : IconButton(onPressed: () => setState(() => _search = ''), icon: const Icon(Icons.clear))),
      );

  bool _matches(Map<String, dynamic> d) {
    if (_search.isEmpty) return true;
    final text = [d['name'], d['city'], d['phone'], d['sellerId'], d['buyerId'], d['carId']].whereType<Object>().join(' ').toLowerCase();
    return text.contains(_search);
  }

  Widget _box({required Widget child, EdgeInsetsGeometry? margin}) => Card(
        color: _panel.withOpacity(.96),
        margin: margin ?? const EdgeInsets.only(bottom: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21), side: const BorderSide(color: Colors.white10)),
        child: Padding(padding: const EdgeInsets.all(13), child: child),
      );

  Widget _thumb(dynamic value) {
    final list = value is List ? value : const [];
    final url = list.isNotEmpty ? '${list.first}' : '';
    return Container(width: 52, height: 52, decoration: BoxDecoration(color: _panel2, borderRadius: BorderRadius.circular(13)), child: url.isEmpty ? const Icon(Icons.directions_car, color: _gold) : ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.directions_car, color: _gold))));
  }

  Widget _imageFallback() => Container(height: 175, color: _panel2, child: const Center(child: Icon(Icons.directions_car_rounded, color: _gold, size: 62)));

  Widget _role(String role) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: _gold.withOpacity(.12), borderRadius: BorderRadius.circular(18)), child: Text(role == 'admin' ? 'أدمن' : 'مستخدم', style: const TextStyle(color: _gold, fontSize: 10, fontWeight: FontWeight.w800)));

  Widget _status(String status) {
    final color = status == 'approved' ? Colors.greenAccent : status == 'rejected' ? Colors.redAccent : _gold;
    final text = status == 'approved' ? 'مقبول' : status == 'rejected' ? 'مرفوض' : 'قيد الانتظار';
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(18)), child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)));
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Empty({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: _gold, size: 52), const SizedBox(height: 10), Text(text, style: const TextStyle(color: _muted))]));
}

class _Error extends StatelessWidget {
  final String text;
  const _Error(this.text);
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent))));
}
