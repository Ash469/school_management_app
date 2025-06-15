class Assignment {
  final String id;
  final String teacherId;
  final String classId;
  final String subject;
  final String title;
  final String description;
  final DateTime assignedAt;
  final DateTime dueDate;
  final ClassInfo? classInfo;
  final TeacherInfo? teacherInfo;

  Assignment({
    required this.id,
    required this.teacherId,
    required this.classId,
    required this.subject,
    required this.title,
    required this.description,
    required this.assignedAt,
    required this.dueDate,
    this.classInfo,
    this.teacherInfo,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['_id'] ?? json['id'] ?? '',
      teacherId: _extractId(json['teacherId']),
      classId: _extractId(json['classId']),
      subject: json['subject'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      assignedAt: _parseDateTime(json['assignedAt']),
      dueDate: _parseDateTime(json['dueDate']),
      classInfo: json['classId'] is Map<String, dynamic> 
        ? ClassInfo.fromJson(json['classId']) 
        : null,
      teacherInfo: json['teacherId'] is Map<String, dynamic> 
        ? TeacherInfo.fromJson(json['teacherId']) 
        : null,
    );
  }

  // Helper method to extract ID from either string or object
  static String _extractId(dynamic value) {
    if (value is String) {
      return value;
    } else if (value is Map<String, dynamic>) {
      return value['_id'] ?? value['id'] ?? '';
    }
    return '';
  }

  // Helper method to safely parse DateTime
  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing date: $value, using current time');
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'classId': classId,
      'subject': subject,
      'title': title,
      'description': description,
      'assignedAt': assignedAt.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
    };
  }
}

class TeacherInfo {
  final String id;
  final String? teacherId;
  final String name;

  TeacherInfo({
    required this.id,
    this.teacherId,
    required this.name,
  });

  factory TeacherInfo.fromJson(Map<String, dynamic> json) {
    return TeacherInfo(
      id: json['_id'] ?? json['id'] ?? '',
      teacherId: json['teacherId']?.toString(),
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'name': name,
    };
  }
}

class ClassInfo {
  final String id;
  final String name;
  final String? grade;
  final String? section;
  final String? year;

  ClassInfo({
    required this.id,
    required this.name,
    this.grade,
    this.section,
    this.year,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      grade: json['grade']?.toString(),
      section: json['section']?.toString(),
      year: json['year']?.toString(), // Convert to string regardless of input type
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'section': section,
      'year': year,
    };
  }
}

class Submission {
  final String id;
  final String assignmentId;
  final String studentId;
  final DateTime submittedAt;
  final String? content;
  final String? filePath;
  final String? grade;
  final String? feedback;
  final String status;

  Submission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.submittedAt,
    this.content,
    this.filePath,
    this.grade,
    this.feedback,
    this.status = 'submitted',
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['_id'] ?? json['id'] ?? '',
      assignmentId: json['assignmentId'] ?? '',
      studentId: json['studentId'] ?? '',
      submittedAt: _parseDateTime(json['submittedAt']),
      content: json['content'],
      filePath: json['filePath'],
      grade: json['grade'],
      feedback: json['feedback'],
      status: json['status'] ?? 'submitted',
    );
  }

  // Helper method to safely parse DateTime
  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing date: $value, using current time');
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'studentId': studentId,
      'submittedAt': submittedAt.toIso8601String(),
      'content': content,
      'filePath': filePath,
      'grade': grade,
      'feedback': feedback,
      'status': status,
    };
  }
}
