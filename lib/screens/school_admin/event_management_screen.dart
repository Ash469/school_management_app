import 'package:flutter/material.dart';
import '../../services/event_service.dart';
import '../../utils/constants.dart'; // Import constants for base URL

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({Key? key}) : super(key: key);

  @override
  _EventManagementScreenState createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  final List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  late EventService _eventService;
  
  @override
  void initState() {
    super.initState();
    _eventService = EventService(baseUrl: Constants.apiBaseUrl);
    _loadEvents();
  }
  
  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final events = await _eventService.getAllEvents();
      setState(() {
        _events.clear();
        _events.addAll(events);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading events: $e')),
      );
    }
  }
  
  Future<void> _deleteEvent(String eventId, int index) async {
    try {
      await _eventService.deleteEvent(eventId);
      setState(() {
        _events.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event cancelled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling event: $e')),
      );
    }
  }
  
  Future<void> _showAddEventDialog() async {
    final nameController = TextEditingController();  // Changed from titleController
    final descriptionController = TextEditingController();
    final dateController = TextEditingController();
    final venueController = TextEditingController();  // Changed from locationController
    final timeController = TextEditingController();
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Event'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,  // Changed controller name
                  decoration: const InputDecoration(
                    labelText: 'Event Name *',  // Updated label
                    hintText: 'Enter event name',  // Updated hint
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Enter event description',
                  ),
                  maxLines: 3,
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date *',
                    hintText: 'YYYY-MM-DD',
                  ),
                ),
                TextField(
                  controller: venueController,  // Changed controller name
                  decoration: const InputDecoration(
                    labelText: 'Venue',  // Updated label
                    hintText: 'Enter venue (optional)',  // Updated hint
                  ),
                ),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    hintText: 'Enter time (optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () async {
                if (nameController.text.isEmpty ||  // Changed from titleController
                    descriptionController.text.isEmpty ||
                    dateController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                
                try {
                  
                  Navigator.of(context).pop();
                  _loadEvents(); // Reload all events
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event created successfully')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating event: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? const Center(child: Text('No events scheduled'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(event['name'] ?? 'No name'),  // Changed from 'title' to 'name'
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${event['date']?.toString().substring(0, 10) ?? 'TBD'}'),  // Format ISO date properly
                            if (event['venue'] != null)
                              Text('Venue: ${event['venue']}'),  // Changed from 'location' to 'venue'
                            if (event['time'] != null)
                              Text('Time: ${event['time']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteEvent(event['_id'] ?? event['id'], index);
                          },
                        ),
                        onTap: () {
                          // Show event details on tap
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${event['description'] ?? 'No description'}'),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _showAddEventDialog,
      ),
    );
  }
}
