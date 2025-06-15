import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../utils/storage_util.dart';

class AttendanceService {
  final String baseUrl;
  String? _token;

  AttendanceService({required this.baseUrl});

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

  Future<String?> _getSchoolId() async {
    return await StorageUtil.getString('schoolId');
  }

  Future<Map<String, String>> get _headers async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// List all attendance records with optional filters
  /// Query params: classId, date, studentId, schoolId
  Future<List<Map<String, dynamic>>> listAttendance({
    String? classId,
    String? date,
    String? studentId,
  }) async {
    try {
      final schoolId = await _getSchoolId();
      
      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final queryParams = <String, String>{
        'schoolId': schoolId,
      };
      if (classId != null) queryParams['classId'] = classId;
      if (date != null) queryParams['date'] = date;
      if (studentId != null) queryParams['studentId'] = studentId;

      final uri = Uri.parse('$baseUrl/attendance').replace(
        queryParameters: queryParams,
      );

      final headers = await _headers;
      final response = await http.get(uri, headers: headers);

      print('📋 List attendance response status: ${response.statusCode}');
      print('📋 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          // Return empty list if no data found (not an error)
          return [];
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching attendance records: $e');
    }
  }

  /// Mark attendance for a class on a given date
  /// Expected body: { classId, date, entries: [{ studentId, status }], schoolId }
  Future<Map<String, dynamic>> markAttendance({
    required String classId,
    required String date,
    required List<Map<String, dynamic>> attendanceData,
  }) async {
    try {
      final schoolId = await _getSchoolId();
      
      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final body = {
        'classId': classId,
        'date': date,
        'entries': attendanceData,
        'schoolId': schoolId, // Add schoolId to request body
      };

      print('📋 Mark attendance request body: ${json.encode(body)}');

      final queryParams = {'schoolId': schoolId};
      final uri = Uri.parse('$baseUrl/attendance').replace(queryParameters: queryParams);

      final headers = await _headers;
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      print('📋 Mark attendance response status: ${response.statusCode}');
      print('📋 Mark attendance response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to mark attendance');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error marking attendance: $e');
    }
  }

  /// Update a specific attendance record
  Future<Map<String, dynamic>> updateAttendance({
    required String attendanceId,
    required List<Map<String, dynamic>> attendanceData,
  }) async {
    try {
      final schoolId = await _getSchoolId();
      
      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final body = {
        'entries': attendanceData,
        'schoolId': schoolId, // Add schoolId to request body
      };

      print('📋 Update attendance request body: ${json.encode(body)}');

      final queryParams = {'schoolId': schoolId};
      final uri = Uri.parse('$baseUrl/attendance/$attendanceId').replace(queryParameters: queryParams);

      final headers = await _headers;
      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      print('📋 Update attendance response status: ${response.statusCode}');
      print('📋 Update attendance response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to update attendance');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating attendance: $e');
    }
  }

  /// Download attendance report as CSV
  Future<File> downloadAttendanceReport(String attendanceId) async {
    try {
      final schoolId = await _getSchoolId();
      
      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final queryParams = {'schoolId': schoolId};
      final uri = Uri.parse('$baseUrl/attendance/$attendanceId/report').replace(queryParameters: queryParams);

      final headers = await _headers;
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        // Get the downloads directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/attendance_report_$attendanceId.csv');
        
        // Write the CSV data to file
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error downloading attendance report: $e');
    }
  }

  /// Get class attendance overview/summary
  Future<Map<String, dynamic>> getClassAttendanceOverview({
    required String classId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final schoolId = await _getSchoolId();
      
      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final queryParams = <String, String>{
        'schoolId': schoolId,
      };
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final uri = Uri.parse('$baseUrl/attendance/class/$classId').replace(
        queryParameters: queryParams,
      );

      final headers = await _headers;
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] ?? {};
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch class attendance overview');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching class attendance overview: $e');
    }
  }

  /// Get attendance records for a specific class
  Future<List<Map<String, dynamic>>> getClassAttendance({
    required String classId,
    String? date,
  }) async {
    try {
      final schoolId = await _getSchoolId();
      
      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final queryParams = <String, String>{
        'schoolId': schoolId,
        'classId': classId,
      };
      if (date != null) queryParams['date'] = date;

      final uri = Uri.parse('$baseUrl/attendance').replace(
        queryParameters: queryParams,
      );

      final headers = await _headers;
      final response = await http.get(uri, headers: headers);

      print('📋 Get class attendance request: $uri');
      print('📋 Response status: ${response.statusCode}');
      print('📋 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final attendanceList = List<Map<String, dynamic>>.from(data['data'] ?? []);
          
          // Filter by date if provided (additional client-side filtering)
          if (date != null) {
            return attendanceList.where((record) {
              final recordDate = record['date'];
              if (recordDate is String) {
                // Extract date part from ISO string (YYYY-MM-DD)
                final recordDateOnly = recordDate.split('T')[0];
                return recordDateOnly == date;
              }
              return false;
            }).toList();
          }
          
          return attendanceList;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch attendance records');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('📋 Error fetching class attendance: $e');
      throw Exception('Error fetching attendance records: $e');
    }
  }

  /// Get attendance summary for a class on a specific date
  Future<Map<String, dynamic>?> getAttendanceForDate({
    required String classId,
    required String date,
  }) async {
    try {
      final attendanceRecords = await getClassAttendance(
        classId: classId,
        date: date,
      );
      
      // Return the first record that matches the date (should be only one per class per date)
      return attendanceRecords.isNotEmpty ? attendanceRecords.first : null;
    } catch (e) {
      print('📋 Error fetching attendance for date: $e');
      return null;
    }
  }

  /// Helper method to format attendance data for API
  /// Now formats for the 'entries' field structure
  static List<Map<String, dynamic>> formatAttendanceData(
    List<Map<String, dynamic>> students,
  ) {
    return students.map((student) => {
      'studentId': student['_id'] ?? student['id'], // Use _id first, fallback to id
      'status': student['present'] ? 'present' : 'absent',
    }).toList();
  }

  /// Helper method to format date for API (YYYY-MM-DD)
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
