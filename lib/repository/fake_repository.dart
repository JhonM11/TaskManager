import 'dart:async';
import '../models/task.dart';

/// Repositorio simulado que almacena tareas por usuario en memoria
class FakeRepository {
  /// Mapa de username a lista de tareas para ese usuario
  final Map<String, List<Task>> _tasksByUser = {};

  /// Obtiene la lista de tareas del usuario especificado
  Future<List<Task>> fetchTasks(String username) async {
    await Future.delayed(const Duration(seconds: 2)); // Simula latencia
    return List.unmodifiable(_tasksByUser[username] ?? []);
  }

  /// Agrega una tarea a la lista del usuario correspondiente
  Future<Task> addTask(Task task) async {
    await Future.delayed(const Duration(seconds: 1));
    _tasksByUser.putIfAbsent(task.username, () => []);
    _tasksByUser[task.username]!.add(task);
    return task;
  }

  /// Actualiza una tarea existente para el usuario dado
  Future<Task> updateTask(Task updatedTask) async {
    await Future.delayed(const Duration(seconds: 1));
    final tasks = _tasksByUser[updatedTask.username];
    if (tasks == null) throw Exception('No se encontraron tareas para el usuario');
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index == -1) throw Exception('Tarea no encontrada');
    tasks[index] = updatedTask;
    return updatedTask;
  }

  /// Elimina una tarea por ID para el usuario dado
  Future<void> deleteTask(String username, String id) async {
    await Future.delayed(const Duration(seconds: 1));
    final tasks = _tasksByUser[username];
    if (tasks == null) return;
    tasks.removeWhere((t) => t.id == id);
  }
}
