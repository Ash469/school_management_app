import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/school_selection_screen.dart';
import 'utils/storage_util.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure app to keep running when permissions dialogs appear
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, 
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  
  try {
    // Initialize StorageUtil and show status
    final storageInitialized = await StorageUtil.init();
    
    // Force a write to verify storage is working
    await StorageUtil.setString('app_initialized', DateTime.now().toString());
    final verifyValue = await StorageUtil.getString('app_initialized');
    print('🔍 Verification write/read test: ${verifyValue != null ? "SUCCESS" : "FAILED"}');
    
    // Dump all stored values for debugging
    await StorageUtil.debugDumpAll();
  } catch (e) {
    print('⚠️ Error during initialization: $e');
    // Continue with app launch even if initialization fails
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Management App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SchoolSelectionScreen(),
    );
  }
}
