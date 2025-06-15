import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/storage_util.dart';

class EventService {
  final String baseUrl;

  EventService({required this.baseUrl});

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

  /// Get all events
  Future<List<Map<String, dynamic>>> getAllEvents() async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      print('📅 Making API request for events with schoolId: $schoolId');
      print('📅 Headers: $headers');

      final url = '$baseUrl/events?schoolId=$schoolId';
      print('📅 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📅 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📅 Response body preview: ${response.body}');

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
        
        // Filter the events to ensure they match the stored schoolId
        final filteredData = data.where((item) {
          if (item is Map<String, dynamic>) {
            // Check if the event has a schoolId field that matches our stored schoolId
            return item['schoolId'] == schoolId;
          }
          return false;
        }).toList();
        
        return filteredData.map((item) => item as Map<String, dynamic>).toList();
      } else {
        print('📅 Error response body: ${response.body}');
        throw Exception('Failed to load events: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📅 Error getting events: $e');
      throw Exception('Error getting events: $e');
    }
  }

  /// Get an event by ID
  Future<Map<String, dynamic>> getEventById(String eventId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null) {
        throw Exception('School ID not found');
      }

      print('📅 Getting event details for ID: $eventId with schoolId: $schoolId');
      print('📅 Headers: $headers');

      final url = '$baseUrl/events/$eventId?schoolId=$schoolId';
      print('📅 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📅 Response status: ${response.statusCode}');

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
        print('📅 Error response body: ${response.body}');
        throw Exception('Failed to load event details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📅 Error getting event details: $e');
      throw Exception('Error getting event details: $e');
    }
  }

  /// Create a new event
  Future<Map<String, dynamic>> createEvent({
    required String name,  // Changed from title to name
    required String description,
    required String date,
    String? venue,        // Changed from location to venue
    String? time,
    List<String>? attendees,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final Map<String, dynamic> eventData = {
        'schoolId': schoolId,
        'name': name,     // Changed from title to name
        'description': description,
        'date': date,
      };

      // Add optional fields if they exist
      if (venue != null) eventData['venue'] = venue;  // Changed from location to venue
      if (time != null) eventData['time'] = time;
      if (attendees != null) eventData['attendees'] = attendees;

      final body = json.encode(eventData);

      print('📅 Creating event with data: $eventData');
      print('📅 Headers: $headers');

      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: headers,
        body: body,
      );

      print('📅 Create event response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('📅 Response body preview: ${response.body}');

        final jsonResponse = json.decode(response.body);

        // Handle the new response format with success and data fields
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('success') &&
            jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }

        // Handle the old format where response is directly the event object
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        }

        throw Exception('Unexpected response format');
      } else {
        print('📅 Error response body: ${response.body}');
        throw Exception('Failed to create event: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📅 Error creating event: $e');
      throw Exception('Error creating event: $e');
    }
  }

  /// Update an existing event
  Future<Map<String, dynamic>> updateEvent({
    required String eventId,
    String? name,       // Changed from title to name
    String? description,
    String? date,
    String? venue,      // Changed from location to venue
    String? time,
    List<String>? attendees,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final Map<String, dynamic> updateData = {'schoolId': schoolId};
      
      // Only add fields that are provided
      if (name != null) updateData['name'] = name;  // Changed from title to name
      if (description != null) updateData['description'] = description;
      if (date != null) updateData['date'] = date;
      if (venue != null) updateData['venue'] = venue;  // Changed from location to venue
      if (time != null) updateData['time'] = time;
      if (attendees != null) updateData['attendees'] = attendees;

      final body = json.encode(updateData);

      final url = '$baseUrl/events/$eventId?schoolId=$schoolId'; 
      print('📅 Update event URL: $url');
      print('📅 Update event body: $body');
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('📅 Update event response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📅 Response body preview: ${response.body}');
        
        final jsonResponse = json.decode(response.body);
        
        // Handle the new response format with success, message and data fields
        if (jsonResponse is Map<String, dynamic> && 
            jsonResponse.containsKey('success') && 
            jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }
        
        // Handle the old format where response is directly the event object
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        }
        
        throw Exception('Unexpected response format');
      } else {
        print('📅 Error response body: ${response.body}');
        throw Exception('Failed to update event: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📅 Error updating event: $e');
      throw Exception('Error updating event: $e');
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final url = '$baseUrl/events/$eventId?schoolId=$schoolId';
      print('📅 Delete event URL: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        print('📅 Error response body: ${response.body}');
        throw Exception('Failed to delete event: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📅 Error deleting event: $e');
      throw Exception('Error deleting event: $e');
    }
  }

  /// Send notifications for a specific event
  Future<Map<String, dynamic>> sendEventNotifications({
    required String eventId,
    required List<String> recipients,
    required String message,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final Map<String, dynamic> notificationData = {
        'schoolId': schoolId,
        'recipients': recipients,
        'message': message,
      };

      final body = json.encode(notificationData);

      final url = '$baseUrl/events/$eventId/notifications';
      print('📅 Send event notifications URL: $url');
      print('📅 Send event notifications body: $body');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('📅 Send event notifications response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📅 Response body preview: ${response.body}');
        
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
        
        throw Exception('Unexpected response format');
      } else {
        print('📅 Error response body: ${response.body}');
        throw Exception('Failed to send event notifications: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📅 Error sending event notifications: $e');
      throw Exception('Error sending event notifications: $e');
    }
  }
}
