import 'package:flutter/material.dart';
import 'services/phone_password_auth_service.dart';

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
  void dispose() { phone.dispose(); password.dispose(); name.dispose(); super.dispose(); }

  String normalize(String value) {
    var p = value.trim().replaceAll(RegExp(r'[^0-9+]'), '');
    if (p.startsWith('00249')) p = '+${p.substring(2)}';
    if (p.startsWith('249')) p = '+$p';
    if (p.startsWith('0') && p.length == 10) p = '+249${p.substring(1)}';
    return p;
  }

  Future<void> submit() async {
    final p = normalize(phone.text);
    if (!RegExp(r'^\+249\d{9}$').hasMatch(p)) { setState(() => error = 'أدخل رقم سوداني صحيح مثل 0912345678'); return; }
    if (password.text.length < 6) { setState(() => error = 'كلمة المرور يجب أن تكون 6 أحرف أو أرقام على الأقل'); return; }
    if (register && name.text.trim().isEmpty) { setState(() => error = 'أدخل اسمك'); return; }
    setState(() { loading = true; error = ''; });
    try {
      if (register) {
        await PhonePasswordAuthService.instance.register(phone: p, password: password.text, name: name.text.trim());
      } else {
        await PhonePasswordAuthService.instance.login(phone: p, password: password.text);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on PhonePasswordAuthException catch (e) {
      setState(() => error = switch (e.code) {
        'phone-already-registered' => 'هذا الرقم مسجل بالفعل. اختر تسجيل الدخول.',
        'invalid-credentials' => 'رقم الهاتف أو كلمة المرور غير صحيحة.',
        'invalid-phone' => 'رقم الهاتف السوداني غير صحيح.',
        'invalid-password' => 'كلمة المرور يجب أن تكون بين 6 و128 خانة.',
        'name-required' => 'أدخل اسمك.',
        _ => 'تعذر إتمام العملية الآن.',
      });
    } catch (_) {
      setState(() => error = 'تعذر الاتصال بخدمة تسجيل الدخول.');
    } finally { if (mounted) setState(() => loading = false); }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      body: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: Column(children: [
          const Icon(Icons.directions_car, size: 76, color: Color(0xFFD4AF37)),
          const SizedBox(height: 12),
          const Text('BUKO', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('سوق السيارات السوداني', style: TextStyle(fontSize: 17)),
          const SizedBox(height: 30),
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
            Text(register ? 'إنشاء حساب' : 'تسجيل الدخول', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            if (register) ...[
              TextField(controller: name, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'الاسم', prefixIcon: Icon(Icons.person_outline))),
              const SizedBox(height: 12),
            ],
            TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف السوداني', hintText: '0912345678', prefixIcon: Icon(Icons.phone))),
            const SizedBox(height: 12),
            TextField(controller: password, obscureText: obscure, decoration: InputDecoration(labelText: 'كلمة المرور', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility : Icons.visibility_off)))),
            const SizedBox(height: 8),
            const Align(alignment: Alignment.centerRight, child: Text('دخول آمن بدون SMS أو بريد إلكتروني', style: TextStyle(fontSize: 12, color: Colors.white60))),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: loading ? null : submit, icon: Icon(register ? Icons.person_add : Icons.login), label: Text(loading ? 'جارٍ التنفيذ...' : register ? 'إنشاء الحساب' : 'دخول'))),
            TextButton(onPressed: loading ? null : () => setState(() { register = !register; error = ''; }), child: Text(register ? 'لدي حساب بالفعل — تسجيل الدخول' : 'ليس لدي حساب — إنشاء حساب')),
            if (error.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center)),
          ]))),
        ])),
      ))),
    ),
  );
}
