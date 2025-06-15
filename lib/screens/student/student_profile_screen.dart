import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../services/student_service.dart';

class StudentProfileScreen extends StatefulWidget {
  final User user;
  final String? studentId;

  const StudentProfileScreen({
    super.key, 
    required this.user,
    this.studentId,
  });

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late StudentService _studentService;
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _studentService = StudentService(baseUrl: 'http://localhost:3000');
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Use provided studentId or extract from user
      final String studentIdToFetch = widget.studentId ?? widget.user.id;
      
      final studentData = await _studentService.getStudentById(studentIdToFetch);
      
      setState(() {
        _studentData = studentData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStudentData,
          ),
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading student data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchStudentData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_studentData == null) {
      return const Center(
        child: Text('No student data available'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(context, _studentData!),
          const SizedBox(height: 20),
          _buildInfoSection(context, _studentData!),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> studentData) {
    final classData = studentData['classId'] as Map<String, dynamic>?;
    final studentName = studentData['name'] ?? 'Unknown Student';
    final studentId = studentData['studentId'] ?? 'N/A';
    final gradeSection = classData != null 
        ? 'Grade ${classData['grade']}-${classData['section']}'
        : 'No Class Assigned';

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
              backgroundImage: NetworkImage(widget.user.profile.profilePicture),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            studentName,
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
            child: Text(
              gradeSection,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'ID: $studentId',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, Map<String, dynamic> studentData) {
    final classData = studentData['classId'] as Map<String, dynamic>?;
    final academicReport = studentData['academicReport'] as Map<String, dynamic>?;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personal Details'),
          _buildInfoCard([
            _buildInfoRow('Student ID', studentData['studentId'] ?? 'N/A'),
            _buildInfoRow('Name', studentData['name'] ?? 'N/A'),
            _buildInfoRow('Email', studentData['email'] ?? 'N/A'),
            _buildInfoRow('Gender', studentData['gender'] ?? 'Not specified'),
            _buildInfoRow('Fee Status', studentData['feePaid'] == true ? 'Paid' : 'Pending'),
          ]),
          
          const SizedBox(height: 20),
          _buildSectionTitle('Academic Information'),
          _buildInfoCard([
            _buildInfoRow('Class', classData?['name'] ?? 'Not assigned'),
            _buildInfoRow('Grade', classData?['grade']?.toString() ?? 'N/A'),
            _buildInfoRow('Section', classData?['section'] ?? 'N/A'),
            _buildInfoRow('Academic Year', classData?['year']?.toString() ?? 'N/A'),
            _buildInfoRow('Attendance', '${academicReport?['attendancePct'] ?? 0}%'),
          ]),
          
          if (academicReport?['grades'] != null && (academicReport!['grades'] as List).isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSectionTitle('Academic Performance'),
            _buildInfoCard([
              for (var grade in academicReport['grades'] as List)
                _buildInfoRow(
                  grade['subject'] ?? 'Subject', 
                  '${grade['score'] ?? 'N/A'} (${grade['grade'] ?? 'N/A'})'
                ),
            ]),
          ],
          
          const SizedBox(height: 20),
          _buildSectionTitle('System Information'),
          _buildInfoCard([
            _buildInfoRow('Created', _formatDate(studentData['createdAt'])),
            _buildInfoRow('Last Updated', _formatDate(studentData['updatedAt'])),
            _buildInfoRow('School ID', studentData['schoolId'] ?? 'N/A'),
          ]),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
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
