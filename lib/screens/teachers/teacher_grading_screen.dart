import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class TeacherGradingScreen extends StatefulWidget {
  final User user;
  final Map<String, dynamic>? selectedClass;

  const TeacherGradingScreen({
    Key? key, 
    required this.user, 
    this.selectedClass,
  }) : super(key: key);

  @override
  _TeacherGradingScreenState createState() => _TeacherGradingScreenState();
}

class _TeacherGradingScreenState extends State<TeacherGradingScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _assignments = [];
  final List<Map<String, dynamic>> _students = [];
  final List<Map<String, dynamic>> _grades = [];
  final List<Map<String, dynamic>> _classes = [];
  Map<String, dynamic>? _selectedClass;

  // Light theme colors to match attendance screen
  final Color _primaryColor = const Color(0xFF5E63B6);
  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _cardColor = Colors.white;
  final Color _textPrimaryColor = const Color(0xFF333333);
  final Color _textSecondaryColor = const Color(0xFF717171);
  
  // Class colors
  final List<Color> _classColors = [
    const Color(0xFF5E63B6),
    const Color(0xFF43A047),
    const Color(0xFFFF9800),
    const Color(0xFF2196F3),
    const Color(0xFFE53935),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedClass = widget.selectedClass;
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Load classes if not already selected
    if (_classes.isEmpty) {
      setState(() {
        _classes.addAll([
          {
            'id': '10A',
            'name': 'Class 10A',
            'subject': 'Mathematics',
            'color': _classColors[0],
          },
          {
            'id': '9B',
            'name': 'Class 9B',
            'subject': 'Mathematics',
            'color': _classColors[1],
          },
          {
            'id': '8C',
            'name': 'Class 8C',
            'subject': 'Physics',
            'color': _classColors[2],
          },
        ]);
      });
    }
    
    if (_selectedClass != null) {
      await _loadDataForClass(_selectedClass!['id']);
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _loadDataForClass(String classId) async {
    // Clear previous data
    setState(() {
      _students.clear();
      _assignments.clear();
      _grades.clear();
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Load mock data based on class
    List<Map<String, dynamic>> studentsData = [];
    List<Map<String, dynamic>> assignmentsData = [];
    List<Map<String, dynamic>> gradesData = [];
    
    switch (classId) {
      case '10A':
        studentsData = [
          {'id': '1001', 'name': 'Alice Johnson'},
          {'id': '1002', 'name': 'Bob Smith'},
          {'id': '1003', 'name': 'Carol White'},
          {'id': '1004', 'name': 'David Brown'},
          {'id': '1005', 'name': 'Eva Green'},
        ];
        assignmentsData = [
          {'id': 'A001', 'title': 'Quadratic Equations', 'maxScore': 100},
          {'id': 'A002', 'title': 'Linear Algebra Quiz', 'maxScore': 50},
          {'id': 'A003', 'title': 'Calculus Homework', 'maxScore': 30},
        ];
        gradesData = [
          {'studentId': '1001', 'assignmentId': 'A001', 'score': 95},
          {'studentId': '1001', 'assignmentId': 'A002', 'score': 48},
          {'studentId': '1002', 'assignmentId': 'A001', 'score': 82},
          {'studentId': '1002', 'assignmentId': 'A002', 'score': 41},
          {'studentId': '1003', 'assignmentId': 'A001', 'score': 78},
          {'studentId': '1003', 'assignmentId': 'A002', 'score': 39},
        ];
        break;
      case '9B':
        studentsData = [
          {'id': '2001', 'name': 'Frank Black'},
          {'id': '2002', 'name': 'Grace Lee'},
          {'id': '2003', 'name': 'Henry Wilson'},
          {'id': '2004', 'name': 'Irene Adams'},
        ];
        assignmentsData = [
          {'id': 'B001', 'title': 'Algebra Basics', 'maxScore': 100},
          {'id': 'B002', 'title': 'Geometry Quiz', 'maxScore': 50},
        ];
        gradesData = [
          {'studentId': '2001', 'assignmentId': 'B001', 'score': 88},
          {'studentId': '2001', 'assignmentId': 'B002', 'score': 46},
          {'studentId': '2002', 'assignmentId': 'B001', 'score': 92},
          {'studentId': '2003', 'assignmentId': 'B002', 'score': 42},
        ];
        break;
      case '8C':
        studentsData = [
          {'id': '3001', 'name': 'Jack Davies'},
          {'id': '3002', 'name': 'Karen Miller'},
          {'id': '3003', 'name': 'Leo Taylor'},
          {'id': '3004', 'name': 'Maria Garcia'},
          {'id': '3005', 'name': 'Noah Wilson'},
          {'id': '3006', 'name': 'Olivia Moore'},
        ];
        assignmentsData = [
          {'id': 'C001', 'title': 'Forces and Motion', 'maxScore': 100},
          {'id': 'C002', 'title': 'Energy Conservation', 'maxScore': 50},
          {'id': 'C003', 'title': 'Physics Lab Report', 'maxScore': 30},
        ];
        gradesData = [
          {'studentId': '3001', 'assignmentId': 'C001', 'score': 90},
          {'studentId': '3002', 'assignmentId': 'C001', 'score': 85},
          {'studentId': '3003', 'assignmentId': 'C002', 'score': 47},
          {'studentId': '3004', 'assignmentId': 'C003', 'score': 28},
        ];
        break;
    }
    
    setState(() {
      _students.addAll(studentsData);
      _assignments.addAll(assignmentsData);
      _grades.addAll(gradesData);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        title: Text(_selectedClass == null 
            ? 'Grading' 
            : 'Grading - ${_selectedClass!['name']}'),
        bottom: _selectedClass != null ? TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Assignments'),
            Tab(text: 'Students'),
            Tab(text: 'Grade Book'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ) : null,
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator(color: _primaryColor))
        : _selectedClass == null 
            ? _buildClassSelectionScreen()
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildAssignmentsTab(),
                  _buildStudentsTab(),
                  _buildGradeBookTab(),
                ],
              ),
      floatingActionButton: _selectedClass != null ? FloatingActionButton(
        onPressed: _addNewGrade,
        backgroundColor: _primaryColor,
        child: const Icon(Icons.add),
        tooltip: 'Add New Grade',
      ) : null,
    );
  }
  
  Widget _buildClassSelectionScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Select a Class to Manage Grades',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textPrimaryColor,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: _classes.length,
            itemBuilder: (context, index) {
              final classData = _classes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                color: _cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: classData['color'],
                    radius: 25,
                    child: Text(
                      classData['id'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    classData['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textPrimaryColor,
                    ),
                  ),
                  subtitle: Text(
                    classData['subject'],
                    style: TextStyle(
                      color: _textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: _primaryColor,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedClass = classData;
                    });
                    _loadDataForClass(classData['id']);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAssignmentsTab() {
    Color classColor = _selectedClass!['color'] ?? _primaryColor;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: classColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedClass!['subject'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assignments: ${_assignments.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondaryColor,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => _selectClass(),
                icon: const Icon(Icons.class_),
                label: const Text('Change Class'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: BorderSide(color: _primaryColor),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _assignments.length,
            itemBuilder: (context, index) {
              final assignment = _assignments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 1,
                color: _cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    assignment['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _textPrimaryColor,
                    ),
                  ),
                  subtitle: Text(
                    'Max Score: ${assignment['maxScore']}',
                    style: TextStyle(
                      color: _textSecondaryColor,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: _primaryColor),
                        onPressed: () => _editAssignment(assignment),
                      ),
                      IconButton(
                        icon: Icon(Icons.visibility, color: _primaryColor),
                        onPressed: () => _viewAssignmentGrades(assignment),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildStudentsTab() {
    Color classColor = _selectedClass!['color'] ?? _primaryColor;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: classColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedClass!['subject'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Students: ${_students.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondaryColor,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => _selectClass(),
                icon: const Icon(Icons.class_),
                label: const Text('Change Class'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: BorderSide(color: _primaryColor),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 1,
                color: _cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: classColor,
                    child: Text(
                      student['name'].substring(0, 1),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    student['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _textPrimaryColor,
                    ),
                  ),
                  subtitle: Text(
                    'ID: ${student['id']}',
                    style: TextStyle(
                      color: _textSecondaryColor,
                    ),
                  ),
                  trailing: _calculateStudentAverage(student['id']),
                  onTap: () => _viewStudentGrades(student),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildGradeBookTab() {
    Color classColor = _selectedClass!['color'] ?? _primaryColor;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: classColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedClass!['subject'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Grade Book',
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondaryColor,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => _selectClass(),
                icon: const Icon(Icons.class_),
                label: const Text('Change Class'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: BorderSide(color: _primaryColor),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                classColor.withOpacity(0.1),
              ),
              columns: [
                DataColumn(
                  label: Text(
                    'Student', 
                    style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimaryColor),
                  )
                ),
                ..._assignments.map((a) => DataColumn(
                  label: Tooltip(
                    message: a['title'],
                    child: Text(
                      a['title'],
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimaryColor),
                    ),
                  ),
                )),
                DataColumn(
                  label: Text(
                    'Average',
                    style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimaryColor),
                  )
                ),
              ],
              rows: _students.map((student) {
                return DataRow(
                  cells: [
                    DataCell(Text(
                      student['name'],
                      style: TextStyle(color: _textPrimaryColor),
                    )),
                    ..._assignments.map((assignment) {
                      final grade = _findGrade(student['id'], assignment['id']);
                      return DataCell(
                        grade != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                              decoration: BoxDecoration(
                                color: _getGradeColor(grade['score'] * 100 / assignment['maxScore']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getGradeColor(grade['score'] * 100 / assignment['maxScore']).withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                '${grade['score']}/${assignment['maxScore']}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _getGradeColor(grade['score'] * 100 / assignment['maxScore']),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const Text('-'),
                        onTap: () {
                          _addOrEditGrade(student, assignment);
                        },
                      );
                    }),
                    DataCell(_calculateStudentAverage(student['id'])),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
  
  Map<String, dynamic>? _findGrade(String studentId, String assignmentId) {
    try {
      return _grades.firstWhere(
        (g) => g['studentId'] == studentId && g['assignmentId'] == assignmentId,
      );
    } catch (e) {
      return null;
    }
  }
  
  Widget _calculateStudentAverage(String studentId) {
    final studentGrades = _grades.where((g) => g['studentId'] == studentId).toList();
    if (studentGrades.isEmpty) return const Text('-');
    
    double sum = 0;
    double maxSum = 0;
    
    for (var grade in studentGrades) {
      final assignment = _assignments.firstWhere(
        (a) => a['id'] == grade['assignmentId'],
        orElse: () => {'maxScore': 100},
      );
      sum += grade['score'];
      maxSum += assignment['maxScore'];
    }
    
    final percentage = (sum / maxSum) * 100;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: _getGradeColor(percentage).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getGradeColor(percentage).withOpacity(0.5),
        ),
      ),
      child: Text(
        '${percentage.toStringAsFixed(1)}%',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _getGradeColor(percentage),
        ),
      ),
    );
  }
  
  Color _getGradeColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
  
  void _selectClass() {
    setState(() {
      _selectedClass = null;
    });
  }
  
  void _editAssignment(Map<String, dynamic> assignment) {
    final titleController = TextEditingController(text: assignment['title']);
    final scoreController = TextEditingController(text: assignment['maxScore'].toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Assignment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Assignment Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: scoreController,
              decoration: const InputDecoration(
                labelText: 'Max Score',
              ),
              keyboardType: TextInputType.number,
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
              final maxScore = int.tryParse(scoreController.text);
              if (titleController.text.isEmpty || maxScore == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields with valid values')),
                );
                return;
              }
              
              setState(() {
                assignment['title'] = titleController.text;
                assignment['maxScore'] = maxScore;
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Assignment updated successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _viewAssignmentGrades(Map<String, dynamic> assignment) {
    final assignmentGrades = _grades
        .where((g) => g['assignmentId'] == assignment['id'])
        .toList();
        
    final studentsWithGrades = _students
        .where((s) => assignmentGrades.any((g) => g['studentId'] == s['id']))
        .toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(assignment['title']),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: studentsWithGrades.length,
            itemBuilder: (context, index) {
              final student = studentsWithGrades[index];
              final grade = _findGrade(student['id'], assignment['id']);
              final percentage = (grade!['score'] / assignment['maxScore']) * 100;
              
              return ListTile(
                title: Text(student['name']),
                subtitle: Text('${grade['score']}/${assignment['maxScore']}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: _getGradeColor(percentage).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getGradeColor(percentage).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getGradeColor(percentage),
                    ),
                  ),
                ),
              );
            },
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
  }
  
  void _viewStudentGrades(Map<String, dynamic> student) {
    final studentGrades = _grades
        .where((g) => g['studentId'] == student['id'])
        .toList();
    
    final assignmentsWithGrades = _assignments
        .where((a) => studentGrades.any((g) => g['assignmentId'] == a['id']))
        .toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Grades for ${student['name']}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: assignmentsWithGrades.length,
            itemBuilder: (context, index) {
              final assignment = assignmentsWithGrades[index];
              final grade = _findGrade(student['id'], assignment['id']);
              final percentage = (grade!['score'] / assignment['maxScore']) * 100;
              
              return ListTile(
                title: Text(assignment['title']),
                subtitle: Text('${grade['score']}/${assignment['maxScore']}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: _getGradeColor(percentage).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getGradeColor(percentage).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getGradeColor(percentage),
                    ),
                  ),
                ),
              );
            },
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
  }
  
  void _addNewGrade() {
    if (_students.isEmpty || _assignments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No students or assignments available')),
      );
      return;
    }
    
    Map<String, dynamic>? selectedStudent;
    Map<String, dynamic>? selectedAssignment;
    final scoreController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Add New Grade'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Map<String, dynamic>>(
                  decoration: const InputDecoration(
                    labelText: 'Student',
                  ),
                  value: selectedStudent,
                  items: _students.map((student) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: student,
                      child: Text(student['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedStudent = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Map<String, dynamic>>(
                  decoration: const InputDecoration(
                    labelText: 'Assignment',
                  ),
                  value: selectedAssignment,
                  items: _assignments.map((assignment) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: assignment,
                      child: Text(assignment['title']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedAssignment = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: scoreController,
                  decoration: InputDecoration(
                    labelText: 'Score',
                    hintText: selectedAssignment != null 
                      ? 'Max: ${selectedAssignment!['maxScore']}' 
                      : 'Enter score',
                  ),
                  keyboardType: TextInputType.number,
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
                  if (selectedStudent == null || selectedAssignment == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select student and assignment')),
                    );
                    return;
                  }
                  
                  final score = double.tryParse(scoreController.text);
                  if (score == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid score')),
                    );
                    return;
                  }
                  
                  if (score < 0 || score > selectedAssignment!['maxScore']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Score must be between 0 and ${selectedAssignment!['maxScore']}')),
                    );
                    return;
                  }
                  
                  final existingGrade = _findGrade(
                    selectedStudent!['id'], 
                    selectedAssignment!['id']
                  );
                  
                  setState(() {
                    if (existingGrade != null) {
                      existingGrade['score'] = score;
                    } else {
                      _grades.add({
                        'studentId': selectedStudent!['id'],
                        'assignmentId': selectedAssignment!['id'],
                        'score': score,
                      });
                    }
                  });
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Grade added successfully')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _addOrEditGrade(Map<String, dynamic> student, Map<String, dynamic> assignment) {
    final textController = TextEditingController();
    final existingGrade = _findGrade(student['id'], assignment['id']);
    if (existingGrade != null) {
      textController.text = existingGrade['score'].toString();
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${student['name']} - ${assignment['title']}'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: 'Score (Max: ${assignment['maxScore']})',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final score = double.tryParse(textController.text);
              if (score == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid score')),
                );
                return;
              }
              
              if (score < 0 || score > assignment['maxScore']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Score must be between 0 and ${assignment['maxScore']}')),
                );
                return;
              }
              
              setState(() {
                if (existingGrade != null) {
                  existingGrade['score'] = score;
                } else {
                  _grades.add({
                    'studentId': student['id'],
                    'assignmentId': assignment['id'],
                    'score': score,
                  });
                }
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Grade updated successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
