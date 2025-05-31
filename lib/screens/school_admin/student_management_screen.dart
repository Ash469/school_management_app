import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({Key? key}) : super(key: key);

  @override
  _StudentManagementScreenState createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final List<Map<String, dynamic>> _students = [
    {
      'id': 'S001',
      'name': 'Alice Smith',
      'grade': '10',
      'class': 'Class 10A',
      'gender': 'Female',
      'dob': '2008-05-12',
      'address': '123 Main St, Anytown',
      'contact': '+1 (555) 123-4567',
      'parent': 'John Smith',
      'parentContact': '+1 (555) 123-4568',
      'email': 'alice.smith@example.com',
      'attendance': '95%',
      'academicRecord': [
        {'subject': 'Mathematics', 'grade': 'A'},
        {'subject': 'Science', 'grade': 'A-'},
        {'subject': 'English', 'grade': 'B+'},
        {'subject': 'History', 'grade': 'A'},
      ]
    },
    {
      'id': 'S002',
      'name': 'Bob Johnson',
      'grade': '9',
      'class': 'Class 9B',
      'gender': 'Male',
      'dob': '2009-08-23',
      'address': '456 Oak St, Anytown',
      'contact': '+1 (555) 234-5678',
      'parent': 'Mary Johnson',
      'parentContact': '+1 (555) 234-5679',
      'email': 'bob.johnson@example.com',
      'attendance': '88%',
      'academicRecord': [
        {'subject': 'Mathematics', 'grade': 'B'},
        {'subject': 'Science', 'grade': 'B+'},
        {'subject': 'English', 'grade': 'A-'},
        {'subject': 'History', 'grade': 'B'},
      ]
    },
    {
      'id': 'S003',
      'name': 'Charlie Davis',
      'grade': '10',
      'class': 'Class 10A',
      'gender': 'Male',
      'dob': '2008-02-15',
      'address': '789 Pine St, Anytown',
      'contact': '+1 (555) 345-6789',
      'parent': 'Sarah Davis',
      'parentContact': '+1 (555) 345-6780',
      'email': 'charlie.davis@example.com',
      'attendance': '92%',
      'academicRecord': [
        {'subject': 'Mathematics', 'grade': 'A'},
        {'subject': 'Science', 'grade': 'A'},
        {'subject': 'English', 'grade': 'B'},
        {'subject': 'History', 'grade': 'B+'},
      ]
    },
    {
      'id': 'S004',
      'name': 'Diana Wilson',
      'grade': '9',
      'class': 'Class 9B',
      'gender': 'Female',
      'dob': '2009-11-30',
      'address': '101 Elm St, Anytown',
      'contact': '+1 (555) 456-7890',
      'parent': 'Robert Wilson',
      'parentContact': '+1 (555) 456-7891',
      'email': 'diana.wilson@example.com',
      'attendance': '78%',
      'academicRecord': [
        {'subject': 'Mathematics', 'grade': 'C+'},
        {'subject': 'Science', 'grade': 'B-'},
        {'subject': 'English', 'grade': 'B'},
        {'subject': 'History', 'grade': 'C'},
      ]
    },
  ];

  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = false;
  String _selectedFilter = 'All';

  // Theme colors
  late Color _primaryColor;
  late Color _accentColor;
  late Color _tertiaryColor;
  late List<Color> _gradientColors;
  late List<Color> _cardColors;

  @override
  void initState() {
    super.initState();
    _loadThemeColors();
    _filteredStudents = List.from(_students);
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

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _students;
      } else {
        _filteredStudents = _students
            .where((student) =>
                student['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
                student['id'].toString().toLowerCase().contains(query.toLowerCase()) ||
                student['class'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _applyGradeFilter(String grade) {
    setState(() {
      _selectedFilter = grade;
      if (grade == 'All') {
        _filteredStudents = List.from(_students);
      } else {
        _filteredStudents = _students
            .where((student) => student['grade'] == grade)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Management', 
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
                    hintText: 'Search students...',
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
                  onChanged: _filterStudents,
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
                                ? 'All Students'
                                : 'Grade $_selectedFilter Students',
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
                              '${_filteredStudents.length}',
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
                  : _filteredStudents.isEmpty
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
                                'No students found',
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
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
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

                            return Card(
                              elevation: 3,
                              shadowColor: gradientColors[0].withOpacity(0.3),
                              margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => _showStudentDetails(student),
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
                                              student['name'].toString().substring(0, 1),
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
                                                  student['name'] as String,
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
                                                  'ID: ${student['id']} | Grade: ${student['grade']}',
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
                                        ],
                                      ),
                                    ),
                                    
                                    // Footer with essential info and actions
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
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.school, size: 16, color: gradientColors[0]),
                                              const SizedBox(width: 6),
                                              Text(
                                                student['class'] as String,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade800
                                                ),
                                              ),
                                              const Spacer(),
                                              Row(
                                                children: [
                                                  Icon(Icons.access_time, size: 16, color: Colors.blue.shade700),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    student['attendance'] as String,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.blue.shade700
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.badge, size: 16, color: Colors.orange.shade700),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Avg: ${_getAverageGrade(student['academicRecord'] as List)}',
                                                      style: TextStyle(
                                                        fontSize: 13, 
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.orange.shade700
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              TextButton.icon(
                                                icon: Icon(Icons.visibility, size: 16, color: gradientColors[0]),
                                                label: Text(
                                                  'View Profile',
                                                  style: TextStyle(color: gradientColors[0], fontSize: 13),
                                                ),
                                                onPressed: () => _showStudentDetails(student),
                                                style: ButtonStyle(
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  visualDensity: VisualDensity.compact,
                                                  padding: MaterialStateProperty.all(
                                                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                                                  ),
                                                ),
                                              ),
                                              PopupMenuButton(
                                                icon: Icon(
                                                  Icons.more_vert,
                                                  color: Colors.grey.shade600,
                                                  size: 20,
                                                ),
                                                padding: EdgeInsets.zero,
                                                position: PopupMenuPosition.under,
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit, color: Colors.blue, size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Edit', style: TextStyle(fontSize: 14)),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'academic',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.book, color: Colors.green, size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Academic Record', style: TextStyle(fontSize: 14)),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'message',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.message, color: Colors.orange, size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Message Parent', style: TextStyle(fontSize: 14)),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete, color: Colors.red, size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Remove Student', style: TextStyle(fontSize: 14)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                onSelected: (value) {
                                                  _handleMenuAction(value, student);
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
          onPressed: _showAddStudentDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.person_add, color: Colors.white),
          label: const Text("Enroll New Student", style: TextStyle(color: Colors.white)),
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
                  'Filter Students',
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
            
            // Filter by grade
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.blue.shade100.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Filter by Grade',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'All',
                      '9',
                      '10',
                      '11',
                      '12',
                    ].map((grade) => _buildFilterChip(
                      label: grade,
                      selected: _selectedFilter == grade,
                      onSelected: (selected) {
                        Navigator.pop(context);
                        _applyGradeFilter(grade);
                      },
                      color: Colors.blue,
                    )).toList(),
                  ),
                ],
              ),
            ),
            
            // Actions
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear All'),
                    onPressed: () {
                      setState(() {
                        _filteredStudents = List.from(_students);
                        _selectedFilter = 'All';
                      });
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Apply'),
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),
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

  void _showStudentDetails(Map<String, dynamic> student) {
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
                            student['name'].toString().substring(0, 1),
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
                                student['name'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Grade ${student['grade']} | ${student['class']}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
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
                      // Basic information
                      _buildInfoSection(
                        'Basic Information',
                        Icons.person,
                        [
                          _buildDetailRow('Student ID', student['id'] as String),
                          _buildDetailRow('Date of Birth', student['dob'] as String),
                          _buildDetailRow('Gender', student['gender'] as String),
                        ],
                        _primaryColor,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Contact information
                      _buildInfoSection(
                        'Contact Information',
                        Icons.contact_mail,
                        [
                          _buildDetailRow('Address', student['address'] as String),
                          _buildDetailRow('Contact', student['contact'] as String),
                          _buildDetailRow('Email', student['email'] as String),
                        ],
                        _tertiaryColor,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Parent information
                      _buildInfoSection(
                        'Parent Information',
                        Icons.family_restroom,
                        [
                          _buildDetailRow('Parent Name', student['parent'] as String),
                          _buildDetailRow('Parent Contact', student['parentContact'] as String),
                        ],
                        Colors.orange,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Academic information
                      _buildInfoSection(
                        'Academic Information',
                        Icons.school,
                        [
                          _buildDetailRow('Average Grade', _getAverageGrade(student['academicRecord'] as List)),
                          _buildDetailRow('Attendance', student['attendance'] as String),
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Subject Grades',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ..._buildGradesList(student['academicRecord'] as List),
                              ],
                            ),
                          ),
                        ],
                        _accentColor,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profile'),
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditStudentDialog(student);
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
                            icon: const Icon(Icons.book),
                            label: const Text('Academic Record'),
                            onPressed: () {
                              Navigator.pop(context);
                              _showAcademicRecordDialog(student);
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
                          OutlinedButton.icon(
                            icon: const Icon(Icons.assessment),
                            label: const Text('Report'),
                            onPressed: () {
                              Navigator.pop(context);
                              _generateStudentReport(student);
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildGradesList(List academicRecord) {
    if (academicRecord.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No grades recorded yet',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        )
      ];
    }
    
    return academicRecord.map((record) => Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(record['subject'] as String)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getGradeColor(record['grade'] as String),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              record['grade'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final idController = TextEditingController(text: 'S00${_students.length + 1}');
    final gradeController = TextEditingController();
    final classController = TextEditingController();
    final dobController = TextEditingController();
    final addressController = TextEditingController();
    final contactController = TextEditingController();
    final parentController = TextEditingController();
    final parentContactController = TextEditingController();
    final emailController = TextEditingController();
    
    String selectedGender = 'Male';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Enroll New Student'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter student\'s full name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    hintText: 'Enter student ID',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: gradeController,
                        decoration: const InputDecoration(
                          labelText: 'Grade',
                          hintText: 'e.g., 10',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: classController,
                        decoration: const InputDecoration(
                          labelText: 'Class',
                          hintText: 'e.g., 10A',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'YYYY-MM-DD',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Gender: '),
                    Radio(
                      value: 'Male',
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value.toString();
                        });
                      },
                    ),
                    const Text('Male'),
                    Radio(
                      value: 'Female',
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value.toString();
                        });
                      },
                    ),
                    const Text('Female'),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Parent Information',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: parentController,
                  decoration: const InputDecoration(
                    labelText: 'Parent Name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: parentContactController,
                  decoration: const InputDecoration(
                    labelText: 'Parent Contact',
                  ),
                  keyboardType: TextInputType.phone,
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
                if (nameController.text.isEmpty || 
                    gradeController.text.isEmpty || 
                    classController.text.isEmpty ||
                    parentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final newStudent = {
                  'id': idController.text,
                  'name': nameController.text,
                  'grade': gradeController.text,
                  'class': classController.text,
                  'gender': selectedGender,
                  'dob': dobController.text,
                  'address': addressController.text,
                  'contact': contactController.text,
                  'parent': parentController.text,
                  'parentContact': parentContactController.text,
                  'email': emailController.text,
                  'attendance': '100%',
                  'academicRecord': [],
                };

                setState(() {
                  _students.add(newStudent);
                  _filteredStudents = List.from(_students);
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Student enrolled successfully')),
                );
              },
              child: const Text('Enroll'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStudentDialog(Map<String, dynamic> student) {
    final nameController = TextEditingController(text: student['name'] as String);
    final gradeController = TextEditingController(text: student['grade'] as String);
    final classController = TextEditingController(text: student['class'] as String);
    final dobController = TextEditingController(text: student['dob'] as String);
    final addressController = TextEditingController(text: student['address'] as String);
    final contactController = TextEditingController(text: student['contact'] as String);
    final parentController = TextEditingController(text: student['parent'] as String);
    final parentContactController = TextEditingController(text: student['parentContact'] as String);
    final emailController = TextEditingController(text: student['email'] as String);
    
    String selectedGender = student['gender'] as String;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Student'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: gradeController,
                        decoration: const InputDecoration(labelText: 'Grade'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: classController,
                        decoration: const InputDecoration(labelText: 'Class'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dobController,
                  decoration: const InputDecoration(labelText: 'Date of Birth'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Gender: '),
                    Radio(
                      value: 'Male',
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value.toString();
                        });
                      },
                    ),
                    const Text('Male'),
                    Radio(
                      value: 'Female',
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value.toString();
                        });
                      },
                    ),
                    const Text('Female'),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Contact Number'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Parent Information',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: parentController,
                  decoration: const InputDecoration(labelText: 'Parent Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: parentContactController,
                  decoration: const InputDecoration(labelText: 'Parent Contact'),
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
                if (nameController.text.isEmpty || gradeController.text.isEmpty || classController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final index = _students.indexOf(student);
                if (index != -1) {
                  setState(() {
                    _students[index]['name'] = nameController.text;
                    _students[index]['grade'] = gradeController.text;
                    _students[index]['class'] = classController.text;
                    _students[index]['gender'] = selectedGender;
                    _students[index]['dob'] = dobController.text;
                    _students[index]['address'] = addressController.text;
                    _students[index]['contact'] = contactController.text;
                    _students[index]['parent'] = parentController.text;
                    _students[index]['parentContact'] = parentContactController.text;
                    _students[index]['email'] = emailController.text;

                    _filteredStudents = List.from(_students);
                  });
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Student updated successfully')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAcademicRecordDialog(Map<String, dynamic> student) {
    final records = student['academicRecord'] as List;
    final subjectController = TextEditingController();
    final gradingOptions = ['A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'D-', 'F'];
    String selectedGrade = 'A';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${student['name']}\'s Academic Record'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (records.isNotEmpty) ...[
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return ListTile(
                          title: Text(record['subject'] as String),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getGradeColor(record['grade'] as String),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              record['grade'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onLongPress: () {
                            setState(() {
                              records.removeAt(index);
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const Divider(),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    hintText: 'Enter subject name',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: selectedGrade,
                  isExpanded: true,
                  items: gradingOptions.map((grade) => DropdownMenuItem<String>(
                    value: grade,
                    child: Text(grade),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedGrade = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (subjectController.text.isEmpty) {
                      return;
                    }
                    setState(() {
                      records.add({
                        'subject': subjectController.text,
                        'grade': selectedGrade,
                      });
                      subjectController.clear();
                    });
                  },
                  child: const Text('Add Grade'),
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
                // The records list is already updated by reference
                Navigator.pop(context);
                setState(() {
                  // Refresh the view
                  _filteredStudents = List.from(_students);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Academic record updated successfully')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _generateStudentReport(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${student['name']}\'s Academic Report'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Student ID: ${student['id']}'),
                Text('Class: ${student['class']}'),
                Text('Grade: ${student['grade']}'),
                const SizedBox(height: 16),
                const Text('Academic Performance', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Column(
                  children: (student['academicRecord'] as List).isEmpty 
                      ? [const Text('No grades recorded yet')]
                      : (student['academicRecord'] as List).map((record) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(child: Text(record['subject'] as String)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getGradeColor(record['grade'] as String),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            record['grade'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Overall Grade: '),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getGradeColor(_getAverageGrade(student['academicRecord'] as List)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getAverageGrade(student['academicRecord'] as List),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Attendance: ${student['attendance']}'),
                const SizedBox(height: 16),
                const Text('Teacher Comments:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('The student has shown good progress throughout the term.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Print'),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Printing report...')),
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Share'),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing report...')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showSendMessageDialog(Map<String, dynamic> student) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message to ${student['parent']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Parent of ${student['name']}'),
            const SizedBox(height: 16),
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
                SnackBar(content: Text('Message sent to ${student['parent']}')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text('Are you sure you want to remove ${student['name']} from the school? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _students.remove(student);
                _filteredStudents = List.from(_students);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Student removed successfully')),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> student) {
    switch (action) {
      case 'view':
        _showStudentDetails(student);
        break;
      case 'edit':
        _showEditStudentDialog(student);
        break;
      case 'academic':
        _showAcademicRecordDialog(student);
        break;
      case 'report':
        _generateStudentReport(student);
        break;
      case 'message':
        _showSendMessageDialog(student);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(student);
        break;
    }
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green;
    if (grade.startsWith('B')) return Colors.blue;
    if (grade.startsWith('C')) return Colors.orange;
    if (grade.startsWith('D')) return Colors.deepOrange;
    return Colors.red;
  }

  String _getAverageGrade(List records) {
    if (records.isEmpty) return 'N/A';
    
    final grades = {
      'A+': 12, 'A': 11, 'A-': 10,
      'B+': 9, 'B': 8, 'B-': 7,
      'C+': 6, 'C': 5, 'C-': 4,
      'D+': 3, 'D': 2, 'D-': 1,
      'F': 0
    };
    
    double total = 0;
    for (var record in records) {
      String grade = record['grade'];
      total += grades[grade] ?? 0;
    }
    
    double average = total / records.length;
    
    if (average >= 11) return 'A';
    if (average >= 10) return 'A-';
    if (average >= 9) return 'B+';
    if (average >= 8) return 'B';
    if (average >= 7) return 'B-';
    if (average >= 6) return 'C+';
    if (average >= 5) return 'C';
    if (average >= 4) return 'C-';
    if (average >= 3) return 'D+';
    if (average >= 2) return 'D';
    if (average >= 1) return 'D-';
    return 'F';
  }
}
