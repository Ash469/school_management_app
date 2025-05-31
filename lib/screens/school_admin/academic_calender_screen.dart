import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CalendarEvent {
  final String title;
  final String description;
  final DateTime date;
  final EventCategory category;
  final bool isFullDay;
  
  CalendarEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    this.isFullDay = true,
  });
}

enum EventCategory {
  holiday,
  exam,
  schoolEvent,
  academicActivity,
  other,
}

extension EventCategoryExtension on EventCategory {
  String get displayName {
    switch (this) {
      case EventCategory.holiday:
        return 'Holiday';
      case EventCategory.exam:
        return 'Exam';
      case EventCategory.schoolEvent:
        return 'School Event';
      case EventCategory.academicActivity:
        return 'Academic Activity';
      case EventCategory.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case EventCategory.holiday:
        return const Color(0xFF43A047); // Deeper green
      case EventCategory.exam:
        return const Color(0xFFE53935); // Deeper red
      case EventCategory.schoolEvent:
        return const Color(0xFF8E24AA); // Rich purple
      case EventCategory.academicActivity:
        return const Color(0xFF1E88E5); // Rich blue
      case EventCategory.other:
        return const Color(0xFF757575); // Darker grey
    }
  }

  IconData get icon {
    switch (this) {
      case EventCategory.holiday:
        return Icons.beach_access;
      case EventCategory.exam:
        return Icons.assignment;
      case EventCategory.schoolEvent:
        return Icons.event;
      case EventCategory.academicActivity:
        return Icons.school;
      case EventCategory.other:
        return Icons.category;
    }
  }
}

class AcademicCalenderScreen extends StatefulWidget {
  const AcademicCalenderScreen({Key? key}) : super(key: key);

  @override
  State<AcademicCalenderScreen> createState() => _AcademicCalenderScreenState();
}

class _AcademicCalenderScreenState extends State<AcademicCalenderScreen> {
  late final ValueNotifier<List<CalendarEvent>> _selectedEvents;
  final Set<EventCategory> _selectedCategories = Set.from(EventCategory.values);
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Example academic calendar data
  final Map<DateTime, List<CalendarEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    
    // Initialize with sample data
    _initializeEvents();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void _initializeEvents() {
    // Current academic year
    final int currentYear = DateTime.now().year;
    final DateTime academicStartDate = DateTime(currentYear, 7, 1); // Academic year starts from July
    final DateTime academicEndDate = DateTime(currentYear + 1, 6, 30); // Ends in June next year
    
    // Holidays
    _addEvent(
      DateTime(currentYear, 8, 15),
      'Independence Day',
      'National Holiday - School Closed',
      EventCategory.holiday,
    );
    _addEvent(
      DateTime(currentYear, 10, 2),
      'Gandhi Jayanti',
      'National Holiday - School Closed',
      EventCategory.holiday,
    );
    _addEvent(
      DateTime(currentYear, 12, 25),
      'Christmas',
      'Holiday - School Closed',
      EventCategory.holiday,
    );
    _addEvent(
      DateTime(currentYear + 1, 1, 1),
      'New Year\'s Day',
      'Holiday - School Closed',
      EventCategory.holiday,
    );
    _addEvent(
      DateTime(currentYear + 1, 1, 26),
      'Republic Day',
      'National Holiday - School Closed',
      EventCategory.holiday,
    );
    
    // Exams
    _addEvent(
      DateTime(currentYear, 9, 15),
      'First Unit Test',
      'Unit test for all classes',
      EventCategory.exam,
    );
    _addEvent(
      DateTime(currentYear, 12, 1),
      'Mid-Term Examination',
      'Mid-term examination for all classes',
      EventCategory.exam,
    );
    _addEvent(
      DateTime(currentYear + 1, 3, 1),
      'Final Examination',
      'Final examination for all classes',
      EventCategory.exam,
    );
    
    // School Events
    _addEvent(
      DateTime(currentYear, 9, 5),
      'Teacher\'s Day',
      'Celebration and cultural program',
      EventCategory.schoolEvent,
    );
    _addEvent(
      DateTime(currentYear, 11, 14),
      'Children\'s Day',
      'Special assembly and activities',
      EventCategory.schoolEvent,
    );
    _addEvent(
      DateTime(currentYear, 12, 20),
      'Annual Day',
      'Annual function and prize distribution',
      EventCategory.schoolEvent,
    );
    _addEvent(
      DateTime(currentYear + 1, 2, 14),
      'Sports Day',
      'Annual sports competition',
      EventCategory.schoolEvent,
    );
    
    // Academic Activities
    _addEvent(
      DateTime(currentYear, 7, 1),
      'First Day of School',
      'Welcome assembly and orientation',
      EventCategory.academicActivity,
    );
    _addEvent(
      DateTime(currentYear, 10, 15),
      'Science Exhibition',
      'Annual science exhibition',
      EventCategory.academicActivity,
    );
    _addEvent(
      DateTime(currentYear + 1, 4, 15),
      'Result Day',
      'Annual results announcement',
      EventCategory.academicActivity,
    );
    _addEvent(
      DateTime(currentYear + 1, 6, 30),
      'Last Day of Academic Year',
      'Farewell and summer vacation begins',
      EventCategory.academicActivity,
    );
  }

