import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';

class TeacherManagementScreen extends StatefulWidget {
  final User user;
  
  const TeacherManagementScreen({Key? key, required this.user}) : super(key: key);

  @override
  _TeacherManagementScreenState createState() => _TeacherManagementScreenState();
}

class _TeacherManagementScreenState extends State<TeacherManagementScreen> {
  final List<Map<String, dynamic>> _teachers = [
    {
      'id': '001',
      'name': 'Robert Johnson',
      'email': 'robert.johnson@school.edu',
      'phone': '+1 (555) 123-4567',
      'subjects': ['Mathematics', 'Physics'],
      'classes': ['Class 10A', 'Class 9B'],
      'joinDate': '2018-09-01',
      'qualification': 'M.Sc. Mathematics',
      'avatar': 'assets/images/teacher1.png',
      'roles': ['Subject Teacher', 'Department Head - Science'],
      'performance': {
        'attendance': 95,
        'studentFeedback': 4.5,
        'classPerformance': 88,
        'lastEvaluation': '2023-05-15',
      }
    },
    {
      'id': '002',
      'name': 'Sarah Williams',
      'email': 'sarah.williams@school.edu',
      'phone': '+1 (555) 234-5678',
      'subjects': ['English', 'History'],
      'classes': ['Class 10A', 'Class 9B', 'Class 8C'],
      'joinDate': '2019-08-15',
      'qualification': 'M.A. English Literature',
      'avatar': 'assets/images/teacher2.png',
      'roles': ['Class Teacher - Class 10A', 'Subject Teacher'],
      'performance': {
        'attendance': 92,
        'studentFeedback': 4.8,
        'classPerformance': 90,
        'lastEvaluation': '2023-04-20',
      }
    },
    {
      'id': '003',
      'name': 'Michael Brown',
      'email': 'michael.brown@school.edu',
      'phone': '+1 (555) 345-6789',
      'subjects': ['Chemistry', 'Biology'],
      'classes': ['Class 10A', 'Class 9B'],
      'joinDate': '2017-07-10',
      'qualification': 'Ph.D. Chemistry',
      'avatar': 'assets/images/teacher3.png',
      'roles': ['Subject Teacher', 'Lab Coordinator'],
      'performance': {
        'attendance': 97,
        'studentFeedback': 4.2,
        'classPerformance': 85,
        'lastEvaluation': '2023-06-05',
      }
    },
    {
      'id': '004',
      'name': 'Emily Davis',
      'email': 'emily.davis@school.edu',
      'phone': '+1 (555) 456-7890',
      'subjects': ['Geography', 'Social Studies'],
      'classes': ['Class 8C', 'Class 7D'],
      'joinDate': '2020-01-05',
      'qualification': 'B.Ed., M.A. Geography',
      'avatar': 'assets/images/teacher4.png',
      'roles': ['Class Teacher - Class 8C', 'Subject Teacher'],
      'performance': {
        'attendance': 89,
        'studentFeedback': 4.4,
        'classPerformance': 82,
        'lastEvaluation': '2023-05-22',
      }
    },
    {
      'id': '005',
      'name': 'Daniel Wilson',
      'email': 'daniel.wilson@school.edu',
      'phone': '+1 (555) 567-8901',
      'subjects': ['Computer Science', 'Mathematics'],
      'classes': ['Class 10A', 'Class 9B'],
      'joinDate': '2018-11-20',
      'qualification': 'M.Tech Computer Science',
      'avatar': 'assets/images/teacher5.png',
      'roles': ['Subject Teacher', 'IT Coordinator'],
      'performance': {
        'attendance': 94,
        'studentFeedback': 4.7,
        'classPerformance': 91,
        'lastEvaluation': '2023-06-10',
      }
    },
  ];

