import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'utils/storage_util.dart';
// import 'screens/school_selection_screen.dart';
import 'screens/role_selection_screen.dart';
import 'utils/app_theme.dart';
import 'models/user_model.dart';
import 'screens/school_admin_dashboard.dart';
import 'screens/student_dashboard.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/parent_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/fcm_service.dart';
import 'firebase_options.dart'; 


bool _isAppInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize FCM Service
  try {
    final fcmService = FCMService();
    await fcmService.initialize();
    if (kDebugMode) {
      print('🔔 FCM Service initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Error initializing FCM Service: $e');
    }
  }

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
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      // Add a small delay for better UX
      await Future.delayed(const Duration(seconds: 1));
      
      // Check if user is logged in
      final isLoggedIn = await StorageUtil.getBool('isLoggedIn') ?? false;
      
      if (kDebugMode) {
        print('🔍 Checking login status: $isLoggedIn');
      }
      
      if (isLoggedIn) {
        // Try to restore user session
        await _restoreUserSession();
      } else {
        // Navigate to school selection
        _navigateToSchoolSelection();
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error checking login status: $e');
      }
      // On error, go to school selection
      _navigateToSchoolSelection();
    }
  }

  Future<void> _restoreUserSession() async {
    try {
      // Get stored user data
      final userId = await StorageUtil.getString('userId') ?? '';
      final userEmail = await StorageUtil.getString('userEmail') ?? '';
      final userRole = await StorageUtil.getString('userRole') ?? '';
      final userFirstName = await StorageUtil.getString('userFirstName') ?? '';
      final userLastName = await StorageUtil.getString('userLastName') ?? '';
      final userPhone = await StorageUtil.getString('userPhone') ?? '';
      final userAddress = await StorageUtil.getString('userAddress') ?? '';
      final userProfilePic = await StorageUtil.getString('userProfilePic') ?? '';
      final schoolToken = await StorageUtil.getString('schoolToken') ?? '';
      final schoolName = await StorageUtil.getString('schoolName') ?? '';

      if (kDebugMode) {
        print('🔍 Restoring user session:');
        print('🔍 User ID: $userId');
        print('🔍 User Email: $userEmail');
        print('🔍 User Role: $userRole');
        print('🔍 School Name: $schoolName');
      }

      // Validate essential data
      if (userId.isEmpty || userEmail.isEmpty || userRole.isEmpty) {
        if (kDebugMode) {
          print('⚠️ Essential user data missing, redirecting to login');
        }
        _navigateToSchoolSelection();
        return;
      }

      // Create user object from stored data
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

      // Navigate based on role
      _navigateBasedOnRole(userRole, user);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error restoring user session: $e');
      }
      _navigateToSchoolSelection();
    }
  }

  void _navigateBasedOnRole(String role, User user) {
    if (!mounted) return;

    Widget destinationScreen;
    
    switch (role) {
      case 'school_admin':
        destinationScreen = SchoolAdminDashboard(user: user);
        break;
      case 'teacher':
        destinationScreen = TeacherDashboard(user: user);
        break;
      case 'student':
        destinationScreen = StudentDashboard(user: user);
        break;
      case 'parent':
        destinationScreen = ParentDashboard(user: user);
        break;
      default:
        if (kDebugMode) {
          print('⚠️ Unknown role: $role, redirecting to school selection');
        }
        _navigateToSchoolSelection();
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destinationScreen),
    );
  }

  void _navigateToSchoolSelection() {
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen(
         schoolName: "",
            schoolToken: "",
            schoolAddress: "",
            schoolPhone: "",

      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'app_logo',
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.school,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'School Management',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

