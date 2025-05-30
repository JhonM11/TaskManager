import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/fake_repository.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';

/// Proveedor para inyectar FakeRepository
final repositoryProvider = Provider<FakeRepository>((ref) => FakeRepository());

/// StateNotifierProvider que gestiona el estado de la lista de tareas y las operaciones CRUD
final taskProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return TaskNotifier(repo);
});

/// StateNotifier que maneja la lógica del estado de tareas
class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final FakeRepository repo;

  TaskNotifier(this.repo) : super(const AsyncValue.loading()) {
    loadTasks(); // Carga inicial de tareas al instanciar
  }

  /// Carga las tareas y actualiza el estado con el resultado o error
  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repo.fetchTasks());
  }

  /// Agrega una tarea y recarga el estado
  Future<void> addTask(String title, String description, DateTime dueDate, TaskPriority priority) async {
    final newTask = Task(
      id: const Uuid().v4(), // Genera UUID único para cada tarea
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
    );
    await repo.addTask(newTask);
    await loadTasks();
  }

  /// Cambia el estado de completado y actualiza la tarea
  Future<void> toggleCompletion(Task task) async {
    await repo.updateTask(task.copyWith(completed: !task.completed));
    await loadTasks();
  }

  /// Elimina una tarea por su ID y recarga el estado
  Future<void> deleteTask(String id) async {
    await repo.deleteTask(id);
    await loadTasks();
  }

  Future<void> editTask(Task updatedTask) async {
  await repo.updateTask(updatedTask);
  await loadTasks();
}



}

