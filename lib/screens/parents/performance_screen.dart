import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';

class ParentPerformanceScreen extends StatefulWidget {
  final User user;

  const ParentPerformanceScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ParentPerformanceScreenState createState() => _ParentPerformanceScreenState();
}

class _ParentPerformanceScreenState extends State<ParentPerformanceScreen> {
  bool _isLoading = true;
  late Color _primaryColor;
  late Color _accentColor;
  
  // Student data for the children of the parent
  List<Map<String, dynamic>> _studentsData = [];
  
  // Selected student for viewing detailed performance
  Map<String, dynamic>? _selectedStudent;
  
  @override
  void initState() {
    super.initState();
    _loadThemeColors();
    _loadStudentsData();
    
    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_studentsData.isNotEmpty) {
            _selectedStudent = _studentsData[0];
          }
        });
      }
    });
  }
  
  void _loadThemeColors() {
    _primaryColor = AppTheme.getPrimaryColor(AppTheme.defaultTheme);
    _accentColor = AppTheme.getAccentColor(AppTheme.defaultTheme);
  }
  
  void _loadStudentsData() {
    // Simulated data for parent's children
    _studentsData = [
      {
        'name': 'John Smith',
        'grade': '10th Grade',
        'section': 'A',
        'rollNumber': '1023',
        'image': 'https://randomuser.me/api/portraits/children/1.jpg',
        'gpa': '3.8',
        'subjects': [
          {'name': 'Mathematics', 'grade': 'A', 'score': 92, 'color': Colors.blue},
          {'name': 'Science', 'grade': 'A-', 'score': 88, 'color': Colors.green},
          {'name': 'English', 'grade': 'B+', 'score': 85, 'color': Colors.purple},
          {'name': 'History', 'grade': 'A', 'score': 90, 'color': Colors.orange},
          {'name': 'Physical Education', 'grade': 'A+', 'score': 95, 'color': Colors.teal},
        ]
      },
      {
        'name': 'Emily Smith',
        'grade': '7th Grade',
        'section': 'B',
        'rollNumber': '2045',
        'image': 'https://randomuser.me/api/portraits/children/2.jpg',
        'gpa': '3.9',
        'subjects': [
          {'name': 'Mathematics', 'grade': 'A+', 'score': 96, 'color': Colors.blue},
          {'name': 'Science', 'grade': 'A', 'score': 91, 'color': Colors.green},
          {'name': 'English', 'grade': 'A', 'score': 90, 'color': Colors.purple},
          {'name': 'History', 'grade': 'B+', 'score': 87, 'color': Colors.orange},
          {'name': 'Art', 'grade': 'A+', 'score': 98, 'color': Colors.pink},
        ]
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.getTheme(AppTheme.defaultTheme),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.grade, color: Colors.white),
              const SizedBox(width: 10),
              const Text('Performance Reports', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _accentColor))
          : Column(
              children: [
                _buildStudentSelector(),
                Expanded(
                  child: _selectedStudent != null
                    ? _buildPerformanceDetails()
                    : Center(child: Text('No student selected')),
                ),
              ],
            ),
      ),
    );
  }
  
  Widget _buildStudentSelector() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _studentsData.length,
        itemBuilder: (context, index) {
          final student = _studentsData[index];
          final isSelected = _selectedStudent == student;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStudent = student;
              });
            },
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? _primaryColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                border: Border.all(
                  color: isSelected ? _primaryColor : Colors.transparent,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(student['image']),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          student['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? _primaryColor : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          student['grade'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? _primaryColor.withOpacity(0.8) : Colors.grey[600],
                          ),
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
    );
  }
  
  Widget _buildPerformanceDetails() {
    if (_selectedStudent == null) return Container();
    
    final student = _selectedStudent!;
    final subjects = student['subjects'] as List;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GPA Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, _primaryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Text(
                      student['gpa'],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
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
                          'Current GPA',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Excellent Performance',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Keep up the good work!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.flag, color: Colors.white),
                    tooltip: 'Set Academic Goals',
                    onPressed: () => _showSetGoalsDialog(context),
                  ),
                ],
              ),
            ),
          ),
          
          // Subject Grades
          const SizedBox(height: 24),
          _buildSectionHeader('Subject Grades'),
          const SizedBox(height: 16),
          
          for (var subject in subjects)
            _buildSubjectCard(subject),
            
          // Academic Progress
          const SizedBox(height: 24),
          _buildSectionHeader('Academic Progress'),
          const SizedBox(height: 16),
          _buildProgressChart(),
          
          // Teacher's Remarks
          const SizedBox(height: 24),
          _buildSectionHeader('Teacher\'s Remarks'),
          const SizedBox(height: 16),
          _buildTeacherRemarks(),
          
          // Request report button
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.download),
              label: Text('Download Detailed Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => _showReportDownloadDialog(context),
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  void _showSetGoalsDialog(BuildContext context) {
    if (_selectedStudent == null) return;
    
    final student = _selectedStudent!;
    final TextEditingController _goalController = TextEditingController(text: "3.9");
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Academic Goals'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current GPA: ${student['gpa']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Target GPA for this semester:'),
              SizedBox(height: 8),
              TextField(
                controller: _goalController,
                decoration: InputDecoration(
                  hintText: 'E.g. 4.0',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Here you would normally save the goal to a database
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Academic goal set successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Set Goal'),
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            ),
          ],
        );
      },
    );
  }
  
  void _showReportDownloadDialog(BuildContext context) {
    if (_selectedStudent == null) return;
    
    final student = _selectedStudent!;
    
    // Simulate downloading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                ),
              ),
              SizedBox(width: 16),
              Text('Downloading Report'),
            ],
          ),
          content: Text('Please wait while we prepare the detailed report for ${student['name']}...'),
        );
      },
    );
    
    // Simulate download completion after a delay
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 16),
                Text('Download Complete'),
              ],
            ),
            content: Text('The detailed academic report for ${student['name']} has been downloaded successfully.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Open Report'),
                style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildTeacherRemarks() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _primaryColor.withOpacity(0.2),
                  child: Icon(Icons.person, color: _primaryColor),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mrs. Jennifer Wilson',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Class Teacher',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              _selectedStudent!['name'] + ' is showing excellent progress in most subjects. '
              'Particularly strong in Mathematics and Science. Could improve participation '
              'in group discussions. Overall, a dedicated student with good potential.',
              style: TextStyle(
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {
                  // Schedule a meeting with teacher
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: BorderSide(color: _primaryColor),
                ),
                child: const Text('Schedule a Meeting'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressChart() {
    // This would be a placeholder for an actual chart
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Progress Chart will be displayed here',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    final subjectName = subject['name'] as String;
    final subjectGrade = subject['grade'] as String;
    final subjectScore = subject['score'] as int;
    final subjectColor = subject['color'] as Color;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: subjectColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.book, color: subjectColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: subjectScore / 100,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: subjectColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Score: $subjectScore%',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: subjectColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: subjectColor, width: 1),
              ),
              child: Text(
                subjectGrade,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: subjectColor,
                ),
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
            color: _accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
