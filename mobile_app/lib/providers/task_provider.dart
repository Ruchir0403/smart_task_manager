import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/task.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, AsyncValue<List<Task>>>((ref) {
      return TaskListNotifier(ref.read(apiServiceProvider));
    });

class TaskListNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final ApiService _apiService;

  TaskListNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks({
    String? search,
    String? category,
    String? priority,
  }) async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _apiService.getTasks(
        search: search,
        category: category,
        priority: priority,
      );
      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<Task?> addTask({
    required String title,
    required String desc,
    required String assignedTo,
    required DateTime? dueDate, // Changed from auto-generated to parameter
  }) async {
    try {
      final newTask = await _apiService.createTask({
        "title": title,
        "description": desc,
        "assigned_to": assignedTo,
        "due_date": dueDate?.toIso8601String(), // Send selected date
      });

      final currentList = state.value ?? [];
      state = AsyncValue.data([newTask, ...currentList]);

      return newTask;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _apiService.deleteTask(id);
      final currentList = state.value ?? [];
      state = AsyncValue.data(
        currentList.where((task) => task.id != id).toList(),
      );
    } catch (e) {
      print("Provider delete error: $e");
    }
  }
}
