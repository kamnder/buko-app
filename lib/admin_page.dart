import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _db = FirebaseFirestore.instance;
  bool _loading = false;

  Future<void> _setStatus(String id, String status) async {
    setState(() => _loading = true);
    try {
      await _db.collection('cars').doc(id).update({
        'status': status,
        'reviewedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(status == 'approved' ? 'تم قبول الإعلان ✓' : 'تم رفض الإعلان')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تحديث الإعلان: $e')),
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
        appBar: AppBar(title: const Text('لوحة تحكم BUKO')),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _db.collection('cars').where('status', isEqualTo: 'pending').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('تعذر تحميل الطلبات. تأكد أن الحساب لديه صلاحية admin.\n\n${snap.error}', textAlign: TextAlign.center)));
            }
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snap.data!.docs;
            if (docs.isEmpty) return const Center(child: Text('لا توجد إعلانات بانتظار المراجعة ✓'));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (_, index) {
                final doc = docs[index];
                final data = doc.data();
                final images = List<String>.from(data['imageUrls'] ?? const []);
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      if (images.isNotEmpty)
                        ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(images.first, height: 190, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(height: 190, child: Icon(Icons.directions_car, size: 64))))
                      else
                        const SizedBox(height: 120, child: Center(child: Icon(Icons.directions_car, size: 64))),
                      const SizedBox(height: 12),
                      Text('${data['name'] ?? 'سيارة'} • ${data['year'] ?? ''}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('السعر: ${data['price'] ?? '-'}\nالمدينة: ${data['city'] ?? '-'}\nالنوع: ${data['type'] ?? '-'}\nالبائع: ${data['sellerId'] ?? '-'}'),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(child: FilledButton.icon(onPressed: _loading ? null : () => _setStatus(doc.id, 'approved'), icon: const Icon(Icons.check), label: const Text('قبول'))),
                        const SizedBox(width: 10),
                        Expanded(child: OutlinedButton.icon(onPressed: _loading ? null : () => _setStatus(doc.id, 'rejected'), icon: const Icon(Icons.close), label: const Text('رفض'))),
                      ]),
                    ]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
