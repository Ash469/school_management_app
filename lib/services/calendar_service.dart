import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/storage_util.dart';

class CalendarService {
  final String baseUrl;

  CalendarService({required this.baseUrl});

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

  /// Get all calendar items
  Future<List<Map<String, dynamic>>> getAllCalendarItems() async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      print('📆 Making API request for calendar items with schoolId: $schoolId');
      print('📆 Headers: $headers');

      // Using GET request with query parameter instead of POST
      final url = '$baseUrl/calendar?schoolId=$schoolId';
      print('📆 URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📆 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📆 Response body preview: ${response.body}');

        // Parse the JSON response
        final jsonResponse = json.decode(response.body);

        // Check if response has success and data fields
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('success') &&
            jsonResponse.containsKey('data')) {
            
          final List<dynamic> calendars = jsonResponse['data'];
          if (calendars.isEmpty) {
            return [];
          }
          
          // Filter calendars to ensure they match the stored schoolId
          final filteredCalendars = calendars.where((calendar) {
            if (calendar is Map<String, dynamic>) {
              return calendar['schoolId'] == schoolId;
            }
            return false;
          }).toList();
          
          // The response contains calendar objects with arrays of events
          final List<Map<String, dynamic>> allEvents = [];
          
          for (var calendar in filteredCalendars) {
            final Map<String, dynamic> calendarData = calendar as Map<String, dynamic>;
            final String calendarId = calendarData['_id'] ?? '';
            final int year = calendarData['year'] ?? DateTime.now().year;
            
            // Extract holidays
            if (calendarData['holidays'] != null) {
              final List<dynamic> holidays = calendarData['holidays'];
              for (var holiday in holidays) {
                final Map<String, dynamic> eventMap = {
                  'id': '${calendarId}_holiday_${allEvents.length}',
                  'name': holiday['name'] ?? 'Holiday',
                  'description': 'School holiday',
                  'date': holiday['date'],
                  'type': 'holiday',
                  'calendarId': calendarId,
                  'year': year,
                  'schoolId': schoolId // Add schoolId for consistency
                };
                allEvents.add(eventMap);
              }
            }
            
            // Extract exam schedule
            if (calendarData['examSchedule'] != null) {
              final List<dynamic> exams = calendarData['examSchedule'];
              for (var exam in exams) {
                final Map<String, dynamic> eventMap = {
                  'id': '${calendarId}_exam_${allEvents.length}',
                  'name': exam['name'] ?? 'Exam',
                  'description': exam['description'] ?? 'Examination',
                  'date': exam['date'],
                  'type': 'exam',
                  'calendarId': calendarId,
                  'year': year,
                  'schoolId': schoolId // Add schoolId for consistency
                };
                allEvents.add(eventMap);
              }
            }
            
            // Extract fixed events (school events)
            if (calendarData['fixedEvents'] != null) {
              final List<dynamic> events = calendarData['fixedEvents'];
              for (var event in events) {
                final Map<String, dynamic> eventMap = {
                  'id': '${calendarId}_event_${allEvents.length}',
                  'name': event['name'] ?? 'School Event',
                  'description': event['description'] ?? 'School event',
                  'date': event['date'],
                  'type': 'schoolEvent',
                  'calendarId': calendarId,
                  'year': year,
                  'schoolId': schoolId // Add schoolId for consistency
                };
                allEvents.add(eventMap);
              }
            }
            
            // Handle any standalone events if they exist
            if (calendarData['events'] != null) {
              final List<dynamic> regularEvents = calendarData['events'];
              for (var event in regularEvents) {
                final Map<String, dynamic> eventMap = {
                  'id': event['_id'] ?? '${calendarId}_other_${allEvents.length}',
                  'name': event['name'] ?? 'Event',
                  'description': event['description'] ?? '',
                  'date': event['date'],
                  'type': event['type'] ?? 'other',
                  'calendarId': calendarId,
                  'year': year,
                  'schoolId': schoolId // Add schoolId for consistency
                };
                allEvents.add(eventMap);
              }
            }
          }
          
          return allEvents;
        }
        // Handle the direct array response format (legacy support)
        else if (jsonResponse is List) {
          final List<dynamic> data = jsonResponse;
          
          // Filter the calendar items to ensure they match the stored schoolId
          final filteredData = data.where((item) {
            if (item is Map<String, dynamic>) {
              // Check if the calendar item has a schoolId field that matches our stored schoolId
              return item['schoolId'] == schoolId;
            }
            return false;
          }).toList();
          
          return filteredData.map((item) => item as Map<String, dynamic>).toList();
        }

        throw Exception('Unexpected response format');
      } else {
        print('📆 Error response body: ${response.body}');
        throw Exception('Failed to load calendar items: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📆 Error getting calendar items: $e');
      throw Exception('Error getting calendar items: $e');
    }
  }

  /// Create a new calendar item
  Future<Map<String, dynamic>> createCalendarItem({
    required String title,
    required String description,
    required DateTime date,
    required String category,
    bool? isFullDay,
    String? startTime,
    String? endTime,
    Map<String, dynamic>? additionalDetails,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      // Updated request body format to match API requirements
      final Map<String, dynamic> calendarData = {
        'schoolId': schoolId,
        'year': date.year,
        'type': category.toLowerCase(),
        'name': title,
        'date': date.toIso8601String(),
      };

      // Add optional description if available
      if (description.isNotEmpty) {
        calendarData['description'] = description;
      }

      // Add optional fields if they exist
      if (isFullDay != null) calendarData['isFullDay'] = isFullDay;
      if (startTime != null) calendarData['startTime'] = startTime;
      if (endTime != null) calendarData['endTime'] = endTime;
      if (additionalDetails != null) {
        calendarData.addAll(additionalDetails);
      }

      final body = json.encode(calendarData);

      print('📆 Creating calendar item with data: $calendarData');
      print('📆 Headers: $headers');

      final response = await http.post(
        Uri.parse('$baseUrl/calendar'),
        headers: headers,
        body: body,
      );

      print('📆 Create calendar item response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('📆 Response body preview: ${response.body}');

        final jsonResponse = json.decode(response.body);

        // Handle the new response format with success and data fields
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('success') &&
            jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }

        // Handle the old format where response is directly the calendar object
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        }

        throw Exception('Unexpected response format');
      } else {
        print('📆 Error response body: ${response.body}');
        throw Exception('Failed to create calendar item: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📆 Error creating calendar item: $e');
      throw Exception('Error creating calendar item: $e');
    }
  }

  /// Update an existing calendar item
  Future<Map<String, dynamic>> updateCalendarItem({
    required String calendarId,
    String? title,
    String? description,
    DateTime? date,
    String? category,
    bool? isFullDay,
    String? startTime,
    String? endTime,
    Map<String, dynamic>? additionalDetails,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final Map<String, dynamic> updateData = {'schoolId': schoolId};
      
      // Update with the new API format
      if (title != null) updateData['name'] = title;
      if (description != null) updateData['description'] = description;
      if (date != null) {
        updateData['date'] = date.toIso8601String();
        updateData['year'] = date.year;
      }
      if (category != null) updateData['type'] = category.toLowerCase();
      if (isFullDay != null) updateData['isFullDay'] = isFullDay;
      if (startTime != null) updateData['startTime'] = startTime;
      if (endTime != null) updateData['endTime'] = endTime;
      
      // Add any additional details directly to the update data
      if (additionalDetails != null) {
        updateData.addAll(additionalDetails);
      }

      final body = json.encode(updateData);

      // Fixed URL format - no query parameters, schoolId included in body
      final url = '$baseUrl/calendar/$calendarId'; 
      print('📆 Update calendar item URL: $url');
      print('📆 Update calendar item body: $body');
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('📆 Update calendar item response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📆 Response body preview: ${response.body}');
        
        final jsonResponse = json.decode(response.body);
        
        // Handle the new response format with success, message and data fields
        if (jsonResponse is Map<String, dynamic> && 
            jsonResponse.containsKey('success') && 
            jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }
        
        // Handle the old format where response is directly the calendar object
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        }
        
        throw Exception('Unexpected response format');
      } else {
        print('📆 Error response body: ${response.body}');
        throw Exception('Failed to update calendar item: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📆 Error updating calendar item: $e');
      throw Exception('Error updating calendar item: $e');
    }
  }

  /// Delete a calendar item
  Future<void> deleteCalendarItem(String calendarId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final url = '$baseUrl/calendar/$calendarId?schoolId=$schoolId';
      print('📆 Delete calendar item URL: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        print('📆 Error response body: ${response.body}');
        throw Exception('Failed to delete calendar item: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📆 Error deleting calendar item: $e');
      throw Exception('Error deleting calendar item: $e');
    }
  }

  /// Add a holiday to the calendar
  Future<Map<String, dynamic>> addHoliday({
    required String name,
    required DateTime date,
    String? description,
    int? year,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      // Create request body
      final Map<String, dynamic> holidayData = {
        'schoolId': schoolId,
        'name': name,
        'date': date.toIso8601String(),
        'year': year ?? date.year,
      };
      
      if (description != null) {
        holidayData['description'] = description;
      }

      final body = json.encode(holidayData);
      final url = '$baseUrl/calendar/holidays';
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('success') &&
            jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }
        
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        }
        
        throw Exception('Unexpected response format');
      } else {
        print('📆 Error response body: ${response.body}');
        throw Exception('Failed to add holiday: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📆 Error adding holiday: $e');
      throw Exception('Error adding holiday: $e');
    }
  }
  
  /// Add an exam to the calendar
  Future<Map<String, dynamic>> addExam({
    required String name,
    required DateTime date,
    required String description,
    int? year,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      // Create request body
      final Map<String, dynamic> examData = {
        'schoolId': schoolId,
        'name': name,
        'date': date.toIso8601String(),
        'description': description,
        'year': year ?? date.year,
      };

      final body = json.encode(examData);
      final url = '$baseUrl/calendar/exams';
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('success') &&
            jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }
        
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        }
        
        throw Exception('Unexpected response format');
      } else {
        print('📆 Error response body: ${response.body}');
        throw Exception('Failed to add exam: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📆 Error adding exam: $e');
      throw Exception('Error adding exam: $e');
    }
  }
  
  /// Add a school event to the calendar
  Future<Map<String, dynamic>> addSchoolEvent({
    required String name,
    required DateTime date,
    required String description,
    int? year,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      // Create request body
      final Map<String, dynamic> eventData = {
        'schoolId': schoolId,
        'name': name,
        'date': date.toIso8601String(),
        'description': description,
        'year': year ?? date.year,
      };

      final body = json.encode(eventData);
      final url = '$baseUrl/calendar/events';
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('success') &&
            jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }
        
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        }
        
        throw Exception('Unexpected response format');
      } else {
        print('📆 Error response body: ${response.body}');
        throw Exception('Failed to add school event: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📆 Error adding school event: $e');
      throw Exception('Error adding school event: $e');
    }
  }
}
