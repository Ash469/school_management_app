class Homework {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String subjectName;
  final String classId;
  final String className;
  final String teacherId;
  final String teacherName;
  final DateTime assignedDate;
  final DateTime dueDate;
  final List<String> attachments; // URLs to files
  final List<String> submittedBy; // Student IDs
  final List<Submission> submissions;
  final bool isActive;
  final int maxPoints;

  Homework({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.subjectName,
    required this.classId,
    required this.className,
    required this.teacherId,
    required this.teacherName,
    required this.assignedDate,
    required this.dueDate,
    required this.attachments,
    required this.submittedBy,
    required this.submissions,
    required this.isActive,
    required this.maxPoints,
  });

  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      classId: json['classId'],
      className: json['className'],
      teacherId: json['teacherId'],
      teacherName: json['teacherName'],
      assignedDate: DateTime.parse(json['assignedDate']),
      dueDate: DateTime.parse(json['dueDate']),
      attachments: List<String>.from(json['attachments']),
      submittedBy: List<String>.from(json['submittedBy']),
      submissions: (json['submissions'] as List)
          .map((submission) => Submission.fromJson(submission))
          .toList(),
      isActive: json['isActive'],
      maxPoints: json['maxPoints'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'classId': classId,
      'className': className,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'assignedDate': assignedDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'attachments': attachments,
      'submittedBy': submittedBy,
      'submissions': submissions.map((submission) => submission.toJson()).toList(),
      'isActive': isActive,
      'maxPoints': maxPoints,
    };
  }
}

class Submission {
  final String studentId;
  final String studentName;
  final DateTime submissionDate;
  final List<String> files; // URLs to submitted files
  final String? comments;
  final int? points;
  final String? feedback;
  final bool isGraded;

  Submission({
    required this.studentId,
    required this.studentName,
    required this.submissionDate,
    required this.files,
    this.comments,
    this.points,
    this.feedback,
    required this.isGraded,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      studentId: json['studentId'],
      studentName: json['studentName'],
      submissionDate: DateTime.parse(json['submissionDate']),
      files: List<String>.from(json['files']),
      comments: json['comments'],
      points: json['points'],
      feedback: json['feedback'],
      isGraded: json['isGraded'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'submissionDate': submissionDate.toIso8601String(),
      'files': files,
      'comments': comments,
      'points': points,
      'feedback': feedback,
      'isGraded': isGraded,
    };
  }
}