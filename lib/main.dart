import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'utils/storage_util.dart';
import 'screens/school_selection_screen.dart';
import 'utils/app_theme.dart';
import 'models/user_model.dart';
import 'screens/school_admin_dashboard.dart';
import 'screens/student_dashboard.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/parent_dashboard.dart';


bool _isAppInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (!_isAppInitialized) {
      print('🔄 App initialization started (first time)');
      _isAppInitialized = true;
      await StorageUtil.setString('app_initialized', DateTime.now().toString());
      final verifyValue = await StorageUtil.getString('app_initialized');
      print('🔍 Verification write/read test: ${verifyValue != null ? "SUCCESS" : "FAILED"}');
      
      // Dump all stored values for debugging
      await StorageUtil.debugDumpAll();
    } else {
      print('🔄 Skipping duplicate initialization on hot reload');
      // Just reinitialize StorageUtil without any other operations
      await StorageUtil.init();
    }
  } catch (e) {
    print('⚠️ Error during initialization: $e');
    // Continue with app launch even if initialization fails
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Use a completer to handle the initialization once
  final Completer<bool> _initCompleter = Completer<bool>();
  bool _initStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Don't call _initializeApp() here, let the FutureBuilder do it
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('🔄 App lifecycle state changed to: $state');
    // Reinitialize storage when app resumes from background
    if (state == AppLifecycleState.resumed) {
      StorageUtil.init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Management App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(AppTheme.defaultTheme),
      home: FutureBuilder<bool>(
        // This ensures StorageUtil is initialized even after hot reload
        future: _getInitFuture(),
        builder: (context, snapshot) {
          // While initializing, show a loading screen
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          }
          
          // After initialization, check if user is already logged in
          return FutureBuilder<bool>(
            future: _checkLoginStatus(),
            builder: (context, loginSnapshot) {
              if (loginSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen();
              }
              
              // If user is logged in, navigate directly to appropriate dashboard
              if (loginSnapshot.data == true) {
                // Show a temporary loading message while redirecting
                Future.microtask(() => _navigateToUserDashboard(context));
                return _buildLoadingScreen();
              }
              
              // Otherwise, go to school selection screen
              return const SchoolSelectionScreen();
            },
          );
        },
      ),
    );
  }
  
  Future<bool> _getInitFuture() {
    if (!_initStarted) {
      _initStarted = true;
      _initializeApp().then((value) {
        if (!_initCompleter.isCompleted) {
          _initCompleter.complete(value);
        }
      }).catchError((error) {
        if (!_initCompleter.isCompleted) {
          print('⚠️ Error during app initialization: $error');
          _initCompleter.complete(false);
        }
      });
    }
    return _initCompleter.future;
  }
  
  Future<bool> _initializeApp() async {
    try {
      print('🔄 App UI initialization started');
      
      // Lightweight initialization for hot reload
      // Just check if storage is available without writing test values
      await StorageUtil.init();
      
      // Do not write test values here to avoid disturbing existing data
      return true;
    } catch (e) {
      print('⚠️ Error during app UI initialization: $e');
      return false;
    }
  }
  
  // New method to check if user is logged in
  Future<bool> _checkLoginStatus() async {
    final isLoggedIn = await StorageUtil.getBool('isLoggedIn') ?? false;
    print('🔐 User login status check: $isLoggedIn');
    return isLoggedIn;
  }
  
  // New method to navigate to appropriate dashboard based on stored user role
  Future<void> _navigateToUserDashboard(BuildContext context) async {
    try {
      // Get necessary user data from storage
      final userId = await StorageUtil.getString('userId');
      final userEmail = await StorageUtil.getString('userEmail');
      final userRole = await StorageUtil.getString('userRole');
      final userFirstName = await StorageUtil.getString('userFirstName');
      final userLastName = await StorageUtil.getString('userLastName');
      final userPhone = await StorageUtil.getString('userPhone') ?? '';
      final userAddress = await StorageUtil.getString('userAddress') ?? '';
      final userProfilePic = await StorageUtil.getString('userProfilePic') ?? '';
      final schoolName = await StorageUtil.getString('schoolName') ?? '';
      final schoolToken = await StorageUtil.getString('schoolToken') ?? '';
      
      // Check if we have the minimum required data
      if (userId == null || userEmail == null || userRole == null || 
          userFirstName == null || userLastName == null) {
        print('⚠️ Incomplete user data in storage - redirecting to login');
        return;
      }
      
      print('🔐 Navigating to dashboard for role: $userRole');
      
      // Create a user object from stored data
      final user = User(
        id: userId,
        email: userEmail,
        role: userRole,
        schoolToken: schoolToken,
        schoolName: schoolName,
        profile: UserProfile(
          firstName: userFirstName,
          lastName: userLastName,
          phone: userPhone,
          address: userAddress,
          profilePicture: userProfilePic,
        ),
      );
      
      // Navigate to the appropriate dashboard
      switch (userRole) {
        case 'school_admin':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SchoolAdminDashboard(user: user)),
          );
          break;
        case 'teacher':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => TeacherDashboard(user: user)),
          );
          break;
        case 'student':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => StudentDashboard(user: user)),
          );
          break;
        case 'parent':
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ParentDashboard(user: user)),
          );
          break;
        default:
          // If role is unrecognized, don't navigate
          print('⚠️ Unknown user role: $userRole');
      }
    } catch (e) {
      print('⚠️ Error in _navigateToUserDashboard: $e');
      // In case of any error, let the app default to SchoolSelectionScreen
    }
  }
  
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.school,
                size: 80,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Loading...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
