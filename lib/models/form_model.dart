import 'package:intl/intl.dart';

class FormType {
  final String id;
  final String name;
  final String code;
  final String description;

  FormType({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
  });

  factory FormType.fromJson(Map<String, dynamic> json) {
    return FormType(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class FormData {
  final String id;
  final String schoolId;
  final String studentId;
  final String type;
  final Map<String, dynamic> data;
  final String status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewComment;
  final String? reviewerId;
  final String? reviewerName;

  FormData({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.type,
    required this.data,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewComment,
    this.reviewerId,
    this.reviewerName,
  });

  factory FormData.fromJson(Map<String, dynamic> json) {
    // Print the JSON for debugging
    print('Form JSON: $json');
    
    // Handle _id or id
    String formId = json['_id'] ?? json['id'] ?? '';
    
    // Parse dates
    DateTime submittedDate;
    try {
      submittedDate = DateTime.parse(json['submittedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String());
    } catch (e) {
      print('Error parsing submission date: $e');
      submittedDate = DateTime.now();
    }
    
    DateTime? reviewDate;
    if (json['reviewedAt'] != null) {
      try {
        reviewDate = DateTime.parse(json['reviewedAt']);
      } catch (e) {
        print('Error parsing review date: $e');
      }
    }
    
    // Get form type
    String formType = '';
    if (json['type'] != null) {
      formType = json['type'];
    }
    
    // Get form data
    Map<String, dynamic> formData = {};
    if (json['data'] != null && json['data'] is Map) {
      formData = Map<String, dynamic>.from(json['data']);
    }
    
    return FormData(
      id: formId,
      schoolId: json['schoolId'] ?? '',
      studentId: json['studentId'] ?? '',
      type: formType,
      data: formData,
      status: json['status'] ?? 'pending',
      submittedAt: submittedDate,
      reviewedAt: reviewDate,
      reviewComment: json['reviewComment'],
      reviewerId: json['reviewerId'],
      reviewerName: json['reviewerName'],
    );
  }

  // Convert to a map for UI display
  Map<String, dynamic> toUIMap() {
    // Get a more readable form type name
    String formTypeName = '';
    switch (type) {
      case 'leave_request':
        formTypeName = 'Leave Request';
        break;
      case 'event_participation':
        formTypeName = 'Event Participation';
        break;
      case 'feedback':
        formTypeName = 'Feedback';
        break;
      case 'other':
        formTypeName = 'Other Request';
        break;
      default:
        formTypeName = type.split('_').map((word) => 
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
        ).join(' ');
    }
    
    // Convert status to title case for UI
    String displayStatus = '';
    switch (status.toLowerCase()) {
      case 'pending':
        displayStatus = 'Pending';
        break;
      case 'approved':
        displayStatus = 'Approved';
        break;
      case 'rejected':
        displayStatus = 'Rejected';
        break;
      case 'cancelled':
        displayStatus = 'Cancelled';
        break;
      default:
        displayStatus = status.isNotEmpty ? 
          '${status[0].toUpperCase()}${status.substring(1)}' : 'Pending';
    }
    
    // Parse the requested date from data
    DateTime requestedDate;
    try {
      if (data.containsKey('date') && data['date'] != null) {
        requestedDate = DateTime.parse(data['date']);
      } else if (data.containsKey('startDate') && data['startDate'] != null) {
        requestedDate = DateTime.parse(data['startDate']);
      } else {
        requestedDate = submittedAt;
      }
    } catch (e) {
      print('Error parsing requested date: $e');
      requestedDate = submittedAt;
    }
    
    return {
      'id': id,
      'type': formTypeName,
      'title': data['title'] ?? 'Untitled Request',
      'description': data['description'] ?? '',
      'status': displayStatus,
      'submissionDate': submittedAt,
      'requestedDate': requestedDate,
      'responder': reviewerName ?? 'Staff Member',
      'responseMessage': reviewComment ?? 'No additional comments',
    };
  }
}
