import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/school_model.dart';
import '../services/api_service.dart';
import '../screens/login_screen.dart';
import '../utils/app_theme.dart';
import 'school_admin/class_management_screen.dart';
import 'school_admin/teacher_management_screen.dart';
import 'school_admin/student_management_screen.dart';
import 'school_admin/academic_calender_screen.dart';
import 'school_admin/event_management_screen.dart';
import 'school_admin/fee_collection_screen.dart';
import 'school_admin/schedule_management_screen.dart';
import 'school_admin/notifiaction_management_screen.dart';
import 'school_admin/analytic_dashboard.dart';

class SchoolAdminDashboard extends StatefulWidget {
  final User user;

  const SchoolAdminDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _SchoolAdminDashboardState createState() => _SchoolAdminDashboardState();
}

class _SchoolAdminDashboardState extends State<SchoolAdminDashboard> {
  late ApiService _apiService;
  bool _isLoading = true;
  School? _school;
  List<Map<String, dynamic>> _stats = [];
  int _currentIndex = 0;

  // Theme colors from app_theme.dart
  late Color _primaryColor;
  late Color _accentColor;
  late Color _tertiaryColor;
  late List<Color> _gradientColors;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(baseUrl: 'https://api.schoolmanagement.com');
    _loadThemeColors();
    _loadDashboardData();
  }

  void _loadThemeColors() {
    _primaryColor = AppTheme.getPrimaryColor(AppTheme.defaultTheme);
    _accentColor = AppTheme.getAccentColor(AppTheme.defaultTheme);
    _tertiaryColor = AppTheme.getTertiaryColor(AppTheme.defaultTheme);
    _gradientColors = AppTheme.getGradientColors(AppTheme.defaultTheme);
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final schools = await _apiService.getSchools();
      if (schools.isNotEmpty) {
        _school = School.fromJson(schools[0]);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading dashboard data: $e');
    } finally {
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
              Text(
                'School Admin',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 18 : 20),
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
              onPressed: _navigateToNotifications,
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
                    onTap: _navigateToProfile,
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
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.user.profile.firstName[0],
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.dashboard, color: _accentColor),
                title: const Text('Dashboard'),
                selected: _currentIndex == 0,
                selectedTileColor: _accentColor.withOpacity(0.1),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentIndex = 0;
                  });
                },
              ),
              const Divider(),
              _buildCategoryHeader('ACADEMICS'),
              _buildDrawerTile(
                  Icons.class_, 'Class Management', _navigateToClassManagement),
              _buildDrawerTile(Icons.schedule, 'Schedule Management',
                  _navigateToScheduleManagement),
              _buildDrawerTile(Icons.calendar_today, 'Academic Calendar',
                  _navigateToAcademicCalendar),
              _buildDrawerTile(Icons.analytics, 'Analytics Dashboard',
                  _navigateToAnalyticsDashboard),
              const Divider(),
              _buildCategoryHeader('PEOPLE'),
              _buildDrawerTile(Icons.people, 'Students', _navigateToStudents),
              _buildDrawerTile(Icons.person, 'Teachers', _navigateToTeachers),
              _buildDrawerTile(
                  Icons.family_restroom, 'Parents', _navigateToParents),
              const Divider(),
              _buildCategoryHeader('FINANCE'),
              _buildDrawerTile(
                  Icons.payment, 'Fee Collection', _navigateToFeeManagement),
              const Divider(),
              _buildCategoryHeader('COMMUNICATION'),
              _buildDrawerTile(
                  Icons.message, 'Messaging', _navigateToMessaging),
              _buildDrawerTile(Icons.announcement, 'Notifications',
                  _navigateToNotifications),
              _buildDrawerTile(Icons.event, 'Events', _navigateToEvents),
              const Divider(),
              _buildDrawerTile(Icons.exit_to_app, 'Logout', () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }),
            ],
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: _accentColor))
            : RefreshIndicator(
                color: _accentColor,
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_school != null) _buildSchoolInfoCard(),
                      const SizedBox(height: 16),
                      _buildStatsGrid(),
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      _buildSectionHeader('Administrative Tools'),
                      const SizedBox(height: 16),
                      _buildAdminToolsGrid(),
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      _buildSectionHeader('Recent Activities'),
                      const SizedBox(height: 16),
                      _buildActivitiesCard(),
                      const SizedBox(
                          height:
                              24), // Add bottom padding for better scrolling
                    ],
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: _accentColor,
          child: const Icon(Icons.add),
          onPressed: _showQuickActions,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'People'),
            BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Classes'),
            BottomNavigationBarItem(
                icon: Icon(Icons.message), label: 'Messages'),
            BottomNavigationBarItem(
                icon: Icon(Icons.analytics), label: 'Analytics'),
          ],
          onTap: _handleBottomNavTap,
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
            color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildDrawerTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _buildStatsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.64,
      ),
      itemCount: _stats.length,
      itemBuilder: (context, index) {
        final stat = _stats[index];
        final Color statColor = stat['color'] as Color;

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              switch (stat['title']) {
                case 'Students':
                  _navigateToStudents();
                  break;
                case 'Teachers':
                  _navigateToTeachers();
                  break;
                case 'Classes':
                  _navigateToClassManagement();
                  break;
                case 'Fees Due':
                  _navigateToFeeManagement();
                  break;
              }
            },
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(stat['icon'] as IconData,
                      size: 70, color: statColor.withOpacity(0.15)),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0), // Reduced from 14.0
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(stat['icon'] as IconData,
                          size: 24, color: statColor), // Reduced from 26
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${stat['count']}${stat['suffix'] ?? ''}',
                              style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: statColor), // Reduced from 20
                            ),
                          ),
                          const SizedBox(height: 2), // Reduced from 3
                          Text(
                            stat['title'] as String,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500), // Reduced from 13
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminToolsGrid() {
    final adminTools = [
      {
        'icon': Icons.class_,
        'label': 'Class',
        'color': Colors.green,
        'onTap': _navigateToClassManagement,
      },
      {
        'icon': Icons.person,
        'label': 'Teacher',
        'color': Colors.blue,
        'onTap': _navigateToTeachers,
      },
      {
        'icon': Icons.people,
        'label': 'Student',
        'color': _accentColor,
        'onTap': _navigateToStudents,
      },
      {
        'icon': Icons.schedule,
        'label': 'Schedule',
        'color': Colors.orange,
        'onTap': _navigateToScheduleManagement,
      },
      {
        'icon': Icons.calendar_month,
        'label': 'Calendar',
        'color': Colors.indigo,
        'onTap': _navigateToAcademicCalendar,
      },
      {
        'icon': Icons.notifications_active,
        'label': 'Notifications',
        'color': _tertiaryColor,
        'onTap': _navigateToNotifications,
      },
      {
        'icon': Icons.event,
        'label': 'Event',
        'color': Colors.purple,
        'onTap': _navigateToEvents,
      },
      {
        'icon': Icons.payment,
        'label': 'Fee',
        'color': Colors.teal,
        'onTap': _navigateToFeeManagement,
      },
      // {
      //   'icon': Icons.analytics,
      //   'label': 'Dashboard',
      //   'color': Colors.blue,
      //   'onTap': _navigateToAnalyticsDashboard,
      // },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio:
            1.2, // Adjusted back since we don't need space for description
      ),
      itemCount: adminTools.length,
      itemBuilder: (context, index) {
        final tool = adminTools[index];
        return _buildModernAdminTool(
          icon: tool['icon'] as IconData,
          label: tool['label'] as String,
          color: tool['color'] as Color,
          onTap: tool['onTap'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildModernAdminTool({
    required IconData icon,
    required String label,
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 10,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivitiesCard() {
    final activities = [
      {
        'title': 'New student enrolled',
        'description': 'John Doe added to Class 10A',
        'time': '2h ago',
        'icon': Icons.person_add,
        'color': _accentColor,
      },
      {
        'title': 'Fee payment received',
        'description': 'Sarah paid \$500 for Term 1',
        'time': '3h ago',
        'icon': Icons.payment,
        'color': Colors.blue,
      },
      {
        'title': 'New timetable created',
        'description': 'Class 9B schedule updated',
        'time': '5h ago',
        'icon': Icons.schedule,
        'color': Colors.orange,
      },
      {
        'title': 'Notification sent',
        'description': 'School closure notice sent to all',
        'time': '6h ago',
        'icon': Icons.notifications,
        'color': _tertiaryColor,
      },
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: (activity['color'] as Color).withOpacity(0.2),
              child: Icon(activity['icon'] as IconData,
                  color: activity['color'] as Color, size: 18),
            ),
            title: Text(
              activity['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              activity['description'] as String,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              activity['time'] as String,
              style: const TextStyle(color: Colors.black54, fontSize: 11),
            ),
            onTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildSchoolInfoCard() {
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
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                image: DecorationImage(
                    image: NetworkImage(_school!.logo), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _school!.name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Academic Year: ${_school!.settings.academicYear.start.year}-${_school!.settings.academicYear.end.year}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
              margin: const EdgeInsets.only(bottom: 16),
            ),
            _buildQuickActionTile(
              icon: Icons.person_add,
              color: _accentColor,
              title: 'Add Student',
              onTap: _navigateToAddStudent,
            ),
            _buildQuickActionTile(
              icon: Icons.class_,
              color: _primaryColor,
              title: 'Create Class',
              onTap: _navigateToCreateClass,
            ),
            _buildQuickActionTile(
              icon: Icons.schedule,
              color: Colors.orange,
              title: 'Add Timetable',
              onTap: _navigateToScheduleManagement,
            ),
            _buildQuickActionTile(
              icon: Icons.payment,
              color: _tertiaryColor,
              title: 'Manage Fees',
              onTap: _navigateToFeeManagement,
            ),
            _buildQuickActionTile(
              icon: Icons.notifications,
              color: _tertiaryColor,
              title: 'Send Notification',
              onTap: _navigateToSendNotification,
            ),
            _buildQuickActionTile(
              icon: Icons.event,
              color: Colors.purple,
              title: 'Add Event',
              onTap: _navigateToAddEvent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withOpacity(0.2), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0: // Dashboard
        break;
      case 1:
        _showPeopleOptions();
        break;
      case 2:
        _navigateToClassManagement();
        break;
      case 3:
        _navigateToMessaging();
        break;
      case 4:
        _navigateToAnalyticsDashboard();
        break;
    }
  }

  void _showPeopleOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
            margin: const EdgeInsets.symmetric(vertical: 16),
          ),
          _buildQuickActionTile(
            icon: Icons.person,
            color: _primaryColor,
            title: 'Teachers',
            onTap: _navigateToTeachers,
          ),
          _buildQuickActionTile(
            icon: Icons.people,
            color: _accentColor,
            title: 'Students',
            onTap: _navigateToStudents,
          ),
          _buildQuickActionTile(
            icon: Icons.family_restroom,
            color: Colors.amber,
            title: 'Parents',
            onTap: _navigateToParents,
          ),
        ],
      ),
    );
  }

  // Navigation methods aligned with LaTeX features
  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const NotificationManagementScreen()),
    );
  }

  void _navigateToProfile() {
    _launchFeature('Profile', 'View and edit admin profile');
  }

  void _navigateToClassManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ClassManagementScreen(user: widget.user)),
    );
  }

  void _navigateToTeachers() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TeacherManagementScreen(user: widget.user)),
    );
  }

  void _navigateToStudents() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudentManagementScreen()),
    );
  }

  void _navigateToScheduleManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScheduleManagementScreen()),
    );
  }

  void _navigateToAcademicCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AcademicCalenderScreen()),
    );
  }

  void _navigateToAnalyticsDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalyticsDashboard()),
    );
  }

  void _navigateToFeeManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FeeCollectionScreen()),
    );
  }

  void _navigateToEvents() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EventManagementScreen()),
    );
  }

  void _navigateToAddEvent() {
    // Navigate to EventManagementScreen with parameter to indicate adding new event
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EventManagementScreen()),
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use the + button to add a new event')),
      );
    });
  }

  void _navigateToParents() {
    _launchFeature(
        'Parent Management', 'Manage parent information and communication');
  }

  void _navigateToMessaging() {
    _launchFeature(
        'Messaging', 'Send messages to teachers, students, or parents');
  }

  void _navigateToAddStudent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudentManagementScreen()),
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use the + button to add a new student')),
      );
    });
  }

  void _navigateToCreateClass() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ClassManagementScreen(user: widget.user)),
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use the + button to create a new class')),
      );
    });
  }

  void _navigateToSendNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const NotificationManagementScreen()),
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Use the options to send a new notification')),
      );
    });
  }

  // Keep this method for any features still in development
  void _launchFeature(String title, String description) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Coming Soon'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
