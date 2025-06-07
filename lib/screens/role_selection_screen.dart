import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../utils/storage_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'school_selection_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  final String schoolName;
  final String schoolToken;
  final String schoolAddress;
  final String schoolPhone;
  
  const RoleSelectionScreen({
    Key? key, 
    required this.schoolName,
    required this.schoolToken,
    required this.schoolAddress,
    required this.schoolPhone,
  }) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    // Clear only school-related data, not user data
    print("Clearing school selection...");
    
    try {
      // Use StorageUtil to clear only school-related data
      await StorageUtil.setString('schoolToken', '');
      await StorageUtil.setString('schoolName', '');
      await StorageUtil.setString('schoolId', '');
      await StorageUtil.setString('schoolAddress', '');
      await StorageUtil.setString('schoolPhone', '');
      
      // Set login status to false (user not logged in)
      await StorageUtil.setBool('isLoggedIn', false);
      
      // Verify data was cleared
      print("School selection cleared, returning to school selection screen");
      
      // Navigate back to school selection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SchoolSelectionScreen()),
      );
    } catch (e) {
      print("Error during school logout: $e");
      // Still try to navigate even if there was an error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SchoolSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Print school info when the screen builds
    print("🏫 CURRENT SCHOOL INFO IN ROLE SELECTION:");
    print("🏫 School Name: $schoolName");
    print("🏫 School Token: $schoolToken");
    print("🏫 School Token: $schoolAddress");
    print("🏫 School Token: $schoolPhone");
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _logout(context),
          tooltip: 'Back to School Selection',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Change School',
          ),
        ],
      ),
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
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 70,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    schoolName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select your role to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildRoleButton(
                    context: context,
                    role: 'school_admin',
                    label: 'School Admin',
                    icon: Icons.admin_panel_settings,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildRoleButton(
                    context: context,
                    role: 'teacher',
                    label: 'Teacher',
                    icon: Icons.school,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _buildRoleButton(
                    context: context,
                    role: 'student',
                    label: 'Student',
                    icon: Icons.person,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _buildRoleButton(
                    context: context,
                    role: 'parent',
                    label: 'Parent',
                    icon: Icons.family_restroom,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required String role,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: () async {
        // Store selected role in local storage
        await StorageUtil.setString('selectedRole', role);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(
              selectedRole: role,
              schoolToken: schoolToken,
              schoolName: schoolName,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
