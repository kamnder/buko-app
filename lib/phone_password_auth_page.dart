import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'services/phone_password_auth_service.dart';
import 'services/firebase_service.dart' as buko_service;

class PhonePasswordAuthPage extends StatefulWidget {
  const PhonePasswordAuthPage({super.key});
  @override
  State<PhonePasswordAuthPage> createState() => _PhonePasswordAuthPageState();
}

class _PhonePasswordAuthPageState extends State<PhonePasswordAuthPage> {
  final phone = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  bool register = true, loading = false, obscure = true;
  String error = '';

  @override
  void dispose() {
    phone.dispose();
    password.dispose();
    name.dispose();
    super.dispose();
  }

  String normalize(String value) {
    var p = value.trim().replaceAll(RegExp(r'[^0-9+]'), '');
    if (p.startsWith('00249')) p = '+${p.substring(2)}';
    if (p.startsWith('249')) p = '+$p';
    if (p.startsWith('0') && p.length == 10) p = '+249${p.substring(1)}';
    return p;
  }

  Future<void> submit() async {
    final p = normalize(phone.text);
    if (!RegExp(r'^\+249\d{9}$').hasMatch(p)) {
      setState(() => error = 'أدخل رقم سوداني صحيح مثل 0912345678');
      return;
    }
    if (password.text.length < 6) {
      setState(() => error = 'كلمة المرور يجب أن تكون 6 أحرف أو أرقام على الأقل');
      return;
    }
    if (register && name.text.trim().isEmpty) {
      setState(() => error = 'أدخل اسمك');
      return;
    }
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final credential = register
          ? await PhonePasswordAuthService.instance.register(
              phone: p,
              password: password.text,
              name: name.text.trim(),
            )
          : await PhonePasswordAuthService.instance.login(
              phone: p,
              password: password.text,
            );

      if (register) {
        await buko_service.FirebaseService.instance.saveUserProfile(
          uid: credential.user!.uid,
          name: name.text.trim(),
          phone: p,
          role: 'buyer',
        );
      }

      if (mounted) Navigator.of(context).pop(true);
    } on PhonePasswordAuthException catch (e) {
      setState(() => error = switch (e.code) {
            'phone-already-registered' => 'هذا الرقم مسجل بالفعل. اختر تسجيل الدخول.',
            'invalid-credentials' => 'رقم الهاتف أو كلمة المرور غير صحيحة.',
            'invalid-phone' => 'رقم الهاتف السوداني غير صحيح.',
            'invalid-password' => 'كلمة المرور يجب أن تكون بين 6 و128 خانة.',
            'name-required' => 'أدخل اسمك.',
            'too-many-attempts' => 'تم إيقاف المحاولات مؤقتاً. حاول بعد 15 دقيقة.',
            'auth-endpoint-not-configured' => 'خدمة الدخول لم تُربط بعد.',
            _ => 'تعذر إتمام العملية الآن.',
          });
    } catch (_) {
      setState(() => error = 'تعذر الاتصال بخدمة تسجيل الدخول.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _AuthAnimatedBackground(),
            Container(color: Colors.black.withOpacity(.28)),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      children: [
                        Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB51B),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 22, offset: Offset(0, 8))],
                          ),
                          child: const Icon(Icons.key, color: Colors.black, size: 40),
                        ),
                        const SizedBox(height: 10),
                        const Text('BUKO', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        const Text('سوق السيارات السوداني', style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 22),
                        Card(
                          color: const Color(0xEE0B1017),
                          elevation: 18,
                          shadowColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(register ? 'إنشاء حساب' : 'تسجيل الدخول', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 18),
                                if (register) ...[
                                  TextField(
                                    controller: name,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(labelText: 'الاسم', prefixIcon: Icon(Icons.person_outline)),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                TextField(
                                  controller: phone,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(labelText: 'رقم الهاتف السوداني', hintText: '0912345678', prefixIcon: Icon(Icons.phone)),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: password,
                                  obscureText: obscure,
                                  decoration: InputDecoration(
                                    labelText: 'كلمة المرور',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(() => obscure = !obscure),
                                      icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('رقم الهاتف هو هوية الحساب — بدون SMS وبدون بريد إلكتروني', style: TextStyle(fontSize: 12, color: Colors.white60)),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: loading ? null : submit,
                                    icon: Icon(register ? Icons.person_add : Icons.login),
                                    label: Text(loading ? 'جارٍ التنفيذ...' : register ? 'إنشاء الحساب' : 'دخول'),
                                  ),
                                ),
                                TextButton(
                                  onPressed: loading ? null : () => setState(() { register = !register; error = ''; }),
                                  child: Text(register ? 'لدي حساب بالفعل — تسجيل الدخول' : 'ليس لدي حساب — إنشاء حساب'),
                                ),
                                if (error.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(error, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthAnimatedBackground extends StatefulWidget {
  const _AuthAnimatedBackground();
  @override
  State<_AuthAnimatedBackground> createState() => _AuthAnimatedBackgroundState();
}

class _AuthAnimatedBackgroundState extends State<_AuthAnimatedBackground> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (_, __) => CustomPaint(painter: _AuthScenePainter(controller.value), child: const SizedBox.expand()),
      );
}

class _AuthScenePainter extends CustomPainter {
  final double t;
  _AuthScenePainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final sky = Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF101A29), Color(0xFF8A5034), Color(0xFF0A0E13)]).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);
    canvas.drawCircle(Offset(w * .78, h * .22), math.min(w, h) * .055, Paint()..color = const Color(0xFFFFB51B).withOpacity(.45));
    final city = Paint()..color = const Color(0xFF080D13).withOpacity(.78);
    for (var i = 0; i < 13; i++) { final bh = 42.0 + (i % 5) * 17.0; final bw = 22.0 + (i % 3) * 12.0; canvas.drawRect(Rect.fromLTWH(i * w / 12 - 8, h * .57 - bh, bw, bh), city); }
    final road = Paint()..color = const Color(0xFF06090D);
    final roadPath = Path()..moveTo(0, h * .61)..lineTo(w, h * .55)..lineTo(w, h)..lineTo(0, h)..close();
    canvas.drawPath(roadPath, road);
    final lane = Paint()..color = Colors.white24..strokeWidth = math.max(2, w * .006);
    for (var i = -2; i < 10; i++) { final x = (i * w * .19 + t * w * .65) % (w + 120) - 60; canvas.drawLine(Offset(x, h * .91), Offset(x + w * .08, h * .76), lane); }
    _drawCar(canvas, Offset(w * .14 + math.sin(t * math.pi * 2) * 14, h * .70), .72, false);
    _drawCar(canvas, Offset(w * .57 + math.sin(t * math.pi * 2 + 2) * 18, h * .65), .62, false);
    _drawCar(canvas, Offset(w * .86 + math.sin(t * math.pi * 2 + 4) * 16, h * .78), .52, false);
    _drawCar(canvas, Offset(w * .42, h * .83), 1.12, true);
  }
  void _drawCar(Canvas canvas, Offset p, double z, bool hero) {
    final body = Paint()..color = hero ? const Color(0xFFE4E8EC) : const Color(0xFF28323D);
    final glass = Paint()..color = const Color(0xFF14202B);
    final wheel = Paint()..color = Colors.black;
    final trim = Paint()..color = hero ? const Color(0xFFFFB51B) : Colors.white24;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(p.dx - 64 * z, p.dy - 22 * z, 128 * z, 39 * z), Radius.circular(13 * z)), body);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(p.dx - 36 * z, p.dy - 39 * z, 67 * z, 29 * z), Radius.circular(12 * z)), glass);
    canvas.drawCircle(Offset(p.dx - 42 * z, p.dy + 17 * z), 12 * z, wheel);
    canvas.drawCircle(Offset(p.dx + 42 * z, p.dy + 17 * z), 12 * z, wheel);
    canvas.drawLine(Offset(p.dx - 50 * z, p.dy - 2 * z), Offset(p.dx + 50 * z, p.dy - 2 * z), trim..strokeWidth = 3 * z);
    if (hero) {
      final skin = Paint()..color = const Color(0xFF70462F);
      final cloth = Paint()..color = Colors.white;
      final dark = Paint()..color = const Color(0xFF1B1A1A);
      canvas.drawCircle(Offset(p.dx + 2 * z, p.dy - 48 * z), 14 * z, skin);
      canvas.drawOval(Rect.fromCenter(center: Offset(p.dx + 2 * z, p.dy - 59 * z), width: 35 * z, height: 19 * z), cloth);
      canvas.drawOval(Rect.fromCenter(center: Offset(p.dx - 5 * z, p.dy - 64 * z), width: 25 * z, height: 10 * z), cloth);
      canvas.drawLine(Offset(p.dx - 7 * z, p.dy - 41 * z), Offset(p.dx - 20 * z, p.dy - 25 * z), dark..strokeWidth = 6 * z);
    }
  }
  @override
  bool shouldRepaint(covariant _AuthScenePainter oldDelegate) => oldDelegate.t != t;
}
