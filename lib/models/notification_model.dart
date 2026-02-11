enum NotificationType { offer, announcement, reminder }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final bool isSent;
  final int recipientCount;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.scheduledFor,
    this.isSent = false,
    this.recipientCount = 0,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> data) {
    return AppNotification(
      id: id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (type) => type.toString().split('.').last == data['type'],
        orElse: () => NotificationType.announcement,
      ),
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      scheduledFor: data['scheduledFor'] != null
          ? DateTime.parse(data['scheduledFor'])
          : null,
      isSent: data['isSent'] ?? false,
      recipientCount: data['recipientCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'isSent': isSent,
      'recipientCount': recipientCount,
    };
  }
}
