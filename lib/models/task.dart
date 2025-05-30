/// Enum para definir la prioridad de la tarea
enum TaskPriority { alta, media, baja }

/// Modelo que representa una tarea
class Task {
  final String id;            // Identificador único (UUID)
  final String title;         // Título de la tarea
  final String description;   // Descripción de la tarea
  final DateTime dueDate;     // Fecha de vencimiento
  final TaskPriority priority;// Prioridad de la tarea
  bool completed;             // Estado de completado (mutable)

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.completed = false,
  });

  /// Crea una copia modificada del objeto Task (ideal para inmutabilidad parcial)
  Task copyWith({bool? completed}) => Task(
        id: id,
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        completed: completed ?? this.completed,
      );
}
