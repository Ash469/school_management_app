import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final Map<String, Map<String, List<PeriodSchedule>>> _schedules = {};
  
  // List of available classes
  final List<String> _classes = ['9A', '9B', '10A', '10B', '11A', '11B', '12A', '12B'];
  String _selectedClass = '9A';
  
  // Theme colors
  final Color _primaryColor = const Color(0xFF1A237E); // Deep indigo
  final Color _accentColor = const Color(0xFF4CAF50); // Green
  final Color _cardColor = const Color(0xFFE3F2FD); // Light blue
  final Color _dropdownColor = const Color(0xFFFFD54F); // Amber color for dropdown
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _days.length, vsync: this);
    
    // Initialize with sample data for each class
    for (var day in _days) {
      _schedules[day] = {};
      
      for (var className in _classes) {
        if (day == 'Monday') {
          if (className == '9A') {
            _schedules[day]![className] = [
              PeriodSchedule(period: 1, startTime: '8:00 AM', endTime: '9:00 AM', subject: 'Physics', teacher: 'Dr. Brown', classGroup: className),
              PeriodSchedule(period: 2, startTime: '9:10 AM', endTime: '10:10 AM', subject: 'English', teacher: 'Ms. Smith', classGroup: className),
              PeriodSchedule(period: 3, startTime: '10:20 AM', endTime: '11:20 AM', subject: 'Geography', teacher: 'Mr. Thomas', classGroup: className),
              PeriodSchedule(period: 4, startTime: '11:30 AM', endTime: '12:30 PM', subject: 'History', teacher: 'Mrs. Davis', classGroup: className),
            ];
          } else if (className == '9B') {
            _schedules[day]![className] = [
              PeriodSchedule(period: 1, startTime: '8:00 AM', endTime: '9:00 AM', subject: 'Chemistry', teacher: 'Dr. Wilson', classGroup: className),
              PeriodSchedule(period: 2, startTime: '9:10 AM', endTime: '10:10 AM', subject: 'Mathematics', teacher: 'Mr. Johnson', classGroup: className),
              PeriodSchedule(period: 3, startTime: '10:20 AM', endTime: '11:20 AM', subject: 'Biology', teacher: 'Ms. Anderson', classGroup: className),
              PeriodSchedule(period: 4, startTime: '11:30 AM', endTime: '12:30 PM', subject: 'Physical Education', teacher: 'Mr. Clark', classGroup: className),
            ];
          } else {
            _schedules[day]![className] = _createDefaultSchedule(className);
          }
        } else if (day == 'Tuesday') {
          if (className == '9A') {
            _schedules[day]![className] = [
              PeriodSchedule(period: 1, startTime: '8:00 AM', endTime: '9:00 AM', subject: 'Mathematics', teacher: 'Mr. Johnson', classGroup: className),
              PeriodSchedule(period: 2, startTime: '9:10 AM', endTime: '10:10 AM', subject: 'Chemistry', teacher: 'Dr. Wilson', classGroup: className),
              PeriodSchedule(period: 3, startTime: '10:20 AM', endTime: '11:20 AM', subject: 'Biology', teacher: 'Ms. Anderson', classGroup: className),
              PeriodSchedule(period: 4, startTime: '11:30 AM', endTime: '12:30 PM', subject: 'Computer Science', teacher: 'Mrs. Evans', classGroup: className),
            ];
          } else if (className == '9B') {
            _schedules[day]![className] = [
              PeriodSchedule(period: 1, startTime: '8:00 AM', endTime: '9:00 AM', subject: 'Physics', teacher: 'Dr. Brown', classGroup: className),
              PeriodSchedule(period: 2, startTime: '9:10 AM', endTime: '10:10 AM', subject: 'English', teacher: 'Ms. Smith', classGroup: className),
              PeriodSchedule(period: 3, startTime: '10:20 AM', endTime: '11:20 AM', subject: 'History', teacher: 'Mrs. Davis', classGroup: className),
              PeriodSchedule(period: 4, startTime: '11:30 AM', endTime: '12:30 PM', subject: 'Geography', teacher: 'Mr. Thomas', classGroup: className),
            ];
          } else {
            _schedules[day]![className] = _createDefaultSchedule(className);
          }
        } else {
          _schedules[day]![className] = _createDefaultSchedule(className);
        }
      }
    }
  }

  List<PeriodSchedule> _createDefaultSchedule(String className) {
    return [
      PeriodSchedule(period: 1, startTime: '8:00 AM', endTime: '9:00 AM', subject: '', teacher: '', classGroup: className),
      PeriodSchedule(period: 2, startTime: '9:10 AM', endTime: '10:10 AM', subject: '', teacher: '', classGroup: className),
      PeriodSchedule(period: 3, startTime: '10:20 AM', endTime: '11:20 AM', subject: '', teacher: '', classGroup: className),
      PeriodSchedule(period: 4, startTime: '11:30 AM', endTime: '12:30 PM', subject: '', teacher: '', classGroup: className),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Text('Schedule Management', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: _accentColor,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: _days.map((day) => Tab(text: day)).toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Schedule',
            onPressed: _shareSchedule,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Period',
            onPressed: () => _addEditPeriod(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('Select Class: ', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _primaryColor, width: 1),
                    color: _dropdownColor,
                  ),
                  child: DropdownButton<String>(
                    value: _selectedClass,
                    icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
                    underline: Container(),
                    isDense: true,
                    dropdownColor: _dropdownColor,
                    items: _classes.map((String className) {
                      return DropdownMenuItem<String>(
                        value: className,
                        child: Text(className, style: TextStyle(
                          fontWeight: _selectedClass == className ? FontWeight.bold : FontWeight.normal,
                          color: _primaryColor,
                          fontSize: 16,
                        )),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedClass = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _days.map((day) {
                return _buildDaySchedule(day, _selectedClass);
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.save),
        label: const Text('Save'),
        backgroundColor: _accentColor,
        onPressed: _saveSchedule,
        tooltip: 'Save Schedule',
      ),
    );
  }

  Widget _buildDaySchedule(String day, String className) {
    final classSchedule = _schedules[day]?[className] ?? [];
    
    if (classSchedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No schedule for this day and class',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Period'),
              onPressed: () => _addEditPeriod(context, day: day, className: className),
            ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: classSchedule.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final schedule = classSchedule[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _primaryColor.withOpacity(0.2), width: 1),
          ),
          color: _cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Period ${schedule.period}', 
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Colors.white,
                          fontSize: 16
                        )
                      ),
                      const Spacer(),
                      Text(
                        '${schedule.startTime} - ${schedule.endTime}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  title: Text(
                    schedule.subject.isEmpty ? "No Subject Assigned" : schedule.subject,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          blurRadius: 1.0,
                          color: Colors.grey.withOpacity(0.5),
                          offset: const Offset(0.5, 0.5),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, size: 18, color: Colors.indigo),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Teacher: ${schedule.teacher.isEmpty ? "Not Assigned" : schedule.teacher}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.class_, size: 18, color: Colors.indigo),
                            const SizedBox(width: 8),
                            Text(
                              'Class: ${schedule.classGroup}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: _accentColor),
                        onPressed: () => _addEditPeriod(context, day: day, existingSchedule: schedule, className: className),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmDeletePeriod(day, className, index),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeletePeriod(String day, String className, int index) {
    final schedule = _schedules[day]![className]![index];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Period'),
        content: Text('Are you sure you want to delete Period ${schedule.period}: ${schedule.subject}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () {
              _deletePeriod(day, className, index);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
  
  void _addEditPeriod(BuildContext context, {String? day, PeriodSchedule? existingSchedule, String? className}) {
    final currentDay = day ?? _days[_tabController.index];
    final currentClass = className ?? _selectedClass;
    final isEditing = existingSchedule != null;
    
    final periodController = TextEditingController(text: isEditing ? existingSchedule.period.toString() : '');
    final startTimeController = TextEditingController(text: isEditing ? existingSchedule.startTime : '');
    final endTimeController = TextEditingController(text: isEditing ? existingSchedule.endTime : '');
    final subjectController = TextEditingController(text: isEditing ? existingSchedule.subject : '');
    final teacherController = TextEditingController(text: isEditing ? existingSchedule.teacher : '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Period' : 'Add Period'),
        titleTextStyle: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: periodController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Period Number',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: startTimeController,
                decoration: InputDecoration(
                  labelText: 'Start Time',
                  prefixIcon: const Icon(Icons.timer),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final time = await showTimePicker(
                    context: context, 
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    startTimeController.text = _formatTimeOfDay(time);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: endTimeController,
                decoration: InputDecoration(
                  labelText: 'End Time',
                  prefixIcon: const Icon(Icons.timer_off),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final time = await showTimePicker(
                    context: context, 
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    endTimeController.text = _formatTimeOfDay(time);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  prefixIcon: const Icon(Icons.book),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: teacherController,
                decoration: InputDecoration(
                  labelText: 'Teacher',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.class_),
                    const SizedBox(width: 8),
                    Text(
                      'Class: $currentClass', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
            child: Text(isEditing ? 'Update' : 'Add'),
            onPressed: () {
              // Validate inputs
              if (periodController.text.isEmpty ||
                  startTimeController.text.isEmpty ||
                  endTimeController.text.isEmpty ||
                  subjectController.text.isEmpty ||
                  teacherController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields'))
                );
                return;
              }
              
              final newSchedule = PeriodSchedule(
                period: int.parse(periodController.text),
                startTime: startTimeController.text,
                endTime: endTimeController.text,
                subject: subjectController.text,
                teacher: teacherController.text,
                classGroup: currentClass,
              );
              
              setState(() {
                if (isEditing) {
                  final index = _schedules[currentDay]![currentClass]!.indexOf(existingSchedule);
                  _schedules[currentDay]![currentClass]![index] = newSchedule;
                } else {
                  _schedules[currentDay]![currentClass]!.add(newSchedule);
                  // Sort by period
                  _schedules[currentDay]![currentClass]!.sort((a, b) => a.period.compareTo(b.period));
                }
              });
              
              Navigator.of(context).pop();
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEditing ? 'Period updated successfully!' : 'Period added successfully!'),
                  backgroundColor: _accentColor,
                )
              );
            },
          ),
        ],
      ),
      );
  }

  void _deletePeriod(String day, String className, int index) {
    setState(() {
      _schedules[day]![className]!.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Period deleted successfully!'),
        backgroundColor: Colors.redAccent,
      )
    );
  }
  
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute < 10 ? '0${time.minute}' : time.minute;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
  
  void _shareSchedule() {
    final currentDay = _days[_tabController.index];
    final classSchedule = _schedules[currentDay]?[_selectedClass] ?? [];
    
    if (classSchedule.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No schedule to share'))
      );
      return;
    }
    
    String scheduleText = 'Schedule for Class $_selectedClass on $currentDay:\n\n';
    for (var schedule in classSchedule) {
      scheduleText += 'Period ${schedule.period} (${schedule.startTime} - ${schedule.endTime}):\n'
          '- Subject: ${schedule.subject}\n'
          '- Teacher: ${schedule.teacher}\n\n';
    }
    
    Share.share(scheduleText, subject: '$currentDay Schedule for Class $_selectedClass');
  }

  void _saveSchedule() {
    // In a real app, this would save to a database or cloud service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Schedule saved successfully!'),
          ],
        ),
        backgroundColor: _accentColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      )
    );
  }
}

class PeriodSchedule {
  final int period;
  final String startTime;
  final String endTime;
  final String subject;
  final String teacher;
  final String classGroup;
  
  PeriodSchedule({
    required this.period,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.teacher,
    required this.classGroup,
  });
}
