import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import 'package:intl/intl.dart';

class GradesScreen extends StatefulWidget {
  final User user;

  const GradesScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _grades = [];
  Map<String, List<Map<String, dynamic>>> _progressData = {};
  
  // Theme colors - matching ScheduleScreen
  late Color _accentColor;
  late List<Color> _gradientColors;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadThemeColors();
    
    // Simulate loading data
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadGradeData();
          _loadProgressData();
        });
      }
    });
  }
  
  void _loadThemeColors() {
    _accentColor = AppTheme.getAccentColor(AppTheme.defaultTheme);
    _gradientColors = AppTheme.getGradientColors(AppTheme.defaultTheme);
  }
  
  void _loadGradeData() {
    // Mock data - in a real app, this would come from an API
    _grades = [
      {
        'subject': 'Mathematics',
        'grade': 'A',
        'percentage': 92.5,
        'feedback': 'Excellent work in algebra and calculus. Continue practicing word problems.',
        'teacher': 'Mr. Johnson',
        'date': DateTime.now().subtract(const Duration(days: 10)),
        'color': Colors.blue,
      },
      {
        'subject': 'Science',
        'grade': 'B+',
        'percentage': 87.0,
        'feedback': 'Good understanding of physics concepts. Lab reports need more detail.',
        'teacher': 'Ms. Garcia',
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'color': Colors.green,
      },
      {
        'subject': 'English Literature',
        'grade': 'A-',
        'percentage': 89.5,
        'feedback': 'Strong analytical essays. Work on incorporating more textual evidence.',
        'teacher': 'Mrs. Williams',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'color': Colors.purple,
      },
      {
        'subject': 'History',
        'grade': 'B',
        'percentage': 85.0,
        'feedback': 'Good understanding of historical events. Add more context in your answers.',
        'teacher': 'Dr. Brown',
        'date': DateTime.now().subtract(const Duration(days: 8)),
        'color': Colors.orange,
      },
      {
        'subject': 'Computer Science',
        'grade': 'A+',
        'percentage': 97.0,
        'feedback': 'Outstanding programming assignments. Excellent problem-solving skills.',
        'teacher': 'Mr. Davis',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'color': Colors.teal,
      },
      {
        'subject': 'Art',
        'grade': 'A',
        'percentage': 91.0,
        'feedback': 'Creative portfolio with strong technique. Experiment with more mediums.',
        'teacher': 'Ms. Wilson',
        'date': DateTime.now().subtract(const Duration(days: 12)),
        'color': Colors.pink,
      },
    ];
  }
  
  void _loadProgressData() {
    // Create simple progress data for each subject
    _progressData = {
      'Mathematics': [
        {'month': 'Sep', 'grade': 85.0},
        {'month': 'Oct', 'grade': 87.0},
        {'month': 'Nov', 'grade': 90.0},
        {'month': 'Dec', 'grade': 92.5},
      ],
      'Science': [
        {'month': 'Sep', 'grade': 82.0},
        {'month': 'Oct', 'grade': 84.0},
        {'month': 'Nov', 'grade': 86.0},
        {'month': 'Dec', 'grade': 87.0},
      ],
      'English Literature': [
        {'month': 'Sep', 'grade': 88.0},
        {'month': 'Oct', 'grade': 86.0},
        {'month': 'Nov', 'grade': 91.0},
        {'month': 'Dec', 'grade': 89.5},
      ],
      'History': [
        {'month': 'Sep', 'grade': 78.0},
        {'month': 'Oct', 'grade': 82.0},
        {'month': 'Nov', 'grade': 84.0},
        {'month': 'Dec', 'grade': 85.0},
      ],
      'Computer Science': [
        {'month': 'Sep', 'grade': 95.0},
        {'month': 'Oct', 'grade': 94.0},
        {'month': 'Nov', 'grade': 96.0},
        {'month': 'Dec', 'grade': 97.0},
      ],
      'Art': [
        {'month': 'Sep', 'grade': 88.0},
        {'month': 'Oct', 'grade': 90.0},
        {'month': 'Nov', 'grade': 93.0},
        {'month': 'Dec', 'grade': 91.0},
      ],
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.getTheme(AppTheme.defaultTheme),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Grades & Progress', style: TextStyle(fontWeight: FontWeight.bold)),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Current Grades'),
              Tab(text: 'Progress Tracking'),
            ],
          ),
        ),
        body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: _accentColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildGradesTab(),
                _buildProgressTab(),
              ],
            ),
      ),
    );
  }

  Widget _buildGradesTab() {
    double gpa = 0;
    for (var grade in _grades) {
      gpa += grade['percentage'] as double;
    }
    gpa = gpa / _grades.length;
    
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    gpa.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current GPA',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${gpa.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _getGradeLetterContainer(_getGradeLetter(gpa)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _grades.length,
            itemBuilder: (context, index) {
              final grade = _grades[index];
              return _buildGradeCard(grade);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildGradeCard(Map<String, dynamic> grade) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (grade['color'] as Color).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.book, color: grade['color'] as Color),
        ),
        title: Text(
          grade['subject'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'Teacher: ${grade['teacher']} • ${DateFormat('MMM dd').format(grade['date'] as DateTime)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(grade['percentage'] as double).toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            _getGradeLetterContainer(grade['grade'] as String),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Teacher Feedback:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    grade['feedback'] as String,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _grades.length,
      itemBuilder: (context, index) {
        final subject = _grades[index];
        return _buildSubjectProgressCard(subject);
      },
    );
  }
  
  Widget _buildSubjectProgressCard(Map<String, dynamic> subject) {
    final subjectName = subject['subject'] as String;
    final data = _progressData[subjectName]!;
    final color = subject['color'] as Color;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.book, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  subjectName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _getGradeLetterContainer(subject['grade'] as String),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Progress Timeline:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildSimpleProgressIndicator(data),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Started at: ${data.first['grade']}%',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  'Current: ${data.last['grade']}%',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  _calculateChange(data),
                  style: TextStyle(
                    fontSize: 12, 
                    color: _getChangeColor(data),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleProgressIndicator(List<Map<String, dynamic>> data) {
    return Row(
      children: List.generate(data.length, (index) {
        final item = data[index];
        final isLast = index == data.length - 1;
        
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 3,
                      color: index == 0 ? Colors.transparent : Colors.grey[300],
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _getColorForGrade(item['grade'] as double),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 2,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 3,
                      color: isLast ? Colors.transparent : Colors.grey[300],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item['month'] as String,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${(item['grade'] as double).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: index == data.length - 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
  
  Color _getColorForGrade(double grade) {
    if (grade >= 90) {
      return Colors.green;
    } else if (grade >= 80) {
      return Colors.blue;
    } else if (grade >= 70) {
      return Colors.orange;
    } else if (grade >= 60) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }
  
  String _calculateChange(List<Map<String, dynamic>> data) {
    final first = data.first['grade'] as double;
    final last = data.last['grade'] as double;
    final change = last - first;
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}%';
  }
  
  Color _getChangeColor(List<Map<String, dynamic>> data) {
    final first = data.first['grade'] as double;
    final last = data.last['grade'] as double;
    final change = last - first;
    if (change > 0) {
      return Colors.green;
    } else if (change < 0) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }
  
  Widget _getGradeLetterContainer(String grade) {
    Color color;
    switch (grade[0]) {
      case 'A':
        color = Colors.green;
        break;
      case 'B':
        color = Colors.blue;
        break;
      case 'C':
        color = Colors.orange;
        break;
      case 'D':
        color = Colors.deepOrange;
        break;
      default:
        color = Colors.red;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        grade,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
  
  String _getGradeLetter(double percentage) {
    if (percentage >= 90) {
      return 'A';
    } else if (percentage >= 80) {
      return 'B';
    } else if (percentage >= 70) {
      return 'C';
    } else if (percentage >= 60) {
      return 'D';
    } else {
      return 'F';
    }
  }
}
