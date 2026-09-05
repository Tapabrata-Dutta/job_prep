import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:place_prep/models/application_model.dart';

import 'package:place_prep/services/auth_service.dart';
class ApplicationService {
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (AuthService.token != null) 'Authorization': 'Bearer ${AuthService.token}',
      };

static String getBaseUrl() {
  if (kIsWeb) {
    return 'http://16.192.27.45:8000/api/applications';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000/api/applications';
  }

  return 'http://16.192.27.45:8000/api/applications';
}

  static Future<List<ApplicationItem>> fetchApplications() async {
    final response = await http.get(Uri.parse(getBaseUrl()), headers: _headers).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('Failed to load applications');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>?;
    return data?.map((item) => ApplicationItem.fromJson(item as Map<String, dynamic>)).toList() ?? [];
  }

  static Future<ApplicationItem> createApplication(String name, bool applied, String status) async {
    final response = await http.post(
      Uri.parse(getBaseUrl()),
      headers: _headers,
      body: jsonEncode({'name': name, 'applied': applied, 'status': status}),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode != 201 && response.statusCode != 200) {
      final body = jsonDecode(response.body.toString()) as Map<String, dynamic>?;
      throw Exception(body?['message'] ?? 'Failed to create application');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return ApplicationItem.fromJson(body['data'] as Map<String, dynamic>);
  }

  static Future<void> updateApplication(int id, {String? name, bool? applied, String? status}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (applied != null) body['applied'] = applied;
    if (status != null) body['status'] = status;

    final response = await http.put(
      Uri.parse('${getBaseUrl()}/$id'),
      headers: _headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Failed to update application');
    }
  }

  static Future<void> deleteApplication(int id) async {
    final response = await http.delete(
      Uri.parse('${getBaseUrl()}/$id'),
      headers: _headers,
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete application');
    }
  }
}
