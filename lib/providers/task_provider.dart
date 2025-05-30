import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/fake_repository.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';

/// Proveedor para inyectar FakeRepository
final repositoryProvider = Provider<FakeRepository>((ref) => FakeRepository());

/// Provider con parámetro (family) para recibir username y proveer estado de tareas de ese usuario
final taskProvider = StateNotifierProvider.family<TaskNotifier, AsyncValue<List<Task>>, String>(
  (ref, username) {
    final repo = ref.watch(repositoryProvider);
    return TaskNotifier(repo, username);
  },
);

/// Notifier que maneja la lógica de estado de tareas para un usuario
class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final FakeRepository repo;
  final String username;

  TaskNotifier(this.repo, this.username) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  /// Carga tareas del usuario y actualiza estado
  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repo.fetchTasks(username));
  }

  /// Agrega tarea nueva asociada al usuario
  Future<void> addTask(String title, String description, DateTime dueDate, TaskPriority priority) async {
    final newTask = Task(
      id: const Uuid().v4(),
      username: username,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
    );
    await repo.addTask(newTask);
    await loadTasks();
  }

  /// Cambia el estado completado de una tarea
  Future<void> toggleCompletion(Task task) async {
    final updatedTask = task.copyWith(completed: !task.completed);
    await repo.updateTask(updatedTask);
    await loadTasks();
  }

  /// Elimina tarea por ID para este usuario
  Future<void> deleteTask(String id) async {
    await repo.deleteTask(username, id);
    await loadTasks();
  }

  /// Edita tarea existente
  Future<void> editTask(Task updatedTask) async {
    await repo.updateTask(updatedTask);
    await loadTasks();
  }
}
