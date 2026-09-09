import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const _gold = Color(0xFFFFB51B);
const _ink = Color(0xFF080B10);
const _panel = Color(0xFF11161E);
const _muted = Color(0xFF9BA6B5);

class AdminPostsPage extends StatefulWidget {
  const AdminPostsPage({super.key});
  @override
  State<AdminPostsPage> createState() => _AdminPostsPageState();
}

class _AdminPostsPageState extends State<AdminPostsPage> {
  final db = FirebaseFirestore.instance;
  bool busy = false;

  Future<void> _status(String id, String value) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await db.collection('cars').doc(id).update({
        'availability': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value == 'sold' ? 'تم وضع الإعلان: تم البيع' : 'تم وضع الإعلان: متوفرة')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('حذف الإعلان؟'),
      content: const Text('سيتم حذف الإعلان نهائياً من قاعدة البيانات.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف'))],
    ));
    if (ok != true) return;
    await db.collection('cars').doc(id).delete();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الإعلان.')));
  }

  Future<void> _add() async {
    final name = TextEditingController();
    final year = TextEditingController();
    final price = TextEditingController();
    final city = TextEditingController();
    final type = TextEditingController(text: 'سيدان');
    final image = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(context: context, builder: (_) => Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
      title: const Text('إضافة إعلان'),
      content: SingleChildScrollView(child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(name, 'اسم السيارة'), _field(year, 'السنة', keyboard: TextInputType.number), _field(price, 'السعر'), _field(city, 'المدينة'), _field(type, 'النوع'), _field(image, 'رابط الصورة (اختياري)'),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), FilledButton(onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(context, true); }, child: const Text('إضافة'))],
    )));
    if (ok != true) return;
    final uid = 'admin';
    await db.collection('cars').add({
      'name': name.text.trim(), 'year': int.tryParse(year.text.trim()) ?? 0, 'price': price.text.trim(), 'city': city.text.trim(), 'type': type.text.trim(),
      'sellerId': uid, 'imageUrls': image.text.trim().isEmpty ? <String>[] : [image.text.trim()], 'status': 'approved', 'availability': 'available', 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة الإعلان ونشره مباشرة.')));
  }

  Widget _field(TextEditingController c, String label, {TextInputType? keyboard}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextFormField(controller: c, keyboardType: keyboard, validator: (v) => (v == null || v.trim().isEmpty) && label != 'رابط الصورة (اختياري)' ? 'مطلوب' : null, decoration: InputDecoration(labelText: label)));

  String _availability(Map<String, dynamic> d) => d['availability'] == 'sold' ? 'تم البيع' : 'متوفرة';

  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(
    backgroundColor: _ink,
    appBar: AppBar(title: const Text('إدارة المنشورات'), backgroundColor: _ink, actions: [IconButton(onPressed: _add, icon: const Icon(Icons.add_circle, color: _gold), tooltip: 'إضافة إعلان')]),
    floatingActionButton: FloatingActionButton.extended(onPressed: _add, backgroundColor: _gold, foregroundColor: Colors.black, icon: const Icon(Icons.add), label: const Text('إضافة إعلان')),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: db.collection('cars').orderBy('createdAt', descending: true).snapshots(),
      builder: (_, s) {
        if (s.hasError) return Center(child: Text('تعذر تحميل المنشورات: ${s.error}'));
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final docs = s.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('لا توجد منشورات.'));
        return ListView.builder(padding: const EdgeInsets.all(16), itemCount: docs.length, itemBuilder: (_, i) {
          final doc = docs[i]; final d = doc.data(); final urls = List<String>.from(d['imageUrls'] ?? const <String>[]);
          return Card(color: _panel, margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (urls.isNotEmpty) ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(urls.first, height: 150, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(height: 80, child: Icon(Icons.directions_car, size: 40)))),
            const SizedBox(height: 10),
            Row(children: [Expanded(child: Text('${d['name'] ?? 'سيارة'} • ${d['year'] ?? ''}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))), Text(_availability(d), style: const TextStyle(color: _gold, fontWeight: FontWeight.w800))]),
            const SizedBox(height: 4), Text('${d['price'] ?? '-'} • ${d['city'] ?? '-'}', style: const TextStyle(color: _muted)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton.icon(onPressed: busy ? null : () => _status(doc.id, 'available'), icon: const Icon(Icons.check_circle_outline), label: const Text('متوفرة')),
              OutlinedButton.icon(onPressed: busy ? null : () => _status(doc.id, 'sold'), icon: const Icon(Icons.sell_outlined), label: const Text('تم البيع')),
              OutlinedButton.icon(onPressed: busy ? null : () => _delete(doc.id), icon: const Icon(Icons.delete_outline), label: const Text('حذف')),
            ]),
          ])));
        });
      },
    ),
  ));
}
