import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tasksCollection(
    String userId,
  ) {
    return _firestore
        .collection('tasks')
        .doc(userId)
        .collection('userTasks');
  }

  // CREATE
  Future<void> addTask({
    required String userId,
    required String title,
    required String description,
  }) async {
    await _tasksCollection(userId).add({
      'title': title,
      'description': description,
      'isCompleted': false,
      'userId': userId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // READ - Real-time stream
  Stream<List<Task>> getTasks(String userId) {
    return _tasksCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Task.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  // UPDATE
  Future<void> updateTask({
    required String userId,
    required String taskId,
    required String title,
    required String description,
    required bool isCompleted,
  }) async {
    await _tasksCollection(userId).doc(taskId).update({
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    });
  }

  // DELETE
  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    await _tasksCollection(userId).doc(taskId).delete();
  }
}