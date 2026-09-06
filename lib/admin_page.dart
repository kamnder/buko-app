import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'widgets/animated_background.dart';

const _gold = Color(0xFFFFB51B);
const _ink = Color(0xFF080B10);
const _panel = Color(0xFF11161E);
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

  Future<void> _update(String collection, String id, String status) async {
    setState(() => _loading = true);
    try {
      await _db.collection(collection).doc(id).update({
        'status': status,
        'reviewedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(status == 'approved' ? 'تمت الموافقة ✓' : 'تم الرفض')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تنفيذ العملية')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _ink,
        appBar: AppBar(
          backgroundColor: _ink,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('لوحة تحكم BUKO', style: TextStyle(fontWeight: FontWeight.w900)),
              Text('مراقبة المنصة وإدارة العمليات', style: TextStyle(fontSize: 11, color: _muted)),
            ],
          ),
        ),
        body: BukoAnimatedBackground(
          child: Column(
            children: [
              _summary(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, icon: Icon(Icons.directions_car_outlined), label: Text('السيارات')),
                    ButtonSegment(value: 1, icon: Icon(Icons.people_outline), label: Text('المستخدمون')),
                    ButtonSegment(value: 2, icon: Icon(Icons.shopping_bag_outlined), label: Text('الطلبات')),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (v) => setState(() => _tab = v.first),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: IndexedStack(index: _tab, children: [_cars(), _users(), _requests()])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summary() {
    return SizedBox(
      height: 92,
      child: Row(
        children: [
          Expanded(child: _CountCard(title: 'المستخدمون', icon: Icons.people_outline, stream: _db.collection('users').snapshots())),
          Expanded(child: _CountCard(title: 'طلبات معلقة', icon: Icons.shopping_bag_outlined, stream: _db.collection('purchaseRequests').where('status', isEqualTo: 'pending').snapshots())),
          Expanded(child: _CountCard(title: 'إعلانات معلقة', icon: Icons.directions_car_outlined, stream: _db.collection('cars').where('status', isEqualTo: 'pending').snapshots())),
        ],
      ),
    );
  }

  Widget _cars() {
    final stream = _db.collection('cars').where('status', isEqualTo: 'pending').orderBy('createdAt', descending: true).snapshots();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (_, snapshot) {
        if (snapshot.hasError) return const _Error('تعذر تحميل الإعلانات.');
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const _Empty(icon: Icons.check_circle_outline, text: 'لا توجد إعلانات بانتظار المراجعة');
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final doc = docs[i];
            final data = doc.data();
            final images = List<String>.from(data['imageUrls'] ?? const <String>[]);
            return _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (images.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        images.first,
                        height: 175,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox(height: 175, child: Icon(Icons.directions_car, size: 60, color: _gold)),
                      ),
                    )
                  else
                    const SizedBox(height: 110, child: Center(child: Icon(Icons.directions_car, size: 58, color: _gold))),
                  const SizedBox(height: 10),
                  Text('${data['name'] ?? 'سيارة'} • ${data['year'] ?? ''}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  Text('السعر: ${data['price'] ?? '-'}  •  المدينة: ${data['city'] ?? '-'}\nالبائع: ${data['sellerId'] ?? '-'}', style: const TextStyle(color: _muted, height: 1.5)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: FilledButton.icon(onPressed: _loading ? null : () => _update('cars', doc.id, 'approved'), icon: const Icon(Icons.check), label: const Text('قبول'))),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton.icon(onPressed: _loading ? null : () => _update('cars', doc.id, 'rejected'), icon: const Icon(Icons.close), label: const Text('رفض'))),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _users() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('users').snapshots(),
      builder: (_, snapshot) {
        if (snapshot.hasError) return const _Error('تعذر تحميل المستخدمين.');
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = [...snapshot.data!.docs]..sort((a, b) {
          final aa = a.data()['createdAt'];
          final bb = b.data()['createdAt'];
          return aa is Timestamp && bb is Timestamp ? bb.compareTo(aa) : 0;
        });
        if (docs.isEmpty) return const _Empty(icon: Icons.people_outline, text: 'لا يوجد مستخدمون بعد');
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final data = docs[i].data();
            return _Card(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: _gold.withOpacity(.15), child: const Icon(Icons.person, color: _gold)),
                title: Text('${data['name'] ?? 'مستخدم'}', style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${data['phone'] ?? '-'}\nUID: ${docs[i].id}', style: const TextStyle(color: _muted, fontSize: 11)),
                trailing: _Role(role: '${data['role'] ?? 'buyer'}'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _requests() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('purchaseRequests').orderBy('createdAt', descending: true).snapshots(),
      builder: (_, snapshot) {
        if (snapshot.hasError) return const _Error('تعذر تحميل طلبات الشراء.');
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const _Empty(icon: Icons.shopping_bag_outlined, text: 'لا توجد طلبات شراء');
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final doc = docs[i];
            final data = doc.data();
            final status = '${data['status'] ?? 'pending'}';
            final short = doc.id.substring(0, doc.id.length > 7 ? 7 : doc.id.length);
            return _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [const Icon(Icons.shopping_cart_outlined, color: _gold), const SizedBox(width: 8), Expanded(child: Text('طلب شراء #$short', style: const TextStyle(fontWeight: FontWeight.w900))), _Status(status: status)]),
                  const SizedBox(height: 10),
                  Text('المشتري: ${data['buyerId'] ?? '-'}\nالبائع: ${data['sellerId'] ?? '-'}\nالسيارة: ${data['carId'] ?? '-'}', style: const TextStyle(color: _muted, height: 1.5, fontSize: 12)),
                  if (status == 'pending') ...[
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: FilledButton.icon(onPressed: _loading ? null : () => _update('purchaseRequests', doc.id, 'approved'), icon: const Icon(Icons.check), label: const Text('موافقة'))),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton.icon(onPressed: _loading ? null : () => _update('purchaseRequests', doc.id, 'rejected'), icon: const Icon(Icons.close), label: const Text('رفض'))),
                    ]),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CountCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  const _CountCard({required this.title, required this.icon, required this.stream});
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (_, snapshot) => Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: _panel.withOpacity(.94), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: _gold, size: 19), const Spacer(), Text('${snapshot.data?.size ?? 0}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), Text(title, style: const TextStyle(color: _muted, fontSize: 10))]),
        ),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Card(color: _panel.withOpacity(.96), margin: const EdgeInsets.only(bottom: 5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21), side: const BorderSide(color: Colors.white10)), child: Padding(padding: const EdgeInsets.all(13), child: child));
}

class _Role extends StatelessWidget {
  final String role;
  const _Role({required this.role});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: _gold.withOpacity(.12), borderRadius: BorderRadius.circular(18)), child: Text(role == 'admin' ? 'أدمن' : 'مستخدم', style: const TextStyle(color: _gold, fontSize: 10, fontWeight: FontWeight.w800)));
}

class _Status extends StatelessWidget {
  final String status;
  const _Status({required this.status});
  @override
  Widget build(BuildContext context) {
    final color = status == 'approved' ? Colors.greenAccent : status == 'rejected' ? Colors.redAccent : _gold;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(18)), child: Text(status == 'approved' ? 'مقبول' : status == 'rejected' ? 'مرفوض' : 'قيد الانتظار', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)));
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Empty({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: _gold, size: 50), const SizedBox(height: 10), Text(text, style: const TextStyle(color: _muted))]));
}

class _Error extends StatelessWidget {
  final String text;
  const _Error(this.text);
  @override
  Widget build(BuildContext context) => Center(child: Text(text, style: const TextStyle(color: Colors.redAccent)));
}
