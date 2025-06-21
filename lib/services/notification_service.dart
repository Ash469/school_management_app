import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import '../utils/storage_util.dart';
import '../utils/constants.dart';

class NotificationService {
  static const String _baseUrl = Constants.apiBaseUrl;

  // Get authentication token
  Future<String?> _getToken() async {
    // First try the standard token key
    String? token = await StorageUtil.getString('accessToken');

    // If not found or empty, try the alternative key
    if (token == null || token.isEmpty) {
      token = await StorageUtil.getString('schoolToken');
    }

    return token;
  }

  // Get school ID
  Future<String?> _getSchoolId() async {
    return await StorageUtil.getString('schoolId');
  }
  
  // Get current user ID
  Future<String?> _getCurrentUserId() async {
    return await StorageUtil.getString('userId');
  }

  // Get request headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please log in again.');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Fetch all notifications
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/notifications?schoolId=$schoolId'),
        headers: headers,
      );

      print('🔔 Notification response status: ${response.statusCode}');

      if (response.statusCode == 200) {


        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check if the response has the expected structure
        if (jsonResponse.containsKey('success') && jsonResponse.containsKey('data')) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((item) => NotificationModel.fromJson(item)).toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        print('🔔 Error response body: ${response.body}');
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('🔔 Error fetching notifications: $e');
      throw Exception('Error fetching notifications: $e');
    }
  }

  // Send a new notification
  Future<bool> sendNotification({
    required String type,
    required String message,
    required List<String> audience,
    String? teacherId,
    String? studentId,
    String? classId,
    String? parentId,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();
      final userId = await _getCurrentUserId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      // Format request body based on notification type
      final Map<String, dynamic> data = {
        'type': type,
        'message': message,
        'schoolId': schoolId,
      };

      // Add createdBy if available
      if (userId != null && userId.isNotEmpty) {
        data['createdBy'] = userId;
      }

      // Add specific fields based on notification type
      if (type == 'Announcement') {
        // For Announcement type, audience is required in the request body
        data['audience'] = audience;
      } else if (type == 'Teacher' && teacherId != null) {
        data['teacherId'] = teacherId;
      } else if (type == 'Student' && studentId != null) {
        data['studentId'] = studentId;
      } else if (type == 'Class' && classId != null) {
        data['classId'] = classId;
      } else if (type == 'Parent' && parentId != null) {
        data['parentId'] = parentId;
      }

      print('🔔 Sending notification: $data');

      final response = await http.post(
        Uri.parse('$_baseUrl/notifications'),
        headers: headers,
        body: json.encode(data),
      );

      print('🔔 Send notification response status: ${response.statusCode}');
      print('🔔 Response body: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('🔔 Error sending notification: $e');
      throw Exception('Error sending notification: $e');
    }
  }

  // Send a notification to a specific teacher
  Future<bool> sendTeacherNotification({
    required String teacherId,
    required String message,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      // Format request body for teacher notification - only include required fields
      final Map<String, dynamic> data = {
        'message': message,
        'schoolId': schoolId,
      };
      
      print('👨‍🏫 Sending teacher notification: $data');

      // Use the specific teacher notification endpoint
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/teacher/$teacherId'),
        headers: headers,
        body: json.encode(data),
      );

      print('👨‍🏫 Send teacher notification response status: ${response.statusCode}');
      print('👨‍🏫 Response body: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('👨‍🏫 Error sending teacher notification: $e');
      throw Exception('Error sending teacher notification: $e');
    }
  }

  Future<bool> sendStudentNotification({
    required String studentId,
    required String message,
    required String type,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();
      final userId = await _getCurrentUserId(); // Get the current user ID

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      // Format request body for student notification with all required fields
      final Map<String, dynamic> data = {
        'message': message,
        'schoolId': schoolId,
        'type': type, // Ensure type is included
      };
      
      // Add creator ID if available
      if (userId != null && userId.isNotEmpty) {
        data['createdBy'] = userId;
      }
      
      print('👨‍🏫 Sending student notification: $data');

      // Use the specific student notification endpoint
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/student/$studentId'),
        headers: headers,
        body: json.encode(data),
      );

      print('👨‍🏫 Send student notification response status: ${response.statusCode}');
      print('👨‍🏫 Response body: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('👨‍🏫 Error sending student notification: $e');
      throw Exception('Error sending student notification: $e');
    }
  }

  Future<bool> sendClassNotification({
    required String classId,
    required String message,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();
      final userId = await _getCurrentUserId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      // Format request body for class notification
      final Map<String, dynamic> data = {
        'message': message,
        'schoolId': schoolId,
      };
      
      // Add creator ID if available
      if (userId != null && userId.isNotEmpty) {
        data['createdBy'] = userId;
      }
      
      print('🏫 Sending class notification: $data');

      // Use the specific class notification endpoint
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/class/$classId'),
        headers: headers,
        body: json.encode(data),
      );

      print('🏫 Send class notification response status: ${response.statusCode}');
      print('🏫 Response body: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('🏫 Error sending class notification: $e');
      throw Exception('Error sending class notification: $e');
    }
  }
  /// Send notification to a specific parent
  Future<bool> sendParentNotification({
    required String parentId,
    required String message,
  }) async {
    try {
      // Validate parentId
      if (parentId.isEmpty) {
        throw Exception('Parent ID is required');
      }
      
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();
      final userId = await _getCurrentUserId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      // Format request body for parent notification
      final Map<String, dynamic> data = {
        'message': message,
        'schoolId': schoolId,
      };
      
      // Add creator ID if available
      if (userId != null && userId.isNotEmpty) {
        data['createdBy'] = userId;
      }
      
      print('👪 Sending parent notification to: $parentId');
      print('👪 Notification data: $data');

      // Use the specific parent notification endpoint
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/parent/$parentId'),
        headers: {
          ...headers,
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      print('👪 Send parent notification response status: ${response.statusCode}');
      print('👪 Response body: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('👪 Error sending parent notification: $e');
      throw Exception('Error sending parent notification: $e');
    }
  }

  // Delete a notification
  Future<bool> deleteNotification(String id) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications/$id?schoolId=$schoolId'),
        headers: headers,
      );

      print('🔔 Delete notification response status: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('🔔 Error deleting notification: $e');
      throw Exception('Error deleting notification: $e');
    }
  }
}

