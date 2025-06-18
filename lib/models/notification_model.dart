import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String type;
  final String message;
  final String schoolId;
  final String? createdBy; // Add the createdBy field
  final List<String>? audience;
  final String? teacherId;
  final String? studentId;
  final String? classId;
  final String? parentId;
  final DateTime issuedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.schoolId,
    this.createdBy, // Add to constructor
    this.audience,
    this.teacherId,
    this.studentId,
    this.classId,
    this.parentId,
    required this.issuedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] is String ? json['_id'] : json['_id']['\$oid'],
      type: json['type'],
      message: json['message'],
      schoolId: json['schoolId'] is String ? json['schoolId'] : json['schoolId']['\$oid'],
      // Add createdBy field extraction with proper null checking and type handling
      createdBy: json['createdBy'] != null 
          ? (json['createdBy'] is String ? json['createdBy'] : json['createdBy']['\$oid']) 
          : null,
      audience: json['audience'] != null ? List<String>.from(json['audience']) : null,
      teacherId: json['teacherId'] != null 
          ? (json['teacherId'] is String ? json['teacherId'] : json['teacherId']['\$oid']) 
          : null,
      studentId: json['studentId'] != null 
          ? (json['studentId'] is String ? json['studentId'] : json['studentId']['\$oid']) 
          : null,
      classId: json['classId'] != null 
          ? (json['classId'] is String ? json['classId'] : json['classId']['\$oid']) 
          : null,
      parentId: json['parentId'] != null 
          ? (json['parentId'] is String ? json['parentId'] : json['parentId']['\$oid']) 
          : null,
      issuedAt: json['issuedAt'] is String 
          ? DateTime.parse(json['issuedAt']) 
          : DateTime.parse(json['issuedAt']['\$date']),
      createdAt: json['createdAt'] is String 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.parse(json['createdAt']['\$date']),
      updatedAt: json['updatedAt'] is String 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.parse(json['updatedAt']['\$date']),
    );
  }

  Color getTypeColor() {
    switch (type) {
      case 'Announcement':
        return Colors.amberAccent.shade700;
      case 'Teacher':
        return Colors.blueAccent;
      case 'Student':
        return Colors.tealAccent.shade400;
      case 'Parent':
        return Colors.pinkAccent.shade200;
      case 'Class':
        return Colors.purpleAccent.shade200;
      default:
        return Colors.grey;
    }
  }

  IconData getTypeIcon() {
    switch (type) {
      case 'Announcement':
        return Icons.campaign;
      case 'Teacher':
        return Icons.school;
      case 'Student':
        return Icons.person;
      case 'Parent':
        return Icons.family_restroom;
      case 'Class':
        return Icons.class_;
      default:
        return Icons.notifications;
    }
  }

  String getAudienceString() {
    if (audience == null || audience!.isEmpty) {
      // Show recipient based on type if audience is not specified
      if (type == 'Teacher') return 'To: Specific Teacher';
      if (type == 'Student') return 'To: Specific Student';
      if (type == 'Parent') return 'To: Specific Parent';
      if (type == 'Class') return 'To: Specific Class';
      return 'No specific audience';
    }
    return audience!.map((item) => item.replaceAll('_', ' ')).join(', ');
  }

  String getRecipientDescription() {
    if (type == 'Announcement' && audience != null) {
      return 'To: ${getAudienceString()}';
    } else if (type == 'Teacher' && teacherId != null) {
      return 'To: Teacher ID: ${teacherId!.substring(0, 6)}...';
    } else if (type == 'Student' && studentId != null) {
      return 'To: Student ID: ${studentId!.substring(0, 6)}...';
    } else if (type == 'Parent' && parentId != null) {
      return 'To: Parent ID: ${parentId!.substring(0, 6)}...';
    } else if (type == 'Class' && classId != null) {
      return 'To: Class ID: ${classId!.substring(0, 6)}...';
    }
    return 'To: Unknown recipient';
  }
}
