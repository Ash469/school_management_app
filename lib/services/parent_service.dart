import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/storage_util.dart';

class ParentService {
  final String baseUrl;

  ParentService({required this.baseUrl});

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
    return await StorageUtil.getString('schoolId');
  }

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

  Future<List<Map<String, dynamic>>> getAllParents() async {
    try {
      final headers = await _getHeaders();
      final schoolId = await _getSchoolId();

      if (schoolId == null || schoolId.isEmpty) {
        throw Exception('School ID not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/parents?schoolId=$schoolId'),
        headers: headers,
      );

      print('👪 Parent response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
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
        print('👪 Error response: ${response.body}');
        throw Exception('Failed to load parents: ${response.statusCode}');
      }
    } catch (e) {
      print('👪 Error getting parents: $e');
      throw Exception('Error getting parents: $e');
    }
  }
}
