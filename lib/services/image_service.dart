import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Add this for kDebugMode
import '../utils/storage_util.dart';
import '../utils/constants.dart'; // Import your constants file

class ImageService {
  static const String uploadUrl = '$baseUrl/upload'; // Use the base URL from constants
  static const String baseUrl = Constants.apiBaseUrl; // Use the base URL from constants

  // Helper method for debug logging
  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  Future<UploadResult?> uploadImage(File file) async {
    try {
      // Get authentication token
      final accessToken = await StorageUtil.getString('accessToken') ?? '';
      
      if (accessToken.isEmpty) {
        _debugLog('⚠️ No authentication token available for image upload');
        return null;
      }

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer $accessToken';
      
      request.files.add(await http.MultipartFile.fromPath(
        'file', // field name, should match what your server expects
        file.path,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);

        return UploadResult(
          url: jsonData['url'],
          success: true,
        );
      } else {
        _debugLog('Failed to upload image. Status code: ${response.statusCode}');
        if (response.statusCode == 401) {
          _debugLog('❌ Authentication failed - check access token');
        }
        return null;
      }
    } catch (e) {
      _debugLog('Error uploading image: $e');
      return null;
    }
  }

  // Helper method to determine media type from file extension
  String _getMediaTypeFromFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'image';
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'webm':
        return 'video';
      default:
        return 'image'; // Default to image
    }
  }

  // Helper method to normalize media type
  String _normalizeMediaType(String mediaType) {
    if (mediaType.startsWith('image/')) {
      return 'image';
    } else if (mediaType.startsWith('video/')) {
      return 'video';
    }
    return mediaType;
  }

  // Upload a story (file + metadata) to the server
  Future<StoryUploadResult?> uploadStoryWithFile({
    required File file,
    required String schoolId
  }) async {
    try {
      // First upload the file to get the URL
      final uploadResult = await uploadImage(file);
      
      if (uploadResult == null || !uploadResult.success) {
        _debugLog('❌ Failed to upload file for story');
        return null;
      }
      
      // Determine media type from file extension
      final mediaType = _getMediaTypeFromFile(file);
      
      _debugLog('📁 File uploaded successfully: ${uploadResult.url}');
      _debugLog('📱 Media type detected: $mediaType');
      
      // Now upload the story with the media URL
      return await uploadStory(
        mediaUrl: uploadResult.url,
        mediaType: mediaType,
        schoolId: schoolId
      );
    } catch (e) {
      _debugLog('💥 Error uploading story with file: $e');
      return null;
    }
  }

  // Upload a story to the server
  Future<StoryUploadResult?> uploadStory({
    required String mediaUrl, 
    required String mediaType, 
    required String schoolId
  }) async {
    try {
      // Validate inputs
      if (mediaUrl.isEmpty) {
        _debugLog('❌ mediaUrl is empty');
        return null;
      }
      
      // Normalize the media type (convert image/jpeg to image, video/mp4 to video, etc.)
      final normalizedMediaType = _normalizeMediaType(mediaType);
      
      if (normalizedMediaType.isEmpty || (normalizedMediaType != 'image' && normalizedMediaType != 'video')) {
        _debugLog('❌ Invalid mediaType: $mediaType -> $normalizedMediaType (must be "image" or "video")');
        return null;
      }
      
      if (schoolId.isEmpty) {
        _debugLog('❌ schoolId is empty');
        return null;
      }

      // Get authentication token
      final accessToken = await StorageUtil.getString('accessToken') ?? '';
      
      if (accessToken.isEmpty) {
        _debugLog('⚠️ No authentication token available');
        return null;
      }

      final requestBody = {
        'mediaUrl': mediaUrl,
        'mediaType': normalizedMediaType, // Use normalized media type
        'schoolId': schoolId
      };
      
      _debugLog('📤 Uploading story with data: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/story'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestBody)
      );

      _debugLog('📡 Story upload response status: ${response.statusCode}');
      _debugLog('📡 Story upload response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _debugLog('✅ Story uploaded successfully');
        return StoryUploadResult(success: true);
      } else {
        _debugLog('Failed to upload story. Status code: ${response.statusCode}');
        _debugLog('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      _debugLog('Error uploading story: $e');
      return null;
    }
  }

  // Get stories for a specific school
  Future<List<Story>> getStoriesBySchool(String schoolId) async {
    try {
      // Get the authentication token from storage
      final accessToken = await StorageUtil.getString('accessToken') ?? '';
      final schoolToken = await StorageUtil.getString('schoolToken') ?? '';
      
      if (accessToken.isEmpty && schoolToken.isEmpty) {
        _debugLog('⚠️ No authentication token available');
        return [];
      }
      
      // Create headers with authorization
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'school-token': schoolToken,
      };
      
      _debugLog('🔑 Using token for API call: ${headers['Authorization']}');
      _debugLog('🏫 Using school token: ${headers['school-token']}');
      _debugLog('📞 Fetching stories for schoolId: $schoolId');
      
      final response = await http.get(
        Uri.parse('${uploadUrl.replaceAll('/upload', '')}/story?schoolId=$schoolId'),
        headers: headers
      );

      _debugLog('📡 Story API response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        _debugLog('📚 Story data received: ${response.body.substring(0, min(100, response.body.length))}...');
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final stories = (jsonData['data'] as List)
              .map((storyJson) => Story.fromJson(storyJson))
              .toList();
          _debugLog('📚 Parsed ${stories.length} stories successfully');
          return stories;
        }
        _debugLog('⚠️ No stories found or unexpected response format');
        return [];
      } else {
        _debugLog('❌ Failed to fetch stories. Status code: ${response.statusCode}');
        _debugLog('❌ Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      _debugLog('💥 Error fetching stories: $e');
      return [];
    }
  }
  
  // Helper to get the smaller of two integers
  int min(int a, int b) {
    return a < b ? a : b;
  }

  // Upload profile image and update user profile
  Future<String?> updateProfileImage(File imageFile) async {
    try {
      // First upload the image
      final imageUrl = await uploadImage(imageFile);
      
      if (imageUrl == null) {
        _debugLog('❌ Failed to upload image');
        return null;
      }
      
      // Get authentication token
      final accessToken = await StorageUtil.getString('accessToken') ?? '';
      
      if (accessToken.isEmpty) {
        _debugLog('⚠️ No authentication token available');
        return null;
      }
      
      // Update user profile with new image URL
      final response = await http.post(
        Uri.parse('$baseUrl/users/me/image'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'urlPath': imageUrl.url,
        }),
      );
      
      _debugLog('📡 Update profile image response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        _debugLog('✅ Profile image updated successfully');
        return imageUrl.url;
      } else {
        _debugLog('❌ Failed to update profile image. Status: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      _debugLog('💥 Error updating profile image: $e');
      return null;
    }
  }
  
  // Get user profile image
  Future<String?> getProfileImage(String userId) async {
    try {
      final accessToken = await StorageUtil.getString('accessToken') ?? '';
      
      if (accessToken.isEmpty) {
        _debugLog('⚠️ No authentication token available');
        return null;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/users/me/image/$userId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['urlPath'] as String?;
      } else {
        _debugLog('❌ Failed to get profile image. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _debugLog('💥 Error getting profile image: $e');
      return null;
    }
  }
}

// Model class for Story
class Story {
  final String id;
  final String schoolId;
  final StoryUser user;  // Changed from User to StoryUser
  final String mediaUrl;
  final String mediaType;
  final DateTime createdAt;

  Story({
    required this.id,
    required this.schoolId,
    required this.user,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['_id'],
      schoolId: json['schoolId'],
      user: StoryUser.fromJson(json['userId']),  // Changed from User to StoryUser
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// Renamed from User to StoryUser to avoid name collision
class StoryUser {
  final String id;
  final String name;
  final String role;

  StoryUser({
    required this.id,
    required this.name,
    required this.role,
  });

  factory StoryUser.fromJson(Map<String, dynamic> json) {
    return StoryUser(
      id: json['_id'],
      name: json['name'],
      role: json['role'],
    );
  }
}

// Add new model classes for upload results
class UploadResult {
  final String url;
  final bool success;

  UploadResult({
    required this.url,
    required this.success,
  });
}

class StoryUploadResult {
  final bool success;

  StoryUploadResult({
    required this.success,
  });
}


