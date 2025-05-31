import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class TeacherNotificationsScreen extends StatefulWidget {
  final User user;

  const TeacherNotificationsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _TeacherNotificationsScreenState createState() => _TeacherNotificationsScreenState();
}

class _TeacherNotificationsScreenState extends State<TeacherNotificationsScreen> {
  bool _isLoading = true;
  final List<Map<String, dynamic>> _notifications = [];
  
  // Light theme colors to match attendance screen
  final Color _primaryColor = const Color(0xFF5E63B6);
  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _cardColor = Colors.white;
  final Color _textPrimaryColor = const Color(0xFF333333);
  final Color _textSecondaryColor = const Color(0xFF717171);

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _notifications.addAll([
        {
          'id': '1',
          'title': 'Parent Meeting',
          'message': 'Parent-teacher meeting scheduled for next Friday',
          'sender': 'Principal',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'read': false,
          'type': 'info',
        },
        {
          'id': '2',
          'title': 'Assignment Due',
          'message': 'Students have submitted assignments for Class 10A',
          'sender': 'System',
          'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
          'read': true,
          'type': 'success',
        },
        {
          'id': '3',
          'title': 'Late Submission Request',
          'message': 'Student Bob Smith has requested late submission for Physics Lab Report',
          'sender': 'Bob Smith',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'read': false,
          'type': 'request',
        },
        {
          'id': '4',
          'title': 'Staff Meeting',
          'message': 'Reminder: Staff meeting today at 3 PM in the conference room',
          'sender': 'Admin',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)),
          'read': true,
          'type': 'info',
        },
      ]);
      _isLoading = false;
    });
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'info': return Icons.info;
      case 'success': return Icons.check_circle;
      case 'warning': return Icons.warning;
      case 'error': return Icons.error;
      case 'request': return Icons.question_answer;
      default: return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'info': return const Color(0xFF2196F3);
      case 'success': return const Color(0xFF43A047);
      case 'warning': return const Color(0xFFFF9800);
      case 'error': return const Color(0xFFE53935);
      case 'request': return const Color(0xFF5E63B6);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification['read'] = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Marked all as read')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator(color: _primaryColor))
        : _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationTile(notification);
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing notifications...')),
              );
              _loadNotifications();
            },
            child: const Icon(Icons.refresh),
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            tooltip: 'Refresh',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'new_message',
            onPressed: _showSendMessageOptions,
            backgroundColor: const Color(0xFF43A047),
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
            tooltip: 'Send New Message',
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: _textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 16,
              color: _textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    final timestamp = notification['timestamp'] as DateTime;
    final now = DateTime.now();
    String timeText;
    
    if (now.difference(timestamp).inDays > 0) {
      timeText = '${now.difference(timestamp).inDays}d ago';
    } else if (now.difference(timestamp).inHours > 0) {
      timeText = '${now.difference(timestamp).inHours}h ago';
    } else {
      timeText = '${now.difference(timestamp).inMinutes}m ago';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      color: _cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification['type']).withOpacity(0.2),
          child: Icon(
            _getNotificationIcon(notification['type']),
            color: _getNotificationColor(notification['type']),
          ),
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: notification['read'] ? FontWeight.normal : FontWeight.bold,
            color: _textPrimaryColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['message'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'From: ${notification['sender']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: notification['read']
            ? null
            : Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          setState(() {
            notification['read'] = true;
          });
          _showNotificationDetails(notification);
        },
        onLongPress: () {
          _showNotificationActions(notification);
        },
      ),
    );
  }
  
  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            notification['title'],
            style: TextStyle(color: _textPrimaryColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification['message'],
                style: TextStyle(color: _textPrimaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                'From: ${notification['sender']}',
                style: TextStyle(
                  fontSize: 14,
                  color: _textSecondaryColor,
                ),
              ),
              Text(
                'Received: ${notification['timestamp'].toString().split('.')[0]}',
                style: TextStyle(
                  fontSize: 14,
                  color: _textSecondaryColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(color: _primaryColor)),
            ),
            if (notification['type'] == 'request')
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Response sent')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                ),
                child: const Text('Respond'),
              ),
          ],
        );
      },
    );
  }
  
  void _showNotificationActions(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  notification['read'] ? Icons.mark_email_unread : Icons.mark_email_read,
                  color: _primaryColor,
                ),
                title: Text(
                  notification['read'] ? 'Mark as unread' : 'Mark as read',
                  style: TextStyle(color: _textPrimaryColor),
                ),
                onTap: () {
                  setState(() {
                    notification['read'] = !notification['read'];
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red[700]),
                title: Text(
                  'Delete',
                  style: TextStyle(color: _textPrimaryColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              if (notification['type'] == 'request')
                ListTile(
                  leading: Icon(Icons.reply, color: _primaryColor),
                  title: Text(
                    'Reply',
                    style: TextStyle(color: _textPrimaryColor),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSendMessageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Send New Message',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _textPrimaryColor,
                    ),
                  ),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.group, color: Colors.blue.shade700),
                  ),
                  title: const Text('Send to Class'),
                  subtitle: const Text('Send a message to an entire class'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSendToClassDialog();
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Icon(Icons.person, color: Colors.green.shade700),
                  ),
                  title: const Text('Send to Student'),
                  subtitle: const Text('Send a message to an individual student'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSendToStudentDialog();
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: Icon(Icons.family_restroom, color: Colors.orange.shade700),
                  ),
                  title: const Text('Send to Parent'),
                  subtitle: const Text('Send a message to a parent'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSendToParentDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSendToClassDialog() {
    final classController = TextEditingController();
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Message to Class'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Class',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Class 10A', 'Class 9B', 'Class 8C']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      classController.text = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a class';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a message';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _sendMessage(
                    'class', 
                    classController.text, 
                    titleController.text, 
                    messageController.text
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _showSendToStudentDialog() {
    final studentController = TextEditingController();
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Message to Student'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Student',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Alice Johnson', 'Bob Smith', 'Carol White', 'David Brown']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      studentController.text = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a student';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a message';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _sendMessage(
                    'student', 
                    studentController.text, 
                    titleController.text, 
                    messageController.text
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _showSendToParentDialog() {
    final parentController = TextEditingController();
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Message to Parent'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Parent',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Mr. Johnson (Alice\'s parent)', 'Mrs. Smith (Bob\'s parent)', 
                            'Mr. White (Carol\'s parent)', 'Mrs. Brown (David\'s parent)']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      parentController.text = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a parent';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a message';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _sendMessage(
                    'parent', 
                    parentController.text, 
                    titleController.text, 
                    messageController.text
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
  
  void _sendMessage(String recipientType, String recipient, String title, String message) {
    // In a real app, this would send the message to a backend API
    // For now, we'll just add it to our local notifications list
    
    String type;
    switch (recipientType) {
      case 'class':
        type = 'info';
        break;
      case 'student':
        type = 'success';
        break;
      case 'parent':
        type = 'request';
        break;
      default:
        type = 'info';
    }
    
    setState(() {
      _notifications.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'message': message,
        'sender': 'You → $recipient',
        'timestamp': DateTime.now(),
        'read': true,
        'type': type,
        'outgoing': true,
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message sent to $recipient'),
        backgroundColor: _primaryColor,
      ),
    );
  }
}
