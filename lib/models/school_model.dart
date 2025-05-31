class School {
  final String id;
  final String name;
  final String address;
  final String contactEmail;
  final String contactPhone;
  final String logo;
  final String adminId;
  final SchoolSubscription subscription;
  final SchoolSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  School({
    required this.id,
    required this.name,
    required this.address,
    required this.contactEmail,
    required this.contactPhone,
    required this.logo,
    required this.adminId,
    required this.subscription,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['_id'],
      name: json['name'],
      address: json['address'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      logo: json['logo'],
      adminId: json['adminId'],
      subscription: SchoolSubscription.fromJson(json['subscription']),
      settings: SchoolSettings.fromJson(json['settings']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'logo': logo,
      'adminId': adminId,
      'subscription': subscription.toJson(),
      'settings': settings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class SchoolSubscription {
  final String plan;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  SchoolSubscription({
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory SchoolSubscription.fromJson(Map<String, dynamic> json) {
    return SchoolSubscription(
      plan: json['plan'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
    };
  }
}

class SchoolSettings {
  final Map<String, dynamic> theme;
  final Map<String, dynamic> notifications;
  final AcademicYear academicYear;

  SchoolSettings({
    required this.theme,
    required this.notifications,
    required this.academicYear,
  });

  factory SchoolSettings.fromJson(Map<String, dynamic> json) {
    return SchoolSettings(
      theme: json['theme'],
      notifications: json['notifications'],
      academicYear: AcademicYear.fromJson(json['academicYear']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'notifications': notifications,
      'academicYear': academicYear.toJson(),
    };
  }
}

class AcademicYear {
  final DateTime start;
  final DateTime end;

  AcademicYear({
    required this.start,
    required this.end,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    return AcademicYear(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }
}
