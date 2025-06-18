import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/storage_util.dart';
import '../services/fcm_service.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';
import 'parent_dashboard.dart';
import 'school_admin_dashboard.dart';
import '../services/student_service.dart';
import '../utils/constants.dart'; // Import constants for base URL

class LoginScreen extends StatefulWidget {
  final String? selectedRole;
  final String schoolName;
  final String schoolToken;
  
  const LoginScreen({
    super.key, 
    this.selectedRole, 
    required this.schoolName,
    required this.schoolToken,
  });

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showLoginForm = false;
  String _selectedRole = '';
  bool _isLoading = false;
  bool _obscurePassword = true; // Add this line
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    if (widget.selectedRole != null) {
      _selectedRole = widget.selectedRole!;
      _showLoginForm = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // Helper methods for role-related information
  String _getRoleName(String role) {
    switch (role) {
      case 'school_admin': return 'School Admin';
      case 'teacher': return 'Teacher';
      case 'student': return 'Student';
      case 'parent': return 'Parent';
      default: return 'User';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'school_admin': return Colors.blue;
      case 'teacher': return Colors.green;
      case 'student': return Colors.orange;
      case 'parent': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'school_admin': return Icons.admin_panel_settings;
      case 'teacher': return Icons.school;
      case 'student': return Icons.person;
      case 'parent': return Icons.family_restroom;
      default: return Icons.person;
    }
  }
  
  // Rename this method to _navigateBasedOnRoleDemo for clarity

  void _navigateBasedOnRole(String role, User user) {
    if (!mounted) return;
    
    switch (role) {
      case 'school_admin':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SchoolAdminDashboard(user: user)),
          (route) => false,
        );
        break;
      case 'teacher':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => TeacherDashboard(user: user)),
          (route) => false,
        );
        break;
      case 'student':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => StudentDashboard(user: user)),
          (route) => false,
        );
        break;
      case 'parent':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ParentDashboard(user: user)),
          (route) => false,
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$role dashboard not implemented yet')),
        );
    }
  }
  
  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });
    
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text;
      
      try {
        final response = await http.post(
          Uri.parse('https://nova-backend-tlzr.onrender.com/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'password': password,
          }),
        );
        
        final responseData = json.decode(response.body);
        
        // 🔥 CONSOLE LOG THE COMPLETE RESPONSE
        print('🚀 ==========  AUTH/LOGIN RESPONSE  ==========');
        print('📡 Status Code: ${response.statusCode}');
        print('📄 Response Body: ${response.body}');
        print('📋 Parsed Response Data: $responseData');
        print('🚀 =========================================');
        
        if (response.statusCode == 200 && responseData['success'] == true) {
          final userData = responseData['data']['user'];
          final tokens = responseData['data']['tokens'];
          
          // 🔥 CONSOLE LOG USER DATA
          print('👤 User Data: $userData');
          print('🔑 Tokens: $tokens');
          
          // Store access token and refresh token for future requests
          await StorageUtil.setString('accessToken', tokens['accessToken']);
          await StorageUtil.setString('refreshToken', tokens['refreshToken']);
          
          // Extract schoolId from user data
          String schoolId = userData['schoolId']?.toString() ?? '';
          print('🏫 Extracted schoolId from user: $schoolId');
          
          // Try to fetch school data using the correct API endpoint
          String schoolName = 'Unknown School';
          String schoolToken = '';
          String schoolAddress = '';
          String schoolPhone = '';
          
          if (schoolId.isNotEmpty) {
            try {
              print('🔍 Fetching school data for ID: $schoolId');
              final schoolResponse = await http.get(
                Uri.parse('https://nova-backend-tlzr.onrender.com/api/schools?schoolId=$schoolId'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer ${tokens['accessToken']}',
                },
              );
              
              print('🏫 School API Response Status: ${schoolResponse.statusCode}');
              print('🏫 School API Response Body: ${schoolResponse.body}');
              
              if (schoolResponse.statusCode == 200) {
                final schoolResponseData = json.decode(schoolResponse.body);
                
                if (schoolResponseData['success'] == true && 
                    schoolResponseData['data'] != null && 
                    schoolResponseData['data']['schools'] != null &&
                    schoolResponseData['data']['schools'].isNotEmpty) {
                  
                  // Extract school data from the schools array
                  final fetchedSchoolData = schoolResponseData['data']['schools'][0];
                  
                  // Map the response fields to our storage
                  schoolToken = fetchedSchoolData['secretKey'] ?? ''; // Using secretKey as token
                  schoolName = fetchedSchoolData['name'] ?? 'Unknown School';
                  schoolAddress = fetchedSchoolData['address'] ?? '';
                  schoolPhone = fetchedSchoolData['phone'] ?? '';
                  
                  print('✅ Successfully fetched school data:');
                  print('✅ School Name: $schoolName');
                  print('✅ School Token (secretKey): $schoolToken');
                  print('✅ School Address: $schoolAddress');
                  print('✅ School Phone: $schoolPhone');
                  print('✅ School ID: ${fetchedSchoolData['_id']}');
                  print('✅ School Email: ${fetchedSchoolData['email']}');
                  print('✅ Teachers: ${fetchedSchoolData['teachers']}');
                  print('✅ Students: ${fetchedSchoolData['students']}');
                  print('✅ Classes: ${fetchedSchoolData['classes']}');
                  print('✅ Parents: ${fetchedSchoolData['parents']}');
                  print('✅ Admins: ${fetchedSchoolData['admins']}');
                  
                  // Store additional school data that might be useful
                  await StorageUtil.setString('schoolEmail', fetchedSchoolData['email'] ?? '');
                  await StorageUtil.setString('schoolSecretKey', fetchedSchoolData['secretKey'] ?? '');
                  await StorageUtil.setString('schoolTeachers', json.encode(fetchedSchoolData['teachers'] ?? []));
                  await StorageUtil.setString('schoolStudents', json.encode(fetchedSchoolData['students'] ?? []));
                  await StorageUtil.setString('schoolClasses', json.encode(fetchedSchoolData['classes'] ?? []));
                  await StorageUtil.setString('schoolParents', json.encode(fetchedSchoolData['parents'] ?? []));
                  await StorageUtil.setString('schoolAdmins', json.encode(fetchedSchoolData['admins'] ?? []));
                  
                } else {
                  print('⚠️ School data response format unexpected or empty: $schoolResponseData');
                }
              } else {
                print('⚠️ Failed to fetch school data. Status: ${schoolResponse.statusCode}');
                print('⚠️ Response: ${schoolResponse.body}');
              }
            } catch (e) {
              print('⚠️ Error fetching school data: $e');
            }
          }
          
          // Store school data (fetched or defaults)
          await StorageUtil.setString('schoolToken', schoolToken);
          await StorageUtil.setString('schoolName', schoolName);
          await StorageUtil.setString('schoolId', schoolId);
          await StorageUtil.setString('schoolAddress', schoolAddress);
          await StorageUtil.setString('schoolPhone', schoolPhone);
          
          print('💾 STORED SCHOOL VALUES:');
          print('💾 schoolToken: $schoolToken');
          print('💾 schoolName: $schoolName');
          print('💾 schoolId: $schoolId');
          print('💾 schoolAddress: $schoolAddress');
          print('💾 schoolPhone: $schoolPhone');
          
          // Verification checks
          bool roleMatches = userData['role'] == _selectedRole;
          
          if (!roleMatches) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Access denied: The role does not match your account type'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            // Create user object with school data
            final user = User(
              id: userData['id'],
              email: userData['email'],
              role: userData['role'],
              schoolToken: schoolToken,
              schoolName: schoolName,
              profile: UserProfile(
                firstName: userData['name']?.split(' ')[0] ?? 'User',
                lastName: userData['name']?.split(' ').length > 1 ? userData['name'].split(' ')[1] : '',
                phone: '123-456-7890',
                address: '123 School St',
                profilePicture: 'https://randomuser.me/api/portraits/${userData['role'] == 'teacher' ? 'men' : 
                                                       userData['role'] == 'student' ? 'lego' : 
                                                       userData['role'] == 'parent' ? 'women' : 'men'}/1.jpg',
              ),
            );
            
            // Store user information in persistent storage
            await StorageUtil.setString('userId', user.id);
            await StorageUtil.setString('userEmail', user.email);
            await StorageUtil.setString('userRole', user.role);
            await StorageUtil.setString('userFirstName', user.profile.firstName);
            await StorageUtil.setString('userLastName', user.profile.lastName);
            await StorageUtil.setString('userPhone', user.profile.phone);
            await StorageUtil.setString('userAddress', user.profile.address);
            await StorageUtil.setString('userProfilePic', user.profile.profilePicture);
            
            // Store theme preferences
           
            
            // Flag to indicate user is logged in - THIS IS CRUCIAL
            await StorageUtil.setBool('isLoggedIn', true);
            
            // Verify storage was successful
            final verifyLogin = await StorageUtil.getBool('isLoggedIn');
            print('✅ Login status stored and verified: $verifyLogin');
            
            // For student role, fetch class ID before proceeding
            String? classId;
            if (user.role == 'student') {
              try {
                final studentService = StudentService(baseUrl: Constants.apiBaseUrl);
                final studentData = await studentService.getStudentById(user.id);
                
                if (studentData.containsKey('classId')) {
                  if (studentData['classId'] is Map<String, dynamic>) {
                    classId = studentData['classId']['_id'];
                  } else {
                    classId = studentData['classId'];
                  }
                  
                  if (classId != null) {
                    await StorageUtil.setString('userClassId', classId);
                    print('📚 Student class ID stored: $classId');
                  }
                }
              } catch (e) {
                print('📚 Error fetching student class ID: $e');
              }
            }
            
            // Generate FCM token and subscribe to school topic
            try {
              final fcmService = FCMService();
              
              await fcmService.initialize();
              final fcmToken = fcmService.fcmToken;
              print('🔔 FCM Token generated: $fcmToken');
              
              if (schoolId.isNotEmpty) {
                await fcmService.subscribeToSchoolTopic(schoolId);
                print('🔔 Subscribed to school topic: school_$schoolId');
                
                await fcmService.storeFCMDataForUser(
                  userId: user.id,
                  schoolId: schoolId,
                  userRole: user.role,
                );
                print('🔔 FCM data stored for user: ${user.id}');

                if (fcmToken != null) {
                  await _registerFcmTokenWithServer(
                    token: fcmToken,
                    schoolId: schoolId,
                    userId: user.id,
                    role: user.role,
                    classId: classId,
                  );
                }
              }
            } catch (e) {
              print('⚠️ Error setting up FCM: $e');
            }
            
            // 🔥 FINAL VERIFICATION - LOG ALL STORED VALUES
            print('🔍 FINAL VERIFICATION - ALL STORED VALUES:');
            final finalSchoolToken = await StorageUtil.getString('schoolToken');
            final finalSchoolName = await StorageUtil.getString('schoolName');
            final finalSchoolId = await StorageUtil.getString('schoolId');
            final finalSchoolAddress = await StorageUtil.getString('schoolAddress');
            final finalSchoolPhone = await StorageUtil.getString('schoolPhone');
            final finalSchoolEmail = await StorageUtil.getString('schoolEmail');
            final finalSchoolSecretKey = await StorageUtil.getString('schoolSecretKey');
            final finalSchoolTeachers = await StorageUtil.getString('schoolTeachers');
            final finalSchoolStudents = await StorageUtil.getString('schoolStudents');
            final finalSchoolClasses = await StorageUtil.getString('schoolClasses');
            final finalSchoolParents = await StorageUtil.getString('schoolParents');
            final finalSchoolAdmins = await StorageUtil.getString('schoolAdmins');
            final finalUserId = await StorageUtil.getString('userId');
            final finalUserEmail = await StorageUtil.getString('userEmail');
            final finalUserRole = await StorageUtil.getString('userRole');
            final finalIsLoggedIn = await StorageUtil.getBool('isLoggedIn');
            
            print('✅ Final schoolToken: $finalSchoolToken');
            print('✅ Final schoolName: $finalSchoolName');
            print('✅ Final schoolId: $finalSchoolId');
            print('✅ Final schoolAddress: $finalSchoolAddress');
            print('✅ Final schoolPhone: $finalSchoolPhone');
            print('✅ Final schoolEmail: $finalSchoolEmail');
            print('✅ Final schoolSecretKey: $finalSchoolSecretKey');
            print('✅ Final schoolTeachers: $finalSchoolTeachers');
            print('✅ Final schoolStudents: $finalSchoolStudents');
            print('✅ Final schoolClasses: $finalSchoolClasses');
            print('✅ Final schoolParents: $finalSchoolParents');
            print('✅ Final schoolAdmins: $finalSchoolAdmins');
            print('✅ Final userId: $finalUserId');
            print('✅ Final userEmail: $finalUserEmail');
            print('✅ Final userRole: $finalUserRole');
            print('✅ Final isLoggedIn: $finalIsLoggedIn');
            
            // Navigate based on role
            _navigateBasedOnRole(userData['role'], user);
          }
        } else {
          String errorMessage = responseData['message'] ?? 'Login failed';
          
          if (response.statusCode == 401) {
            errorMessage = 'Invalid email or password';
          } else if (response.statusCode == 403) {
            errorMessage = 'Your account is not authorized for this school';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('❌ Login error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  // Update to include classId parameter
  Future<void> _registerFcmTokenWithServer({
    required String token,
    required String schoolId,
    required String userId,
    required String role,
    String? classId,  // Add classId parameter
  }) async {
    try {
      // Create request body with all parameters
      final Map<String, dynamic> requestBody = {
        "token": token,
        "userId": userId,
        "schoolId": schoolId,
        "topic": "school_$schoolId",
        "deviceType": Theme.of(context).platform == TargetPlatform.iOS ? "ios" : "android",
        "role": role,
      };
      
      // Add classId to request body if it exists (for students)
      if (classId != null) {
        requestBody["classId"] = classId;
        print('🔔 Including classId in FCM registration: $classId');
      }
      
      final response = await http.post(
        Uri.parse('https://nova-backend-tlzr.onrender.com/api/fcm/token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 200) {
        print('🔔 FCM token registered with server successfully');
      } else {
        print('⚠️ Failed to register FCM token with server: ${response.body}');
      }
    } catch (e) {
      print('⚠️ Error registering FCM token with server: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showLoginForm ? AppBar(
        backgroundColor: const Color.fromARGB(184, 92, 206, 228),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Always go back to the previous screen (role selection)
            Navigator.pop(context);
          },
        ),
        title: Text(widget.schoolName),
      ) : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Hero(
                            tag: 'app_logo',
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.school,
                                size: 60,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _showLoginForm 
                                ? '${_getRoleName(_selectedRole)} Login' 
                                : widget.schoolName,
                           
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _showLoginForm 
                                ? 'Sign in to continue' 
                                : 'Select your role to continue',
                           
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          if (_showLoginForm) 
                            _buildLoginForm()
                          else
                            _buildRoleSelection(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.email),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Navigate to forgot password screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Forgot password functionality will be implemented soon'),
                  ),
                );
              },
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: _getRoleColor(_selectedRole),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRoleSelection() {
    final roles = ['school_admin', 'teacher', 'student', 'parent'];
    
    return Column(
      children: [
        ...roles.map((role) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedRole = role;
                _showLoginForm = true;
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: _getRoleColor(role),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getRoleIcon(role)),
                const SizedBox(width: 12),
                Text(
                  _getRoleName(role),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

