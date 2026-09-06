import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

import 'admin_page.dart';
import 'services/phone_password_auth_service.dart';

const _gold = Color(0xFFFFB51B);
const _ink = Color(0xFF080B10);
const _panel = Color(0xFF11161E);

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final phone = TextEditingController(text: '0909976346');
  final password = TextEditingController();
  bool loading = false;
  bool obscure = true;
  String error = '';

  @override
  void dispose() {
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      await PhonePasswordAuthService.instance.login(
        phone: phone.text,
        password: password.text,
      );
      final user = auth.FirebaseAuth.instance.currentUser;
      final token = await user?.getIdTokenResult(true);
      if (token?.claims?['admin'] != true) {
        await auth.FirebaseAuth.instance.signOut();
        throw const PhonePasswordAuthException('not-admin');
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminPage()),
      );
    } on PhonePasswordAuthException catch (e) {
      setState(() => error = switch (e.code) {
            'invalid-credentials' => 'بيانات الدخول غير صحيحة.',
            'too-many-attempts' => 'تم إيقاف المحاولات مؤقتاً. حاول لاحقاً.',
            'invalid-phone' => 'رقم الهاتف غير صحيح.',
            'invalid-password' => 'أدخل كلمة المرور.',
            'not-admin' => 'هذا الحساب لا يملك صلاحية الإدارة.',
            _ => 'تعذر تسجيل الدخول الآن.',
          });
    } catch (_) {
      setState(() => error = 'تعذر تسجيل الدخول الآن.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _ink,
        appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('BUKO')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Card(
                color: _panel,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      const Icon(Icons.lock_rounded, color: _gold, size: 58),
                      const SizedBox(height: 10),
                      const Text('دخول آمن', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 22),
                      TextField(
                        controller: phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: password,
                        obscureText: obscure,
                        onSubmitted: (_) => loading ? null : login(),
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.key_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => obscure = !obscure),
                            icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: loading ? null : login,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: Text(loading ? 'جارٍ التحقق...' : 'متابعة'),
                        ),
                      ),
                      if (error.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(error, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
