import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const _gold = Color(0xFFFFB51B);
const _ink = Color(0xFF080B10);
const _panel = Color(0xFF11161E);
const _muted = Color(0xFF9BA6B5);

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _db = FirebaseFirestore.instance;
  int _tab = 0;
  bool _loading = false;

  Future<void> _setCarStatus(String id, String status) async {
    setState(() => _loading = true);
    try {
      await _db.collection('cars').doc(id).update({'status': status, 'reviewedAt': FieldValue.serverTimestamp()});
      _toast(status == 'approved' ? 'تم قبول الإعلان ✓' : 'تم رفض الإعلان');
    } catch (_) { _toast('تعذر تحديث الإعلان'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _setRequestStatus(String id, String status) async {
    setState(() => _loading = true);
    try {
      await _db.collection('purchaseRequests').doc(id).update({'status': status, 'reviewedAt': FieldValue.serverTimestamp()});
      _toast(status == 'approved' ? 'تمت الموافقة على الطلب ✓' : 'تم رفض الطلب');
    } catch (_) { _toast('تعذر تحديث الطلب'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  void _toast(String message) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))); }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _ink,
        appBar: AppBar(
          backgroundColor: _ink,
          title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('لوحة تحكم BUKO', style: TextStyle(fontWeight: FontWeight.w900)),
            Text('إدارة المنصة والمستخدمين والطلبات', style: TextStyle(fontSize: 11, color: _muted)),
          ]),
        ),
        body: Column(children: [
          _DashboardSummary(db: _db),
          const SizedBox(height: 8),
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
        ]),
      ),
    );
  }

  Widget _cars() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: _db.collection('cars').where('status', isEqualTo: 'pending').orderBy('createdAt', descending: true).snapshots(),
    builder: (context, snap) {
      if (snap.hasError) return _ErrorState('تعذر تحميل الإعلانات بانتظار المراجعة.\n\n${snap.error}');
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      if (docs.isEmpty) return const _EmptyState(icon: Icons.check_circle_outline, text: 'لا توجد إعلانات بانتظار المراجعة');
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28), itemCount: docs.length,
        itemBuilder: (_, i) {
          final doc = docs[i]; final d = doc.data(); final images = List<String>.from(d['imageUrls'] ?? const []);
          return _GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (images.isNotEmpty) ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(images.first, height: 185, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(height: 185, child: Icon(Icons.directions_car, size: 60, color: _gold))))
            else const SizedBox(height: 120, child: Center(child: Icon(Icons.directions_car, size: 60, color: _gold))),
            const SizedBox(height: 12),
            Text('${d['name'] ?? 'سيارة'} • ${d['year'] ?? ''}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text('السعر: ${d['price'] ?? '-'}\nالمدينة: ${d['city'] ?? '-'}\nالنوع: ${d['type'] ?? '-'}\nالبائع: ${d['sellerId'] ?? '-'}', style: const TextStyle(color: _muted, height: 1.5)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: FilledButton.icon(onPressed: _loading ? null : () => _setCarStatus(doc.id, 'approved'), icon: const Icon(Icons.check), label: const Text('قبول'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: _loading ? null : () => _setCarStatus(doc.id, 'rejected'), icon: const Icon(Icons.close), label: const Text('رفض'))),
            ]),
          ]));
        },
      );
    },
  );

  Widget _users() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: _db.collection('users').snapshots(),
    builder: (context, snap) {
      if (snap.hasError) return _ErrorState('تعذر تحميل المستخدمين.\n\n${snap.error}');
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = [...snap.data!.docs]..sort((a, b) {
        final aa = a.data()['createdAt']; final bb = b.data()['createdAt'];
        if (aa is Timestamp && bb is Timestamp) return bb.compareTo(aa); return 0;
      });
      if (docs.isEmpty) return const _EmptyState(icon: Icons.people_outline, text: 'لا يوجد مستخدمون بعد');
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28), itemCount: docs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 9),
        itemBuilder: (_, i) { final d = docs[i].data(); return _GlassCard(child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(backgroundColor: _gold.withOpacity(.16), child: const Icon(Icons.person, color: _gold)),
          title: Text(d['name'] ?? 'مستخدم', style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text('${d['phone'] ?? '-'}\nUID: ${docs[i].id}', style: const TextStyle(color: _muted, fontSize: 11)),
          trailing: _RoleBadge(role: '${d['role'] ?? 'buyer'}'),
        )); },
      );
    },
  );

  Widget _requests() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: _db.collection('purchaseRequests').orderBy('createdAt', descending: true).snapshots(),
    builder: (context, snap) {
      if (snap.hasError) return _ErrorState('تعذر تحميل طلبات الشراء.\n\n${snap.error}');
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snap.data!.docs;
      if (docs.isEmpty) return const _EmptyState(icon: Icons.shopping_bag_outlined, text: 'لا توجد طلبات شراء');
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28), itemCount: docs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final doc = docs[i]; final d = doc.data(); final status = '${d['status'] ?? 'pending'}';
          final short = doc.id.substring(0, doc.id.length > 7 ? 7 : doc.id.length);
          return _GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              const CircleAvatar(backgroundColor: Color(0x1FFF B51B), child: Icon(Icons.shopping_cart_outlined, color: _gold)),
              const SizedBox(width: 10), Expanded(child: Text('طلب شراء #$short', style: const TextStyle(fontWeight: FontWeight.w900))), _StatusBadge(status: status),
            ]),
            const SizedBox(height: 12),
            Text('المشتري: ${d['buyerId'] ?? '-'}\nالبائع: ${d['sellerId'] ?? '-'}\nالسيارة: ${d['carId'] ?? '-'}', style: const TextStyle(color: _muted, height: 1.5, fontSize: 12)),
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: FilledButton.icon(onPressed: _loading ? null : () => _setRequestStatus(doc.id, 'approved'), icon: const Icon(Icons.check), label: const Text('موافقة'))),
                const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: _loading ? null : () => _setRequestStatus(doc.id, 'rejected'), icon: const Icon(Icons.close), label: const Text('رفض'))),
              ]),
            ],
          ]));
        },
      );
    },
  );
}

