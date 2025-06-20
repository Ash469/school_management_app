import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  // Signup
  Future<http.Response> signup(Map<String, dynamic> userDetails) async {
    final url = Uri.parse('$baseUrl/auth/signup');
    return await http.post(url, body: jsonEncode(userDetails), headers: {
      'Content-Type': 'application/json',
    });
  }

  // Login
  Future<http.Response> login(Map<String, dynamic> credentials) async {
    final url = Uri.parse('$baseUrl/auth/login');
    return await http.post(url, body: jsonEncode(credentials), headers: {
      'Content-Type': 'application/json',
    });
  }

  // Refresh Token
  Future<http.Response> refreshToken(String refreshToken) async {
    final url = Uri.parse('$baseUrl/auth/refresh');
    return await http.post(url, body: jsonEncode({'refreshToken': refreshToken}), headers: {
      'Content-Type': 'application/json',
    });
  }

  // Forgot Password
  Future<http.Response> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/auth/forgot-password');
    return await http.post(url, body: jsonEncode({'email': email}), headers: {
      'Content-Type': 'application/json',
    });
  }

  // Reset Password
  Future<http.Response> resetPassword(String token, String newPassword) async {
    final url = Uri.parse('$baseUrl/auth/reset-password');
    return await http.post(url, body: jsonEncode({'token': token, 'password': newPassword}), headers: {
      'Content-Type': 'application/json',
    });
  }

  // Logout
  Future<http.Response> logout(String accessToken) async {
    final url = Uri.parse('$baseUrl/auth/logout');
    return await http.post(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    });
  }


  // Bulk Signup
  Future<http.Response> bulkSignup(List<Map<String, dynamic>> rows, String accessToken) async {
    final url = Uri.parse('$baseUrl/auth/bulk-upload');
    return await http.post(url, body: jsonEncode({'rows': rows}), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    });
  }
}
