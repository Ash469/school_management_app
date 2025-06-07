import 'dart:convert';
import 'dart:math' as Math;
import 'package:http/http.dart' as http;
import '../utils/storage_util.dart';

class ClassService {
  final String baseUrl;

  ClassService({required this.baseUrl});

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

  Future<List<Map<String, dynamic>>> getAllClasses() async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      print('📊 Making API request for classes with schoolId: $schoolId');
      print('📊 Headers: $headers');

      final url = '$baseUrl/classes?schoolId=$schoolId';
      print('📊 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📊 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📊 Response body preview: ${response.body}');
        // Parse the outer JSON structure first
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // Check if the response has a 'success' and 'data' field (new format)
        if (jsonResponse.containsKey('success') && jsonResponse.containsKey('data')) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else {
          // Handle the old format where response is directly an array
          final List<dynamic> data = json.decode(response.body);
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
      } else {
        print('📊 Error response body: ${response.body}');
        throw Exception('Failed to load classes: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📊 Error getting classes: $e');
      throw Exception('Error getting classes: $e');
    }
  }

  Future<Map<String, dynamic>> getClassById(String classId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null) {
        throw Exception('School ID not found');
      }

      print('📊 Getting class details for ID: $classId with schoolId: $schoolId');
      print('📊 Headers: $headers');
      
      final url = '$baseUrl/classes/$classId?schoolId=$schoolId';
      print('📊 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        // Check if the response is wrapped in a data object (new API format)
        if (responseData is Map<String, dynamic> && 
            responseData.containsKey('success') && 
            responseData.containsKey('data')) {
          final data = responseData['data'];
          
          // If data is null or empty, return an empty map to prevent null errors
          if (data == null) {
            return {};
          }
          
          // If data is a list with one item, return the first item
          if (data is List && data.isNotEmpty) {
            return data[0] as Map<String, dynamic>;
          }
          
          // If data is a map, return it directly
          if (data is Map<String, dynamic>) {
            return data;
          }
          
          // Fallback to empty map if data is in an unexpected format
          return {};
        } else if (responseData is Map<String, dynamic>) {
          // Direct response object (old API format)
          return responseData;
        } else {
          // Unexpected format, return empty map to prevent errors
          return {};
        }
      } else {
        print('📊 Error response body: ${response.body}');
        throw Exception('Failed to load class details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📊 Error getting class details: $e');
      throw Exception('Error getting class details: $e');
    }
  }

  Future<Map<String, dynamic>> createClass({
    required String name,
    required String grade,
    required String section,
    required String year,
    required List<String> subjects,
    List<String> teachers = const [],
    List<String> students = const [],
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      final body = json.encode({
        'name': name,
        'grade': grade,
        'section': section,
        'year': year,
        'subjects': subjects,
        'teachers': teachers,
        'students': students,
        'schoolId': schoolId,
        'analytics': {
          'attendancePct': 0,
          'avgGrade': 0,
          'passPct': 0
        }
      });

      final response = await http.post(
        Uri.parse('$baseUrl/classes'),
        headers: headers,
        body: body,
      );

      print('📊 Create class response status: ${response.statusCode}');
      print('📊 Response body preview: ${response.body}');

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        
        // Handle the new response format with success and data fields
        if (jsonResponse is Map<String, dynamic> && 
            jsonResponse.containsKey('success') && 
            jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }
        
        // Handle the old format where response is directly the class object
        return jsonResponse;
      } else {
        throw Exception('Failed to create class: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📊 Error creating class: $e');
      throw Exception('Error creating class: $e');
    }
  }

  Future<Map<String, dynamic>> updateClass({
    required String classId,
    String? name,
    String? grade,
    String? section,
    String? year,
    List<String>? teacherIds,
    List<String>? subjects,
    List<String>? studentIds,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final Map<String, dynamic> updateData = {'schoolId': schoolId};
      if (name != null) updateData['name'] = name;
      if (grade != null) updateData['grade'] = grade;
      if (section != null) updateData['section'] = section;
      if (year != null) updateData['year'] = year;
      if (teacherIds != null) updateData['teachers'] = teacherIds;
      if (subjects != null) updateData['subjects'] = subjects;
      if (studentIds != null) updateData['students'] = studentIds;

      final body = json.encode(updateData);

      // Use the exact URL format that works: http://localhost:3000/classes/{id}?schoolId=...
      final url = '$baseUrl/classes/$classId?schoolId=$schoolId';
      print('📊 Update class URL: $url');
      print('📊 Update class body: $body');
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('📊 Update class response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📊 Response body preview: ${response.body}');
        final jsonResponse = json.decode(response.body);
        
        // Handle the new response format with success and data fields
        if (jsonResponse is Map<String, dynamic> && 
            jsonResponse.containsKey('success') && 
            jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }
        
        // Handle the old format where response is directly the class object
        return jsonResponse;
      } else {
        print('📊 Error response body: ${response.body}');
        throw Exception('Failed to update class: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📊 Error updating class: $e');
      throw Exception('Error updating class: $e');
    }
  }

  Future<void> deleteClass(String classId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();
      final url = '$baseUrl/classes/$classId?schoolId=$schoolId';
      print('📊 Delete URL: $url');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete class: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting class: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getClassTeachers(String classId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      final url = '$baseUrl/classes/$classId/teachers?schoolId=$schoolId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load class teachers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting class teachers: $e');
    }
  }

  Future<List<Map<String, dynamic>>> setClassTeachers(String classId, List<String> teacherIds) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final body = json.encode({
        'teacherIds': teacherIds,
        'schoolId': schoolId,
      });

      final url = '$baseUrl/classes/$classId/teachers?schoolId=$schoolId';
      print('📊 Set class teachers URL: $url');
      print('📊 Set class teachers body: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('📊 Set class teachers response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📊 Response body preview: ${response.body}');
        final jsonResponse = json.decode(response.body);
        
        // Handle the new response format with success and data fields
        if (jsonResponse is Map<String, dynamic> && 
            jsonResponse.containsKey('success') && 
            jsonResponse.containsKey('data')) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        
        // Handle the old format where response is directly an array
        if (jsonResponse is List) {
          return jsonResponse.map((item) => item as Map<String, dynamic>).toList();
        }
        
        throw Exception('Unexpected response format');
      } else {
        print('📊 Error response body: ${response.body}');
        throw Exception('Failed to set class teachers: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📊 Error setting class teachers: $e');
      throw Exception('Error setting class teachers: $e');
    }
  }

  Future<List<String>> getClassSubjects(String classId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();


      final url = '$baseUrl/classes/$classId/subjects?schoolId=$schoolId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item.toString()).toList();
      } else {
        throw Exception('Failed to load class subjects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting class subjects: $e');
    }
  }

  Future<List<String>> setClassSubjects(String classId, List<String> subjects) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final body = json.encode({
        'subjects': subjects,
        'schoolId': schoolId,
      });

      final url = '$baseUrl/classes/$classId?schoolId=$schoolId';
      print('📊 Set class subjects URL: $url');
      print('📊 Set class subjects body: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('📊 Set class subjects response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📊 Response body preview: ${response.body}');
        final jsonResponse = json.decode(response.body);
        
        // Handle the new response format with success and data fields
        if (jsonResponse is Map<String, dynamic> && 
            jsonResponse.containsKey('success') && 
            jsonResponse.containsKey('data')) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((item) => item.toString()).toList();
        }
        
        // Handle the old format where response is directly an array
        if (jsonResponse is List) {
          return jsonResponse.map((item) => item.toString()).toList();
        }
        
        return [];
      } else {
        print('📊 Error response body: ${response.body}');
        throw Exception('Failed to set class subjects: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📊 Error setting class subjects: $e');
      throw Exception('Error setting class subjects: $e');
    }
  }

  Future<Map<String, dynamic>> getClassAnalytics(String classId) async {
    try {
      // Reuse the existing getClassById method to fetch class data
      final classData = await getClassById(classId);
      
      // Extract analytics data from the response
      if (classData.containsKey('analytics')) {
        return classData['analytics'] as Map<String, dynamic>;
      } else {
        // Return default analytics object if not found
        return {
          'attendancePct': 0,
          'avgGrade': 0, 
          'passPct': 0
        };
      }
    } catch (e) {
      print('📊 Error getting class analytics: $e');
      throw Exception('Error getting class analytics: $e');
    }
  }
}
