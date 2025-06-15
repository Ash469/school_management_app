import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../school_selection_screen.dart'; // Add this import

class SchoolAdminProfileScreen extends StatefulWidget {
  const SchoolAdminProfileScreen({Key? key}) : super(key: key);

  @override
  State<SchoolAdminProfileScreen> createState() => _SchoolAdminProfileScreenState();
}

class _SchoolAdminProfileScreenState extends State<SchoolAdminProfileScreen> {
  String? userEmail;
  String? userRole;
  String? userFirstName;
  String? userLastName;
  String? userPhone;
  String? userAddress;
  String? schoolToken;
  String? schoolName;
  String? schoolId;
  String? schoolAddress;
  String? schoolPhone;
  String? schoolSecretKey;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail') ?? 'admin1@example.com';
      userRole = prefs.getString('userRole') ?? 'school_admin';
      userFirstName = prefs.getString('userFirstName') ?? 'Admin';
      userLastName = prefs.getString('userLastName') ?? 'User';
      userPhone = prefs.getString('userPhone') ?? '123-456-7890';
      userAddress = prefs.getString('userAddress') ?? '123 School St';
      schoolToken = prefs.getString('schoolToken') ?? '68497a3ee035c9ad4a19a37b';
      schoolName = prefs.getString('schoolName') ?? 'Springfield High School';
      schoolId = prefs.getString('schoolId') ?? '68497a3ee035c9ad4a19a37b';
      schoolAddress = prefs.getString('schoolAddress') ?? '123 Elm Street, Springfield';
      schoolPhone = prefs.getString('schoolPhone') ?? '555-123-4567';
      schoolSecretKey = prefs.getString('schoolSecretKey') ?? 'qwerty';
      userId = prefs.getString('userId') ?? '684991cec1f5eaeb0d9b1d67';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit profile screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[600],
                    child: Text(
                      '${userFirstName?[0] ?? 'A'}${userLastName?[0] ?? 'U'}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${userFirstName ?? 'Admin'} ${userLastName ?? 'User'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      userRole?.replaceAll('_', ' ').toUpperCase() ?? 'SCHOOL ADMIN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Personal Information
            _buildSectionCard(
              title: 'Personal Information',
              icon: Icons.person,
              children: [
                _buildInfoRow('Email', userEmail ?? '', Icons.email),
                _buildInfoRow('Phone', userPhone ?? '', Icons.phone),
                _buildInfoRow('Address', userAddress ?? '', Icons.location_on),
                _buildInfoRow('User ID', userId ?? '', Icons.badge),
              ],
            ),

            const SizedBox(height: 16),

            // School Information
            _buildSectionCard(
              title: 'School Information',
              icon: Icons.school,
              children: [
                _buildInfoRow('School Name', schoolName ?? '', Icons.business),
                _buildInfoRow('School Address', schoolAddress ?? '', Icons.location_city),
                _buildInfoRow('School Phone', schoolPhone ?? '', Icons.phone_in_talk),
                _buildInfoRow('School ID', schoolId ?? '', Icons.badge_outlined),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to edit profile
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await _showLogoutDialog();
                      if (confirmed) {
                        await _logout();
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[600],
                      side: BorderSide(color: Colors.red[600]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[600], size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showLogoutDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear all stored data
      await prefs.clear();
      
      if (mounted) {
        // Navigate to school selection screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const SchoolSelectionScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
