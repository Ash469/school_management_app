import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthBloc {
  final ApiService apiService;
  
  // Controllers for login form
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // Stream controllers for authentication state
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<Map<String, dynamic>?> currentUser = ValueNotifier<Map<String, dynamic>?>(null);
  
  AuthBloc({required this.apiService});
  
  Future<bool> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = 'Email and password are required';
      return false;
    }
    
    try {
      isLoading.value = true;
      errorMessage.value = null;
      
      final response = await apiService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      
      // Store token and user data (in a real app, would use secure storage)
      currentUser.value = response['user'];
      
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Login failed: ${e.toString()}';
      return false;
    }
  }
  
  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      
      final response = await apiService.register(userData);
      
      isLoading.value = false;
      return response['success'] ?? false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Registration failed: ${e.toString()}';
      return false;
    }
  }
  
  Future<bool> forgotPassword(String email) async {
    if (email.isEmpty) {
      errorMessage.value = 'Email is required';
      return false;
    }
    
    try {
      isLoading.value = true;
      errorMessage.value = null;
      
      final response = await apiService.forgotPassword(email);
      
      isLoading.value = false;
      return response['success'] ?? false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Password reset failed: ${e.toString()}';
      return false;
    }
  }
  
  void logout() {
    // Clear user data and token
    currentUser.value = null;
  }
  
  // Method for dummy login with predefined roles
  Future<bool> loginWithDummyAccount(String role) async {
    isLoading.value = true;
    errorMessage.value = null;
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      // Create dummy user data based on selected role
      final Map<String, dynamic> dummyUserData = {
        '_id': 'dummy_${role}_id',
        'username': '${role}_user',
        'email': '${role}@example.com',
        'role': role,
        'profile': {
          'firstName': role.substring(0, 1).toUpperCase() + role.substring(1),
          'lastName': 'User',
          'phoneNumber': '1234567890',
          'address': '123 School Street',
          'profilePicture': 'https://via.placeholder.com/150',
        },
        'schoolId': 'school_1',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      // Set the current user
      currentUser.value = dummyUserData;
      
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Login failed: ${e.toString()}';
      return false;
    }
  }
  
  // Helper method to get the User model from currentUser value
  User? getCurrentUser() {
    if (currentUser.value == null) return null;
    return User.fromJson(currentUser.value!);
  }
  
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    currentUser.dispose();
  }
}
