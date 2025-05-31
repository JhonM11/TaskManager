// Importaciones necesarias para el uso de widgets, Riverpod, modelos y persistencia local
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/task_item.dart';

// Pantalla principal donde se gestionan las tareas
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String? username; // Nombre del usuario obtenido de SharedPreferences

  @override
  void initState() {
    super.initState();
    _loadUsername(); // Cargar el nombre del usuario al iniciar
  }

  // Carga el nombre de usuario almacenado localmente
  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
  }

  // Cierra la sesión del usuario y redirige a la pantalla de login
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // Función para mostrar SnackBars personalizados con ícono y color
  void _showAppSnackbar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Muestra un loader mientras se obtiene el nombre del usuario
    if (username == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Observa el estado de la lista de tareas usando Riverpod
    final taskState = ref.watch(taskProvider(username!));

    return Scaffold(
      body: Container(
        // Fondo con degradado
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Encabezado con el nombre del usuario y botón de cerrar sesión
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                color: const Color(0xFF4DB6AC),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Tareas de $username',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 5, 40, 36),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: _logout,
                      tooltip: 'Cerrar sesión',
                    ),
                  ],
                ),
              ),
              // Lista de tareas o estado de carga/error
              Expanded(
                child: taskState.when(
                  data: (tasks) => tasks.isEmpty
                      ? const Center(child: Text('No tienes tareas creadas'))
                      : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (_, index) => TaskItem(
                            task: tasks[index],
                            username: username!,
                            onCompleted: _showAppSnackbar,
                            onDeleted: _showAppSnackbar,
                            onUpdated: _showAppSnackbar, // callback de actualización
                          ),
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),
        ),
      ),
      // Botón para agregar una nueva tarea
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
        tooltip: 'Agregar tarea',
        backgroundColor: const Color(0xFF4DB6AC),
      ),
    );
  }

  // Muestra el diálogo para crear una nueva tarea
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
                // Campo de título
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                // Campo de descripción
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 10),
                // Selección de fecha
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
                    ),
                  ],
                ),
                // Selector de prioridad
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
          // Botón para cancelar
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          // Botón para guardar la tarea
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (selectedDate == null) {
                  _showAppSnackbar(
                    'Seleccione una fecha',
                    Icons.calendar_today,
                    Colors.orange,
                  );
                  return;
                }

                final messenger = ScaffoldMessenger.of(context);
                // Mostrar spinner de carga
                messenger.showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 10),
                        Text('Guardando tarea...'),
                      ],
                    ),
                    duration: Duration(minutes: 1),
                  ),
                );

                // Crear la tarea
                await ref.read(taskProvider(username!).notifier).addTask(
                      titleController.text.trim(),
                      descriptionController.text.trim(),
                      selectedDate!,
                      priority,
                    );

                // Ocultar spinner y mostrar notificación de éxito
                messenger.hideCurrentSnackBar();
                _showAppSnackbar('Tarea guardada.', Icons.check, Colors.green);

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
