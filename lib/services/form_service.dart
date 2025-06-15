import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../utils/storage_util.dart';

class FormService {
  final String baseUrl;

  FormService({required this.baseUrl});

  Future<String?> _getToken() async {
    // First try the standard token key
    String? token = await StorageUtil.getString('accessToken');

    // If not found or empty, try the alternative key
    if (token == null || token.isEmpty) {
      token = await StorageUtil.getString('schoolToken');
    }

    return token;
  }

  Future<String?> _getSchoolId() async {
    // Get directly from StorageUtil
    return await StorageUtil.getString('schoolId');
  }

  Future<Map<String, String>> _getHeaders({bool jsonContent = true}) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please log in again.');
    }

    final headers = <String, String>{
      'Authorization': 'Bearer $token',
    };

    if (jsonContent) {
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }

  // Get available form types
  Future<ApiResponse> getFormTypes() async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final url = '$baseUrl/forms/types?schoolId=$schoolId';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Handle different response formats
        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('success')) {
          return ApiResponse(
            success: jsonResponse['success'],
            data: jsonResponse['data'],
            message: jsonResponse['message'] ?? 'Form types fetched successfully',
          );
        } else {
          return ApiResponse(
            success: true,
            data: jsonResponse,
            message: 'Form types fetched successfully',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to fetch form types: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('📋 Error getting form types: $e');
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // Submit a new form
  Future<ApiResponse> submitForm({
    required String studentId,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final requestBody = {
        'studentId': studentId,
        'type': type,
        'data': data,
        'schoolId': schoolId,
      };

      print('📋 Submit form request body: $requestBody');

      final url = '$baseUrl/forms?schoolId=$schoolId';
      print('📋 Submit form URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('📋 Submit form response status: ${response.statusCode}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('📋 Response body preview: ${response.body}');
        final jsonResponse = json.decode(response.body);

        // Handle different response formats
        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('success')) {
          return ApiResponse(
            success: jsonResponse['success'],
            data: jsonResponse['data'],
            message: jsonResponse['message'] ?? 'Form submitted successfully',
          );
        } else {
          return ApiResponse(
            success: true,
            data: jsonResponse,
            message: 'Form submitted successfully',
          );
        }
      } else {
        print('📋 Error response body: ${response.body}');
        return ApiResponse(
          success: false,
          message: 'Failed to submit form: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('📋 Error submitting form: $e');
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // Get forms for a specific student
  Future<ApiResponse> getStudentForms(String studentId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      print('📋 Loading forms for student: $studentId');

      final url = '$baseUrl/forms/student/$studentId?schoolId=$schoolId';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Handle different response formats
        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('success')) {
          return ApiResponse(
            success: jsonResponse['success'],
            data: jsonResponse['data'],
            message: jsonResponse['message'] ?? 'Student forms fetched successfully',
          );
        } else {
          return ApiResponse(
            success: true,
            data: jsonResponse,
            message: 'Student forms fetched successfully',
          );
        }
      } else {
        print('📋 Error fetching forms: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: 'Failed to fetch student forms: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('📋 Error getting student forms: $e');
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // Get a specific form by ID
  Future<ApiResponse> getFormById(String formId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      print('📋 Getting form details for ID: $formId with schoolId: $schoolId');
      print('📋 Headers: $headers');

      final url = '$baseUrl/forms/$formId?schoolId=$schoolId';
      print('📋 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📋 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📋 Response body preview: ${response.body}');
        final jsonResponse = json.decode(response.body);

        // Handle different response formats
        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('success')) {
          return ApiResponse(
            success: jsonResponse['success'],
            data: jsonResponse['data'],
            message: jsonResponse['message'] ?? 'Form fetched successfully',
          );
        } else {
          return ApiResponse(
            success: true,
            data: jsonResponse,
            message: 'Form fetched successfully',
          );
        }
      } else {
        print('📋 Error response body: ${response.body}');
        return ApiResponse(
          success: false,
          message: 'Failed to fetch form: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('📋 Error getting form details: $e');
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // Update form status
  Future<ApiResponse> updateFormStatus({
    required String formId,
    required String status,
    required String reviewComment,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final requestBody = {
        'status': status,
        'reviewComment': reviewComment,
        'schoolId': schoolId,
      };

      print('📋 Update form status request body: $requestBody');

      final url = '$baseUrl/forms/$formId/status?schoolId=$schoolId';
      print('📋 Update form status URL: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('📋 Update form status response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📋 Response body preview: ${response.body}');
        final jsonResponse = json.decode(response.body);

        // Handle different response formats
        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('success')) {
          return ApiResponse(
            success: jsonResponse['success'],
            data: jsonResponse['data'],
            message: jsonResponse['message'] ?? 'Form status updated successfully',
          );
        } else {
          return ApiResponse(
            success: true,
            data: jsonResponse,
            message: 'Form status updated successfully',
          );
        }
      } else {
        print('📋 Error response body: ${response.body}');
        return ApiResponse(
          success: false,
          message: 'Failed to update form status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('📋 Error updating form status: $e');
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }
}