  // Theme colors
  late Color _primaryColor;
  late Color _accentColor;
  late Color _tertiaryColor;
  late List<Color> _gradientColors;
  late List<Color> _cardColors;

  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredTeachers = [];
  bool _isLoading = false;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadThemeColors();
    _filteredTeachers = List.from(_teachers);
  }
  
  void _loadThemeColors() {
    _primaryColor = AppTheme.getPrimaryColor(AppTheme.defaultTheme);
    _accentColor = AppTheme.getAccentColor(AppTheme.defaultTheme);
    _tertiaryColor = AppTheme.getTertiaryColor(AppTheme.defaultTheme);
    _gradientColors = AppTheme.getGradientColors(AppTheme.defaultTheme);
    _cardColors = [
      const Color(0xFFE3F2FD), // Vibrant blue shade
      const Color(0xFFE0F2F1), // Vibrant teal shade
      const Color(0xFFFFF8E1), // Vibrant amber shade
      const Color(0xFFF3E5F5), // Vibrant purple shade
    ];
  }

  void _filterTeachers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTeachers = _teachers;
      } else {
        _filteredTeachers = _teachers
            .where((teacher) =>
                teacher['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
                teacher['email'].toString().toLowerCase().contains(query.toLowerCase()) ||
                teacher['subjects'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _applySubjectFilter(String subject) {
    setState(() {
      _selectedFilter = subject;
      if (subject == 'All') {
        _filteredTeachers = List.from(_teachers);
      } else {
        _filteredTeachers = _teachers
            .where((teacher) => (teacher['subjects'] as List<String>).contains(subject))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Management', 
          style: TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.bold,
          )
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: IconThemeData(color: _primaryColor),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: _accentColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications'))
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade100],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search teachers...',
                    prefixIcon: Icon(Icons.search, color: _accentColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                    fillColor: Colors.grey.shade50,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide(color: _accentColor),
                    ),
                  ),
                  onChanged: _filterTeachers,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedFilter == 'All'
                                ? 'All Teachers'
                                : '$_selectedFilter Teachers',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_filteredTeachers.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      icon: Icon(Icons.filter_list, color: _accentColor),
                      label: Text(
                        'Filter', 
                        style: TextStyle(color: _accentColor)
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _accentColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _showFilterOptions,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: _accentColor))
                  : _filteredTeachers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No teachers found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try changing your search criteria',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 20, left: 8, right: 8, bottom: 8),
                          itemCount: _filteredTeachers.length,
                          itemBuilder: (context, index) {
                            final teacher = _filteredTeachers[index];
                            // Create gradient colors based on index
                            final List<Color> gradientColors;
                            switch (index % 4) {
                              case 0:
                                gradientColors = [
                                  const Color(0xFF90CAF9),
                                  const Color(0xFFBBDEFB),
                                ];
                                break;
                              case 1:
                                gradientColors = [
                                  const Color(0xFF80CBC4),
                                  const Color(0xFFB2DFDB),
                                ];
                                break;
                              case 2:
                                gradientColors = [
                                  const Color(0xFFFFD54F),
                                  const Color(0xFFFFE082),
                                ];
                                break;
                              case 3:
                                gradientColors = [
                                  const Color(0xFFCE93D8),
                                  const Color(0xFFE1BEE7),
                                ];
                                break;
                              default:
                                gradientColors = [
                                  const Color(0xFF90CAF9),
                                  const Color(0xFFBBDEFB),
                                ];
                            }
                        
                            final cardColor = _cardColors[index % _cardColors.length];
                            
                            return Card(
                              elevation: 3,
                              shadowColor: gradientColors[0].withOpacity(0.3),
                              margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => _showTeacherDetails(teacher),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header section with gradient
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: gradientColors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(18),
                                          topRight: Radius.circular(18),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: gradientColors[0].withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              teacher['name'].toString().substring(0, 1),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: gradientColors[0],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  teacher['name'] as String,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    shadows: [
                                                      Shadow(
                                                        offset: Offset(0, 1),
                                                        blurRadius: 2,
                                                        color: Color(0x50000000),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  teacher['email'] as String,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    shadows: [
                                                      Shadow(
                                                        offset: Offset(0, 1),
                                                        blurRadius: 2,
                                                        color: Color(0x50000000),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: gradientColors[0].withOpacity(0.3),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              'ID: ${teacher['id']}',
                                              style: TextStyle(
                                                color: gradientColors[0],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Body section
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.book, color: gradientColors[0], size: 20),
                                              const SizedBox(width: 6),
                                              const Text(
                                                'Teaching Subjects:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: (teacher['subjects'] as List<String>)
                                                .map((subject) => Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            gradientColors[0].withOpacity(0.2),
                                                            gradientColors[1].withOpacity(0.2),
                                                          ],
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                        ),
                                                        borderRadius: BorderRadius.circular(16),
                                                        border: Border.all(color: gradientColors[0].withOpacity(0.3)),
                                                      ),
                                                      child: Text(
                                                        subject,
                                                        style: TextStyle(
                                                          fontSize: 12, 
                                                          color: gradientColors[0].withOpacity(0.8),
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Icon(Icons.school, color: gradientColors[0], size: 20),
                                              const SizedBox(width: 6),
                                              const Text(
                                                'Classes:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: (teacher['classes'] as List<String>)
                                                .map((className) => Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: gradientColors[0].withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(16),
                                                        border: Border.all(color: gradientColors[0].withOpacity(0.2)),
                                                      ),
                                                      child: Text(
                                                        className,
                                                        style: TextStyle(
                                                          fontSize: 12, 
                                                          color: gradientColors[0].withOpacity(0.8),
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Footer with actions
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(18),
                                          bottomRight: Radius.circular(18),
                                        ),
                                        border: Border(
                                          top: BorderSide(
                                            color: gradientColors[0].withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton.icon(
                                            icon: Icon(Icons.edit, size: 18, color: gradientColors[0]),
                                            label: Text('Edit', style: TextStyle(color: gradientColors[0])),
                                            onPressed: () => _showEditTeacherDialog(teacher),
                                          ),
                                          Row(
                                            children: [
                                              Material(
                                                color: Colors.transparent,
                                                shape: const CircleBorder(),
                                                clipBehavior: Clip.antiAlias,
                                                child: IconButton(
                                                  icon: Icon(Icons.badge, color: Colors.green.shade400),
                                                  onPressed: () => _showManageRolesDialog(teacher),
                                                  tooltip: "Manage Roles",
                                                ),
                                              ),
                                              Material(
                                                color: Colors.transparent,
                                                shape: const CircleBorder(),
                                                clipBehavior: Clip.antiAlias,
                                                child: IconButton(
                                                  icon: Icon(Icons.class_, color: Colors.orange.shade400),
                                                  onPressed: () => _showAssignClassesDialog(teacher),
                                                  tooltip: "Assign Classes",
                                                ),
                                              ),
                                              Material(
                                                color: Colors.transparent,
                                                shape: const CircleBorder(),
                                                clipBehavior: Clip.antiAlias,
                                                child: IconButton(
                                                  icon: Icon(Icons.analytics, color: Colors.purple.shade400),
                                                  onPressed: () => _showTeacherPerformance(teacher),
                                                  tooltip: "Performance",
                                                ),
                                              ),
                                              PopupMenuButton(
                                                icon: const Icon(
                                                  Icons.more_vert,
                                                  color: Colors.grey,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'message',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.message, color: Colors.blue, size: 20),
                                                        SizedBox(width: 8),
                                                        Text('Send Message'),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete, color: Colors.red, size: 20),
                                                        SizedBox(width: 8),
                                                        Text('Delete Teacher'),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                onSelected: (value) {
                                                  _handleMenuAction(value, teacher);
                                                },
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
                        ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_accentColor, _accentColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _accentColor.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddTeacherDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add Teacher", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_accentColor, _accentColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _accentColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Filter Teachers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Filter by Subject',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'All',
                'Mathematics',
                'Physics',
                'Chemistry',
                'Biology',
                'English',
                'History',
                'Geography',
                'Computer Science',
                'Social Studies'
              ].map((subject) => _buildFilterChip(
                label: subject,
                selected: _selectedFilter == subject,
                onSelected: (selected) {
                  Navigator.pop(context);
                  _applySubjectFilter(subject);
                },
                color: _accentColor,
              )).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper method to create consistent filter chips
  Widget _buildFilterChip({
    required String label, 
    required bool selected, 
    required Function(bool) onSelected, 
    required Color color
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: color.withOpacity(0.15),
      checkmarkColor: color.withOpacity(0.8),
      labelStyle: TextStyle(
        color: selected ? color : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(color: selected ? color : Colors.grey.shade300),
      elevation: 1,
      shadowColor: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  void _showTeacherDetails(Map<String, dynamic> teacher) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Colorful header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_accentColor, _accentColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Text(
                            teacher['name'].toString().substring(0, 1),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                teacher['name'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                teacher['qualification'] as String,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Teacher ID: ${teacher['id']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Content area with details
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact information
                      _buildInfoSection(
                        'Contact Information',
                        Icons.contact_mail,
                        [
                          _buildInfoRow(Icons.email, 'Email', teacher['email'] as String),
                          _buildInfoRow(Icons.phone, 'Phone', teacher['phone'] as String),
                          _buildInfoRow(Icons.calendar_today, 'Joined', teacher['joinDate'] as String),
                        ],
                        _primaryColor,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Teacher Roles
                      _buildInfoSection(
                        'Teacher Roles',
                        Icons.badge,
                        [
                          Wrap(
                            spacing: 8,
                            children: ((teacher['roles'] ?? <String>[]) as List<dynamic>).map((role) => Chip(
                                  label: Text(role.toString()),
                                  backgroundColor: _tertiaryColor.withOpacity(0.2),
                                )).toList(),
                          ),
                        ],
                        _tertiaryColor,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Teaching Subjects
                      _buildInfoSection(
                        'Teaching Subjects',
                        Icons.book,
                        [
                          Wrap(
                            spacing: 8,
                            children: (teacher['subjects'] as List<String>).map((subject) => Chip(
                                  label: Text(subject),
                                  backgroundColor: _primaryColor.withOpacity(0.2),
                                )).toList(),
                          ),
                        ],
                        _primaryColor,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Assigned Classes
                      _buildInfoSection(
                        'Assigned Classes',
                        Icons.class_,
                        [
                          Wrap(
                            spacing: 8,
                            children: (teacher['classes'] as List<String>).map((className) => Chip(
                                  label: Text(className),
                                  backgroundColor: _accentColor.withOpacity(0.2),
                                )).toList(),
                          ),
                        ],
                        _accentColor,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Performance summary
                      if (teacher.containsKey('performance')) ...[
                        _buildPerformanceSummary(teacher['performance'] as Map<String, dynamic>),
                        const SizedBox(height: 32),
                      ],
                      
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditTeacherDialog(teacher);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.badge),
                            label: const Text('Roles'),
                            onPressed: () {
                              Navigator.pop(context);
                              _showManageRolesDialog(teacher);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _tertiaryColor,
                              side: BorderSide(color: _tertiaryColor),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.message),
                            label: const Text('Message'),
                            onPressed: () {
                              Navigator.pop(context);
                              _showSendMessageDialog(teacher);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _accentColor,
                              side: BorderSide(color: _accentColor),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      );
  }
  
  Widget _buildInfoSection(String title, IconData icon, List<Widget> children, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPerformanceSummary(Map<String, dynamic> performance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Performance Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue.shade800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Last updated: ${performance['lastEvaluation']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPerformanceMetricCircular(
                'Attendance',
                performance['attendance'] as num,
                100,
                Colors.green,
                Icons.check_circle,
              ),
              _buildPerformanceMetricCircular(
                'Student\nFeedback',
                performance['studentFeedback'] as num,
                5,
                Colors.orange,
                Icons.star,
              ),
              _buildPerformanceMetricCircular(
                'Class\nPerformance',
                performance['classPerformance'] as num,
                100,
                Colors.purple,
                Icons.school,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPerformanceMetricCircular(
    String label, num value, num maxValue, Color color, IconData icon
  ) {
    final double percentage = (value / maxValue);
    
    return Column(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: percentage,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(height: 4),
                  Text(
                    maxValue == 5 ? value.toString() : '${value.toInt()}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showAddTeacherDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final qualificationController = TextEditingController();
    
    // Selected subjects and roles
    final selectedSubjects = <String>{};
    final selectedRoles = <String>{};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Teacher'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter teacher\'s full name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter email address',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter phone number',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: qualificationController,
                  decoration: const InputDecoration(
                    labelText: 'Qualification',
                    hintText: 'Enter highest qualification',
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Teaching Subjects:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'Mathematics',
                    'Physics',
                    'Chemistry',
                    'Biology',
                    'English',
                    'History',
                    'Geography',
                    'Computer Science',
                    'Social Studies'
                  ].map((subject) => FilterChip(
                        label: Text(subject),
                        selected: selectedSubjects.contains(subject),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedSubjects.add(subject);
                            } else {
                              selectedSubjects.remove(subject);
                            }
                          });
                        },
                      )).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Teacher Roles:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'Subject Teacher',
                    'Class Teacher',
                    'Department Head',
                    'Lab Coordinator',
                    'IT Coordinator',
                    'Examination Coordinator',
                    'Sports Coordinator'
                  ].map((role) => FilterChip(
                        label: Text(role),
                        selected: selectedRoles.contains(role),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedRoles.add(role);
                            } else {
                              selectedRoles.remove(role);
                            }
                          });
                        },
                      )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || emailController.text.isEmpty || selectedSubjects.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final newTeacher = {
                  'id': 'T${_teachers.length + 1}',
                  'name': nameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'subjects': selectedSubjects.toList(),
                  'classes': <String>[],
                  'joinDate': DateTime.now().toString().substring(0, 10),
                  'qualification': qualificationController.text,
                  'avatar': 'assets/images/teacher_default.png',
                  'roles': selectedRoles.isEmpty ? ['Subject Teacher'] : selectedRoles.toList(),
                  'performance': {
                    'attendance': 0,
                    'studentFeedback': 0,
                    'classPerformance': 0,
                    'lastEvaluation': 'Not Yet Evaluated',
                  },
                };

                setState(() {
                  _teachers.add(newTeacher);
                  _filteredTeachers = List.from(_teachers);
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Teacher added successfully')),
                );
              },
              child: const Text('Add Teacher'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTeacherDialog(Map<String, dynamic> teacher) {
    final nameController = TextEditingController(text: teacher['name'] as String);
    final emailController = TextEditingController(text: teacher['email'] as String);
    final phoneController = TextEditingController(text: teacher['phone'] as String);
    final qualificationController = TextEditingController(text: teacher['qualification'] as String);
    
    // Selected subjects
    final selectedSubjects = Set<String>.from(teacher['subjects'] as List<String>);
    final selectedRoles = Set<String>.from(teacher['roles'] as List<String>);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Teacher'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: qualificationController,
                  decoration: const InputDecoration(labelText: 'Qualification'),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Teaching Subjects:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'Mathematics',
                    'Physics',
                    'Chemistry',
                    'Biology',
                    'English',
                    'History',
                    'Geography',
                    'Computer Science',
                    'Social Studies'
                  ].map((subject) => FilterChip(
                        label: Text(subject),
                        selected: selectedSubjects.contains(subject),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedSubjects.add(subject);
                            } else {
                              selectedSubjects.remove(subject);
                            }
                          });
                        },
                      )).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Teacher Roles:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'Subject Teacher',
                    'Class Teacher',
                    'Department Head',
                    'Lab Coordinator',
                    'IT Coordinator',
                    'Examination Coordinator',
                    'Sports Coordinator'
                  ].map((role) => FilterChip(
                        label: Text(role),
                        selected: selectedRoles.contains(role),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedRoles.add(role);
                            } else {
                              selectedRoles.remove(role);
                            }
                          });
                        },
                      )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || emailController.text.isEmpty || selectedSubjects.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final index = _teachers.indexOf(teacher);
                if (index != -1) {
                  setState(() {
                    _teachers[index]['name'] = nameController.text;
                    _teachers[index]['email'] = emailController.text;
                    _teachers[index]['phone'] = phoneController.text;
                    _teachers[index]['qualification'] = qualificationController.text;
                    _teachers[index]['subjects'] = selectedSubjects.toList();
                    _teachers[index]['roles'] = selectedRoles.toList();
                    _filteredTeachers = List.from(_teachers);
                  });
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Teacher updated successfully')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignClassesDialog(Map<String, dynamic> teacher) {
    final availableClasses = ['Class 10A', 'Class 9B', 'Class 8C', 'Class 7D'];
    final selectedClasses = Set<String>.from(teacher['classes'] as List<String>);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Assign Classes to ${teacher['name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: availableClasses.map((className) => CheckboxListTile(
                title: Text(className),
                value: selectedClasses.contains(className),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedClasses.add(className);
                    } else {
                      selectedClasses.remove(className);
                    }
                  });
                },
              )).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final index = _teachers.indexOf(teacher);
                if (index != -1) {
                  setState(() {
                    _teachers[index]['classes'] = selectedClasses.toList();
                    _filteredTeachers = List.from(_teachers);
                  });
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Classes assigned successfully')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSendMessageDialog(Map<String, dynamic> teacher) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message to ${teacher['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Enter your message here',
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (messageController.text.isEmpty) {
                return;
              }

              // In a real app, this would send the message
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message sent to ${teacher['name']}')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${teacher['name']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _teachers.remove(teacher);
                _filteredTeachers = List.from(_teachers);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Teacher deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showManageRolesDialog(Map<String, dynamic> teacher) {
    final availableRoles = [
      'Subject Teacher', 
      'Class Teacher',
      'Class Teacher - Class 10A', 
      'Class Teacher - Class 9B',
      'Class Teacher - Class 8C',
      'Class Teacher - Class 7D',
      'Department Head - Science',
      'Department Head - Languages',
      'Department Head - Social Studies',
      'Department Head - Mathematics',
      'Lab Coordinator',
      'IT Coordinator',
      'Examination Coordinator',
      'Sports Coordinator',
      'Cultural Coordinator'
    ];
    
    final selectedRoles = Set<String>.from((teacher['roles'] ?? <String>[]) as List<dynamic>);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Manage Roles for ${teacher['name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Assign roles to this teacher:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableRoles.map((role) => FilterChip(
                    label: Text(role),
                    selected: selectedRoles.contains(role),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          // Handle mutually exclusive class teacher roles
                          if (role.startsWith('Class Teacher - Class')) {
                            selectedRoles.removeWhere((r) => r.startsWith('Class Teacher - Class'));
                          }
                          // Handle mutually exclusive department head roles
                          if (role.startsWith('Department Head')) {
                            selectedRoles.removeWhere((r) => r.startsWith('Department Head'));
                          }
                          selectedRoles.add(role);
                        } else {
                          selectedRoles.remove(role);
                        }
                      });
                    },
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final index = _teachers.indexOf(teacher);
                if (index != -1) {
                  setState(() {
                    _teachers[index]['roles'] = selectedRoles.toList();
                    _filteredTeachers = List.from(_teachers);
                  });
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Roles updated successfully')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showTeacherPerformance(Map<String, dynamic> teacher) {
    final performance = teacher['performance'] as Map<String, dynamic>? ?? {
      'attendance': 0,
      'studentFeedback': 0,
      'classPerformance': 0,
      'lastEvaluation': 'Not Yet Evaluated',
    };
    
    // Chart data
    final monthlyData = [
      {'month': 'Aug', 'value': 0.88},
      {'month': 'Sep', 'value': 0.92},
      {'month': 'Oct', 'value': 0.90},
      {'month': 'Nov', 'value': 0.94},
      {'month': 'Dec', 'value': 0.89},
    ];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colorful header with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _primaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Text(
                            teacher['name'].toString().substring(0, 1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${teacher['name']} Performance',
                                style: const TextStyle(
                                  fontSize: 22, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                      color: Color(0x70000000),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'ID: ${teacher['id']} | ${teacher['qualification']}',
                                style: const TextStyle(
                                  fontSize: 14, 
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                      color: Color(0x50000000),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () => Navigator.pop(context),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Key stats in the header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildHeaderStat(
                          '${performance['attendance']}%',
                          'Attendance',
                          Icons.check_circle,
                        ),
                        _buildHeaderStat(
                          '${performance['studentFeedback']}/5.0',
                          'Student Rating',
                          Icons.star,
                        ),
                        _buildHeaderStat(
                          '${performance['classPerformance']}%',
                          'Class Performance',
                          Icons.school,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Content area
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  children: [
                    // Controllers for editing performance metrics
                    const Text(
                      'Update Performance Metrics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    Card(
                      elevation: 2,
                      shadowColor: Colors.blue.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildPerformanceMetric(
                              context, 
                              'Attendance Rate', 
                              '${performance['attendance']}%',
                              performance['attendance'] as num,
                              Colors.blue,
                            ),
                            const SizedBox(height: 16),
                            _buildPerformanceMetric(
                              context, 
                              'Student Feedback', 
                              '${performance['studentFeedback']}/5.0',
                              (performance['studentFeedback'] as num) / 5 * 100,
                              Colors.green,
                            ),
                            const SizedBox(height: 16),
                            _buildPerformanceMetric(
                              context, 
                              'Class Performance', 
                              '${performance['classPerformance']}%',
                              performance['classPerformance'] as num,
                              Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Monthly attendance chart
                    Card(
                      elevation: 2,
                      shadowColor: Colors.purple.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.date_range, color: Colors.purple.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Monthly Performance Trend',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.purple.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 180,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: monthlyData.map((data) {
                                  return Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${((data['value'] as double) * 100).toInt()}%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: _primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 120 * (data['value'] as double),
                                          width: 20,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                _primaryColor,
                                                _primaryColor.withOpacity(0.7),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(6)
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _primaryColor.withOpacity(0.3),
                                                blurRadius: 3,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          data['month'] as String,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _primaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Performance update form
                    Card(
                      elevation: 2,
                      shadowColor: Colors.orange.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.edit, color: Colors.orange.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Update Performance',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // We'll create a stateful builder for this form in a real app
                            // For now, we'll just show the input fields
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'Attendance Rate (%)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                prefixIcon: const Icon(Icons.check_circle),
                              ),
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(text: performance['attendance'].toString()),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'Student Feedback (0-5)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                prefixIcon: const Icon(Icons.star),
                              ),
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(text: performance['studentFeedback'].toString()),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'Class Performance (%)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                prefixIcon: const Icon(Icons.school),
                              ),
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(text: performance['classPerformance'].toString()),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text('Save Performance Data'),
                                onPressed: () {
                                  // This would update the performance in a real app
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Performance updated successfully')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      );
  }
  
  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPerformanceMetric(BuildContext context, String label, String value, num percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
  
  void _handleMenuAction(String action, Map<String, dynamic> teacher) {
    switch (action) {
      case 'view':
        _showTeacherDetails(teacher);
        break;
      case 'edit':
        _showEditTeacherDialog(teacher);
        break;
      case 'roles':
        _showManageRolesDialog(teacher);
        break;
      case 'assign':
        _showAssignClassesDialog(teacher);
        break;
      case 'message':
        _showSendMessageDialog(teacher);
        break;
      case 'performance':
        _showTeacherPerformance(teacher);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(teacher);
        break;
    }
  }
}