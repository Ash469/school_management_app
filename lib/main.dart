import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/parent_dashboard.dart';
import 'screens/school_admin_dashboard.dart';
// Import other necessary screens
import 'screens/role_selection_screen.dart';
import 'models/user_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SchoolApp());
}

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const RoleSelectionScreen(),
        '/admin_dashboard': (context) => SchoolAdminDashboard(
              user: ModalRoute.of(context)!.settings.arguments as User,
            ),
        '/teacher_dashboard': (context) => TeacherDashboard(
              user: ModalRoute.of(context)!.settings.arguments as User,
            ),
        '/student_dashboard': (context) => StudentDashboard(
              user: ModalRoute.of(context)!.settings.arguments as User,
            ),
        '/parent_dashboard': (context) => ParentDashboard(
              user: ModalRoute.of(context)!.settings.arguments as User,
            ),
      },
      onGenerateRoute: (settings) {
        // Default route for any undefined routes
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(child: Text('The requested page does not exist.')),
          ),
        );
      },
    );
  }
}
