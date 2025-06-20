import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_auth_service.dart';

class StudentService {
  final String baseUrl;
  final ApiAuthService _authService = ApiAuthService();

  StudentService({required this.baseUrl});

 
  /// Create user account via auth/signup
  Future<Map<String, dynamic>> createUserAccount({
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String dob,
    required String password,
    required String studentId,
    required String classId,
    required String schoolId,
  }) async {
    try {
      final Map<String, dynamic> signupData = {
        'name': name,
        'email': email,
        'password': password,
        'role': 'student',
        'phone': phone,
        'dob': dob,
        'gender': gender,
        'studentId': studentId,
        'classId': classId,
        'schoolId': schoolId,
      };

      final body = json.encode(signupData);

      print('👤 Creating student user account with data: $signupData');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('👤 Student user account created successfully: ${response.body}');
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create student user account: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating student user account: $e');
    }
  }

  /// Get all students
  Future<List<Map<String, dynamic>>> getAllStudents({String? classId, int page = 1, int limit = 20}) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      // Build query parameters
      final queryParams = {
        'schoolId': schoolId,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (classId != null && classId.isNotEmpty) {
        queryParams['classId'] = classId;
      }

      final uri = Uri.parse('$baseUrl/students').replace(queryParameters: queryParams);
      
      print('👨‍🎓 Making API request for students with schoolId: $schoolId');
      print('👨‍🎓 Headers: $headers');
      print('👨‍🎓 URL: $uri');

      final response = await http.get(
        uri,
        headers: headers,
      );

      print('👨‍🎓 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('👨‍🎓 Response body preview: ${response.body}');

        // Parse the JSON response
        final jsonResponse = json.decode(response.body);

        List<dynamic> data;
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('success') &&
            jsonResponse.containsKey('data')) {
          data = jsonResponse['data'];
        }
        // Handle the direct array response format
        else if (jsonResponse is List) {
          data = jsonResponse;
        } else {
          throw Exception('Unexpected response format');
        }
        
        // Filter the students to ensure they match the stored schoolId
        final filteredData = data.where((item) {
          if (item is Map<String, dynamic>) {
            // Check if the student has a schoolId field that matches our stored schoolId
            return item['schoolId'] == schoolId;
          }
          return false;
        }).toList();
        
        return filteredData.map((item) => item as Map<String, dynamic>).toList();
      } else {
        print('👨‍🎓 Error response body: ${response.body}');
        throw Exception('Failed to load students: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👨‍🎓 Error getting students: $e');
      throw Exception('Error getting students: $e');
    }
  }

  /// Get a student by ID
  Future<Map<String, dynamic>> getStudentById(String studentId) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      print('👨‍🎓 Getting student details for ID: $studentId with schoolId: $schoolId');
      print('👨‍🎓 Headers: $headers');

      final url = '$baseUrl/students/$studentId?schoolId=$schoolId';
      print('👨‍🎓 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('👨‍🎓 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        print('👨‍🎓 Full response data: $responseData');

        Map<String, dynamic> studentData;

        // Check if the response is wrapped in a success/data object (new API format)
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('success') &&
            responseData.containsKey('data')) {
          studentData = responseData['data'] as Map<String, dynamic>;
        }
        // Direct response object (old API format)
        else if (responseData is Map<String, dynamic>) {
          studentData = responseData;
        } else {
          throw Exception('Unexpected response format: expected Map but got ${responseData.runtimeType}');
        }

        // Validate that we have the essential student data
        if (!studentData.containsKey('_id') || !studentData.containsKey('name')) {
          throw Exception('Invalid student data: missing required fields');
        }

        print('👨‍🎓 Processed student data: ${studentData['name']} (${studentData['_id']})');
        return studentData;
      } else {
        print('👨‍🎓 Error response body: ${response.body}');
        throw Exception('Failed to load student details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👨‍🎓 Error getting student details: $e');
      throw Exception('Error getting student details: $e');
    }
  }

  /// Create a new student using /auth/signup endpoint
  Future<Map<String, dynamic>> createStudent({
    required String studentId,
    required String name,
    required String classId,
    String? dob,
    String? gender,
    String? address,
    String? phone,
    String? email,
    bool feePaid = false,
    List<Map<String, dynamic>>? parents,
  }) async {
    try {
      final schoolId = await _authService.getSchoolId();
      final schoolSecretKey = await _authService.getSchoolSecretKey();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      if (schoolSecretKey == null || schoolSecretKey.isEmpty) {
        throw Exception('School secret key not found');
      }

      if (email == null || email.isEmpty) {
        throw Exception('Email is required for student registration');
      }

      // Prepare parent data with passwords (using school secret key)
      List<Map<String, dynamic>> processedParents = [];
      if (parents != null && parents.isNotEmpty) {
        processedParents = parents.map((parent) {
          final processedParent = Map<String, dynamic>.from(parent);
          // Add password field using school secret key for each parent
          processedParent['password'] = schoolSecretKey;
          return processedParent;
        }).toList();
      }

      // Create the complete signup payload
      final Map<String, dynamic> signupData = {
        'name': name,
        'email': email,
        'password': schoolSecretKey, // Use school secret key as password
        'role': 'student',
        'studentId': studentId,
        'classId': classId,
        'schoolId': schoolId,
        'gender': gender, // Ensure gender is included
        'dob': dob,       // Ensure dob is included
        'phone': phone,
        'parents': processedParents,
      };

      // Add optional fields if provided
      if (address != null && address.isNotEmpty) signupData['address'] = address;

      final body = json.encode(signupData);

      print('👤 Creating student via /auth/signup with data: $signupData');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('👤 Signup response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('👤 Student created successfully: ${response.body}');
        final jsonResponse = json.decode(response.body);
        
        // Handle different response formats
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse.containsKey('success') && jsonResponse.containsKey('data')) {
            return jsonResponse['data'];
          }
          return jsonResponse;
        }
        
        return jsonResponse;
      } else {
        print('👤 Error response body: ${response.body}');
        throw Exception('Failed to create student: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👤 Error creating student: $e');
      throw Exception('Error creating student: $e');
    }
  }

  /// Update an existing student
  Future<Map<String, dynamic>> updateStudent({
    required String studentId,
    String? name,
    String? classId,
    String? dob,
    String? gender,
    String? address,
    String? phone,
    String? email,
    bool? feePaid,
    List<Map<String, dynamic>>? parents,
  }) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final Map<String, dynamic> updateData = {'schoolId': schoolId};
      
      // Only add fields that are provided
      if (name != null) updateData['name'] = name;
      if (classId != null) updateData['classId'] = classId;
      if (dob != null) updateData['dob'] = dob;
      if (gender != null) updateData['gender'] = gender;
      if (address != null) updateData['address'] = address;
      if (phone != null) updateData['phone'] = phone;
      if (email != null) updateData['email'] = email;
      if (feePaid != null) updateData['feePaid'] = feePaid;
      if (parents != null) updateData['parents'] = parents;

      final body = json.encode(updateData);

      final url = '$baseUrl/students/$studentId?schoolId=$schoolId';
      print('👨‍🎓 Update student URL: $url');
      print('👨‍🎓 Update student body: $body');
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('👨‍🎓 Update student response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('👨‍🎓 Response body preview: ${response.body}');
        
        final jsonResponse = json.decode(response.body);
        
        // Handle the new response format with success and data fields
        if (jsonResponse is Map<String, dynamic> && 
            jsonResponse.containsKey('success') && 
            jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }
        
        // Handle the old format where response is directly the student object
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        }
        
        throw Exception('Unexpected response format');
      } else {
        print('👨‍🎓 Error response body: ${response.body}');
        throw Exception('Failed to update student: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👨‍🎓 Error updating student: $e');
      throw Exception('Error updating student: $e');
    }
  }

  /// Delete a student
  Future<void> deleteStudent(String studentId) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final url = '$baseUrl/students/$studentId?schoolId=$schoolId';
      print('👨‍🎓 Delete student URL: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        print('👨‍🎓 Error response body: ${response.body}');
        throw Exception('Failed to delete student: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👨‍🎓 Error deleting student: $e');
      throw Exception('Error deleting student: $e');
    }
  }

  /// Get student's academic progress
  Future<Map<String, dynamic>> getStudentProgress(String studentId) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final url = '$baseUrl/students/$studentId/progress?schoolId=$schoolId';
      print('👨‍🎓 Get student progress URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('👨‍🎓 Get student progress response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('👨‍🎓 Response body preview: ${response.body}');
        
        final jsonResponse = json.decode(response.body);
        
        // Handle the response format with success and data fields
        if (jsonResponse is Map<String, dynamic> && 
            jsonResponse.containsKey('success') && 
            jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }
        
        // Handle direct response format
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        }
        
        // Return empty progress if the format is unexpected
        return {
          'studentId': studentId,
          'progress': []
        };
      } else {
        print('👨‍🎓 Error response body: ${response.body}');
        throw Exception('Failed to get student progress: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👨‍🎓 Error getting student progress: $e');
      throw Exception('Error getting student progress: $e');
    }
  }

 
  /// Get students by parent ID
  Future<List<Map<String, dynamic>>> getStudentsByParentId(String parentId) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final url = '$baseUrl/students/par/$parentId?schoolId=$schoolId';
      print('👨‍👩‍👧‍👦 Getting students for parent ID: $parentId with schoolId: $schoolId');
      print('👨‍👩‍👧‍👦 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('👨‍👩‍👧‍👦 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Handle the response format with success and data fields
        if (jsonResponse is Map<String, dynamic> && 
            jsonResponse.containsKey('success') && 
            jsonResponse.containsKey('data')) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        
        // Handle direct response format
        if (jsonResponse is List) {
          return jsonResponse.map((item) => item as Map<String, dynamic>).toList();
        }
        
        throw Exception('Unexpected response format');
      } else {
        print('👨‍👩‍👧‍👦 Error response: ${response.body}');
        throw Exception('Failed to load students for parent: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👨‍👩‍👧‍👦 Error getting students for parent: $e');
      throw Exception('Error getting students for parent: $e');
    }
  }
}

