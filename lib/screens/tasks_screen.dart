import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/task_item.dart';

/// Pantalla principal para mostrar lista de tareas y acciones CRUD
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  /// Cierra sesión borrando el username y redirigiendo a login
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  /// Muestra diálogo para agregar nueva tarea
  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;
    TaskPriority priority = TaskPriority.media;
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agregar Tarea'),
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
                    Text(
                      selectedDate == null
                          ? 'Fecha de vencimiento'
                          : 'Fecha: ${selectedDate!.toLocal()}'.split(' ')[0],
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final now = DateTime.now();
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: now,
                          lastDate: DateTime(now.year + 5),
                        );
                        if (pickedDate != null) {
                          selectedDate = pickedDate;
                          // Usar setState en StatefulBuilder para refrescar diálogo
                          (context as Element).markNeedsBuild();
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
                      priority = value;
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
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seleccione una fecha')),
                  );
                  return;
                }
                await ref.read(taskProvider.notifier).addTask(
                      titleController.text.trim(),
                      descriptionController.text.trim(),
                      selectedDate!,
                      priority,
                    );
                if (context.mounted) Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: taskState.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text('No hay tareas registradas'));
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (_, index) {
              final task = tasks[index];
              return TaskItem(task: task);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, ref),
        child: const Icon(Icons.add),
        tooltip: 'Agregar tarea',
      ),
    );
  }
}
