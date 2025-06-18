import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../services/class_services.dart';
import '../../services/teacher_service.dart';
import '../../services/student_service.dart';
import '../../services/parent_service.dart';
import '../../utils/storage_util.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart'; // Import constants for base URL

class NotificationManagementScreen extends StatefulWidget {
  const NotificationManagementScreen({Key? key}) : super(key: key);

  @override
  State<NotificationManagementScreen> createState() => _NotificationManagementScreenState();
}

class _NotificationManagementScreenState extends State<NotificationManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;  

    // Theme colors
  late Color _primaryColor;

  // Services for fetching recipients
  late ClassService _classService;
  late TeacherService _teacherService;
  late StudentService _studentService;
  late ParentService _parentService;
  
  @override
  void initState() {
    super.initState();
     _loadThemeColors();
    _tabController = TabController(length: 2, vsync: this); // Change to 2 tabs
    _fetchNotifications();
    _fetchCurrentUserId(); // Add this to get the current user's ID
    
    // Initialize services
    _classService = ClassService(baseUrl: Constants.apiBaseUrl);
    _teacherService = TeacherService(baseUrl:  Constants.apiBaseUrl);
    _studentService = StudentService(baseUrl: Constants.apiBaseUrl);
    _parentService = ParentService(baseUrl:  Constants.apiBaseUrl);
  }

  void _loadThemeColors() {
    _primaryColor = AppTheme.getPrimaryColor(AppTheme.defaultTheme);
  }
  // Add method to fetch current user ID
  Future<void> _fetchCurrentUserId() async {
    try {
      final userId = await StorageUtil.getString('userId');
      setState(() {
        _currentUserId = userId;
      });
    } catch (e) {
      print('Error fetching current user ID: $e');
    }
  }

  // Fetch notifications from the API
  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await _notificationService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<NotificationModel> _getFilteredNotifications(String? type) {
    if (type == null) return _notifications;
    return _notifications.where((notification) => notification.type == type).toList();
  }

  // Update this method to filter announcements
  List<NotificationModel> _getAnnouncementNotifications() {
    return _notifications.where((notification) => 
      notification.type == 'Announcement').toList();
  }
  
  // Add new method to filter my notifications
  List<NotificationModel> _getMyNotifications() {
    if (_currentUserId == null) return [];
    return _notifications.where((notification) => 
      notification.createdBy == _currentUserId).toList();
  }

  void _showComposeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Notification Type'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNotificationTypeCard(
                  icon: Icons.campaign,
                  color: Colors.amberAccent.shade700,
                  title: 'Announcement',
                  subtitle: 'Send to everyone in the school',
                  onTap: () {
                    Navigator.pop(context);
                    _showAnnouncementDialog();
                  },
                ),
                _buildNotificationTypeCard(
                  icon: Icons.class_,
                  color: Colors.purpleAccent.shade200,
                  title: 'Message to Class',
                  subtitle: 'Send to a specific class',
                  onTap: () {
                    Navigator.pop(context);
                    _showClassMessageDialog();
                  },
                ),
                _buildNotificationTypeCard(
                  icon: Icons.school,
                  color: Colors.blueAccent,
                  title: 'Message to Teacher',
                  subtitle: 'Send to a specific teacher',
                  onTap: () {
                    Navigator.pop(context);
                    _showTeacherMessageDialog();
                  },
                ),
                _buildNotificationTypeCard(
                  icon: Icons.person,
                  color: Colors.tealAccent.shade400,
                  title: 'Message to Student',
                  subtitle: 'Send to a specific student',
                  onTap: () {
                    Navigator.pop(context);
                    _showStudentMessageDialog();
                  },
                ),
                _buildNotificationTypeCard(
                  icon: Icons.family_restroom,
                  color: Colors.pinkAccent.shade200,
                  title: 'Message to Parent',
                  subtitle: 'Send to a specific parent',
                  onTap: () {
                    Navigator.pop(context);
                    _showParentMessageDialog();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationTypeCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Show dialog for creating an announcement
  void _showAnnouncementDialog() {
    final messageController = TextEditingController();
    List<String> selectedAudience = ['all_students', 'all_teachers', 'all_parents'];
    DateTime scheduleDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.amberAccent.shade700,
                  child: const Icon(Icons.campaign, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text('New Announcement'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: messageController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Announcement Message',
                      hintText: 'Enter your announcement message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Audience',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  CheckboxListTile(
                    title: const Text('All Students'),
                    value: selectedAudience.contains('all_students'),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          if (!selectedAudience.contains('all_students')) {
                            selectedAudience.add('all_students');
                          }
                        } else {
                          selectedAudience.remove('all_students');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('All Teachers'),
                    value: selectedAudience.contains('all_teachers'),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          if (!selectedAudience.contains('all_teachers')) {
                            selectedAudience.add('all_teachers');
                          }
                        } else {
                          selectedAudience.remove('all_teachers');
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('All Parents'),
                    value: selectedAudience.contains('all_parents'),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          if (!selectedAudience.contains('all_parents')) {
                            selectedAudience.add('all_parents');
                          }
                        } else {
                          selectedAudience.remove('all_parents');
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent.shade700,
                ),
                onPressed: () async {
                  if (messageController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a message')),
                    );
                    return;
                  }
                  
                  if (selectedAudience.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one audience')),
                    );
                    return;
                  }
                  
                  Navigator.pop(context);
                  
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );
                  
                  try {
                    // Send announcement notification with the expected format
                    final success = await _notificationService.sendNotification(
                      type: 'Announcement',
                      message: messageController.text,
                      audience: selectedAudience,
                    );
                    
                    // Always close loading dialog if context is still valid
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Announcement sent successfully')),
                      );
                      _fetchNotifications(); // Refresh the list
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to send announcement')),
                      );
                    }
                  } catch (e) {
                    // Ensure loading dialog is dismissed even on error
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
                child: const Text('Send Announcement', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // Show dialog for sending message to a class
  void _showClassMessageDialog() async {
    final messageController = TextEditingController();
    DateTime scheduleDate = DateTime.now();
    String? selectedClassId;
    Map<String, String> classMap = {};
    bool isLoading = true;

    try {
      // Load classes
      final classes = await _classService.getAllClasses();
      for (var classData in classes) {
        if (classData.containsKey('_id') && classData.containsKey('name')) {
          classMap[classData['_id']] = classData['name'];
        }
      }
      isLoading = false;
    } catch (e) {
      print('Error loading classes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading classes: $e')),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.purpleAccent.shade200,
                  child: const Icon(Icons.class_, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text('Message to Class'),
              ],
            ),
            content: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Class',
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text('Choose a class'),
                          value: selectedClassId,
                          items: classMap.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedClassId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: messageController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            hintText: 'Enter your message to the class',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent.shade200,
                ),
                onPressed: isLoading || selectedClassId == null
                    ? null
                    : () async {
                        if (messageController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a message')),
                          );
                          return;
                        }
                        
                        Navigator.pop(context);
                        _sendNotification(
                          type: 'Class',
                          message: messageController.text,
                          classId: selectedClassId,
                          scheduleDate: scheduleDate,
                        );
                      },
                child: const Text('Send to Class', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // Show dialog for sending message to a teacher
  void _showTeacherMessageDialog() async {
    final messageController = TextEditingController();
    String? selectedTeacherId;
    Map<String, String> teacherMap = {};
    bool isLoading = true;

    try {
      // Load teachers using the TeacherService
      final teachers = await _teacherService.getAllTeachers();
      print('Found ${teachers.length} teachers');
      
      for (var teacher in teachers) {
        if (teacher.containsKey('_id') && teacher.containsKey('name')) {
          teacherMap[teacher['_id']] = teacher['name'];
          print('Added teacher: ${teacher['name']} with ID: ${teacher['_id']}');
        }
      }
      isLoading = false;
    } catch (e) {
      print('Error loading teachers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading teachers: $e')),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: const Icon(Icons.school, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text('Message to Teacher'),
              ],
            ),
            content: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (teacherMap.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'No teachers found. Please add teachers first.',
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                        else
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Select Teacher',
                              border: OutlineInputBorder(),
                            ),
                            hint: const Text('Choose a teacher'),
                            value: selectedTeacherId,
                            items: teacherMap.entries.map((entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedTeacherId = value;
                                print('Selected teacher ID: $selectedTeacherId');
                              });
                            },
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: messageController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            hintText: 'Enter your message to the teacher',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: isLoading || teacherMap.isEmpty || selectedTeacherId == null
                    ? null
                    : () async {
                        if (messageController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a message')),
                          );
                          return;
                        }
                        
                        Navigator.pop(context);
                        
                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );
                        
                        try {
                          // Use the specific teacher notification endpoint
                          final success = await _notificationService.sendTeacherNotification(
                            teacherId: selectedTeacherId!,
                            message: messageController.text,
                     
                          );
                          
                          // Close loading dialog
                          Navigator.pop(context);
                          
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Message sent to teacher successfully')),
                            );
                            _fetchNotifications(); // Refresh the list
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to send message to teacher')),
                            );
                          }
                        } catch (e) {
                          // Close loading dialog
                          Navigator.pop(context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      },
                child: const Text('Send to Teacher', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // Show dialog for sending message to a student
  void _showStudentMessageDialog() async {
    final messageController = TextEditingController();
    DateTime scheduleDate = DateTime.now();
    String? selectedStudentId;
    Map<String, String> studentMap = {};
    bool isLoading = true;

    try {
      // Load students
      final students = await _studentService.getAllStudents();
      for (var student in students) {
        if (student.containsKey('_id') && student.containsKey('name')) {
          studentMap[student['_id']] = student['name'];
        }
      }
      isLoading = false;
    } catch (e) {
      print('Error loading students: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading students: $e')),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.tealAccent.shade400,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text('Message to Student'),
              ],
            ),
            content: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Student',
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text('Choose a student'),
                          value: selectedStudentId,
                          items: studentMap.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStudentId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: messageController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            hintText: 'Enter your message to the student',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent.shade400,
                ),
                onPressed: isLoading || selectedStudentId == null
                    ? null
                    : () async {
                        if (messageController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a message')),
                          );
                          return;
                        }
                        
                        Navigator.pop(context);
                        _sendNotification(
                          type: 'Student',
                          message: messageController.text,
                          studentId: selectedStudentId,
                          scheduleDate: scheduleDate,
                        );
                      },
                child: const Text('Send to Student', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // Show dialog for sending message to a parent
  void _showParentMessageDialog() async {
    final messageController = TextEditingController();
    DateTime scheduleDate = DateTime.now();
    String? selectedParentId;
    Map<String, String> parentMap = {};
    bool isLoading = true;

    try {
      // Load parents
      final parents = await _parentService.getAllParents();
      for (var parent in parents) {
        if (parent.containsKey('_id') && parent.containsKey('name')) {
          parentMap[parent['_id']] = parent['name'];
        }
      }
      isLoading = false;
    } catch (e) {
      print('Error loading parents: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading parents: $e')),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.pinkAccent.shade200,
                  child: const Icon(Icons.family_restroom, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text('Message to Parent'),
              ],
            ),
            content: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Parent',
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text('Choose a parent'),
                          value: selectedParentId,
                          items: parentMap.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedParentId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: messageController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            hintText: 'Enter your message to the parent',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent.shade200,
                ),
                onPressed: isLoading || selectedParentId == null
                    ? null
                    : () async {
                        if (messageController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a message')),
                          );
                          return;
                        }
                        
                        Navigator.pop(context);
                        _sendNotification(
                          type: 'Parent',
                          message: messageController.text,
                          parentId: selectedParentId,
                          scheduleDate: scheduleDate,
                        );
                      },
                child: const Text('Send to Parent', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // Common method to send notifications of any type
  Future<void> _sendNotification({
    required String type,
    required String message,
    List<String> audience = const [],
    String? teacherId,
    String? studentId,
    String? classId,
    String? parentId,
    DateTime? scheduleDate,
  }) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      bool success;
      
      // Use specific endpoints based on notification type
      if (type == 'Teacher' && teacherId != null) {
        success = await _notificationService.sendTeacherNotification(
          teacherId: teacherId,
          message: message,
        );
      } else {
        // Use the general notification endpoint for other types
        success = await _notificationService.sendNotification(
          type: type,
          message: message,
          audience: audience,
          teacherId: teacherId,
          studentId: studentId,
          classId: classId,
          parentId: parentId,
        );
      }
      
      // Ensure loading dialog is dismissed regardless of success state
      if (mounted) {
        Navigator.pop(context);
      }
      
      // Now handle success or failure
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification sent successfully')),
        );
        _fetchNotifications(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send notification')),
        );
      }
    } catch (e) {
      // Make sure loading dialog is dismissed even if there's an error
      if (mounted) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Management'),
        backgroundColor: _primaryColor,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amberAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Announcements'),
            Tab(text: 'My Notifications'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotifications,
            tooltip: 'Refresh notifications',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchNotifications,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAnnouncementsList(), // First tab - Announcements
                    _buildMyNotificationsList(), // Second tab - My Notifications
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showComposeDialog,
        backgroundColor: Colors.lightGreen.shade400,
        child: const Icon(Icons.add),
        tooltip: 'Compose New Notification',
      ),
    );
  }

  // Add a new method to build the announcements list
  Widget _buildAnnouncementsList() {
    final announcements = _getAnnouncementNotifications();
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: announcements.isEmpty
        ? const Center(child: Text('No announcements', style: TextStyle(fontSize: 16, color: Colors.blueGrey)))
        : RefreshIndicator(
            onRefresh: _fetchNotifications,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(announcements[index]);
              },
            ),
          ),
    );
  }

  // Add a new method to build my notifications list
  Widget _buildMyNotificationsList() {
    final myNotifications = _getMyNotifications();
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple.shade50, Colors.white],
        ),
      ),
      child: myNotifications.isEmpty
        ? const Center(child: Text('No notifications created by you', style: TextStyle(fontSize: 16, color: Colors.blueGrey)))
        : RefreshIndicator(
            onRefresh: _fetchNotifications,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myNotifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(myNotifications[index]);
              },
            ),
          ),
    );
  }

  // Add a helper method to build notification cards to avoid code duplication
  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: notification.getTypeColor().withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.getTypeColor().withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.getTypeColor(),
          child: Icon(notification.getTypeIcon(), color: Colors.white),
        ),
        title: Text(
          notification.type,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              notification.getRecipientDescription(),
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Issued: ${notification.issuedAt.day}/${notification.issuedAt.month}/${notification.issuedAt.year}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(Icons.more_vert, color: notification.getTypeColor()),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.redAccent),
                      title: const Text('Delete'),
                      onTap: () async {
                        Navigator.pop(context);
                        
                        // Show confirmation dialog
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Notification'),
                            content: const Text('Are you sure you want to delete this notification?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          try {
                            final success = await _notificationService.deleteNotification(notification.id);
                            if (success) {
                              setState(() {
                                _notifications.remove(notification);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Notification deleted successfully')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to delete notification')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
