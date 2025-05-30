import 'dart:async';
import '../models/task.dart';

/// Repositorio simulado que actúa como API fake con respuestas retrasadas para simular latencia
class FakeRepository {
  final List<Task> _tasks = [];

  /// Simula obtener todas las tareas (GET)
  Future<List<Task>> fetchTasks() async {
    await Future.delayed(const Duration(seconds: 2)); // Simula latencia de red
    return List.unmodifiable(_tasks); // Retorna una copia inmutable para evitar modificaciones externas
  }

  /// Simula agregar una nueva tarea (POST)
  Future<Task> addTask(Task task) async {
    await Future.delayed(const Duration(seconds: 1));
    _tasks.add(task);
    return task;
  }

  /// Simula actualizar una tarea existente (PUT)
  Future<Task> updateTask(Task updatedTask) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index == -1) throw Exception('Task not found');
    _tasks[index] = updatedTask;
    return updatedTask;
  }

  /// Simula eliminar una tarea (DELETE)
  Future<void> deleteTask(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    _tasks.removeWhere((task) => task.id == id);
  }
}
