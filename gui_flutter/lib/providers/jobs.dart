import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TaskTag {
  final String name;
  final Color color;

  TaskTag({required this.name, this.color = Colors.white});
}

class Task {
  final String id;
  final String name;
  final String description;
  final String type;
  final DateTime nextLaunch;
  final List<TaskTag> tags;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.nextLaunch,
    required this.tags,
  });
}

class Jobs with ChangeNotifier {
  final List<Task> _jobs = [
    Task(
      id: Uuid().v4(),
      name: 'Project files',
      description: 'Work files backup',
      type: 'Regular',
      nextLaunch: DateTime.now(),
      tags: [],
    ),
    Task(
      id: Uuid().v4(),
      name: 'Family photos',
      description: '-',
      type: 'Manual',
      nextLaunch: DateTime.now(),
      tags: [],
    ),
    Task(
      id: Uuid().v4(),
      name: 'C:/ drive backup',
      description: '-',
      type: 'Regular',
      nextLaunch: DateTime.now(),
      tags: [],
    ),
  ];

  List<Task> get jobs {
    return [..._jobs];
  }

  void addNewTask(Task newTask) {
    _jobs.add(newTask);
    notifyListeners();
  }

  void removeTaskById(String id) {
    _jobs.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Task getTaskInfoById(String id) {
    return _jobs[_jobs.indexWhere((element) => element.id == id)];
  }
}
