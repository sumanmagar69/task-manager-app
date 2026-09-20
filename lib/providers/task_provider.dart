import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<Task>>? _taskSubscription;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Start listening to the user's tasks
  void listenToTasks(String userId) {
    _taskSubscription?.cancel();

    _isLoading = true;
    _error = null;
    notifyListeners();

    _taskSubscription = _taskService.getTasks(userId).listen(
      (tasks) {
        _tasks = tasks;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // CREATE
  Future<void> addTask({
    required String userId,
    required String title,
    required String description,
  }) async {
    try {
      await _taskService.addTask(
        userId: userId,
        title: title,
        description: description,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // UPDATE
  Future<void> updateTask({
    required String userId,
    required String taskId,
    required String title,
    required String description,
    required bool isCompleted,
  }) async {
    try {
      await _taskService.updateTask(
        userId: userId,
        taskId: taskId,
        title: title,
        description: description,
        isCompleted: isCompleted,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // DELETE
  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    try {
      await _taskService.deleteTask(
        userId: userId,
        taskId: taskId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }
}