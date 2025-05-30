/// Modelo que representa una tarea con asociación a un usuario (username)
enum TaskPriority { alta, media, baja }

class Task {
  final String id;            // ID único de la tarea
  final String username;      // Nombre de usuario propietario de la tarea
  final String title;         // Título de la tarea
  final String description;   // Descripción de la tarea
  final DateTime dueDate;     // Fecha de vencimiento
  final TaskPriority priority;// Prioridad (alta, media, baja)
  bool completed;             // Estado de completado (mutable)

  Task({
    required this.id,
    required this.username, // <-- ahora obligatorio para identificar propietario
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.completed = false,
  });

  /// Crea una copia modificada del objeto Task (ejemplo para cambiar completado)
  Task copyWith({bool? completed}) => Task(
        id: id,
        username: username,
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        completed: completed ?? this.completed,
      );
}
