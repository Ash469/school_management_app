class Announcement {
  final String id;
  final String title;
  final String content;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String? imageUrl;
  final DateTime createdAt;
  final List<String> targetAudience; // e.g., ["all", "parents", "grade_10"]
  final bool isEmergency;
  final bool isPublished;
  final List<String> readBy;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    this.imageUrl,
    required this.createdAt,
    required this.targetAudience,
    required this.isEmergency,
    required this.isPublished,
    required this.readBy,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['_id'],
      title: json['title'],
      content: json['content'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderRole: json['senderRole'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      targetAudience: List<String>.from(json['targetAudience']),
      isEmergency: json['isEmergency'],
      isPublished: json['isPublished'],
      readBy: List<String>.from(json['readBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'targetAudience': targetAudience,
      'isEmergency': isEmergency,
      'isPublished': isPublished,
      'readBy': readBy,
    };
  }
}