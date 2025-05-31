class Class {
  final String id;
  final String name;
  final String section;
  final String schoolId;
  final String teacherId;
  final List<String> students;
  final List<String> subjects;
  final List<Schedule> schedule;
  final DateTime createdAt;
  final DateTime updatedAt;

  Class({
    required this.id,
    required this.name,
    required this.section,
    required this.schoolId,
    required this.teacherId,
    required this.students,
    required this.subjects,
    required this.schedule,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['_id'],
      name: json['name'],
      section: json['section'],
      schoolId: json['schoolId'],
      teacherId: json['teacherId'],
      students: List<String>.from(json['students']),
      subjects: List<String>.from(json['subjects']),
      schedule: (json['schedule'] as List).map((e) => Schedule.fromJson(e)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'section': section,
      'schoolId': schoolId,
      'teacherId': teacherId,
      'students': students,
      'subjects': subjects,
      'schedule': schedule.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Schedule {
  final String day;
  final List<Period> periods;

  Schedule({
    required this.day,
    required this.periods,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      day: json['day'],
      periods: (json['periods'] as List).map((e) => Period.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'periods': periods.map((e) => e.toJson()).toList(),
    };
  }
}

class Period {
  final String subject;
  final String startTime;
  final String endTime;
  final String teacherId;

  Period({
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.teacherId,
  });

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      subject: json['subject'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      teacherId: json['teacherId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'startTime': startTime,
      'endTime': endTime,
      'teacherId': teacherId,
    };
  }
}
