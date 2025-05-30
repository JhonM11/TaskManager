import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tasks_screen.dart';

/// Pantalla de inicio de sesión simulado con solo ingreso de nombre de usuario
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  /// Guarda el username en SharedPreferences y navega a TasksScreen
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text.trim());

    setState(() => _isLoading = false);
    if (!mounted) return;

    // Navega a la pantalla principal de tareas y elimina la pantalla login del stack
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const TasksScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingrese un nombre de usuario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Entrar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
