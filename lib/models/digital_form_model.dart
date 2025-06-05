class DigitalForm {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final DateTime expiryDate;
  final List<String> targetAudience; // e.g., ["parents", "grade_10"]
  final List<FormField> fields;
  final bool isActive;
  final bool requiresApproval;
  final List<FormSubmission> submissions;

  DigitalForm({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.expiryDate,
    required this.targetAudience,
    required this.fields,
    required this.isActive,
    required this.requiresApproval,
    required this.submissions,
  });

  factory DigitalForm.fromJson(Map<String, dynamic> json) {
    return DigitalForm(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      expiryDate: DateTime.parse(json['expiryDate']),
      targetAudience: List<String>.from(json['targetAudience']),
      fields: (json['fields'] as List)
          .map((field) => FormField.fromJson(field))
          .toList(),
      isActive: json['isActive'],
      requiresApproval: json['requiresApproval'],
      submissions: (json['submissions'] as List)
          .map((submission) => FormSubmission.fromJson(submission))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'targetAudience': targetAudience,
      'fields': fields.map((field) => field.toJson()).toList(),
      'isActive': isActive,
      'requiresApproval': requiresApproval,
      'submissions': submissions.map((submission) => submission.toJson()).toList(),
    };
  }
}

class FormField {
  final String id;
  final String label;
  final String type; // "text", "number", "date", "select", "checkbox", "file"
  final bool isRequired;
  final List<String>? options; // For "select" type
  final String? defaultValue;
  final String? placeholder;

  FormField({
    required this.id,
    required this.label,
    required this.type,
    required this.isRequired,
    this.options,
    this.defaultValue,
    this.placeholder,
  });

  factory FormField.fromJson(Map<String, dynamic> json) {
    return FormField(
      id: json['id'],
      label: json['label'],
      type: json['type'],
      isRequired: json['isRequired'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      defaultValue: json['defaultValue'],
      placeholder: json['placeholder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'type': type,
      'isRequired': isRequired,
      'options': options,
      'defaultValue': defaultValue,
      'placeholder': placeholder,
    };
  }
}

class FormSubmission {
  final String id;
  final String userId;
  final String userName;
  final DateTime submittedAt;
  final Map<String, dynamic> responses;
  final String status; // "pending", "approved", "rejected"
  final String? approvedBy;
  final DateTime? reviewedAt;
  final String? comments;

  FormSubmission({
    required this.id,
    required this.userId,
    required this.userName,
    required this.submittedAt,
    required this.responses,
    required this.status,
    this.approvedBy,
    this.reviewedAt,
    this.comments,
  });

  factory FormSubmission.fromJson(Map<String, dynamic> json) {
    return FormSubmission(
      id: json['_id'],
      userId: json['userId'],
      userName: json['userName'],
      submittedAt: DateTime.parse(json['submittedAt']),
      responses: json['responses'],
      status: json['status'],
      approvedBy: json['approvedBy'],
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      comments: json['comments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'userName': userName,
      'submittedAt': submittedAt.toIso8601String(),
      'responses': responses,
      'status': status,
      'approvedBy': approvedBy,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'comments': comments,
    };
  }
}