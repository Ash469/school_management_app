import 'package:flutter/material.dart';

class Notification {
  final String title;
  final String content;
  final DateTime date;
  final NotificationType type;
  final String? recipient; // Can be a person's name or group name

  Notification({
    required this.title,
    required this.content,
    required this.date,
    required this.type,
    this.recipient,
  });
}

enum NotificationType { personal, group, announcement }

// Define available groups
class Group {
  final String id;
  final String name;
  final String type; // e.g., "Class", "Teachers", "Parents"

  Group({required this.id, required this.name, required this.type});
}

class NotificationManagementScreen extends StatefulWidget {
  const NotificationManagementScreen({Key? key}) : super(key: key);

  @override
  State<NotificationManagementScreen> createState() => _NotificationManagementScreenState();
}

class _NotificationManagementScreenState extends State<NotificationManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Notification> _notifications = [
    Notification(
      title: 'Exam Schedule',
      content: 'Final exams will start on October 15th',
      date: DateTime(2023, 9, 15),
      type: NotificationType.announcement,
    ),
    Notification(
      title: 'Holiday Notice',
      content: 'School will remain closed on September 20th',
      date: DateTime(2023, 9, 20),
      type: NotificationType.announcement,
    ),
    Notification(
      title: 'Math Assignment',
      content: 'Please complete exercises 5-10',
      date: DateTime(2023, 9, 25),
      type: NotificationType.group,
      recipient: 'Class 10A',
    ),
    Notification(
      title: 'Performance Update',
      content: 'Your child has shown excellent progress',
      date: DateTime(2023, 9, 30),
      type: NotificationType.personal,
      recipient: 'Parent of John Doe',
    ),
  ];

  // Add predefined groups for the school
  final List<Group> _availableGroups = [
    // Classes
    Group(id: 'class-1', name: 'Class 1A', type: 'Class'),
    Group(id: 'class-2', name: 'Class 1B', type: 'Class'),
    Group(id: 'class-3', name: 'Class 2A', type: 'Class'),
    Group(id: 'class-4', name: 'Class 2B', type: 'Class'),
    Group(id: 'class-5', name: 'Class 3A', type: 'Class'),
    Group(id: 'class-6', name: 'Class 10A', type: 'Class'),
    
    // Role-based groups
    Group(id: 'all-students', name: 'All Students', type: 'Role'),
    Group(id: 'all-teachers', name: 'All Teachers', type: 'Role'),
    Group(id: 'all-parents', name: 'All Parents', type: 'Role'),
    
    // Departments
    Group(id: 'science-dept', name: 'Science Department', type: 'Department'),
    Group(id: 'math-dept', name: 'Mathematics Department', type: 'Department'),
    Group(id: 'english-dept', name: 'English Department', type: 'Department'),
    
    // Activities
    Group(id: 'sports-team', name: 'Sports Team', type: 'Activity'),
    Group(id: 'drama-club', name: 'Drama Club', type: 'Activity'),
    Group(id: 'chess-club', name: 'Chess Club', type: 'Activity'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.personal:
        return Colors.pinkAccent.shade200;
      case NotificationType.group:
        return Colors.tealAccent.shade400;
      case NotificationType.announcement:
        return Colors.amberAccent.shade700;
    }
  }

  Icon _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.personal:
        return const Icon(Icons.person, color: Colors.white);
      case NotificationType.group:
        return const Icon(Icons.group, color: Colors.white);
      case NotificationType.announcement:
        return const Icon(Icons.campaign, color: Colors.white);
    }
  }

  List<Notification> _getFilteredNotifications(NotificationType? type) {
    if (type == null) return _notifications;
    return _notifications.where((notification) => notification.type == type).toList();
  }

  void _showComposeDialog() {
    NotificationType selectedType = NotificationType.personal;
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final recipientController = TextEditingController();
    Group? selectedGroup;
    DateTime scheduleDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Compose Notification'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<NotificationType>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Notification Type'),
                    items: NotificationType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                        // Reset selected group when changing type
                        if (selectedType != NotificationType.group) {
                          selectedGroup = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'Content'),
                  ),
                  const SizedBox(height: 16),
                  if (selectedType == NotificationType.personal)
                    TextFormField(
                      controller: recipientController,
                      decoration: const InputDecoration(labelText: 'Recipient Name'),
                    ),
                  if (selectedType == NotificationType.group)
                    DropdownButtonFormField<Group>(
                      value: selectedGroup,
                      decoration: const InputDecoration(labelText: 'Select Group'),
                      hint: const Text('Select a group'),
                      items: _availableGroups.map((group) {
                        return DropdownMenuItem(
                          value: group,
                          child: Text('${group.name} (${group.type})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGroup = value;
                        });
                      },
                      isExpanded: true,
                    ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Schedule Date'),
                    subtitle: Text(
                      "${scheduleDate.toLocal().day}/${scheduleDate.toLocal().month}/${scheduleDate.toLocal().year}",
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: scheduleDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2025),
                      );
                      if (picked != null && picked != scheduleDate) {
                        setState(() {
                          scheduleDate = picked;
                        });
                      }
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
              ElevatedButton(
                onPressed: () {
                  String? recipient;
                  
                  if (selectedType == NotificationType.personal) {
                    recipient = recipientController.text;
                  } else if (selectedType == NotificationType.group && selectedGroup != null) {
                    recipient = selectedGroup!.name;
                  }
                  
                  final newNotification = Notification(
                    title: titleController.text,
                    content: contentController.text,
                    date: scheduleDate,
                    type: selectedType,
                    recipient: recipient,
                  );

                  setState(() {
                    _notifications.insert(0, newNotification);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification scheduled successfully')),
                  );
                },
                child: const Text('Send'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Management'),
        backgroundColor: Colors.lightBlue.shade300,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amberAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Personal'),
            Tab(text: 'Group'),
            Tab(text: 'Announcements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(null),
          _buildNotificationsList(NotificationType.personal),
          _buildNotificationsList(NotificationType.group),
          _buildNotificationsList(NotificationType.announcement),
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

  Widget _buildNotificationsList(NotificationType? type) {
    final filteredNotifications = _getFilteredNotifications(type);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: filteredNotifications.isEmpty
        ? const Center(child: Text('No notifications', style: TextStyle(fontSize: 16, color: Colors.blueGrey)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredNotifications.length,
            itemBuilder: (context, index) {
              final notification = filteredNotifications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shadowColor: _getColorForType(notification.type).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _getColorForType(notification.type).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorForType(notification.type),
                    child: _getIconForType(notification.type),
                  ),
                  title: Text(
                    notification.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notification.content),
                      const SizedBox(height: 4),
                      if (notification.recipient != null)
                        Text(
                          'To: ${notification.recipient}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                      Text(
                        'Date: ${notification.date.day}/${notification.date.month}/${notification.date.year}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.more_vert, color: _getColorForType(notification.type)),
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
                                leading: Icon(Icons.edit, color: Colors.blueAccent.shade200),
                                title: const Text('Edit'),
                                onTap: () {
                                  Navigator.pop(context);
                                  // Add edit functionality
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete, color: Colors.redAccent),
                                title: const Text('Delete'),
                                onTap: () {
                                  setState(() {
                                    _notifications.remove(notification);
                                  });
                                  Navigator.pop(context);
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
            },
          ),
    );
  }
}