  void _addEvent(DateTime date, String title, String description, EventCategory category) {
    final DateTime dateKey = DateTime(date.year, date.month, date.day);
    
    if (_events[dateKey] == null) {
      _events[dateKey] = [];
    }
    
    _events[dateKey]!.add(
      CalendarEvent(
        title: title,
        description: description,
        date: date,
        category: category,
      ),
    );
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    final DateTime dateKey = DateTime(day.year, day.month, day.day);
    final events = _events[dateKey] ?? [];
    
    // Filter events based on selected categories
    return events.where((event) => _selectedCategories.contains(event.category)).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _toggleCategory(EventCategory category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
      
      if (_selectedDay != null) {
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      }
    });
  }

  // Single implementation of the build method
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Calendar'),
        elevation: 2.0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: theme.scaffoldBackgroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => _buildCategoryFilters(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareCalendar,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.primaryColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: Column(
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.all(8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(DateTime.now().year - 1, 1, 1),
                  lastDay: DateTime.utc(DateTime.now().year + 2, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) => _getEventsForDay(day),
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: _onDaySelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    markerDecoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    outsideDaysVisible: false,
                    markersMaxCount: 3,
                    weekendTextStyle: TextStyle(color: theme.primaryColor.withOpacity(0.7)),
                    holidayTextStyle: const TextStyle(color: Color(0xFFE53935)),
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonDecoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    formatButtonTextStyle: TextStyle(color: theme.primaryColor),
                    leftChevronIcon: Icon(Icons.chevron_left, color: theme.primaryColor),
                    rightChevronIcon: Icon(Icons.chevron_right, color: theme.primaryColor),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return const SizedBox.shrink();
                      
                      // Group events by category for the markers
                      final Map<EventCategory, int> categoryCount = {};
                      for (final event in events as List<CalendarEvent>) {
                        categoryCount[event.category] = (categoryCount[event.category] ?? 0) + 1;
                      }
                      
                      // Show dots instead of circles with numbers
                      return Positioned(
                        bottom: 2,
                        right: 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: categoryCount.keys.take(3).map((category) {
                            return Container(
                              margin: const EdgeInsets.only(left: 1),
                              height: 5,
                              width: 5,
                              decoration: BoxDecoration(
                                color: category.color,
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildCategoryLegend(),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Icon(Icons.event_note, color: theme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _selectedDay != null 
                        ? 'Events on ${DateFormat('MMMM dd, yyyy').format(_selectedDay!)}'
                        : 'No date selected',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Divider(height: 1, thickness: 1),
            Expanded(
              child: ValueListenableBuilder<List<CalendarEvent>>(
                valueListenable: _selectedEvents,
                builder: (context, events, _) {
                  return events.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No events for this day',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: event.category.color.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _showEventDetails(event),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: event.category.color.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            event.category.icon,
                                            color: event.category.color,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                event.description,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: event.category.color.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      event.category.displayName,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: event.category.color,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              DateFormat('MMM dd').format(event.date),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat('EEEE').format(event.date),
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: theme.primaryColor,
        elevation: 4,
        child: const Icon(Icons.add),
        tooltip: 'Add Event',
      ),
    );
  }

  Widget _buildCategoryLegend() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: EventCategory.values.map((category) {
              final bool isSelected = _selectedCategories.contains(category);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: CircleAvatar(
                    backgroundColor: isSelected ? category.color : Colors.grey[300],
                    child: Icon(
                      category.icon,
                      color: isSelected ? Colors.white : Colors.grey,
                      size: 16,
                    ),
                  ),
                  label: Text(
                    category.displayName,
                    style: TextStyle(
                      color: isSelected ? category.color : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  backgroundColor: isSelected ? category.color.withOpacity(0.1) : Colors.grey[100],
                  selectedColor: category.color.withOpacity(0.2),
                  checkmarkColor: category.color,
                  selected: isSelected,
                  onSelected: (selected) => _toggleCategory(category),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? category.color : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              TextButton.icon(
                icon: Icon(
                  _selectedCategories.length == EventCategory.values.length
                      ? Icons.clear_all
                      : Icons.select_all,
                  color: theme.primaryColor,
                ),
                label: Text(
                  _selectedCategories.length == EventCategory.values.length
                      ? 'Deselect All'
                      : 'Select All',
                  style: TextStyle(color: theme.primaryColor),
                ),
                onPressed: () {
                  setState(() {
                    if (_selectedCategories.length == EventCategory.values.length) {
                      // Deselect all if all are selected
                      _selectedCategories.clear();
                    } else {
                      // Select all if not all are selected
                      _selectedCategories.clear();
                      _selectedCategories.addAll(EventCategory.values);
                    }
                    
                    if (_selectedDay != null) {
                      _selectedEvents.value = _getEventsForDay(_selectedDay!);
                    }
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Column(
            children: EventCategory.values.map((category) {
              final bool isSelected = _selectedCategories.contains(category);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected ? category.color.withOpacity(0.1) : Colors.transparent,
                ),
                child: CheckboxListTile(
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(category.icon, color: category.color, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        category.displayName,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  value: isSelected,
                  activeColor: category.color,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (bool? value) {
                    if (value != null) {
                      setState(() {
                        if (value) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                        
                        if (_selectedDay != null) {
                          _selectedEvents.value = _getEventsForDay(_selectedDay!);
                        }
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(CalendarEvent event) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: event.category.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(event.category.icon, color: event.category.color, size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: event.category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.category.displayName,
                        style: TextStyle(
                          color: event.category.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(event.date),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                event.description.isEmpty ? 'No description provided' : event.description,
                style: TextStyle(
                  height: 1.5,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      side: BorderSide(color: theme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // Here you would implement the edit functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit functionality would be implemented here')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text('Share', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Share.share(
                        '${event.title}\nDate: ${DateFormat('MMM dd, yyyy').format(event.date)}\nCategory: ${event.category.displayName}\n\n${event.description}',
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEventDialog() {
    final theme = Theme.of(context);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = _selectedDay ?? DateTime.now();
    EventCategory selectedCategory = EventCategory.academicActivity;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.event_available, color: theme.primaryColor),
            const SizedBox(width: 8),
            const Text('Add Calendar Event'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  hintText: 'Enter event title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.title),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter event description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.description),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: const Icon(Icons.calendar_today),
                  title: Text('Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}'),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime(DateTime.now().year + 2),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: theme.primaryColor,
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EventCategory>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Event Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: EventCategory.values.map((category) {
                  return DropdownMenuItem<EventCategory>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color, size: 20),
                        const SizedBox(width: 8),
                        Text(category.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedCategory = value;
                  }
                },
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addEvent(
                  selectedDate,
                  titleController.text,
                  descriptionController.text,
                  selectedCategory,
                );
                
                // Update the selected events if the new event is for the selected day
                if (_selectedDay != null && 
                    selectedDate.year == _selectedDay!.year &&
                    selectedDate.month == _selectedDay!.month &&
                    selectedDate.day == _selectedDay!.day) {
                  _selectedEvents.value = _getEventsForDay(_selectedDay!);
                }
                
                Navigator.pop(context);
                
                // Show a confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[100]),
                        const SizedBox(width: 12),
                        const Text('Event added successfully'),
                      ],
                    ),
                    backgroundColor: theme.primaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              } else {
                // Show validation error
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event title is required'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('ADD EVENT'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareCalendar() async {
    // Show sharing options
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Share with Teachers'),
            onTap: () {
              Navigator.pop(context);
              _generateAndSharePdf('Teachers');
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Share with Students'),
            onTap: () {
              Navigator.pop(context);
              _generateAndSharePdf('Students');
            },
          ),
          ListTile(
            leading: const Icon(Icons.family_restroom),
            title: const Text('Share with Parents'),
            onTap: () {
              Navigator.pop(context);
              _generateAndSharePdf('Parents');
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Share with All'),
            onTap: () {
              Navigator.pop(context);
              _generateAndSharePdf('All');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndSharePdf(String audience) async {
    // Create a PDF document
    final pdf = pw.Document();

    // Group events by month for a more organized view
    final Map<int, List<CalendarEvent>> eventsByMonth = {};
    
    // Flatten the events map to get all events
    final List<CalendarEvent> allEvents = [];
    _events.forEach((key, value) {
      allEvents.addAll(value);
    });
    
    // Sort events by date
    allEvents.sort((a, b) => a.date.compareTo(b.date));
    
    // Group by month
    for (final event in allEvents) {
      final int monthKey = event.date.month;
      if (!eventsByMonth.containsKey(monthKey)) {
        eventsByMonth[monthKey] = [];
      }
      eventsByMonth[monthKey]!.add(event);
    }

    // Add a title page to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Academic Calendar',
                  style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'School Year ${DateTime.now().year}-${DateTime.now().year + 1}',
                  style: const pw.TextStyle(fontSize: 20),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  'Shared with: $audience',
                  style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey),
                ),
                pw.SizedBox(height: 60),
                pw.Text(
                  'Generated on ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Add the calendar pages to the PDF
    pdf.addPage(
      pw.MultiPage(
        header: (pw.Context context) {
          return pw.Header(
            level: 0,
            child: pw.Text(
              'Academic Calendar ${DateTime.now().year}-${DateTime.now().year + 1}',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        },
        build: (pw.Context context) {
          final List<pw.Widget> widgets = [];
          
          final List<int> sortedMonths = eventsByMonth.keys.toList()..sort();
          
          for (final month in sortedMonths) {
            // Add month header
            widgets.add(
              pw.Header(
                level: 1,
                text: DateFormat('MMMM yyyy').format(DateTime(DateTime.now().year, month)),
              ),
            );
            
            // Add events for this month
            for (final event in eventsByMonth[month]!) {
              final PdfColor eventColor = _getPdfColorForCategory(event.category);
              
              widgets.add(
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: eventColor, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            DateFormat('MMM dd, yyyy (EEEE)').format(event.date),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: eventColor),
                          ),
                          pw.Text(
                            event.category.displayName,
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        event.title,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                      ),
                      if (event.description.isNotEmpty) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(event.description),
                      ],
                    ],
                  ),
                ),
              );
            }
            
            // Add spacer between months
            widgets.add(pw.SizedBox(height: 20));
          }
          
          return widgets;
        },
      ),
    );

    // Save the PDF to a temporary file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/academic_calendar.pdf');
    await file.writeAsBytes(await pdf.save());

    // Share the PDF
    // await Share.shareFiles([file.path], text: 'Academic Calendar for School Year ${DateTime.now().year}-${DateTime.now().year + 1}');
  }

  PdfColor _getPdfColorForCategory(EventCategory category) {
    switch (category) {
      case EventCategory.holiday:
        return PdfColors.green;
      case EventCategory.exam:
        return PdfColors.red;
      case EventCategory.schoolEvent:
        return PdfColors.purple;
      case EventCategory.academicActivity:
        return PdfColors.blue;
      case EventCategory.other:
        return PdfColors.grey;
    }
  }
}
