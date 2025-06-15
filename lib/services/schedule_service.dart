import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/storage_util.dart';

class ScheduleService {
  final String baseUrl;

  ScheduleService({required this.baseUrl});

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

  Future<List<Map<String, dynamic>>> getAllSchedules() async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      print('📅 Making API request for schedules with schoolId: $schoolId');
      print('📅 Headers: $headers');

      final url = '$baseUrl/schedules?schoolId=$schoolId';
      print('📅 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📅 Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📅 Response body preview: ${response.body}');
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        List<dynamic> data;
        // Check if the response has a 'success' and 'data' field (new format)
        if (jsonResponse.containsKey('success') && jsonResponse.containsKey('data')) {
          data = jsonResponse['data'];
        } else {
          // Handle the old format where response is directly an array
          data = json.decode(response.body);
        }
        
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        print('📅 Error response body: ${response.body}');
        throw Exception('Failed to load schedules: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📅 Error getting schedules: $e');
      throw Exception('Error getting schedules: $e');
    }
  }

  Future<Map<String, dynamic>> getScheduleById(String scheduleId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null) {
        throw Exception('School ID not found');
      }

      print('📅 Getting schedule details for ID: $scheduleId with schoolId: $schoolId');
      
      final url = '$baseUrl/schedules/$scheduleId?schoolId=$schoolId';
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
          
          if (data == null) {
            return {};
          }
          
          if (data is List && data.isNotEmpty) {
            return data[0] as Map<String, dynamic>;
          }
          
          if (data is Map<String, dynamic>) {
            return data;
          }
          
          return {};
        } else if (responseData is Map<String, dynamic>) {
          return responseData;
        } else {
          return {};
        }
      } else {
        print('📅 Error response body: ${response.body}');
        throw Exception('Failed to load schedule details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📅 Error getting schedule details: $e');
      throw Exception('Error getting schedule details: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSchedulesByClassId(String classId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      print('📅 Getting schedules for classId: $classId with schoolId: $schoolId');
      
      final url = '$baseUrl/schedules?classId=$classId&schoolId=$schoolId';
      print('📅 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📅 Response status: ${response.statusCode}');
      print('📅 Full response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        
        // Handle the response structure you provided
        if (jsonResponse is Map<String, dynamic>) {
          // If it's a single schedule object (like your example)
          if (jsonResponse.containsKey('classId') && jsonResponse.containsKey('periods')) {
            print('📅 Found single schedule object');
            return [jsonResponse];
          }
          
          // If it has success and data fields
          if (jsonResponse.containsKey('success') && jsonResponse.containsKey('data')) {
            final data = jsonResponse['data'];
            print('📅 Extracted data from success response: $data');
            
            if (data is List) {
              return data.map((item) => item as Map<String, dynamic>).toList();
            } else if (data is Map<String, dynamic>) {
              return [data];
            }
          }
        } else if (jsonResponse is List) {
          print('📅 Response is direct array: $jsonResponse');
          return jsonResponse.map((item) => item as Map<String, dynamic>).toList();
        }
        
        print('📅 Unexpected response format: ${jsonResponse.runtimeType}');
        return [];
      } else {
        print('📅 Error response body: ${response.body}');
        throw Exception('Failed to load schedules: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📅 Error getting schedules by class: $e');
      throw Exception('Error getting schedules by class: $e');
    }
  }

  Future<Map<String, dynamic>> createSchedule({
    required String classId,
    required List<Map<String, dynamic>> periods,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      final body = json.encode({
        'classId': classId,
        'periods': periods,
        'schoolId': schoolId,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/schedules'),
        headers: headers,
        body: body,
      );

      print('📅 Create schedule response status: ${response.statusCode}');
      print('📅 Response body preview: ${response.body}');

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse is Map<String, dynamic> && 
            jsonResponse.containsKey('success') && 
            jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }
        
        return jsonResponse;
      } else {
        throw Exception('Failed to create schedule: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📅 Error creating schedule: $e');
      throw Exception('Error creating schedule: $e');
    }
  }

  Future<Map<String, dynamic>> updateSchedule({
    required String scheduleId,
    String? classId,
    List<Map<String, dynamic>>? periods,
  }) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final Map<String, dynamic> updateData = {'schoolId': schoolId};
      if (classId != null) updateData['classId'] = classId;
      if (periods != null) updateData['periods'] = periods;

      final body = json.encode(updateData);

      final url = '$baseUrl/schedules/$scheduleId?schoolId=$schoolId';
      print('📅 Update schedule URL: $url');
      print('📅 Update schedule body: $body');
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('📅 Update schedule response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('📅 Response body preview: ${response.body}');
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse is Map<String, dynamic> && 
            jsonResponse.containsKey('success') && 
            jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        }
        
        return jsonResponse;
      } else {
        print('📅 Error response body: ${response.body}');
        throw Exception('Failed to update schedule: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📅 Error updating schedule: $e');
      throw Exception('Error updating schedule: $e');
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();
      final url = '$baseUrl/schedules/$scheduleId?schoolId=$schoolId';
      print('📅 Delete URL: $url');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete schedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting schedule: $e');
    }
  }

  /// Get schedule for a specific teacher
  Future<Map<String, dynamic>?> getTeacherSchedule(String teacherId) async {
    try {
      final headers = await _getHeaders();
      
      print('📅 Getting teacher schedule for ID: $teacherId');
      
      final url = '$baseUrl/schedules/teacher/$teacherId';
      print('📅 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📅 Teacher schedule response status: ${response.statusCode}');
      print('📅 Teacher schedule response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        // Return the full response to let the caller handle the structure
        if (responseData is Map<String, dynamic>) {
          return responseData;
        }
        
        return null;
      } else {
        print('📅 Error response body: ${response.body}');
        throw Exception('Failed to load teacher schedule: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📅 Error getting teacher schedule: $e');
      throw Exception('Error getting teacher schedule: $e');
    }
  }

  /// Get schedule for a specific student
  Future<Map<String, dynamic>?> getStudentSchedule(String studentId) async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();
      
      print('📅 Getting student schedule for ID: $studentId with schoolId: $schoolId');
      
      final url = '$baseUrl/schedules/student/$studentId${schoolId != null ? '?schoolId=$schoolId' : ''}';
      print('📅 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📅 Student schedule response status: ${response.statusCode}');
      print('📅 Student schedule response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        if (responseData is Map<String, dynamic>) {
          // Handle the API format with success and data fields
          if (responseData.containsKey('success') && responseData.containsKey('data')) {
            final data = responseData['data'];
            
            if (data != null) {
              // Process the schedule data to create a more usable format
              Map<String, dynamic> processedSchedule = {
                'scheduleId': data['_id'],
                'classInfo': {
                  'id': data['classId']['_id'],
                  'name': data['classId']['name'],
                  'grade': data['classId']['grade'],
                  'section': data['classId']['section'],
                  'year': data['classId']['year'],
                },
                'periods': data['periods'] ?? [],
                'createdAt': data['createdAt'],
                'updatedAt': data['updatedAt'],
              };
              
              // Group periods by day of week for easier access
              Map<String, List<dynamic>> weekSchedule = {};
              if (data['periods'] is List) {
                for (var period in data['periods']) {
                  if (period is Map<String, dynamic>) {
                    String dayOfWeek = (period['dayOfWeek'] ?? '').toString().toLowerCase();
                    if (dayOfWeek.isNotEmpty) {
                      if (weekSchedule[dayOfWeek] == null) {
                        weekSchedule[dayOfWeek] = [];
                      }
                      
                      // Format the period data for easier consumption
                      Map<String, dynamic> formattedPeriod = {
                        'subject': period['subject'] ?? 'Unknown Subject',
                        'teacher': period['teacherId'] is Map 
                            ? period['teacherId']['name'] ?? 'Unknown Teacher'
                            : 'Unknown Teacher',
                        'teacherId': period['teacherId'] is Map 
                            ? period['teacherId']['_id'] ?? ''
                            : period['teacherId'] ?? '',
                        'teacherCode': period['teacherId'] is Map 
                            ? period['teacherId']['teacherId'] ?? ''
                            : '',
                        'startTime': period['startTime'] ?? '',
                        'endTime': period['endTime'] ?? '',
                        'periodNumber': period['periodNumber'] ?? 0,
                        'timeSlot': '${period['startTime'] ?? ''} - ${period['endTime'] ?? ''}',
                        'dayOfWeek': period['dayOfWeek'] ?? '',
                      };
                      
                      weekSchedule[dayOfWeek]!.add(formattedPeriod);
                    }
                  }
                }
              }
              
              // Sort periods by period number for each day
              weekSchedule.forEach((day, periods) {
                periods.sort((a, b) => (a['periodNumber'] ?? 0).compareTo(b['periodNumber'] ?? 0));
              });
              
              processedSchedule['weekSchedule'] = weekSchedule;
              
              return {
                'success': true,
                'schedule': processedSchedule,
                'rawData': data,
              };
            }
          }
          
          // Handle other response formats
          return responseData;
        }
        
        return null;
      } else {
        print('📅 Error response body: ${response.body}');
        throw Exception('Failed to load student schedule: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('📅 Error getting student schedule: $e');
      throw Exception('Error getting student schedule: $e');
    }
  }
}
