class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String receiverId;
  final String receiverName;
  final String receiverRole;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final List<String>? attachments;
  final bool? isDeleted;
  final String? replyToMessageId;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.receiverId,
    required this.receiverName,
    required this.receiverRole,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.attachments,
    this.isDeleted,
    this.replyToMessageId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderRole: json['senderRole'],
      receiverId: json['receiverId'],
      receiverName: json['receiverName'],
      receiverRole: json['receiverRole'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      isDeleted: json['isDeleted'],
      replyToMessageId: json['replyToMessageId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverRole': receiverRole,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'attachments': attachments,
      'isDeleted': isDeleted,
      'replyToMessageId': replyToMessageId,
    };
  }
}

class Chat {
  final String id;
  final List<String> participants; // User IDs
  final List<ParticipantInfo> participantInfo;
  final Message lastMessage;
  final int unreadCount;
  final bool isGroup;
  final String? groupName;
  final String? groupPhoto;

  Chat({
    required this.id,
    required this.participants,
    required this.participantInfo,
    required this.lastMessage,
    required this.unreadCount,
    required this.isGroup,
    this.groupName,
    this.groupPhoto,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'],
      participants: List<String>.from(json['participants']),
      participantInfo: (json['participantInfo'] as List)
          .map((info) => ParticipantInfo.fromJson(info))
          .toList(),
      lastMessage: Message.fromJson(json['lastMessage']),
      unreadCount: json['unreadCount'],
      isGroup: json['isGroup'],
      groupName: json['groupName'],
      groupPhoto: json['groupPhoto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'participants': participants,
      'participantInfo':
          participantInfo.map((info) => info.toJson()).toList(),
      'lastMessage': lastMessage.toJson(),
      'unreadCount': unreadCount,
      'isGroup': isGroup,
      'groupName': groupName,
      'groupPhoto': groupPhoto,
    };
  }
}

class ParticipantInfo {
  final String userId;
  final String name;
  final String role;
  final String? photoUrl;

  ParticipantInfo({
    required this.userId,
    required this.name,
    required this.role,
    this.photoUrl,
  });

  factory ParticipantInfo.fromJson(Map<String, dynamic> json) {
    return ParticipantInfo(
      userId: json['userId'],
      name: json['name'],
      role: json['role'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
    };
  }
}