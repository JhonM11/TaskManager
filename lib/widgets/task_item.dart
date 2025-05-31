import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

/// Widget que representa una tarjeta de tarea con sus acciones
class TaskItem extends ConsumerWidget {
  final Task task;
  final String username;

  // Funciones callback para notificaciones
  final void Function(String, IconData, Color)? onCompleted;
  final void Function(String, IconData, Color)? onDeleted;
  final void Function(String, IconData, Color)? onUpdated;

  const TaskItem({
    super.key,
    required this.task,
    required this.username,
    this.onCompleted,
    this.onDeleted,
    this.onUpdated,
  });

  /// Color basado en la prioridad
  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.alta:
        return Colors.red;
      case TaskPriority.media:
        return Colors.orange;
      case TaskPriority.baja:
        return Colors.green;
    }
  }

  /// Icono basado en la prioridad
  IconData _priorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.alta:
        return Icons.priority_high;
      case TaskPriority.media:
        return Icons.low_priority;
      case TaskPriority.baja:
        return Icons.label_outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueDateFormatted = DateFormat('dd/MM/yyyy').format(task.dueDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: InkWell(
        onTap: () => _showEditTaskDialog(context, ref, task),
        child: ListTile(
          leading: Icon(
            _priorityIcon(task.priority),
            color: _priorityColor(task.priority),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration:
                  task.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            '${task.description}\nVence: $dueDateFormatted',
            style: TextStyle(color: task.completed ? Colors.grey : null),
          ),
          isThreeLine: true,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Completar o desmarcar
              Checkbox(
                value: task.completed,
                onChanged: (_) async {
                  final wasCompleted = task.completed;
                  await ref
                      .read(taskProvider(username).notifier)
                      .toggleCompletion(task);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final nowCompleted = !wasCompleted;
                    onCompleted?.call(
                      nowCompleted
                          ? 'Tarea completada.'
                          : 'Tarea marcada como incompleta.',
                      nowCompleted ? Icons.check_circle : Icons.undo,
                      nowCompleted ? Colors.green : Colors.orange,
                    );
                  });
                },
              ),
              // Eliminar tarea
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () async {
                  await ref
                      .read(taskProvider(username).notifier)
                      .deleteTask(task.id);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onDeleted?.call(
                      'Tarea eliminada.',
                      Icons.delete,
                      Colors.red,
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Diálogo para editar tarea
  void _showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    DateTime selectedDate = task.dueDate;
    TaskPriority priority = task.priority;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Tarea'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Título'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Campo requerido'
                            : null,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Descripción'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Campo requerido'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text('Fecha: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: now,
                                lastDate: DateTime(now.year + 5),
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      DropdownButtonFormField<TaskPriority>(
                        value: priority,
                        decoration: const InputDecoration(labelText: 'Prioridad'),
                        items: TaskPriority.values
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.name.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              priority = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.showSnackBar(const SnackBar(
                        content: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 10),
                            Text('Actualizando tarea...'),
                          ],
                        ),
                        duration: Duration(minutes: 1),
                      ));

                      final updatedTask = Task(
                        id: task.id,
                        username: task.username,
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                        dueDate: selectedDate,
                        priority: priority,
                        completed: task.completed,
                      );

                      await ref
                          .read(taskProvider(task.username).notifier)
                          .editTask(updatedTask);

                      messenger.hideCurrentSnackBar();
                      onUpdated?.call(
                        'Tarea actualizada.',
                        Icons.update,
                        Colors.indigo,
                      );

                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
