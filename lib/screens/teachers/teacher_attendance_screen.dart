import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'package:intl/intl.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  final User user;
  final Map<String, dynamic>? selectedClass;

  const TeacherAttendanceScreen({
    Key? key, 
    required this.user, 
    this.selectedClass,
  }) : super(key: key);

  @override
  _TeacherAttendanceScreenState createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  bool _isLoading = true;
  final List<Map<String, dynamic>> _students = [];
  final List<Map<String, dynamic>> _classes = [];
  Map<String, dynamic>? _selectedClass;
  DateTime _selectedDate = DateTime.now();
  
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  
  // Light theme colors to match assignment screen
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
    _selectedClass = widget.selectedClass;
    _loadData();
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
      await _loadStudentsForClass(_selectedClass!['id']);
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _loadStudentsForClass(String classId) async {
    // Clear previous student data
    setState(() {
      _students.clear();
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Load mock student data based on class
    List<Map<String, dynamic>> studentsData = [];
    
    switch (classId) {
      case '10A':
        studentsData = [
          {'id': '1001', 'name': 'Alice Johnson', 'present': true},
          {'id': '1002', 'name': 'Bob Smith', 'present': true},
          {'id': '1003', 'name': 'Carol White', 'present': false},
          {'id': '1004', 'name': 'David Brown', 'present': true},
          {'id': '1005', 'name': 'Eva Green', 'present': true},
        ];
        break;
      case '9B':
        studentsData = [
          {'id': '2001', 'name': 'Frank Black', 'present': false},
          {'id': '2002', 'name': 'Grace Lee', 'present': true},
          {'id': '2003', 'name': 'Henry Wilson', 'present': true},
          {'id': '2004', 'name': 'Irene Adams', 'present': false},
        ];
        break;
      case '8C':
        studentsData = [
          {'id': '3001', 'name': 'Jack Davies', 'present': true},
          {'id': '3002', 'name': 'Karen Miller', 'present': true},
          {'id': '3003', 'name': 'Leo Taylor', 'present': true},
          {'id': '3004', 'name': 'Maria Garcia', 'present': false},
          {'id': '3005', 'name': 'Noah Wilson', 'present': true},
          {'id': '3006', 'name': 'Olivia Moore', 'present': false},
        ];
        break;
    }
    
    setState(() {
      _students.addAll(studentsData);
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
            ? 'Attendance' 
            : 'Attendance - ${_selectedClass!['name']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAttendance,
          ),
        ],
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator(color: _primaryColor))
        : _selectedClass == null 
            ? _buildClassSelectionScreen()
            : _buildAttendanceScreen(),
    );
  }
  
  Widget _buildClassSelectionScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Select a Class to Take Attendance',
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
                color: _cardColor, // Using white background color
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
                    _loadStudentsForClass(classData['id']);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAttendanceScreen() {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: _textSecondaryColor),
                      const SizedBox(width: 8),
                      Text(
                        _dateFormat.format(_selectedDate),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textPrimaryColor,
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
              const SizedBox(height: 16),
              Text(
                'Students: ${_students.length}',
                style: TextStyle(
                  fontSize: 16,
                  color: _textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _students.isEmpty 
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_off,
                      size: 80,
                      color: _textSecondaryColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Students Found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    color: student['present'] 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.red.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: student['present'] 
                          ? Colors.green.withOpacity(0.3) 
                          : Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      leading: CircleAvatar(
                        backgroundColor: student['present'] ? Colors.green : Colors.red,
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
                      trailing: Switch(
                        value: student['present'],
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                        onChanged: (bool value) {
                          setState(() {
                            _students[index]['present'] = value;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: _cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Present: ${_students.where((s) => s['present']).length}/${_students.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Absent: ${_students.where((s) => !s['present']).length}/${_students.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textPrimaryColor,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _saveAttendance,
                icon: const Icon(Icons.save),
                label: const Text('Save Attendance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              surface: _cardColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // In a real app, you would reload attendance data for the selected date
      });
    }
  }
  
  void _selectClass() {
    setState(() {
      _selectedClass = null;
    });
  }

  void _saveAttendance() {
    // Save attendance data to backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Attendance saved successfully'),
        backgroundColor: _primaryColor,
      ),
    );
  }

  void _markAllPresent(bool present) {
    setState(() {
      for (var student in _students) {
        student['present'] = present;
      }
    });
  }

  void _viewAttendanceHistory() {
    if (_selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class first')),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance history will be available soon')),
    );
  }
}
