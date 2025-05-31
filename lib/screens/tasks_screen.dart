import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/task_item.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (username == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final taskState = ref.watch(taskProvider(username!));

    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas de $username'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: taskState.when(
        data: (tasks) => tasks.isEmpty
            ? const Center(child: Text('No tienes tareas creadas'))
            : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (_, index) => TaskItem(
                  task: tasks[index],
                  username: username!,
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Agregar tarea',
      ),
    );
  }

  void _showAddTaskDialog() {
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
                    Expanded(
                      child: Text(
                        selectedDate == null
                            ? 'Fecha de vencimiento'
                            : 'Fecha: ${selectedDate!.toLocal()}'.split(' ')[0],
                      ),
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
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Seleccione una fecha')));
                  return;
                }

                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(const SnackBar(
                  content: Row(children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 10),
                    Text('Guardando tarea...')
                  ]),
                  duration: Duration(minutes: 1),
                ));

                await ref.read(taskProvider(username!).notifier).addTask(
                    titleController.text.trim(),
                    descriptionController.text.trim(),
                    selectedDate!,
                    priority);

                messenger.hideCurrentSnackBar();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Tarea guardada ✔')),
                );

                if (mounted) Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
