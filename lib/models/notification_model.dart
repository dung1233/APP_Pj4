class NotificationModel {
  final int id;
  final int receiverId;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool read;

  NotificationModel({
    required this.id,
    required this.receiverId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.read,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toInt() ?? 0,
      receiverId: json['receiverId']?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      read: json['read'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiverId': receiverId,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'read': read,
    };
  }
}
