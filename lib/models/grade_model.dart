class Grade {
  final String id;
  final String schoolId;
  final String classId;
  final String subjectId;
  final String teacherId;
  final String studentId;
  final String? studentName;
  final String? teacherName;
  final double percentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Grade({
    required this.id,
    required this.schoolId,
    required this.classId,
    required this.subjectId,
    required this.teacherId,
    required this.studentId,
    this.studentName,
    this.teacherName,
    required this.percentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['_id'] ?? json['id'] ?? '',
      schoolId: json['schoolId'] ?? '',
      classId: json['classId'] is String 
          ? json['classId'] 
          : json['classId']['_id'] ?? '',
      subjectId: json['subjectId'] ?? '',
      teacherId: json['teacherId'] is String 
          ? json['teacherId'] 
          : json['teacherId']['_id'] ?? '',
      studentId: json['entries']?[0]?['studentId'] ?? '',
      studentName: json['entries']?[0]?['studentName'],
      teacherName: json['teacherId'] is Map 
          ? json['teacherId']['name'] 
          : null,
      percentage: (json['entries']?[0]?['percentage'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'schoolId': schoolId,
      'classId': classId,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'entries': [
        {
          'studentId': studentId,
          'percentage': percentage,
        }
      ],
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get gradeLevel {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  Grade copyWith({
    String? id,
    String? schoolId,
    String? classId,
    String? subjectId,
    String? teacherId,
    String? studentId,
    String? studentName,
    String? teacherName,
    double? percentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Grade(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      classId: classId ?? this.classId,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      teacherName: teacherName ?? this.teacherName,
      percentage: percentage ?? this.percentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
    