class _DashboardSummary extends StatelessWidget {
  final FirebaseFirestore db;
  const _DashboardSummary({required this.db});
  @override
  Widget build(BuildContext context) => SizedBox(height: 92, child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: db.collection('users').snapshots(),
    builder: (_, users) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: db.collection('purchaseRequests').where('status', isEqualTo: 'pending').snapshots(),
      builder: (_, requests) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db.collection('cars').where('status', isEqualTo: 'pending').snapshots(),
        builder: (_, cars) {
          final stats = [('المستخدمون', users.data?.size ?? 0, Icons.people_outline), ('طلبات جديدة', requests.data?.size ?? 0, Icons.shopping_bag_outlined), ('إعلانات معلقة', cars.data?.size ?? 0, Icons.directions_car_outlined)];
          return ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), itemCount: stats.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => Container(width: 145, padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(stats[i].$3, color: _gold, size: 20), const Spacer(), Text('${stats[i].$2}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), Text(stats[i].$1, style: const TextStyle(color: _muted, fontSize: 11))]));
        },
      ),
    ),
  ));
}

class _GlassCard extends StatelessWidget { final Widget child; const _GlassCard({required this.child}); @override Widget build(BuildContext context) => Card(color: _panel, margin: const EdgeInsets.only(bottom: 4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: Colors.white10)), child: Padding(padding: const EdgeInsets.all(14), child: child)); }
class _RoleBadge extends StatelessWidget { final String role; const _RoleBadge({required this.role}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: _gold.withOpacity(.13), borderRadius: BorderRadius.circular(20)), child: Text(role == 'admin' ? 'أدمن' : 'مستخدم', style: const TextStyle(color: _gold, fontSize: 10, fontWeight: FontWeight.w800))); }
class _StatusBadge extends StatelessWidget { final String status; const _StatusBadge({required this.status}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: status == 'approved' ? Colors.green.withOpacity(.13) : Colors.red.withOpacity(.13), borderRadius: BorderRadius.circular(20)), child: Text(status == 'approved' ? 'مقبول' : status == 'rejected' ? 'مرفوض' : 'قيد الانتظار', style: TextStyle(color: status == 'approved' ? Colors.greenAccent : status == 'rejected' ? Colors.redAccent : _gold, fontSize: 10, fontWeight: FontWeight.w800))); }
class _EmptyState extends StatelessWidget { final IconData icon; final String text; const _EmptyState({required this.icon, required this.text}); @override Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: _gold, size: 52), const SizedBox(height: 12), Text(text, style: const TextStyle(color: _muted))])); }
class _ErrorState extends StatelessWidget { final String text; const _ErrorState(this.text); @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(22), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)))); }
