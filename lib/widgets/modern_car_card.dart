import 'package:flutter/material.dart';

import '../services/firebase_service.dart';

const _gold = Color(0xFFFFB51B);
const _panel = Color(0xFF11161E);
const _muted = Color(0xFF9BA6B5);

class ModernCarCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String id;

  const ModernCarCard({super.key, required this.data, required this.id});

  @override
  State<ModernCarCard> createState() => _ModernCarCardState();
}

class _ModernCarCardState extends State<ModernCarCard> {
  bool _sending = false;

  List<String> get _images => (widget.data['imageUrls'] is List)
      ? (widget.data['imageUrls'] as List)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList()
      : const [];

  String get _name => (widget.data['name'] ?? 'سيارة').toString().trim();
  String get _price => (widget.data['price'] ?? '').toString().trim();
  String get _city => (widget.data['city'] ?? '').toString().trim();
  String get _type => (widget.data['type'] ?? '').toString().trim();
  String get _year => (widget.data['year'] ?? '').toString().trim();
  String get _sellerId => (widget.data['sellerId'] ?? '').toString().trim();

  Future<void> _buy() async {
    if (_sending) return;
    final user = FirebaseService.instance.currentUser;
    if (user == null) return;

    if (_sellerId == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكنك شراء سيارتك من حسابك.')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      await FirebaseService.instance.createPurchaseRequest(
        carId: widget.id,
        sellerId: _sellerId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب الشراء بنجاح.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Bad state: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _images.isEmpty ? null : _images.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(.08)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 22, offset: Offset(0, 10)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 205,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (image != null)
                  Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _CarPlaceholder(),
                  )
                else
                  const _CarPlaceholder(),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xCC000000)],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      _type.isEmpty ? 'سيارة' : _type,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                Positioned(
                  right: 14,
                  left: 14,
                  bottom: 13,
                  child: Text(
                    _name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _Spec(icon: Icons.calendar_month_rounded, text: _year),
                    const SizedBox(width: 8),
                    if (_city.isNotEmpty)
                      _Spec(icon: Icons.location_on_outlined, text: _city),
                    const Spacer(),
                    if (_price.isNotEmpty)
                      Text(
                        '$_price جنيه',
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _sending ? null : _buy,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.shopping_cart_checkout_rounded),
                    label: Text(_sending ? 'جارٍ الإرسال...' : 'شراء'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: _gold.withOpacity(.45),
                      disabledForegroundColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Spec({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _gold),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarPlaceholder extends StatelessWidget {
  const _CarPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF18202A),
        child: const Center(
          child: Icon(Icons.directions_car_filled_rounded, color: _gold, size: 72),
        ),
      );
}
