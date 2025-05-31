import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart';
import '../utils/app_theme.dart'; 
import 'student/schedule_screen.dart';
import 'student/grades_screen.dart';
import 'student/forms_screen.dart';
import 'student/resource_library_screen.dart';
import 'student/student_profile_screen.dart'; // Add this import for Student Profile

class StudentDashboard extends StatefulWidget {
  final User user;

  const StudentDashboard({super.key, required this.user});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = true;
  int _notificationCount = 3; // Example notification count
  List<Map<String, dynamic>> _upcomingAssignments = [];
  List<Map<String, dynamic>> _todaysClasses = [];
  
  // Add color variables to match teacher dashboard
  late Color _primaryColor;
  late Color _accentColor;
  late Color _tertiaryColor;
  late List<Color> _gradientColors;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // Load theme colors like in teacher dashboard
    _loadThemeColors();
    
    // Simulate loading data
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadUpcomingAssignments();
          _loadTodaysClasses();
        });
        _animationController.forward();
      }
    });
  }
  
  void _loadThemeColors() {
    _primaryColor = AppTheme.getPrimaryColor(AppTheme.defaultTheme);
    _accentColor = AppTheme.getAccentColor(AppTheme.defaultTheme);
    _tertiaryColor = AppTheme.getTertiaryColor(AppTheme.defaultTheme);
    _gradientColors = AppTheme.getGradientColors(AppTheme.defaultTheme);
  }
  
  void _loadUpcomingAssignments() {
    _upcomingAssignments = [
      {
        'title': 'Math Assignment',
        'subject': 'Mathematics',
        'dueDate': DateTime.now().add(const Duration(days: 2)),
        'status': 'Pending'
      },
      {
        'title': 'Physics Lab Report',
        'subject': 'Science',
        'dueDate': DateTime.now().add(const Duration(days: 3)),
        'status': 'Pending'
      },
      {
        'title': 'Essay Submission',
        'subject': 'English',
        'dueDate': DateTime.now().add(const Duration(days: 1)),
        'status': 'Draft Saved'
      },
    ];
  }

  void _loadTodaysClasses() {
    DateFormat('EEEE').format(DateTime.now());
    _todaysClasses = [
      {
        'subject': 'Mathematics',
        'time': '09:00 - 10:00 AM',
        'teacher': 'Mr. Johnson',
        'color': Colors.blue,
      },
      {
        'subject': 'Science',
        'time': '10:15 - 11:15 AM',
        'teacher': 'Ms. Garcia',
        'color': Colors.green,
      },
      {
        'subject': 'English Literature',
        'time': '12:00 - 01:00 PM',
        'teacher': 'Mrs. Williams',
        'color': Colors.purple,
      },
      {
        'subject': 'History',
        'time': '02:00 - 03:00 PM',
        'teacher': 'Dr. Brown',
        'color': Colors.orange,
      },
    ];
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
              const Text('Student',
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
                      child: Text(
                        '$_notificationCount',
                        style: const TextStyle(
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
                _showNotifications(context);
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
                      _showProfile(context);
                    },
                    child: widget.user.profile.profilePicture.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(widget.user.profile.profilePicture),
                          radius: 16,
                        )
                      : Text(
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
        drawer: _buildDrawer(),
        body: _isLoading 
          ? Center(
              child: CircularProgressIndicator(color: _accentColor),
            )
          : RefreshIndicator(
              color: _accentColor,
              onRefresh: () async {
                setState(() {
                  _isLoading = true;
                });
                await Future.delayed(const Duration(milliseconds: 800));
                setState(() {
                  _loadUpcomingAssignments();
                  _loadTodaysClasses();
                  _isLoading = false;
                });
                return Future.value();
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingCard(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Today\'s Schedule'),
                    const SizedBox(height: 12),
                    _buildTodaySchedule(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Upcoming Assignments'),
                    const SizedBox(height: 12),
                    _buildUpcomingAssignments(),
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
                  const Text(
                    'Welcome back,',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  Text(
                    widget.user.profile.firstName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
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

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
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
              backgroundImage: NetworkImage(widget.user.profile.profilePicture),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                  
                  _buildDrawerSectionHeader('ACADEMICS'),
                  
                  _buildDrawerItem(Icons.calendar_today, 'Schedule', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentScheduleScreen(user: widget.user),
                      ),
                    );
                  }, color: Colors.blue),
                  
                  _buildDrawerItem(Icons.trending_up, 'Grades & Progress', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GradesScreen(user: widget.user),
                      ),
                    );
                  }, color: Colors.orange),
                  
                  _buildDrawerItem(Icons.library_books, 'Resource Library', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResourceLibraryScreen(),
                      ),
                    );
                  }, color: Colors.teal),
                  
                  _buildDrawerSectionHeader('COMMUNICATION'),
                  
                  _buildDrawerItem(Icons.notifications_outlined, 'Notifications', () {
                    Navigator.pop(context);
                    _showNotifications(context);
                  }, color: Colors.teal, badge: '$_notificationCount'),
                  
                  _buildDrawerSectionHeader('SERVICES'),
                  
                  _buildDrawerItem(Icons.description, 'Forms & Requests', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormsScreen(user: widget.user),
                      ),
                    );
                  }, color: Colors.deepPurple),
                  
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          
          // Bottom fixed logout button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: _buildDrawerItem(Icons.logout, 'Logout', () {
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
                        child: Text('Cancel', style: TextStyle(color: _accentColor)),
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
            }, color: Colors.red, isLogout: true),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, 
      {String? badge, required Color color, bool isLogout = false}) {
    return ListTile(
      dense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
          color: isLogout ? Colors.red : null,
        ),
      ),
      trailing: badge != null 
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _tertiaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      hoverColor: color.withOpacity(0.05),
      selectedColor: color,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTodaySchedule() {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: classItem['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.class_, color: classItem['color']),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            classItem['subject'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            classItem['time'],
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        classItem['teacher'],
                        style: const TextStyle(color: Colors.black87),
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

  Widget _buildUpcomingAssignments() {
    if (_upcomingAssignments.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No upcoming assignments',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _upcomingAssignments.length,
      itemBuilder: (context, index) {
        final assignment = _upcomingAssignments[index];
        final daysLeft = assignment['dueDate'].difference(DateTime.now()).inDays;
        
        Color statusColor;
        switch (assignment['status']) {
          case 'Completed':
            statusColor = Colors.green;
            break;
          case 'Draft Saved':
            statusColor = Colors.orange;
            break;
          default:
            statusColor = daysLeft <= 1 ? Colors.red : Colors.blue;
        }
        
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(20 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.assignment, color: statusColor),
              ),
              title: Text(
                assignment['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment['subject'],
                    style: const TextStyle(color: Colors.black87),
                  ),
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(assignment['dueDate'])} (${daysLeft} days left)',
                    style: TextStyle(
                      color: daysLeft <= 1 ? Colors.red : Colors.black54, 
                      fontSize: 12,
                      fontWeight: daysLeft <= 1 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  assignment['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/assignment_details');
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
          title: 'Class Schedule',
          icon: Icons.calendar_today,
          color: Colors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentScheduleScreen(user: widget.user),
            ),
          ),
        ),
        _buildDashboardCard(
          context: context,
          title: 'Grades & Progress',
          icon: Icons.trending_up,
          color: Colors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GradesScreen(user: widget.user),
            ),
          ),
        ),
        _buildDashboardCard(
          context: context,
          title: 'Resource Library',
          icon: Icons.library_books,
          color: Colors.green,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ResourceLibraryScreen(),
            ),
          ),
        ),
        _buildDashboardCard(
          context: context,
          title: 'Forms & Requests',
          icon: Icons.description,
          color: Colors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormsScreen(user: widget.user),
            ),
          ),
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

  void _showProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentProfileScreen(user: widget.user),
      ),
    );
  }
  
  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _notificationCount = 0;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Mark all as read'),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final icons = [Icons.announcement, Icons.assignment, Icons.payment];
                      final titles = ['New announcement posted', 'New homework assigned', 'Fee payment reminder'];
                      final subtitles = [
                        'School will be closed on Monday for national holiday',
                        'Math homework due on Friday',
                        'Last date to pay fees is 15th of this month'
                      ];
                      final colors = [Colors.blue, Colors.green, Colors.red];
                      
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(20 * (1 - value), 0),
                              child: child,
                            ),
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colors[index].withOpacity(0.2),
                            child: Icon(icons[index], color: colors[index]),
                          ),
                          title: Text(titles[index]),
                          subtitle: Text(subtitles[index]),
                          trailing: Text(
                            '${index + 1}h ago',
                            style: TextStyle(color: Colors.grey),
                          ),
                          onTap: () {
                            // Handle notification tap
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
