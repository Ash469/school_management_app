import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_auth_service.dart';
import 'class_services.dart';

class AnalyticsService {
  final String baseUrl;
  final ApiAuthService _authService = ApiAuthService();
  late final ClassService _classService;

  AnalyticsService({required this.baseUrl}) {
    _classService = ClassService(baseUrl: baseUrl);
  }


  Future<List<Map<String, dynamic>>> getAttendanceAnalytics({
    required String classId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final url = '$baseUrl/analytics/attendance?classId=$classId&startDate=$startDate&endDate=$endDate';
      print('📊 Analytics attendance URL: $url');
      print('📊 Headers: $headers');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📊 Analytics response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📊 Response body preview: ${response.body}');
        
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // Handle the response format with success and data fields
        if (jsonResponse.containsKey('success') && jsonResponse.containsKey('data')) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else {
          // Handle direct array response format
          final List<dynamic> data = json.decode(response.body);
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
      } else {
        print('📊 Error response body: ${response.body}');
        throw Exception('Failed to load attendance analytics: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📊 Error getting attendance analytics: $e');
      throw Exception('Error getting attendance analytics: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllClasses() async {
    try {
      return await _classService.getAllClasses();
    } catch (e) {
      print('📊 Error getting classes for analytics: $e');
      throw Exception('Error getting classes for analytics: $e');
    }
  }

  Future<Map<String, dynamic>> getClassById(String classId) async {
    try {
      return await _classService.getClassById(classId);
    } catch (e) {
      print('📊 Error getting class details for analytics: $e');
      throw Exception('Error getting class details for analytics: $e');
    }
  }


  // Update the existing getGradeAnalytics method to handle the new endpoint format
  Future<Map<String, dynamic>> getGradeAnalytics({
    required String classId,
    required String subject,
  }) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final url = '$baseUrl/analytics/grades?classId=$classId&subject=$subject';
      print('📊 Analytics grades URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📊 Grade analytics response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse.containsKey('success') && jsonResponse.containsKey('data')) {
          return jsonResponse['data'] as Map<String, dynamic>;
        } else {
          return jsonResponse;
        }
      } else {
        print('📊 Error response body: ${response.body}');
        throw Exception('Failed to load grade analytics: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📊 Error getting grade analytics: $e');
      throw Exception('Error getting grade analytics: $e');
    }
  }

  // Add a new method to get grade analytics with date range (keeping the old one for backwards compatibility)
  Future<List<Map<String, dynamic>>> getGradeAnalyticsWithDateRange({
    required String classId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final url = '$baseUrl/analytics/grades?classId=$classId&startDate=$startDate&endDate=$endDate';
      print('📊 Analytics grades with date range URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📊 Grade analytics with date range response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse.containsKey('success') && jsonResponse.containsKey('data')) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else {
          final List<dynamic> data = json.decode(response.body);
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
      } else {
        print('📊 Error response body: ${response.body}');
        throw Exception('Failed to load grade analytics: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📊 Error getting grade analytics with date range: $e');
      throw Exception('Error getting grade analytics with date range: $e');
    }
  }

  Future<Map<String, dynamic>> getSchoolOverviewAnalytics() async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final url = '$baseUrl/analytics/school?schoolId=$schoolId';
      print('📊 School overview analytics URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📊 School overview response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse.containsKey('success') && jsonResponse.containsKey('data')) {
          return jsonResponse['data'] as Map<String, dynamic>;
        } else {
          return jsonResponse;
        }
      } else {
        print('📊 Error response body: ${response.body}');
        throw Exception('Failed to load school analytics: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📊 Error getting school analytics: $e');
      throw Exception('Error getting school analytics: $e');
    }
  }
}
