import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';

class StudentScheduleScreen extends StatefulWidget {
  final User? user;

  const StudentScheduleScreen({Key? key, this.user}) : super(key: key);

  @override
  _StudentScheduleScreenState createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late Map<DateTime, List<dynamic>> _events;
  late ValueNotifier<List<dynamic>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Theme colors
  late Color _primaryColor;
  late Color _accentColor;
  late Color _tertiaryColor;
  late List<Color> _gradientColors;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();

    // Initialize events
    _events = {};
    _initializeEvents();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));

    // Load theme colors
    _loadThemeColors();
  }

  void _loadThemeColors() {
    _primaryColor = AppTheme.getPrimaryColor(AppTheme.defaultTheme);
    _accentColor = AppTheme.getAccentColor(AppTheme.defaultTheme);
    _tertiaryColor = AppTheme.getTertiaryColor(AppTheme.defaultTheme);
    _gradientColors = AppTheme.getGradientColors(AppTheme.defaultTheme);
  }

  void _initializeEvents() {
    // Add some example events
    final now = DateTime.now();
    
    // Add exams
    _addEvent(now.add(Duration(days: 10)), 'Mid-term Examination', 'Math Exam', Colors.red);
    _addEvent(now.add(Duration(days: 12)), 'Mid-term Examination', 'Science Exam', Colors.red);
    _addEvent(now.add(Duration(days: 14)), 'Mid-term Examination', 'History Exam', Colors.red);
    
    // Add assignment due dates
    _addEvent(now.add(Duration(days: 3)), 'Assignment Due', 'Math Assignment', Colors.orange);
    _addEvent(now.add(Duration(days: 5)), 'Assignment Due', 'Science Lab Report', Colors.orange);
    
    // Add school events
    _addEvent(now.add(Duration(days: 7)), 'School Event', 'Annual Sports Day', Colors.green);
    _addEvent(now.add(Duration(days: 20)), 'School Event', 'Science Fair', Colors.green);
    
    // Add holidays
    _addEvent(now.add(Duration(days: 15)), 'Holiday', 'National Day', Colors.blue);
  }

  void _addEvent(DateTime date, String type, String title, Color color) {
    final dateKey = DateTime(date.year, date.month, date.day);
    if (_events[dateKey] == null) {
      _events[dateKey] = [];
    }
    _events[dateKey]!.add({
      'type': type,
      'title': title,
      'color': color,
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.getTheme(AppTheme.defaultTheme),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
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
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Calendar'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDailySchedule(),
            _buildWeeklySchedule(),
            _buildCalendarView(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySchedule() {
    return Column(
      children: [
        _buildDateSelector(),
        Expanded(
          child: _buildScheduleForDay(_selectedDay),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              setState(() {
                _selectedDay = _selectedDay.subtract(const Duration(days: 1));
              });
            },
            color: _primaryColor,
          ),
          InkWell(
            onTap: () => _selectDate(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    DateFormat('EEEE').format(_selectedDay),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM d, y').format(_selectedDay),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () {
              setState(() {
                _selectedDay = _selectedDay.add(const Duration(days: 1));
              });
            },
            color: _primaryColor,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2023, 1),
      lastDate: DateTime(2025, 12),
    );
    if (picked != null && picked != _selectedDay) {
      setState(() {
        _selectedDay = picked;
      });
    }
  }

  Widget _buildScheduleForDay(DateTime day) {
    // This method would normally fetch the schedule for the specific day
    // For now, we'll use the example data based on the day of week
    
    final weekday = day.weekday;
    List<Map<String, dynamic>> classes = [];
    
    // Generate schedule based on the day of week
    switch (weekday) {
      case DateTime.monday:
        classes = [
          {
            'subject': 'Mathematics',
            'time': '09:00 - 10:00 AM',
            'teacher': 'Mr. Johnson',
            'room': 'Room 101',
            'color': Colors.blue,
          },
          {
            'subject': 'Physics',
            'time': '10:15 - 11:15 AM',
            'teacher': 'Ms. Garcia',
            'room': 'Lab 3',
            'color': Colors.green,
          },
          {
            'subject': 'English Literature',
            'time': '12:00 - 01:00 PM',
            'teacher': 'Mrs. Williams',
            'room': 'Room 203',
            'color': Colors.purple,
          },
          {
            'subject': 'History',
            'time': '02:00 - 03:00 PM',
            'teacher': 'Dr. Brown',
            'room': 'Room 105',
            'color': Colors.orange,
          },
        ];
        break;
      case DateTime.tuesday:
        classes = [
          {
            'subject': 'Biology',
            'time': '09:00 - 10:30 AM',
            'teacher': 'Dr. Martinez',
            'room': 'Lab 2',
            'color': Colors.teal,
          },
          {
            'subject': 'Computer Science',
            'time': '10:45 - 12:15 PM',
            'teacher': 'Mr. Davis',
            'room': 'Computer Lab',
            'color': Colors.indigo,
          },
          {
            'subject': 'Physical Education',
            'time': '01:30 - 03:00 PM',
            'teacher': 'Coach Wilson',
            'room': 'Gymnasium',
            'color': Colors.red,
          },
        ];
        break;
      case DateTime.wednesday:
        classes = [
          {
            'subject': 'Chemistry',
            'time': '09:00 - 10:30 AM',
            'teacher': 'Dr. Smith',
            'room': 'Lab 1',
            'color': Colors.pink,
          },
          {
            'subject': 'Mathematics',
            'time': '10:45 - 12:15 PM',
            'teacher': 'Mr. Johnson',
            'room': 'Room 101',
            'color': Colors.blue,
          },
          {
            'subject': 'Art',
            'time': '01:30 - 03:00 PM',
            'teacher': 'Ms. Taylor',
            'room': 'Art Studio',
            'color': Colors.amber,
          },
        ];
        break;
      case DateTime.thursday:
        classes = [
          {
            'subject': 'English Literature',
            'time': '09:00 - 10:30 AM',
            'teacher': 'Mrs. Williams',
            'room': 'Room 203',
            'color': Colors.purple,
          },
          {
            'subject': 'Geography',
            'time': '10:45 - 12:15 PM',
            'teacher': 'Mr. Thompson',
            'room': 'Room 202',
            'color': Colors.brown,
          },
          {
            'subject': 'Music',
            'time': '01:30 - 03:00 PM',
            'teacher': 'Mrs. Clark',
            'room': 'Music Hall',
            'color': Colors.deepPurple,
          },
        ];
        break;
      case DateTime.friday:
        classes = [
          {
            'subject': 'Physics',
            'time': '09:00 - 10:30 AM',
            'teacher': 'Ms. Garcia',
            'room': 'Lab 3',
            'color': Colors.green,
          },
          {
            'subject': 'History',
            'time': '10:45 - 12:15 PM',
            'teacher': 'Dr. Brown',
            'room': 'Room 105',
            'color': Colors.orange,
          },
          {
            'subject': 'Language',
            'time': '01:30 - 03:00 PM',
            'teacher': 'Mr. Rodriguez',
            'room': 'Room 301',
            'color': Colors.cyan,
          },
        ];
        break;
      case DateTime.saturday:
      case DateTime.sunday:
        // No classes on weekends
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.weekend, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No Classes Scheduled',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enjoy your weekend!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
    }

    if (classes.isEmpty) {
      return const Center(
        child: Text('No classes scheduled for this day'),
      );
    }

    // Get events for this day to show at the top
    final events = _getEventsForDay(day);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show events for this day if any
          if (events.isNotEmpty) ...[
            const Text(
              'Today\'s Events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: event['color'].withOpacity(0.2),
                      child: Icon(
                        _getIconForEventType(event['type']),
                        color: event['color'],
                        size: 20,
                      ),
                    ),
                    title: Text(event['title']),
                    subtitle: Text(event['type']),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
          ],
          
          const Text(
            'Class Schedule',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classItem = classes[index];
              return _buildClassCard(classItem, index);
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconForEventType(String type) {
    switch (type) {
      case 'Mid-term Examination':
        return Icons.edit_document;
      case 'Assignment Due':
        return Icons.assignment;
      case 'School Event':
        return Icons.event;
      case 'Holiday':
        return Icons.celebration;
      default:
        return Icons.event;
    }
  }

  Widget _buildClassCard(Map<String, dynamic> classItem, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: classItem['color'].withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: classItem['color'].withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
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
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(Icons.person, 'Teacher', classItem['teacher']),
                        const SizedBox(height: 8),
                        _infoRow(Icons.room, 'Room', classItem['room']),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      _showClassDetails(context, classItem);
                    },
                    tooltip: 'Class Details',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showClassDetails(BuildContext context, Map<String, dynamic> classItem) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 20),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: classItem['color'].withOpacity(0.2),
                  child: Icon(Icons.class_, color: classItem['color']),
                ),
                title: Text(
                  classItem['subject'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text('${classItem['time']}'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Teacher'),
                subtitle: Text(classItem['teacher']),
              ),
              ListTile(
                leading: const Icon(Icons.room),
                title: const Text('Room'),
                subtitle: Text(classItem['room']),
              ),
              ListTile(
                leading: const Icon(Icons.book),
                title: const Text('Materials Required'),
                subtitle: const Text('Textbook, notebook, calculator'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklySchedule() {
    // Build a weekly view with days of the week
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return Column(
      children: [
        _buildWeekSelector(startOfWeek),
        Expanded(
          child: _buildWeekView(startOfWeek),
        ),
      ],
    );
  }

  Widget _buildWeekSelector(DateTime startOfWeek) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              setState(() {
                _selectedDay = startOfWeek.subtract(const Duration(days: 7));
              });
            },
            color: _primaryColor,
          ),
          Text(
            'Week of ${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d').format(startOfWeek.add(const Duration(days: 6)))}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () {
              setState(() {
                _selectedDay = startOfWeek.add(const Duration(days: 7));
              });
            },
            color: _primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView(DateTime startOfWeek) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 7,
      itemBuilder: (context, index) {
        final day = startOfWeek.add(Duration(days: index));
        return _buildDayCard(day);
      },
    );
  }

  Widget _buildDayCard(DateTime day) {
    // Determine if this is today
    final isToday = day.year == DateTime.now().year && 
                    day.month == DateTime.now().month && 
                    day.day == DateTime.now().day;
    
    // Get the weekday name and date
    final dayName = DateFormat('EEEE').format(day);
    final dateText = DateFormat('MMMM d').format(day);
    
    // Weekend logic
    final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isToday ? 4 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isToday 
              ? Border.all(color: _accentColor, width: 2)
              : null,
        ),
        child: ExpansionTile(
          initiallyExpanded: isToday,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isToday ? _accentColor : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateFormat('E').format(day)[0],
                  style: TextStyle(
                    color: isToday ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isToday ? _accentColor : null,
                    ),
                  ),
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _accentColor, width: 1),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ],
          ),
          children: [
            if (isWeekend)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.weekend, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Text(
                      'No Classes (Weekend)',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              _buildMiniScheduleForDay(day),
            
            // Show events for this day if any
            ..._buildEventsForDay(day),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniScheduleForDay(DateTime day) {
    // Similar to buildScheduleForDay but more compact
    final weekday = day.weekday;
    List<Map<String, dynamic>> classes = [];
    
    // Generate schedule based on the day of week (simplified for brevity)
    switch (weekday) {
      case DateTime.monday:
        classes = [
          {
            'subject': 'Mathematics',
            'time': '09:00 - 10:00 AM',
            'room': 'Room 101',
            'color': Colors.blue,
          },
          {
            'subject': 'Physics',
            'time': '10:15 - 11:15 AM',
            'room': 'Lab 3',
            'color': Colors.green,
          },
          {
            'subject': 'English Literature',
            'time': '12:00 - 01:00 PM',
            'room': 'Room 203',
            'color': Colors.purple,
          },
          // More classes...
        ];
        break;
      case DateTime.tuesday:
        classes = [
          {
            'subject': 'Biology',
            'time': '09:00 - 10:30 AM',
            'room': 'Lab 2',
            'color': Colors.teal,
          },
          {
            'subject': 'Computer Science',
            'time': '10:45 - 12:15 PM',
            'room': 'Computer Lab',
            'color': Colors.indigo,
          },
          // More classes...
        ];
        break;
      // Other weekdays...
      default:
        classes = [];
    }

    if (classes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No classes scheduled for this day'),
      );
    }

    return Column(
      children: classes.map((classItem) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: classItem['color'],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classItem['subject'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${classItem['time']} • ${classItem['room']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  List<Widget> _buildEventsForDay(DateTime day) {
    final events = _getEventsForDay(day);
    if (events.isEmpty) {
      return [];
    }

    return [
      const Divider(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: const [
            Icon(Icons.event, size: 16),
            SizedBox(width: 8),
            Text(
              'Events & Deadlines',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      ...events.map((event) => ListTile(
        leading: CircleAvatar(
          backgroundColor: event['color'].withOpacity(0.2),
          radius: 16,
          child: Icon(
            _getIconForEventType(event['type']),
            color: event['color'],
            size: 16,
          ),
        ),
        title: Text(event['title'], style: const TextStyle(fontSize: 14)),
        subtitle: Text(event['type'], style: const TextStyle(fontSize: 12)),
        dense: true,
      )).toList(),
    ];
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2025, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          eventLoader: _getEventsForDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _selectedEvents.value = _getEventsForDay(selectedDay);
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: _tertiaryColor,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: _primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: _accentColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            formatButtonTextStyle: TextStyle(color: _primaryColor),
            titleTextStyle: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: _accentColor),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('MMMM d, y').format(_selectedDay)} Events',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _accentColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<List<dynamic>>(
            valueListenable: _selectedEvents,
            builder: (context, events, _) {
              if (events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 70,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No events for this day',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: event['color'].withOpacity(0.2),
                        child: Icon(
                          _getIconForEventType(event['type']),
                          color: event['color'],
                        ),
                      ),
                      title: Text(event['title']),
                      subtitle: Text(event['type']),
                      onTap: () {
                        _showEventDetails(context, event);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEventDetails(BuildContext context, Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event['title']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${event['type']}'),
              const SizedBox(height: 8),
              Text('Date: ${DateFormat('MMMM d, y').format(_selectedDay)}'),
              const SizedBox(height: 8),
              const Text('Details: More information about this event would appear here.'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close', style: TextStyle(color: _accentColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
