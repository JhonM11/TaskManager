import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';  // Import para formatear fechas
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskItem extends ConsumerWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

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
    // Formatear la fecha de vencimiento para mostrarla legible
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
              decoration: task.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            '${task.description}\nVence: $dueDateFormatted',
            style: TextStyle(
              color: task.completed ? Colors.grey : null,
            ),
          ),
          isThreeLine: true,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: task.completed,
                onChanged: (_) => ref.read(taskProvider.notifier).toggleCompletion(task),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => ref.read(taskProvider.notifier).deleteTask(task.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Función para mostrar el diálogo de edición
  void _showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    DateTime selectedDate = task.dueDate;
    TaskPriority priority = task.priority;
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar Tarea'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Fecha: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final now = DateTime.now();
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: now,
                              lastDate: DateTime(now.year + 5),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        )
                      ],
                    ),
                    DropdownButtonFormField<TaskPriority>(
                      value: priority,
                      decoration: const InputDecoration(labelText: 'Prioridad'),
                      items: TaskPriority.values
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.name.toUpperCase()),
                            ),
                          )
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
                  if (_formKey.currentState!.validate()) {
                    final updatedTask = Task(
                      id: task.id,
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      dueDate: selectedDate,
                      priority: priority,
                      completed: task.completed,
                    );
                    await ref.read(taskProvider.notifier).editTask(updatedTask);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
                child: const Text('Actualizar'),
              ),
            ],
          );
        });
      },
    );
  }
}
