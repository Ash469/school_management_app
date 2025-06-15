import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/assignment_model.dart';
import '../utils/storage_util.dart';

class AssignmentService {
  static const String baseUrl = 'http://localhost:3000/assignments';
  
  static Future<String?> _getToken() async {
    // First try the standard token key
    String? token = await StorageUtil.getString('accessToken');

    // If not found or empty, try the alternative key
    if (token == null || token.isEmpty) {
      token = await StorageUtil.getString('schoolToken');
    }

    return token;
  }

  static Future<String?> _getSchoolId() async {
    return await StorageUtil.getString('schoolId');
  }

  static Future<Map<String, String>> _getHeaders({bool jsonContent = true}) async {
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
  
  // Get all assignments with optional filters
  static Future<List<Assignment>> getAssignments({
    String? classId,
    String? teacherId,
  }) async {
    try {
      final schoolId = await _getSchoolId();
      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found. Please log in again.');
      }

      List<String> queryParams = ['schoolId=$schoolId'];
      
      if (classId != null) queryParams.add('classId=$classId');
      if (teacherId != null) queryParams.add('teacherId=$teacherId');
      
      final url = '$baseUrl?${queryParams.join('&')}';
      print('📝 Get assignments URL: $url');

      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      print('📝 Get assignments response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> assignmentsJson = data['data'];
          return assignmentsJson.map((json) => Assignment.fromJson(json)).toList();
        }
        throw Exception('Invalid response format');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch assignments');
      }
    } catch (e) {
      throw Exception('Failed to fetch assignments: $e');
    }
  }

  // Create a new assignment
  static Future<Assignment> createAssignment(Assignment assignment) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();
      
      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found. Please log in again.');
      }

      final requestBody = {
        'teacherId': assignment.teacherId,
        'classId': assignment.classId,
        'subject': assignment.subject,
        'title': assignment.title,
        'description': assignment.description,
        'dueDate': assignment.dueDate.toIso8601String(),
        'assignedAt': assignment.assignedAt.toIso8601String(),
        'schoolId': schoolId,
      };

      // Add schoolId to both query params and body like attendance service
      final url = '$baseUrl?schoolId=$schoolId';
      print('📝 Creating assignment with URL: $url');
      print('📝 Creating assignment with data: $requestBody');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('📝 Create assignment response status: ${response.statusCode}');
      print('📝 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Assignment.fromJson(data['data']);
        }
        throw Exception('Invalid response format');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create assignment');
      }
    } catch (e) {
      print('📝 Error creating assignment: $e');
      throw Exception('Failed to create assignment: $e');
    }
  }

  // Get assignment by ID
  static Future<Assignment> getAssignmentById(String assignmentId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();
      
      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found. Please log in again.');
      }

      final url = '$baseUrl/$assignmentId?schoolId=$schoolId';
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Assignment.fromJson(data['data']['assignment']);
        }
        throw Exception('Invalid response format');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch assignment');
      }
    } catch (e) {
      throw Exception('Failed to fetch assignment: $e');
    }
  }

  // Update assignment
  static Future<Assignment> updateAssignment(String assignmentId, Map<String, dynamic> updates) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();
      
      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found. Please log in again.');
      }

      // Add schoolId to the updates
      updates['schoolId'] = schoolId;

      final url = '$baseUrl/$assignmentId?schoolId=$schoolId';
      print('📝 Update assignment URL: $url');
      print('📝 Update assignment data: $updates');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(updates),
      );

      print('📝 Update assignment response status: ${response.statusCode}');
      print('📝 Update assignment response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Assignment.fromJson(data['data']);
        }
        throw Exception('Invalid response format');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update assignment');
      }
    } catch (e) {
      print('📝 Error updating assignment: $e');
      throw Exception('Failed to update assignment: $e');
    }
  }

  // Delete assignment
  static Future<void> deleteAssignment(String assignmentId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();
      
      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found. Please log in again.');
      }

      final url = '$baseUrl/$assignmentId?schoolId=$schoolId';
      final response = await http.delete(Uri.parse(url), headers: headers);

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete assignment');
      }
    } catch (e) {
      throw Exception('Failed to delete assignment: $e');
    }
  }

  // Get submissions for an assignment
  static Future<List<Submission>> getAssignmentSubmissions(String assignmentId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();
      
      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found. Please log in again.');
      }

      final url = '$baseUrl/$assignmentId/submissions?schoolId=$schoolId';
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> submissionsJson = data['data']['submissions'] ?? [];
          return submissionsJson.map((json) => Submission.fromJson(json)).toList();
        }
        throw Exception('Invalid response format');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch submissions');
      }
    } catch (e) {
      throw Exception('Failed to fetch submissions: $e');
    }
  }

  // Provide feedback on submission
  static Future<Submission> provideFeedback(
    String assignmentId, 
    String submissionId, 
    String grade, 
    String feedback
  ) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();
      
      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found. Please log in again.');
      }

      final requestBody = {
        'grade': grade,
        'feedback': feedback,
        'schoolId': schoolId,
      };

      final url = '$baseUrl/$assignmentId/submissions/$submissionId/feedback?schoolId=$schoolId';
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Submission.fromJson(data['data']['submission']);
        }
        throw Exception('Invalid response format');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to provide feedback');
      }
    } catch (e) {
      throw Exception('Failed to provide feedback: $e');
    }
  }
}
