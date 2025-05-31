import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';

class StudentProfileScreen extends StatelessWidget {
  final User user;

  const StudentProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    AppTheme.getAccentColor(AppTheme.defaultTheme);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, user),
            const SizedBox(height: 20),
            _buildInfoSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.getGradientColors(AppTheme.defaultTheme),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'profilePic',
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(user.profile.profilePicture),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '${user.profile.firstName} ${user.profile.lastName}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Grade 10-A',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'ID: STU20240001',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personal Details'),
          _buildInfoCard([
            _buildInfoRow('Date of Birth', '15 June 2008'),
            _buildInfoRow('Age', '16 years'),
            _buildInfoRow('Gender', 'Male'),
            _buildInfoRow('Blood Group', 'O+'),
            _buildInfoRow('Address', '123 Student Lane, Education City'),
          ]),
          
          const SizedBox(height: 20),
          _buildSectionTitle('Academic Information'),
          _buildInfoCard([
            _buildInfoRow('Class', '10th Grade'),
            _buildInfoRow('Section', 'A'),
            _buildInfoRow('Roll Number', '042'),
            _buildInfoRow('Admission Date', '5 April 2021'),
            _buildInfoRow('Academic Year', '2023-2024'),
          ]),
          
          const SizedBox(height: 20),
          _buildSectionTitle('Parent/Guardian Details'),
          _buildInfoCard([
            _buildInfoRow('Father\'s Name', 'Robert Smith'),
            _buildInfoRow('Father\'s Occupation', 'Software Engineer'),
            _buildInfoRow('Father\'s Contact', '+1 555-123-4567'),
            _buildInfoRow('Mother\'s Name', 'Emily Smith'),
            _buildInfoRow('Mother\'s Occupation', 'Doctor'),
            _buildInfoRow('Mother\'s Contact', '+1 555-765-4321'),
          ]),
          
          const SizedBox(height: 20),
          _buildSectionTitle('Contact Information'),
          _buildInfoCard([
            _buildInfoRow('Email', user.email),
            _buildInfoRow('Phone', '+1 555-987-6543'),
            _buildInfoRow('Emergency Contact', '+1 555-123-4567'),
          ]),
          
          const SizedBox(height: 20),
          _buildSectionTitle('Health Information'),
          _buildInfoCard([
            _buildInfoRow('Medical Conditions', 'None'),
            _buildInfoRow('Allergies', 'Peanuts'),
            _buildInfoRow('Medications', 'None'),
          ]),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.getAccentColor(AppTheme.defaultTheme),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
