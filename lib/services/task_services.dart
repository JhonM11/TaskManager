import '../models/task.dart';
import '../repository/fake_repository.dart';

class TaskService {
  final FakeRepository repo;

  TaskService(this.repo);

  Future<List<Task>> fetchTasks(String username) => repo.fetchTasks(username);

  Future<Task> addTask(Task task) => repo.addTask(task);

  Future<Task> updateTask(Task task) => repo.updateTask(task);

  Future<void> deleteTask(String username, String id) => repo.deleteTask(username, id);
}
