import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:http/http.dart' as http;

class PhonePasswordAuthService {
  PhonePasswordAuthService._();
  static final instance = PhonePasswordAuthService._();

  // Public Worker endpoint; the build may override it with BUKO_AUTH_ENDPOINT.
  static const endpoint = String.fromEnvironment(
    'BUKO_AUTH_ENDPOINT',
    defaultValue: 'https://buko-auth-worker.buko-auth.workers.dev',
  );

  Future<auth.UserCredential> register({
    required String phone,
    required String password,
    required String name,
  }) => _request(action: 'register', phone: phone, password: password, name: name);

  Future<auth.UserCredential> login({
    required String phone,
    required String password,
  }) => _request(action: 'login', phone: phone, password: password);

  Future<auth.UserCredential> _request({
    required String action,
    required String phone,
    required String password,
    String? name,
  }) async {
    final path = action == 'register' ? '/auth/register' : '/auth/login';
    final response = await http.post(
      Uri.parse('$endpoint$path'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'password': password,
        if (name != null) 'name': name,
      }),
    );

    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {}

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PhonePasswordAuthException(data['error']?.toString() ?? 'server-error');
    }

    final token = data['token']?.toString();
    if (token == null || token.isEmpty) {
      throw const PhonePasswordAuthException('server-error');
    }

    return auth.FirebaseAuth.instance.signInWithCustomToken(token);
  }
}

class PhonePasswordAuthException implements Exception {
  final String code;
  const PhonePasswordAuthException(this.code);
}
