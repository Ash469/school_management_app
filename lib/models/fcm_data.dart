class FCMData {
  final String? id; // Add the _id field from the server response
  final String userId;
  final String fcmToken;
  final String schoolId;
  final String userRole;
  final String topicSubscribed;
  final DateTime timestamp;

  FCMData({
    this.id, // Make _id optional since it's assigned by the server
    required this.userId,
    required this.fcmToken,
    required this.schoolId,
    required this.userRole,
    required this.topicSubscribed,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fcmToken': fcmToken,
      'schoolId': schoolId,
      'userRole': userRole,
      'topicSubscribed': topicSubscribed,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FCMData.fromJson(Map<String, dynamic> json) {
    return FCMData(
      id: json['_id'], // Get _id from the response
      userId: json['userId'],
      fcmToken: json['fcmToken'],
      schoolId: json['schoolId'],
      userRole: json['userRole'],
      topicSubscribed: json['topicSubscribed'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
