import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/task.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      // return 'http://localhost:3000/api/tasks';
      return 'https://smart-task-manager-5zv5.onrender.com/api/tasks';
    } else {
      // return 'http://10.0.2.2:3000/api/tasks';
      return 'https://smart-task-manager-5zv5.onrender.com/api/tasks';
    }
  }

  final Dio _dio = Dio();

  Future<List<Task>> getTasks({
    String? search,
    String? category,
    String? priority,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (priority != null && priority.isNotEmpty) {
        queryParams['priority'] = priority;
      }

      final response = await _dio.get(baseUrl, queryParameters: queryParams);
      final List data = response.data['data'];
      return data.map((e) => Task.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching tasks: $e");
      rethrow;
    }
  }

  Future<Task> createTask(Map<String, dynamic> taskData) async {
    try {
      final response = await _dio.post(baseUrl, data: taskData);
      return Task.fromJson(response.data['data']);
    } catch (e) {
      print("Error creating task: $e");
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete('$baseUrl/$id');
    } catch (e) {
      print("Error deleting task: $e");
      rethrow;
    }
  }
}
