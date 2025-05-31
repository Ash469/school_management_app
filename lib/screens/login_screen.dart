import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';
import 'parent_dashboard.dart';
import 'school_admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final String? selectedRole;
  
  const LoginScreen({Key? key, this.selectedRole}) : super(key: key);

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
  
  void _navigateBasedOnRole(String role) async {
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
    } else {
      // Show an error message if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to login. Please try again.')),
      );
    }
  }

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

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simplified login logic for demo
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text;
      
      // In a real app, you would verify credentials with a backend
      if (email == "parent@example.com" && password == "password") {
        _navigateBasedOnRole('parent');
      } else if (email == "teacher@example.com" && password == "password") {
        _navigateBasedOnRole('teacher');
      } else if (email == "admin@example.com" && password == "password") {
        _navigateBasedOnRole('school_admin');
      } else if (email == "student@example.com" && password == "password") {
        _navigateBasedOnRole('student');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid credentials. Please try again.'),
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
                                : 'School Management',
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
                            : () => _navigateBasedOnRole(_selectedRole),
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
