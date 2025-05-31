import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';
import 'teachers/teacher_classes_screen.dart';
import 'teachers/teacher_assignments_screen.dart';
import 'teachers/teacher_attendance_screen.dart';
import 'teachers/teacher_grading_screen.dart';
import 'teachers/teacher_notifications_screen.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart'; // Add this import for the LoginScreen

class TeacherDashboard extends StatefulWidget {
  final User user;

  const TeacherDashboard({super.key, required this.user});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  late Color _primaryColor;
  late Color _accentColor;
  late Color _tertiaryColor;
  late List<Color> _gradientColors;
  bool _isLoading = true;
  List<Class> _todaysClasses = [];

  @override
  void initState() {
    super.initState();
    _loadThemeColors();
    _loadTodaysClasses();
  }

  void _loadThemeColors() {
    _primaryColor = AppTheme.getPrimaryColor(AppTheme.defaultTheme);
    _accentColor = AppTheme.getAccentColor(AppTheme.defaultTheme);
    _tertiaryColor = AppTheme.getTertiaryColor(AppTheme.defaultTheme);
    _gradientColors = AppTheme.getGradientColors(AppTheme.defaultTheme);
  }

  Future<void> _loadTodaysClasses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock data - in a real app, this would come from an API
      final weekday = DateFormat('EEEE').format(DateTime.now());
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      final mockClasses = [
        Class(
          id: '1',
          name: 'Mathematics',
          grade: '10',
          section: 'A',
          subject: 'Math',
          startTime: '09:00 AM',
          endTime: '10:00 AM',
          roomNumber: '101',
          weekday: weekday,
        ),
        Class(
          id: '2',
          name: 'Science',
          grade: '10',
          section: 'B',
          subject: 'Physics',
          startTime: '11:00 AM',
          endTime: '12:00 PM',
          roomNumber: '102',
          weekday: weekday,
        ),
        Class(
          id: '3',
          name: 'English',
          grade: '9',
          section: 'C',
          subject: 'Literature',
          startTime: '01:00 PM',
          endTime: '02:00 PM',
          roomNumber: '103',
          weekday: weekday,
        ),
      ];

      setState(() {
        _todaysClasses = mockClasses;
        _isLoading = false;
      });
    } catch (e) {
      // Handle errors
      print('Error loading classes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360 || screenSize.height < 700;

    return Theme(
      data: AppTheme.getTheme(AppTheme.defaultTheme),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.school,
                  color: Colors.white, size: isSmallScreen ? 22 : 28),
              SizedBox(width: isSmallScreen ? 8 : 12),
              const Text(
                'Teacher',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, size: 28),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: _tertiaryColor,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: const Text(
                        '3',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherNotificationsScreen(user: widget.user),
                  ),
                );
              },
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Material(
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Show profile
                    },
                    child: Text(
                      widget.user.profile.firstName[0],
                      style: TextStyle(
                          color: _primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: Text(
                  '${widget.user.profile.firstName} ${widget.user.profile.lastName}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
                accountEmail: Text(
                  widget.user.email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(widget.user.profile.profilePicture),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.dashboard, color: _accentColor),
                ),
                title: const Text('Dashboard'),
                selected: true,
                selectedTileColor: _accentColor.withOpacity(0.1),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'TEACHING',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.class_, color: Colors.blue),
                ),
                title: const Text('My Classes'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => TeacherClassesScreen(user: widget.user))
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.assignment, color: Colors.green),
                ),
                title: const Text('Assignments'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => TeacherAssignmentsScreen(user: widget.user))
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.red),
                ),
                title: const Text('Attendance'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => TeacherAttendanceScreen(user: widget.user))
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.trending_up, color: Colors.orange),
                ),
                title: const Text('Grading'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => TeacherGradingScreen(user: widget.user))
                  );
                },
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'COMMUNICATION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.announcement, color: Colors.purple),
                ),
                title: const Text('Announcements'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/announcements');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.message, color: Colors.indigo),
                ),
                title: const Text('Messaging'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/messaging');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: Colors.teal),
                ),
                title: const Text('Notifications'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _tertiaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeacherNotificationsScreen(user: widget.user),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'OTHER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout, color: Colors.red),
                ),
                title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  // Show confirmation dialog before logout
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Navigate to login screen after logout
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text('Logout', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          color: _accentColor,
          onRefresh: _loadTodaysClasses,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingCard(),
                const SizedBox(height: 16),
                _buildSectionHeader('Today\'s Classes'),
                const SizedBox(height: 12),
                _buildTodayClassesList(),
                const SizedBox(height: 24),
                _buildSectionHeader('Quick Actions'),
                const SizedBox(height: 12),
                _buildQuickActionsGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: _gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(widget.user.profile.profilePicture),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70),
                  ),
                  Text(
                    widget.user.profile.firstName,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayClassesList() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: _accentColor),
        ),
      );
    }

    if (_todaysClasses.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No classes scheduled for today',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _todaysClasses.length,
      itemBuilder: (context, index) {
        final classItem = _todaysClasses[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.class_, color: _accentColor),
            ),
            title: Text(
              classItem.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grade ${classItem.grade}-${classItem.section}',
                  style: TextStyle(color: Colors.black87),
                ),
                Text(
                  'Room ${classItem.roomNumber} • ${classItem.startTime} - ${classItem.endTime}',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward_ios, size: 16, color: _primaryColor),
              onPressed: () {
                // Navigate to class details
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildDashboardCard(
          context: context,
          title: 'My Classes',
          icon: Icons.class_,
          color: Colors.blue,
          onTap: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => TeacherClassesScreen(user: widget.user))
          ),
        ),
        _buildDashboardCard(
          context: context,
          title: 'Assignments',
          icon: Icons.assignment,
          color: Colors.green,
          onTap: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => TeacherAssignmentsScreen(user: widget.user))
          ),
        ),
        _buildDashboardCard(
          context: context,
          title: 'Attendance',
          icon: Icons.check_circle,
          color: Colors.red,
          onTap: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => TeacherAttendanceScreen(user: widget.user))
          ),
        ),
        _buildDashboardCard(
          context: context,
          title: 'Grading',
          icon: Icons.trending_up,
          color: Colors.orange,
          onTap: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => TeacherGradingScreen(user: widget.user))
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
              color: _accentColor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shadowColor: color.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.1), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Class {
  final String id;
  final String name;
  final String grade;
  final String section;
  final String subject;
  final String startTime;
  final String endTime;
  final String roomNumber;
  final String weekday;

  Class({
    required this.id,
    required this.name,
    required this.grade,
    required this.section,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
    required this.weekday,
  });
}
