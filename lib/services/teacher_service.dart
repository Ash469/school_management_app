import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_auth_service.dart';

class TeacherService {
  final String baseUrl;
  final ApiAuthService _authService = ApiAuthService();

  TeacherService({required this.baseUrl});

  

  /// Get all teachers
  Future<List<Map<String, dynamic>>> getAllTeachers() async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      print('👨‍🏫 Making API request for teachers with schoolId: $schoolId');
      print('👨‍🏫 Headers: $headers');

      final url = '$baseUrl/teachers?schoolId=$schoolId';
      print('👨‍🏫 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('👨‍🏫 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('👨‍🏫 Response body preview: ${response.body}');

        // Parse the JSON response
        final jsonResponse = json.decode(response.body);

        List<dynamic> data;
        // Check if response has success and data fields (new API format)
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
        
        // Filter the teachers to ensure they match the stored schoolId
        final filteredData = data.where((item) {
          if (item is Map<String, dynamic>) {
            // Check if the teacher's schoolId matches the stored schoolId
            final teacherSchoolId = item['schoolId'];
            if (teacherSchoolId is Map<String, dynamic> && teacherSchoolId['_id'] == schoolId) {
              return true;
            }
          }
          return false;
        }).toList();
        
        return filteredData.map((item) => item as Map<String, dynamic>).toList();
      } else {
        print('👨‍🏫 Error response body: ${response.body}');
        throw Exception('Failed to load teachers: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👨‍🏫 Error getting teachers: $e');
      throw Exception('Error getting teachers: $e');
    }
  }

  /// Get a teacher by ID
  Future<Map<String, dynamic>> getTeacherById(String _id) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null) {
        throw Exception('School ID not found');
      }

      print('👨‍🏫 Getting teacher details for ID: $_id with schoolId: $schoolId');
      print('👨‍🏫 Headers: $headers');

      final url = '$baseUrl/teachers/$_id?schoolId=$schoolId';
      print('👨‍🏫 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('👨‍🏫 Response status: ${response.statusCode}');

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
        }
        // Direct response object (old API format)
        else if (responseData is Map<String, dynamic>) {
          return responseData;
        }

        // Unexpected format, return empty map to prevent errors
        return {};
      } else {
        print('👨‍🏫 Error response body: ${response.body}');
        throw Exception('Failed to load teacher details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👨‍🏫 Error getting teacher details: $e');
      throw Exception('Error getting teacher details: $e');
    }
  }

  /// Create user account via auth/signup
  Future<Map<String, dynamic>> createUserAccount({
    required String name,
    required String email,
    required String password,
    required String schoolId,
    required String schoolSecretKey,
    required String phone,
    required String dateJoined,
    required String teacherId,
    bool salaryPaid = false,
    List<String>? roles,
    List<String>? subjects,
    List<String>? classes,
  }) async {
    try {
      final Map<String, dynamic> signupData = {
        'name': name,
        'email': email,
        'password': schoolSecretKey, // Use schoolSecretKey as password
        'role': 'teacher',
        'schoolId': schoolId,
        'phone': phone,
        'dateJoined': dateJoined,
        'teacherId': teacherId,
        'salaryPaid': salaryPaid,
      };

      // Add optional fields if they exist
      if (roles != null) signupData['roles'] = roles;
      if (subjects != null) signupData['teachingSubs'] = subjects;
      if (classes != null) signupData['classes'] = classes;

      final body = json.encode(signupData);

      print('👤 Creating teacher account with data: $signupData');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('👤 Create teacher account response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('👤 Teacher account created successfully: ${response.body}');
        return json.decode(response.body);
      } else {
        print('👤 Error response body: ${response.body}');
        throw Exception('Failed to create teacher account: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👤 Error creating teacher account: $e');
      throw Exception('Error creating teacher account: $e');
    }
  }

  /// Create a new teacher
  Future<Map<String, dynamic>> createTeacher({
    required String name,
    required String email,
    required String phone,
    required String dateJoined,
    required String teacherId,
    bool salaryPaid = false,
    List<String>? roles,
    List<String>? subjects,
    List<String>? classes,
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

      // Only create user account via auth/signup - this should handle everything
      print('👨‍🏫 Creating teacher account via auth/signup...');
      final result = await createUserAccount(
        name: name,
        email: email,
        password: schoolSecretKey,
        schoolId: schoolId,
        schoolSecretKey: schoolSecretKey,
        phone: phone,
        dateJoined: dateJoined,
        teacherId: teacherId,
        salaryPaid: salaryPaid,
        roles: roles,
        subjects: subjects,
        classes: classes,
      );

      print('👨‍🏫 Teacher created successfully via auth/signup');
      return result;
    } catch (e) {
      print('👨‍🏫 Error creating teacher: $e');
      throw Exception('Error creating teacher: $e');
    }
  }

  /// Update an existing teacher
  Future<Map<String, dynamic>> updateTeacher({
    required String id, 
    String? name,
    String? email,
    String? phone,
    bool? salaryPaid,
    List<String>? teachingSubs,
    List<String>? classes,
    List<String>? roles, // Added roles parameter
  }) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final Map<String, dynamic> updateData = {'schoolId': schoolId};
      
      // Only add allowed fields that are provided
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email.toLowerCase(); // Ensure email is lowercase
      if (phone != null) updateData['phone'] = phone;
      if (salaryPaid != null) updateData['salaryPaid'] = salaryPaid;
      if (teachingSubs != null) updateData['teachingSubs'] = teachingSubs;
      if (classes != null) updateData['classes'] = classes.map((id) => id).toList(); // Ensure classes are IDs
      if (roles != null) updateData['roles'] = roles;

      final body = json.encode(updateData);

      final url = '$baseUrl/teachers/$id?schoolId=$schoolId'; 
      print('👨‍🏫 Update teacher URL: $url');
      print('👨‍🏫 Update teacher body: $body');
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('👨‍🏫 Update teacher response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('👨‍🏫 Response body preview: ${response.body}');
        
        final jsonResponse = json.decode(response.body);
        
        // Handle the new response format with success, message and data fields
        if (jsonResponse is Map<String, dynamic> && 
            jsonResponse.containsKey('success') && 
            jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }
        
        // Handle the old format where response is directly the teacher object
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        }
        
        throw Exception('Unexpected response format');
      } else {
        print('👨‍🏫 Error response body: ${response.body}');
        throw Exception('Failed to update teacher: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👨‍🏫 Error updating teacher: $e');
      throw Exception('Error updating teacher: $e');
    }
  }

  /// Delete a teacher
  Future<void> deleteTeacher(String _id) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final url = '$baseUrl/teachers/$_id?schoolId=$schoolId';
      print('👨‍🏫 Delete teacher URL: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        print('👨‍🏫 Error response body: ${response.body}');
        throw Exception('Failed to delete teacher: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👨‍🏫 Error deleting teacher: $e');
      throw Exception('Error deleting teacher: $e');
    }
  }

  /// Assign role(s) to a teacher
  Future<Map<String, dynamic>> assignRole({
    required String id, // Changed from teacherObjectId
    required String role,
  }) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final body = json.encode({
        'role': role,
        'schoolId': schoolId,
      });

      final url = '$baseUrl/teachers/$id/assign-role?schoolId=$schoolId'; // Changed from teacherObjectId
      print('👨‍🏫 Assign role URL: $url');
      print('👨‍🏫 Assign role body: $body');
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('👨‍🏫 Assign role response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('👨‍🏫 Response body preview: ${response.body}');
        
        final jsonResponse = json.decode(response.body);
        
        // Handle the response format with success, message and data fields
        if (jsonResponse is Map<String, dynamic> && 
            jsonResponse.containsKey('success') && 
            jsonResponse.containsKey('data')) {
          // The response data is an array of roles
          if (jsonResponse['data'] is List) {
            return {'roles': jsonResponse['data']};
          }
          return jsonResponse['data'];
        }
        
        // Handle the old format
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        }
        
        throw Exception('Unexpected response format');
      } else {
        print('👨‍🏫 Error response body: ${response.body}');
        throw Exception('Failed to assign role: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👨‍🏫 Error assigning role: $e');
      throw Exception('Error assigning role: $e');
    }
  }

  /// Get teacher's performance metrics
  Future<Map<String, dynamic>> getTeacherPerformance(String id) async { // Changed from teacherObjectId
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final url = '$baseUrl/teachers/$id/performance?schoolId=$schoolId'; // Changed from teacherObjectId
      print('👨‍🏫 Get teacher performance URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('👨‍🏫 Get teacher performance response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('👨‍🏫 Response body preview: ${response.body}');
        
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
        
        // Return default structure if the format is unexpected
        return {
          'totalClasses': 0,
          'avgAttendancePct': 0,
          'avgClassGrade': 0,
          'avgPassPct': 0
        };
      } else {
        print('👨‍🏫 Error response body: ${response.body}');
        throw Exception('Failed to get teacher performance: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👨‍🏫 Error getting teacher performance: $e');
      throw Exception('Error getting teacher performance: $e');
    }
  }

  /// Get classes taught by a specific teacher
  Future<List<Map<String, dynamic>>> getTeacherClasses(String id) async { // Changed from teacherObjectId
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      // A custom endpoint that might need to be added to your API
      final url = '$baseUrl/teachers/$id/classes?schoolId=$schoolId'; // Changed from teacherObjectId
      print('👨‍🏫 Get teacher classes URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('👨‍🏫 Get teacher classes response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('👨‍🏫 Response body preview: ${response.body}');

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

        return [];
      } else {
        print('👨‍🏫 Error response body: ${response.body}');
        throw Exception('Failed to get teacher classes: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👨‍🏫 Error getting teacher classes: $e');
      throw Exception('Error getting teacher classes: $e');
    }
  }

  /// Get subjects taught by a specific teacher
  Future<List<String>> getTeacherSubjects(String id) async { // Changed from teacherObjectId
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      // A custom endpoint that might need to be added to your API
      final url = '$baseUrl/teachers/$id/subjects?schoolId=$schoolId'; // Changed from teacherObjectId
      print('👨‍🏫 Get teacher subjects URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('👨‍🏫 Get teacher subjects response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('👨‍🏫 Response body preview: ${response.body}');

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
        print('👨‍🏫 Error response body: ${response.body}');
        throw Exception('Failed to get teacher subjects: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👨‍🏫 Error getting teacher subjects: $e');
      throw Exception('Error getting teacher subjects: $e');
    }
  }

  /// Update teacher's teaching assignments (classes and subjects)
  Future<Map<String, dynamic>> updateTeacherAssignments({
    required String id, // Changed from teacherObjectId
    List<String>? classIds,
    List<String>? subjectIds,
  }) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final Map<String, dynamic> updateData = {'schoolId': schoolId};
      if (classIds != null) updateData['classes'] = classIds;
      if (subjectIds != null) updateData['subjects'] = subjectIds;

      final body = json.encode(updateData);

      final url = '$baseUrl/teachers/$id?schoolId=$schoolId'; // Changed from teacherObjectId
      print('👨‍🏫 Update teacher assignments URL: $url');
      print('👨‍🏫 Update teacher assignments body: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('👨‍🏫 Update teacher assignments response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('👨‍🏫 Response body preview: ${response.body}');

        final jsonResponse = json.decode(response.body);

        // Handle the new response format with success and data fields
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('success') &&
            jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }

        // Handle the old format where response is directly the teacher object
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        }

        throw Exception('Unexpected response format');
      } else {
        print('👨‍🏫 Error response body: ${response.body}');
        throw Exception('Failed to update teacher assignments: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('👨‍🏫 Error updating teacher assignments: $e');
      throw Exception('Error updating teacher assignments: $e');
    }
  }

  /// Get teachers for a specific class
  Future<List<Map<String, dynamic>>> getTeachersByClass(String classId) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final url = '$baseUrl/classes/$classId/teachers?schoolId=$schoolId';
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        List<dynamic> data;
        if (jsonResponse.containsKey('success') && jsonResponse.containsKey('data')) {
          data = jsonResponse['data'];
        } else {
          data = json.decode(response.body);
        }
        
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load teachers for class: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting teachers for class: $e');
    }
  }

  /// Reset teacher password
  Future<Map<String, dynamic>> resetTeacherPassword(String teacherId) async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      print('🔑 Resetting password for teacher ID: $teacherId with schoolId: $schoolId');

      final body = json.encode({
        'schoolId': schoolId,
      });

      final url = '$baseUrl/teachers/$teacherId/reset-password?schoolId=$schoolId';
      print('🔑 Reset password URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('🔑 Reset password response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('🔑 Password reset successfully: ${response.body}');
        
        final jsonResponse = json.decode(response.body);
        
        // Handle the response format with success and message fields
        if (jsonResponse is Map<String, dynamic> && 
            jsonResponse.containsKey('success')) {
          return jsonResponse;
        }
        
        // Handle direct response format
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        }
        
        // Return success if response format is unexpected but status is OK
        return {'success': true, 'message': 'Password reset successfully'};
      } else {
        print('🔑 Error response body: ${response.body}');
        throw Exception('Failed to reset password: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔑 Error resetting teacher password: $e');
      throw Exception('Error resetting teacher password: $e');
    }
  }
}

