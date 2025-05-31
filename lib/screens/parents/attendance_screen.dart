import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import 'package:intl/intl.dart';

class ParentAttendanceScreen extends StatefulWidget {
  final User user;

  const ParentAttendanceScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ParentAttendanceScreenState createState() => _ParentAttendanceScreenState();
}

class _ParentAttendanceScreenState extends State<ParentAttendanceScreen> {
  bool _isLoading = true;
  late Color _primaryColor;
  late Color _accentColor;
  
  // Student data for the children of the parent
  List<Map<String, dynamic>> _studentsData = [];
  
  // Selected student for viewing attendance
  Map<String, dynamic>? _selectedStudent;
  
  // Selected month for viewing attendance
  int _selectedMonth = DateTime.now().month;
  
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
        'image': 'https://i.pravatar.cc/150?img=1', // Changed to a more reliable image source
        'attendance': '95%',
        'attendanceData': _generateAttendanceData(0.95),
        'monthlyData': [
          {'month': 'Jan', 'percentage': 95, 'present': 19, 'absent': 1, 'late': 0},
          {'month': 'Feb', 'percentage': 90, 'present': 18, 'absent': 2, 'late': 0},
          {'month': 'Mar', 'percentage': 100, 'present': 20, 'absent': 0, 'late': 0},
        ]
      },
      {
        'name': 'Emily Smith',
        'grade': '7th Grade',
        'section': 'B',
        'rollNumber': '2045',
        'image': 'https://i.pravatar.cc/150?img=5', // Changed to a more reliable image source
        'attendance': '92%',
        'attendanceData': _generateAttendanceData(0.92),
        'monthlyData': [
          {'month': 'Jan', 'percentage': 100, 'present': 20, 'absent': 0, 'late': 0},
          {'month': 'Feb', 'percentage': 85, 'present': 17, 'absent': 2, 'late': 1},
          {'month': 'Mar', 'percentage': 92, 'present': 18, 'absent': 1, 'late': 1},
        ]
      },
    ];
  }
  
  List<Map<String, dynamic>> _generateAttendanceData(double attendanceRate) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final result = <Map<String, dynamic>>[];
    
    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(now.year, now.month, i);
      
      // Skip future dates
      if (day.isAfter(now)) {
        continue;
      }
      
      // Skip weekends (6 = Saturday, 7 = Sunday)
      if (day.weekday >= 6) {
        continue;
      }
      
      // Randomly determine if absent based on attendance rate
      final isAbsent = i % (1 / (1 - attendanceRate)) == 0;
      final isLate = !isAbsent && i % 15 == 0; // Occasionally late
      
      result.add({
        'date': day,
        'status': isAbsent ? 'Absent' : (isLate ? 'Late' : 'Present'),
        'color': isAbsent ? Colors.red : (isLate ? Colors.orange : Colors.green),
      });
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.getTheme(AppTheme.defaultTheme),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white),
              const SizedBox(width: 10),
              const Text('Attendance Records', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    ? _buildAttendanceDetails()
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
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: isSelected ? _primaryColor.withOpacity(0.8) : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              student['attendance'],
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? _primaryColor.withOpacity(0.8) : Colors.grey[600],
                              ),
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
    );
  }
  
  Widget _buildAttendanceDetails() {
    if (_selectedStudent == null) return Container();
    
    final student = _selectedStudent!;
    final attendanceData = student['attendanceData'] as List<Map<String, dynamic>>;
    final monthlyData = student['monthlyData'] as List;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Attendance Card
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
                      student['attendance'],
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
                          'Overall Attendance',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Good Attendance Rate',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Regular school attendance is important',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Monthly Attendance
          const SizedBox(height: 24),
          _buildSectionHeader('Monthly Attendance'),
          const SizedBox(height: 16),
          _buildMonthSelector(),
          const SizedBox(height: 16),
          
          // Monthly Attendance Stats
          _buildMonthlyStatsCards(monthlyData),
          
          // Calendar View
          const SizedBox(height: 24),
          _buildSectionHeader('Daily Attendance'),
          const SizedBox(height: 16),
          _buildCalendarView(attendanceData),
          
          // Recent Records
          const SizedBox(height: 24),
          _buildSectionHeader('Recent Records'),
          const SizedBox(height: 16),
          _buildRecentRecords(attendanceData),
          
          const SizedBox(height: 40),
        ],
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
  
  Widget _buildMonthSelector() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedMonth == index + 1;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMonth = index + 1;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? _primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? _primaryColor : Colors.grey.shade300,
                ),
              ),
              child: Text(
                months[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildMonthlyStatsCards(List monthlyData) {
    // Find the data for the selected month (default to first month if not found)
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final currentMonthName = months[_selectedMonth - 1];
    
    // Fix for the type error - make sure the orElse function matches the expected return type
    // Cast the list to the correct type and use the correct function signature for orElse
    Map<String, Object> currentMonthData = (monthlyData as List<dynamic>).firstWhere(
      (month) => month['month'] == currentMonthName,
      orElse: () => <String, Object>{
        'month': currentMonthName,
        'percentage': 0,
        'present': 0,
        'absent': 0,
        'late': 0
      }
    );
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAttendanceStatCard(
          title: 'Present',
          value: '${currentMonthData['present']}',
          color: Colors.green,
        ),
        _buildAttendanceStatCard(
          title: 'Absent',
          value: '${currentMonthData['absent']}',
          color: Colors.red,
        ),
        _buildAttendanceStatCard(
          title: 'Late',
          value: '${currentMonthData['late']}',
          color: Colors.orange,
        ),
        _buildAttendanceStatCard(
          title: 'Percentage',
          value: '${currentMonthData['percentage']}%',
          color: _primaryColor,
        ),
      ],
    );
  }
  
  Widget _buildAttendanceStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCalendarView(List<Map<String, dynamic>> attendanceData) {
    // Filter data for the selected month
    final filteredData = attendanceData.where((record) {
      final date = record['date'] as DateTime;
      return date.month == _selectedMonth;
    }).toList();
    
    if (filteredData.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 150,
          child: Center(
            child: Text(
              'No attendance data available for this month',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }
    
    // Group by week
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, _selectedMonth, 1);
    int startPadding = firstDayOfMonth.weekday - 1; // 0 is Monday in our calendar
    if (startPadding < 0) startPadding += 7;
    
    // Build calendar grid
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Days of week header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map((day) => 
                Container(
                  width: 36,
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                )
              ).toList(),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
              ),
              itemCount: startPadding + filteredData.length,
              itemBuilder: (context, index) {
                if (index < startPadding) {
                  return Container(); // Empty space for padding days
                }
                
                final dataIndex = index - startPadding;
                if (dataIndex >= filteredData.length) {
                  return Container(); // Empty space for days after the month
                }
                
                final record = filteredData[dataIndex];
                final date = record['date'] as DateTime;
                final status = record['status'] as String;
                final color = record['color'] as Color;
                
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontSize: 14,
                          ),
                        ),
                        Icon(
                          status == 'Present' ? Icons.check_circle :
                          status == 'Absent' ? Icons.cancel :
                          Icons.access_time,
                          color: color,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentRecords(List<Map<String, dynamic>> attendanceData) {
    // Take last 5 records only
    final recentRecords = attendanceData
        .where((record) => (record['date'] as DateTime).month == _selectedMonth)
        .toList()
      ..sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    
    final recordsToShow = recentRecords.take(5).toList();
    
    if (recordsToShow.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 100,
          child: Center(
            child: Text(
              'No recent attendance records',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }
    
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recordsToShow.length,
          itemBuilder: (context, index) {
            final record = recordsToShow[index];
            final date = record['date'] as DateTime;
            final status = record['status'] as String;
            final color = record['color'] as Color;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(
                    status == 'Present' ? Icons.check_circle :
                    status == 'Absent' ? Icons.cancel :
                    Icons.access_time,
                    color: color,
                  ),
                ),
                title: Text(DateFormat('EEEE, MMMM d').format(date)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: status == 'Absent' ? () => _showAbsenceJustificationDialog(context, date) : null,
              ),
            );
          },
        ),
        if (recordsToShow.any((record) => record['status'] == 'Absent'))
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Tap on an absence to provide justification',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic
              ),
            ),
          ),
      ],
    );
  }
  
  // Add method to justify absences
  void _showAbsenceJustificationDialog(BuildContext context, DateTime date) {
    final TextEditingController _reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Justify Absence'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: ${DateFormat('EEEE, MMMM d').format(date)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Please provide reason for absence:'),
              SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                decoration: InputDecoration(
                  hintText: 'E.g. Medical appointment, illness, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
                if (_reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please provide a reason for absence')),
                  );
                  return;
                }
                
                // Here you would normally save the justification to a database
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Justification submitted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            ),
          ],
        );
      },
    );
  }
}
