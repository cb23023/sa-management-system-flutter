class CoCurriculumNotificationModel {
  const CoCurriculumNotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.actionLink,
    required this.isRead,
  });

  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String actionLink;
  final bool isRead;

  factory CoCurriculumNotificationModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return CoCurriculumNotificationModel(
      id: id,
      userId: (data['userId'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      message: (data['message'] ?? '').toString(),
      type: (data['type'] ?? 'info').toString(),
      actionLink: (data['actionLink'] ?? '').toString(),
      isRead: data['isRead'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'module': 'module2',
      'actionLink': actionLink,
      'isRead': isRead,
    };
  }
}
