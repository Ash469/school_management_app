import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/storage_util.dart';
import '../utils/app_theme.dart';
import 'role_selection_screen.dart';
import '../widgets/debug_storage_viewer.dart';

class SchoolSelectionScreen extends StatefulWidget {
  const SchoolSelectionScreen({Key? key}) : super(key: key);

  @override
  _SchoolSelectionScreenState createState() => _SchoolSelectionScreenState();
}

class _SchoolSelectionScreenState extends State<SchoolSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _schoolIdController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _schools = [];
  String _currentTheme = AppTheme.defaultTheme;
  
  @override
  void initState() {
    super.initState();
    _loadSchools();
    _checkSharedPreferencesStatus(showErrorDialog: false); // Don't show error dialog on startup
    _checkForExistingSchool();
    _loadTheme();
  }

  // Modified method to debug SharedPreferences with optional dialog display
  Future<void> _checkSharedPreferencesStatus({bool showErrorDialog = false}) async {
    try {
      // Test if SharedPreferences is working
      final prefs = await SharedPreferences.getInstance();
      final testKey = 'shared_prefs_test_key';
      final testValue = 'test_value_${DateTime.now().millisecondsSinceEpoch}';
      
      // Try to write a value
      await prefs.setString(testKey, testValue);
      
      // Try to read it back
      final readValue = prefs.getString(testKey);
      
      print('🔍 SharedPreferences Test:');
      print('🔍 Write value: $testValue');
      print('🔍 Read value: $readValue');
      print('🔍 SharedPreferences working: ${testValue == readValue}');
      
      if (testValue != readValue && showErrorDialog) {
        print('⚠️ WARNING: SharedPreferences write/read test failed!');
        _showSharedPreferencesErrorDialog();
      }
      
      // Check path and storage details
      print('🔍 SharedPreferences directory info:');
      print('🔍 App directory: ${await _getAppDirectory()}');
    } catch (e) {
      print('⚠️ ERROR accessing SharedPreferences: $e');
      if (showErrorDialog) _showSharedPreferencesErrorDialog();
    }
  }
  
  // Helper to get app directory for debugging
  Future<String> _getAppDirectory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // This is just a trick to get some path info
      final keys = prefs.getKeys();
      return 'Available keys: ${keys.join(', ')}';
    } catch (e) {
      return 'Unable to get directory info: $e';
    }
  }
  
  // Show an error dialog if SharedPreferences fails
  void _showSharedPreferencesErrorDialog() {
    if (!mounted) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Storage Error'),
            content: const Text(
              'There seems to be an issue with app storage. Your data may not be saved between sessions. '
              'This could be due to limited storage permissions or device storage issues.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> _loadTheme() async {
    final theme = await StorageUtil.getString('appTheme') ?? AppTheme.defaultTheme;
    setState(() {
      _currentTheme = theme;
    });
  }

  @override
  void dispose() {
    _schoolIdController.dispose();
    super.dispose();
  }

  // Check if a school token already exists and navigate if it does
  Future<void> _checkForExistingSchool() async {
    try {
      final String? schoolToken = await StorageUtil.getString('schoolToken');
      final String? schoolName = await StorageUtil.getString('schoolName');
      
      if (schoolToken != null && schoolName != null) {
        print("Found existing school: $schoolName");
        // Auto-navigate to the role selection screen if school token exists
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RoleSelectionScreen(
                schoolName: schoolName,
                schoolToken: schoolToken,
              ),
            ),
          );
        }
      } else {
        print("No existing school found");
      }
    } catch (e) {
      print("Error checking for existing school: $e");
      // Continue showing the school selection screen
    }
  }

  // Load sample schools for demonstration
  void _loadSchools() {
    // In a real app, you would fetch this from an API
    setState(() {
      _schools = [
        {'id': 'SCH001', 'name': 'Springfield Elementary School', 'token': 'token_sch001'},
        {'id': 'SCH002', 'name': 'Westfield High School', 'token': 'token_sch002'},
        {'id': 'SCH003', 'name': 'Northside Academy', 'token': 'token_sch003'},
        {'id': 'SCH004', 'name': 'Eastwood Junior College', 'token': 'token_sch004'},
        {'id': 'SCH005', 'name': 'Central Public School', 'token': 'token_sch005'},
      ];
    });
  }

  Future<void> _verifyAndStoreSchool(String schoolId) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));

    print("Entered school ID: '$schoolId'");
    
    // Find matching school
    final schoolMatch = _schools.firstWhere(
      (school) => school['id'].toString().trim() == schoolId.trim(),
      orElse: () => {}, // Empty map if not found
    );

    print("Match found: ${schoolMatch.isNotEmpty}");

    // Check if we found a match
    if (schoolMatch.isNotEmpty) {
      print("📝 SELECTED SCHOOL INFO:");
      print("📝 School ID: ${schoolMatch['id']}");
      print("📝 School Name: ${schoolMatch['name']}");
      print("📝 School Token: ${schoolMatch['token']}");

      // Use our storage utility to store the data
      await StorageUtil.setString('schoolToken', schoolMatch['token']);
      await StorageUtil.setString('schoolName', schoolMatch['name']);
      await StorageUtil.setString('schoolId', schoolMatch['id']);
      
      // Verify stored data
      print("✓ VERIFYING STORED DATA:");
      final storedToken = await StorageUtil.getString('schoolToken');
      final storedName = await StorageUtil.getString('schoolName');
      final storedId = await StorageUtil.getString('schoolId');
      print("✓ Stored School ID: $storedId");
      print("✓ Stored School Name: $storedName");
      print("✓ Stored School Token: $storedToken");
      
      if (mounted) {
        print("Navigating to role selection screen");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RoleSelectionScreen(
              schoolName: schoolMatch['name'],
              schoolToken: schoolMatch['token'],
            ),
          ),
        );
      }
    } else {
      // If exact match not found, try partial match
      final partialMatches = _schools.where(
        (school) => school['id'].toString().toLowerCase().contains(schoolId.trim().toLowerCase())
      ).toList();
      
      if (partialMatches.isNotEmpty) {
        // Use the first partial match
        final match = partialMatches.first;
        
        // Store the data using our utility
        await StorageUtil.setString('schoolToken', match['token']);
        await StorageUtil.setString('schoolName', match['name']);
        await StorageUtil.setString('schoolId', match['id']);

        if (mounted) {
          print("Navigating to role selection screen with partial match");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RoleSelectionScreen(
                schoolName: match['name'],
                schoolToken: match['token'],
              ),
            ),
          );
        }
      } else if (mounted) {
        print("No match found - showing error");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid school ID. Please try again.'),
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
    // Get colors from theme
    final primaryColor = AppTheme.getPrimaryColor(_currentTheme);
    final accentColor = AppTheme.getAccentColor(_currentTheme);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade200,
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
                  // Logo with enhanced shadow and glow
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.school,
                        size: 70,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Title with enhanced styling
                  Text(
                    'Welcome to School Management',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subtitle with better contrast
                  Text(
                    'Please select your school to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color(0xFF505050),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Enhanced form card with better styling
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: primaryColor.withOpacity(0.4),
                    // Explicitly set the card color to white
                    color: Colors.white, 
                    surfaceTintColor: Colors.white, // Important for Material 3
                    clipBehavior: Clip.antiAlias, // Ensures content doesn't bleed outside rounded corners
                    child: Container(
                      // Add a container with explicit background decoration
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Enhanced input field
                              TextFormField(
                                controller: _schoolIdController,
                                decoration: InputDecoration(
                                  labelText: 'School ID',
                                  labelStyle: TextStyle(color: primaryColor),
                                  hintText: 'Enter your school ID (e.g., SCH001)',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: accentColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  prefixIcon: Icon(Icons.business, color: primaryColor),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF424242),
                                  fontWeight: FontWeight.w500,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your school ID';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              // Enhanced button
                              ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          _verifyAndStoreSchool(_schoolIdController.text);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 54),
                                  elevation: 4,
                                  shadowColor: primaryColor.withOpacity(0.5),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.0,
                                        ),
                                      )
                                    : const Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Enhanced demo section label
                  Text(
                    'Demo School IDs:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF424242),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Enhanced school cards with better styling
                  ...List.generate(_schools.length, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () => _schoolIdController.text = _schools[index]['id'],
                      borderRadius: BorderRadius.circular(12),
                      splashColor: primaryColor.withOpacity(0.1),
                      highlightColor: primaryColor.withOpacity(0.05),
                      child: Card(
                        color: Colors.white, // Explicitly set color
                        surfaceTintColor: Colors.white, // Important for Material 3
                        elevation: 3,
                        shadowColor: accentColor.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: accentColor.withOpacity(0.2)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: primaryColor.withOpacity(0.1),
                                child: Icon(
                                  Icons.school_outlined,
                                  color: accentColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_schools[index]['name']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF424242),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID: ${_schools[index]['id']}',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
      // Add debug button to test storage
      floatingActionButton: FloatingActionButton(
        onPressed: () => _debugSharedPreferences(),
        backgroundColor: primaryColor,
        child: const Icon(Icons.bug_report),
        tooltip: 'Debug Storage',
      ),
    );
  }
  
  // Debug method to check SharedPreferences
  Future<void> _debugSharedPreferences() async {
    try {
      // Display current SharedPreferences data
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('SharedPreferences Debug'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total keys: ${keys.length}'),
                const Divider(),
                ...keys.map((key) {
                  final value = prefs.get(key);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text('$key: $value', 
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  );
                }).toList(),
                const Divider(),
                const Text('Test write/read:'),
                ElevatedButton(
                  onPressed: () async {
                    await _checkSharedPreferencesStatus(showErrorDialog: true); // Show dialog if test fails
                    if (mounted) Navigator.pop(context);
                    _debugSharedPreferences();
                  },
                  child: const Text('Test SharedPreferences'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing SharedPreferences: $e')),
      );
    }
  }
}













