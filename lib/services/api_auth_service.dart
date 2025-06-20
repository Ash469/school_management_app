import '../utils/storage_util.dart';

class ApiAuthService {
  // Singleton pattern
  static final ApiAuthService _instance = ApiAuthService._internal();
  
  factory ApiAuthService() {
    return _instance;
  }
  
  ApiAuthService._internal();
  
  Future<String?> getToken() async {
    // First try the standard token key
    String? token = await StorageUtil.getString('accessToken');

    // If not found or empty, try the alternative key
    if (token == null || token.isEmpty) {
      token = await StorageUtil.getString('schoolToken');
    }

    return token;
  }

  Future<String?> getSchoolId() async {
    // Get directly from StorageUtil
    return await StorageUtil.getString('schoolId');
  }
  Future<String?> getSchoolSecretKey() async {
    // Get directly from StorageUtil
    return await StorageUtil.getString('schoolSecretKey');
  }

  Future<Map<String, String>> getHeaders({bool jsonContent = true}) async {
    final token = await getToken();

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
}
