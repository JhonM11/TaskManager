import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/repository/fake_repository.dart';
import 'package:task_manager/services/task_services.dart';

void main() {
  late FakeRepository repository;
  late TaskService taskService;

  const String username = 'usuario_test';

  setUp(() {
    repository = FakeRepository();
    taskService = TaskService(repository);
  });

  test('fetchTasks devuelve una lista vacía inicialmente', () async {
    final tasks = await taskService.fetchTasks(username);
    expect(tasks, isEmpty);
  });

  test('addTask agrega correctamente una tarea', () async {
    final task = Task(
      id: const Uuid().v4(),
      username: username,
      title: 'Tarea 1',
      description: 'Descripción',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: TaskPriority.alta,
    );

    await taskService.addTask(task);
    final tasks = await taskService.fetchTasks(username);

    expect(tasks.length, 1);
    expect(tasks.first.title, equals('Tarea 1'));
  });

  test('updateTask modifica correctamente una tarea existente', () async {
    final originalTask = Task(
      id: const Uuid().v4(),
      username: username,
      title: 'Original',
      description: 'Descripción',
      dueDate: DateTime.now(),
      priority: TaskPriority.media,
    );

    await taskService.addTask(originalTask);

    final updatedTask = originalTask.copyWith(completed: true);
    await taskService.updateTask(updatedTask);

    final tasks = await taskService.fetchTasks(username);
    expect(tasks.first.completed, isTrue);
  });

  test('deleteTask elimina correctamente la tarea', () async {
    final task = Task(
      id: const Uuid().v4(),
      username: username,
      title: 'Eliminar',
      description: 'Descripción',
      dueDate: DateTime.now(),
      priority: TaskPriority.baja,
    );

    await taskService.addTask(task);
    await taskService.deleteTask(username, task.id);

    final tasks = await taskService.fetchTasks(username);
    expect(tasks.any((t) => t.id == task.id), isFalse);
  });
}
