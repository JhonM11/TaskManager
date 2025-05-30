import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import '../models/task.dart';
import '../providers/task_provider.dart';

/// Widget que representa una tarea en la lista con opciones para editar, completar y eliminar.
/// Recibe la tarea y el username del usuario activo para interactuar con el provider correcto.
class TaskItem extends ConsumerWidget {
  final Task task;
  final String username; // Usuario propietario de la tarea, necesario para el provider family

  const TaskItem({
    super.key,
    required this.task,
    required this.username,
  });

  /// Retorna el color asociado a la prioridad
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

  /// Retorna el icono asociado a la prioridad
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
    // Formateamos la fecha para mostrarla legible
    final dueDateFormatted = DateFormat('dd/MM/yyyy').format(task.dueDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: InkWell(
        // Al tocar la tarjeta se abre el diálogo para editar la tarea
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
              // Checkbox para marcar la tarea como completada o no
              Checkbox(
                value: task.completed,
                onChanged: (_) =>
                    ref.read(taskProvider(username).notifier).toggleCompletion(task),
              ),
              // Botón para eliminar la tarea
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () =>
                    ref.read(taskProvider(username).notifier).deleteTask(task.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra un diálogo modal para editar la tarea
  void _showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    DateTime selectedDate = task.dueDate;
    TaskPriority priority = task.priority;
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        // Usamos StatefulBuilder para manejar estado local dentro del diálogo
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar Tarea'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Campo para editar título
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo requerido' : null,
                    ),
                    // Campo para editar descripción
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 10),
                    // Selector de fecha de vencimiento con botón calendario
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
                        ),
                      ],
                    ),
                    // Selector para prioridad
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
              // Botón cancelar cierra el diálogo sin guardar
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              // Botón actualizar valida y guarda cambios
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final updatedTask = Task(
                      id: task.id,
                      username: task.username, // Mantener el usuario original
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      dueDate: selectedDate,
                      priority: priority,
                      completed: task.completed,
                    );
                    await ref.read(taskProvider(task.username).notifier).editTask(updatedTask);
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
