import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/storage_util.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';
import 'parent_dashboard.dart';
import 'school_admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final String? selectedRole;
  final String schoolName;
  final String schoolToken;
  
  const LoginScreen({
    Key? key, 
    this.selectedRole, 
    required this.schoolName,
    required this.schoolToken,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showLoginForm = false;
  String _selectedRole = '';
  bool _isLoading = false;
  
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
  void _navigateBasedOnRoleDemo(String role) async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate network delay for a more realistic experience
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
    
    if (mounted) {
      // Create a mock user for demonstration purposes
      final user = User(
        id: '1',
        email: _emailController.text.trim(),
        role: role,
        schoolToken: widget.schoolToken,
        schoolName: widget.schoolName,
        profile: UserProfile(
          firstName: role == 'school_admin' ? 'Admin' : 
                    role == 'teacher' ? 'Teacher' :
                    role == 'student' ? 'Student' : 'Parent',
          lastName: 'User',
          phone: '123-456-7890',
          address: '123 School St',
          profilePicture: 'https://randomuser.me/api/portraits/${role == 'teacher' ? 'men' : 
                                                               role == 'student' ? 'lego' : 
                                                               role == 'parent' ? 'women' : 'men'}/1.jpg',
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
      
      // Flag to indicate user is logged in
      await StorageUtil.setBool('isLoggedIn', true);

      // Call the main navigation method with the user
      _navigateBasedOnRole(role, user);
    } else {
      // Show an error message if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to login. Please try again.')),
      );
    }
  }

  void _navigateBasedOnRole(String role, User user) {
    if (!mounted) return;
    
    switch (role) {
      case 'school_admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SchoolAdminDashboard(user: user)),
        );
        break;
      case 'teacher':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TeacherDashboard(user: user)),
        );
        break;
      case 'student':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentDashboard(user: user)),
        );
        break;
      case 'parent':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ParentDashboard(user: user)),
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
        // Get schoolId from storage for verification
        final storedSchoolId = await StorageUtil.getString('schoolId');
        
        if (storedSchoolId == null) {
          throw Exception('School ID not found. Please select a school again.');
        }
        
        final response = await http.post(
          Uri.parse('http://localhost:3000/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'password': password,
          }),
        );
        
        final responseData = json.decode(response.body);
        
        if (response.statusCode == 200 && responseData['success'] == true) {
          final userData = responseData['data']['user'];
          final tokens = responseData['data']['tokens'];
          final responseSchoolId = userData['schoolId']?.toString() ?? '';
          
          // Store access token and refresh token for future requests
          await StorageUtil.setString('accessToken', tokens['accessToken']);
          await StorageUtil.setString('refreshToken', tokens['refreshToken']);
          
          // Verification checks:
          // 1. Check if the role matches
          // 2. Check if the schoolId matches
          bool roleMatches = userData['role'] == _selectedRole;
          bool schoolIdMatches = responseSchoolId == storedSchoolId;
          
          if (!roleMatches) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Access denied: The role does not match your account type'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (!schoolIdMatches) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Access denied: You are not authorized for this school'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            // Both role and schoolId match, proceed with navigation
            final user = User(
              id: userData['id'],
              email: userData['email'],
              role: userData['role'],
              schoolToken: widget.schoolToken,
              schoolName: widget.schoolName,
              profile: UserProfile(
                firstName: userData['name']?.split(' ')[0] ?? 'User',
                lastName: userData['name']?.split(' ').length > 1 ? userData['name'].split(' ')[1] : '',
                phone: '123-456-7890', // Default value, update if API provides phone
                address: '123 School St', // Default value, update if API provides address
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
            
            // Flag to indicate user is logged in
            await StorageUtil.setBool('isLoggedIn', true);
            
            // Navigate based on role, passing the user object
            _navigateBasedOnRole(userData['role'], user);
          }
        } else {
          String errorMessage = responseData['message'] ?? 'Login failed';
          
          // Check for specific error conditions
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showLoginForm ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.selectedRole != null) {
              Navigator.pop(context);
            } else {
              setState(() {
                _showLoginForm = false;
              });
            }
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
                            textAlign: TextAlign.center,
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
                            textAlign: TextAlign.center,
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
                  if (_showLoginForm) 
                    ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Quick Login (Demo)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading 
                            ? null 
                            : () => _navigateBasedOnRoleDemo(_selectedRole), // Update this call
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: _getRoleColor(_selectedRole).withOpacity(0.8),
                          foregroundColor: Colors.white,
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
                            : Text('Login as ${_getRoleName(_selectedRole)} (Demo)'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Remove the entire registration section to avoid navigation to non-existent page
                          /* Removing this section:
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Signup functionality will be implemented soon'),
                                ),
                              );
                            },
                            child: const Text('Register'),
                          ),
                          */
                        ],
                      ),
                    ],
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
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            obscureText: true,
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
