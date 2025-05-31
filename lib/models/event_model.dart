class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String organizerId;
  final String organizerName;
  final String type; // e.g., "holiday", "exam", "activity", "meeting"
  final List<String> participants; // IDs of users who should attend
  final List<String> confirmed; // IDs of users who confirmed attendance
  final bool allDay;
  final bool isRecurring;
  final String? recurrenceRule; // e.g., "FREQ=WEEKLY;UNTIL=20251231T000000Z"
  final List<Reminder> reminders;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.organizerId,
    required this.organizerName,
    required this.type,
    required this.participants,
    required this.confirmed,
    required this.allDay,
    required this.isRecurring,
    this.recurrenceRule,
    required this.reminders,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      location: json['location'],
      organizerId: json['organizerId'],
      organizerName: json['organizerName'],
      type: json['type'],
      participants: List<String>.from(json['participants']),
      confirmed: List<String>.from(json['confirmed']),
      allDay: json['allDay'],
      isRecurring: json['isRecurring'],
      recurrenceRule: json['recurrenceRule'],
      reminders: (json['reminders'] as List)
          .map((reminder) => Reminder.fromJson(reminder))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'type': type,
      'participants': participants,
      'confirmed': confirmed,
      'allDay': allDay,
      'isRecurring': isRecurring,
      'recurrenceRule': recurrenceRule,
      'reminders': reminders.map((reminder) => reminder.toJson()).toList(),
    };
  }
}

class Reminder {
  final int minutesBefore;
  final String type; // e.g., "notification", "email"

  Reminder({
    required this.minutesBefore,
    required this.type,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      minutesBefore: json['minutesBefore'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minutesBefore': minutesBefore,
      'type': type,
    };
  }
}
