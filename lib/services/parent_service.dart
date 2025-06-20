import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_auth_service.dart';

class ParentService {
  final String baseUrl;
  final ApiAuthService _authService = ApiAuthService();
  ParentService({required this.baseUrl});

  

  Future<List<Map<String, dynamic>>> getAllParents() async {
    try {
      final headers = await _authService.getHeaders();
      final schoolId = await _authService.getSchoolId();

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
