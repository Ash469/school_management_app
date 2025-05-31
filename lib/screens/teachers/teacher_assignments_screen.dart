import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'package:intl/intl.dart';

class TeacherAssignmentsScreen extends StatefulWidget {
  final User user;
  final Map<String, dynamic>? selectedClass;

  const TeacherAssignmentsScreen({
    Key? key, 
    required this.user, 
    this.selectedClass,
  }) : super(key: key);

  @override
  _TeacherAssignmentsScreenState createState() => _TeacherAssignmentsScreenState();
}

class _TeacherAssignmentsScreenState extends State<TeacherAssignmentsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  final List<Map<String, dynamic>> _assignments = [];
  final List<Map<String, dynamic>> _classes = [];
  Map<String, dynamic>? _selectedClass;
  
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  
  // Light theme colors
  final Color _primaryColor = const Color(0xFF5E63B6);
  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _cardColor = Colors.white;
  final Color _textPrimaryColor = const Color(0xFF333333);
  final Color _textSecondaryColor = const Color(0xFF717171);
  
  // Status colors for light theme
  final Map<String, Color> _statusColors = {
    'Active': const Color(0xFF43A047),
    'Scheduled': const Color(0xFF2196F3),
    'Past Due': const Color(0xFFE53935),
    'Closed': const Color(0xFF9E9E9E),
    'Draft': const Color(0xFFFF9800),
  };
  
  // Class colors for light theme
  
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
    if (_selectedClass == null) {
      setState(() {
        _classes.addAll([
          {
            'id': '10A',
            'name': 'Class 10A',
            'subject': 'Mathematics',
            'color': Colors.blue,
          },
          {
            'id': '9B',
            'name': 'Class 9B',
            'subject': 'Mathematics',
            'color': Colors.green,
          },
          {
            'id': '8C',
            'name': 'Class 8C',
            'subject': 'Physics',
            'color': Colors.orange,
          },
        ]);
      });
    }
    
    // Load assignments
    setState(() {
      _assignments.addAll([
        {
          'id': 'A001',
          'title': 'Quadratic Equations Practice',
          'description': 'Complete exercises 1-10 from Chapter 4',
          'classId': '10A',
          'className': 'Class 10A',
          'subject': 'Mathematics',
          'dueDate': DateTime.now().add(const Duration(days: 2)),
          'status': 'Active',
          'submissions': 15,
          'totalStudents': 32,
          'createdAt': DateTime.now().subtract(const Duration(days: 1)),
          'type': 'Homework',
        },
        {
          'id': 'A002',
          'title': 'Linear Algebra Quiz',
          'description': 'Prepare for in-class quiz on linear transformations',
          'classId': '10A',
          'className': 'Class 10A',
          'subject': 'Mathematics',
          'dueDate': DateTime.now().add(const Duration(days: 5)),
          'status': 'Scheduled',
          'submissions': 0,
          'totalStudents': 32,
          'createdAt': DateTime.now(),
          'type': 'Quiz',
        },
        {
          'id': 'A003',
          'title': 'Physics Lab Report',
          'description': 'Write a lab report on the pendulum experiment',
          'classId': '8C',
          'className': 'Class 8C',
          'subject': 'Physics',
          'dueDate': DateTime.now().add(const Duration(days: 7)),
          'status': 'Active',
          'submissions': 8,
          'totalStudents': 30,
          'createdAt': DateTime.now().subtract(const Duration(days: 2)),
          'type': 'Lab Report',
        },
        {
          'id': 'A004',
          'title': 'Algebraic Expressions',
          'description': 'Complete worksheet on factoring expressions',
          'classId': '9B',
          'className': 'Class 9B',
          'subject': 'Mathematics',
          'dueDate': DateTime.now().subtract(const Duration(days: 1)),
          'status': 'Past Due',
          'submissions': 24,
          'totalStudents': 28,
          'createdAt': DateTime.now().subtract(const Duration(days: 8)),
          'type': 'Homework',
        },
      ]);
      _isLoading = false;
    });
  }
  
  List<Map<String, dynamic>> get _filteredAssignments {
    if (_selectedClass == null) {
      return _assignments;
    } else {
      return _assignments.where((a) => a['classId'] == _selectedClass!['id']).toList();
    }
  }
  
  List<Map<String, dynamic>> get _activeAssignments {
    return _filteredAssignments.where((a) => 
      a['status'] == 'Active' || a['status'] == 'Scheduled').toList();
  }
  
  List<Map<String, dynamic>> get _pastAssignments {
    return _filteredAssignments.where((a) => 
      a['status'] == 'Past Due' || a['status'] == 'Closed').toList();
  }
  
  List<Map<String, dynamic>> get _draftAssignments {
    return _filteredAssignments.where((a) => a['status'] == 'Draft').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        title: Text(_selectedClass == null ? 'Assignments' : 
          'Assignments - ${_selectedClass!['name']}'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Past'),
            Tab(text: 'Drafts'),
          ],
        ),
        actions: [
          if (_selectedClass == null)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showClassSelectionDialog,
            ),
        ],
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator(color: _primaryColor))
        : TabBarView(
            controller: _tabController,
            children: [
              _buildAssignmentsList(_activeAssignments),
              _buildAssignmentsList(_pastAssignments),
              _buildAssignmentsList(_draftAssignments),
            ],
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateAssignmentDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Assignment'),
        backgroundColor: _primaryColor,
      ),
    );
  }
  
  Widget _buildAssignmentsList(List<Map<String, dynamic>> assignments) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: _textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Assignments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new assignment to get started',
              style: TextStyle(
                fontSize: 16,
                color: _textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) => _buildAssignmentCard(assignments[index]),
    );
  }
  
  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final Color statusColor = _getStatusColor(assignment['status']);
    final Color cardColor = _getClassColor(assignment['classId']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      color: _cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        onTap: () => _showAssignmentDetails(assignment),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAssignmentIcon(assignment['type']),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          assignment['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: _textSecondaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.class_, size: 16, color: _textSecondaryColor),
                          const SizedBox(width: 4),
                          Text(
                            assignment['className'],
                            style: TextStyle(
                              color: _textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          assignment['status'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: _textSecondaryColor),
                          const SizedBox(width: 4),
                          Text(
                            'Due: ${_dateFormat.format(assignment['dueDate'])}',
                            style: TextStyle(
                              color: _textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.people, size: 16, color: _textSecondaryColor),
                          const SizedBox(width: 4),
                          Text(
                            '${assignment['submissions']}/${assignment['totalStudents']} submitted',
                            style: TextStyle(
                              color: _textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _viewSubmissions(assignment),
                    icon: Icon(Icons.assignment_turned_in, color: _primaryColor),
                    label: Text('View Submissions', style: TextStyle(color: _primaryColor)),
                    style: TextButton.styleFrom(
                      foregroundColor: _primaryColor,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _editAssignment(assignment),
                    icon: Icon(Icons.edit, color: _primaryColor),
                    label: Text('Edit', style: TextStyle(color: _primaryColor)),
                    style: TextButton.styleFrom(
                      foregroundColor: _primaryColor,
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
  
  Color _getStatusColor(String status) {
    return _statusColors[status] ?? Colors.grey;
  }
  
  Color _getClassColor(String classId) {
    if (_selectedClass != null && _selectedClass!['id'] == classId) {
      return _selectedClass!['color'] ?? _primaryColor;
    }
    
    final classData = _classes.firstWhere(
      (c) => c['id'] == classId, 
      orElse: () => {'color': _primaryColor},
    );
    
    return classData['color'] ?? _primaryColor;
  }
  
  IconData _getAssignmentIcon(String type) {
    switch (type) {
      case 'Quiz': return Icons.quiz;
      case 'Lab Report': return Icons.science;
      case 'Project': return Icons.engineering;
      case 'Test': return Icons.sticky_note_2;
      case 'Homework':
      default: return Icons.assignment;
    }
  }
  
  void _showClassSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Class'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _classes.length + 1, // +1 for "All Classes" option
              itemBuilder: (context, index) {
                if (index == 0) {
                  // "All Classes" option
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.all_inclusive),
                    ),
                    title: const Text('All Classes'),
                    selected: _selectedClass == null,
                    onTap: () {
                      setState(() {
                        _selectedClass = null;
                      });
                      Navigator.pop(context);
                    },
                  );
                }
                
                final classData = _classes[index - 1];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: classData['color'],
                    child: Text(
                      classData['id'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(classData['name']),
                  subtitle: Text(classData['subject']),
                  selected: _selectedClass != null && _selectedClass!['id'] == classData['id'],
                  onTap: () {
                    setState(() {
                      _selectedClass = classData;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
  
  void _showAssignmentDetails(Map<String, dynamic> assignment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: _backgroundColor,
          appBar: AppBar(
            title: Text(assignment['title']),
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pop(context);
                  _editAssignment(assignment);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  elevation: 1,
                  color: _cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment['title'],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(assignment['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            assignment['status'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(assignment['status']),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Colors.grey.shade200),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.class_, color: _textSecondaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Class: ${assignment['className']}',
                              style: TextStyle(fontSize: 16, color: _textPrimaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.subject, color: _textSecondaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Subject: ${assignment['subject']}',
                              style: TextStyle(fontSize: 16, color: _textPrimaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: _textSecondaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Due Date: ${_dateFormat.format(assignment['dueDate'])}',
                              style: TextStyle(fontSize: 16, color: _textPrimaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.category, color: _textSecondaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Type: ${assignment['type']}',
                              style: TextStyle(fontSize: 16, color: _textPrimaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          assignment['description'],
                          style: TextStyle(fontSize: 16, color: _textPrimaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  elevation: 1,
                  color: _cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submission Statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: assignment['submissions'] / assignment['totalStudents'],
                          backgroundColor: Colors.grey[200],
                          color: _primaryColor,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${assignment['submissions']} out of ${assignment['totalStudents']} students have submitted',
                          style: TextStyle(color: _textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _viewSubmissions(assignment),
                  icon: const Icon(Icons.assignment_turned_in),
                  label: const Text('View Submissions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      );
  }
  
  void _showCreateAssignmentDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
    String assignmentType = 'Homework';
    Map<String, dynamic>? classForAssignment = _selectedClass;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Create New Assignment',
                style: TextStyle(color: _textPrimaryColor),
              ),
              backgroundColor: _cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter assignment title',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelStyle: TextStyle(color: _textSecondaryColor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter assignment description',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelStyle: TextStyle(color: _textSecondaryColor),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Assignment Type:',
                      style: TextStyle(color: _textSecondaryColor),
                    ),
                    DropdownButton<String>(
                      value: assignmentType,
                      isExpanded: true,
                      items: <String>['Homework', 'Quiz', 'Test', 'Project', 'Lab Report']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            assignmentType = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Class:',
                      style: TextStyle(color: _textSecondaryColor),
                    ),
                    if (_classes.isNotEmpty)
                      DropdownButton<Map<String, dynamic>>(
                        value: classForAssignment,
                        isExpanded: true,
                        hint: const Text('Select a class'),
                        items: _classes.map<DropdownMenuItem<Map<String, dynamic>>>((classData) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: classData,
                            child: Text('${classData['name']} - ${classData['subject']}'),
                          );
                        }).toList(),
                        onChanged: (Map<String, dynamic>? newValue) {
                          setState(() {
                            classForAssignment = newValue;
                          });
                        },
                      )
                    else
                      const Text('No classes available'),
                    const SizedBox(height: 16),
                    Text(
                      'Due Date:',
                      style: TextStyle(color: _textSecondaryColor),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _dateFormat.format(dueDate),
                        style: TextStyle(color: _textPrimaryColor),
                      ),
                      trailing: Icon(Icons.calendar_today, color: _primaryColor),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
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
                        if (picked != null) {
                          setState(() {
                            dueDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: _textSecondaryColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Create'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (titleController.text.isEmpty || 
                        descriptionController.text.isEmpty || 
                        classForAssignment == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields')),
                      );
                      return;
                    }
                    
                    // Add the new assignment
                    setState(() {
                      _assignments.add({
                        'id': 'A00${_assignments.length + 1}',
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'classId': classForAssignment!['id'],
                        'className': classForAssignment!['name'],
                        'subject': classForAssignment!['subject'],
                        'dueDate': dueDate,
                        'status': 'Active',
                        'submissions': 0,
                        'totalStudents': 30, // Mock value
                        'createdAt': DateTime.now(),
                        'type': assignmentType,
                      });
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Assignment created successfully'),
                        backgroundColor: _primaryColor,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }
  
  void _viewSubmissions(Map<String, dynamic> assignment) {
    // Navigate to submissions view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submissions view coming soon')),
    );
  }
  
  void _editAssignment(Map<String, dynamic> assignment) {
    // Show dialog to edit assignment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment editing coming soon')),
    );
  }
}
