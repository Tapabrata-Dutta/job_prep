import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static String? token;
  static String? userName;
  static String? userEmail;

static String getBaseUrl() {
  if (kIsWeb) {
    return 'http://127.0.0.1:8000/api/auth';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000/api/auth';
  }

  return 'http://127.0.0.1:8000/api/auth';
}

  static bool get isAuthenticated => token != null;

  static Future<bool> signup(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('${getBaseUrl()}/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 8));

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 201 || response.statusCode == 200) {
      token = body['token'] as String?;
      final user = body['user'] as Map<String, dynamic>?;
      userName = user?['name'] as String?;
      userEmail = user?['email'] as String?;
      return true;
    } else {
      throw Exception(body['message'] ?? 'Signup failed');
    }
  }

  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${getBaseUrl()}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 8));

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      token = body['token'] as String?;
      final user = body['user'] as Map<String, dynamic>?;
      userName = user?['name'] as String?;
      userEmail = user?['email'] as String?;
      return true;
    } else {
      throw Exception(body['message'] ?? 'Login failed');
    }
  }

  static void logout() {
    token = null;
    userName = null;
    userEmail = null;
  }
}
