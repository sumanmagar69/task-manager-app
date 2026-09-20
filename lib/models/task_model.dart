class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String userId;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.userId,
    required this.createdAt,
  });

  factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}