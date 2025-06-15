import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../utils/storage_util.dart';

class GradingService {
  final String baseUrl;
  String? _token;

  GradingService({required this.baseUrl});

  void setAuthToken(String token) {
    _token = token;
  }

  Future<String?> _getToken() async {
    if (_token != null) return _token;
    
    // First try the standard token key
    String? token = await StorageUtil.getString('accessToken');

    // If not found or empty, try the alternative key
    if (token == null || token.isEmpty) {
      token = await StorageUtil.getString('schoolToken');
    }

    _token = token;
    return token;
  }

  /// Submit bulk grades for multiple students
  Future<void> submitBulkGrades({
    required String classId,
    required String subjectId,
    required String teacherId,
    required List<Map<String, dynamic>> entries,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }

    final schoolId = await StorageUtil.getString('schoolId');
    if (schoolId == null) {
      throw Exception('No school ID available');
    }

    print('📊 Submitting bulk grades:');
    print('📊 ClassId: $classId');
    print('📊 SubjectId: $subjectId');
    print('📊 TeacherId: $teacherId');
    print('📊 Entries: ${entries.length}');

    final requestBody = {
      'schoolId': schoolId,
      'classId': classId,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'entries': entries,
    };

    print('📊 Request body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse('$baseUrl/grades'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    print('📊 Response status: ${response.statusCode}');
    print('📊 Response body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to submit bulk grades');
    }
  }

  /// Get grades for a specific class and subject
  Future<List<Map<String, dynamic>>> getGradesForClassAndSubject(String classId, String subject) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }

    final schoolId = await StorageUtil.getString('schoolId');
    if (schoolId == null) {
      throw Exception('No school ID available');
    }

    print('📊 Making API call: $baseUrl/grades?schoolId=$schoolId&classId=$classId&subjectId=$subject');

    final response = await http.get(
      Uri.parse('$baseUrl/grades?schoolId=$schoolId&classId=$classId&subjectId=$subject'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print('📊 API Response status: ${response.statusCode}');
    print('📊 API Response body: ${response.body}');

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to load grades');
    }

    final data = jsonDecode(response.body);
    
    // Handle the actual response structure - single grade document with entries
    List<Map<String, dynamic>> grades = [];
    
    if (data['success'] == true && data['data'] != null) {
      final gradeDoc = data['data'] as Map<String, dynamic>;
      final entries = gradeDoc['entries'] as List<dynamic>? ?? [];
      
      for (var entry in entries) {
        // Handle studentId which can be a string or object
        String studentId = '';
        if (entry['studentId'] is String) {
          studentId = entry['studentId'];
        } else if (entry['studentId'] is Map<String, dynamic>) {
          studentId = entry['studentId']['_id'] ?? '';
        }
        
        grades.add({
          '_id': gradeDoc['_id'],
          'studentId': studentId,
          'classId': gradeDoc['classId'],
          'subjectId': gradeDoc['subjectId'],
          'teacherId': gradeDoc['teacherId'],
          'percentage': (entry['percentage'] ?? 0).toDouble(),
          'createdAt': gradeDoc['createdAt'],
          'updatedAt': gradeDoc['updatedAt'],
        });
      }
    }
    
    print('📊 Processed ${grades.length} grade entries');
    return grades;
  }

  /// Get grades for a specific student
  Future<List<Map<String, dynamic>>> getStudentGrades(String studentId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }

    print('📊 Fetching grades for student: $studentId');
    print('📊 Making API call: $baseUrl/grades/student/$studentId');

    final response = await http.get(
      Uri.parse('$baseUrl/grades/student/$studentId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print('📊 API Response status: ${response.statusCode}');
    print('📊 API Response body: ${response.body}');

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to load student grades');
    }

    final data = jsonDecode(response.body);
    List<Map<String, dynamic>> grades = [];
    
    if (data['success'] == true && data['data'] != null) {
      final gradeDocuments = data['data'] as List<dynamic>;
      
      for (var gradeDoc in gradeDocuments) {
        // Find the student's entry in this grade document
        final entries = gradeDoc['entries'] as List<dynamic>? ?? [];
        
        for (var entry in entries) {
          String entryStudentId = '';
          if (entry['studentId'] is String) {
            entryStudentId = entry['studentId'];
          } else if (entry['studentId'] is Map<String, dynamic>) {
            entryStudentId = entry['studentId']['_id'] ?? '';
          }
          
          // Only include entries for the requested student
          if (entryStudentId == studentId) {
            final classInfo = gradeDoc['classId'] as Map<String, dynamic>? ?? {};
            final teacherInfo = gradeDoc['teacherId'] as Map<String, dynamic>? ?? {};
            
            grades.add({
              '_id': gradeDoc['_id'],
              'studentId': entryStudentId,
              'subject': gradeDoc['subjectId'] ?? 'Unknown Subject',
              'className': classInfo['name'] ?? 'Unknown Class',
              'classGrade': classInfo['grade'] ?? '',
              'classSection': classInfo['section'] ?? '',
              'teacherName': teacherInfo['name'] ?? 'Unknown Teacher',
              'teacherId': teacherInfo['teacherId'] ?? '',
              'percentage': (entry['percentage'] ?? 0).toDouble(),
              'createdAt': gradeDoc['createdAt'],
              'updatedAt': gradeDoc['updatedAt'],
            });
          }
        }
      }
    }
    
    print('📊 Processed ${grades.length} grade entries for student');
    return grades;
  }

  /// Helper method to calculate overall student average
  static double calculateOverallAverage(List<Map<String, dynamic>> grades) {
    if (grades.isEmpty) return 0.0;
    
    double totalPercentage = 0.0;
    int count = 0;
    
    for (var grade in grades) {
      final percentage = (grade['percentage'] ?? 0).toDouble();
      totalPercentage += percentage;
      count++;
    }
    
    return count > 0 ? totalPercentage / count : 0.0;
  }
}


