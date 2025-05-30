import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_screen.dart';
import 'screens/tasks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/// Widget principal que determina la pantalla inicial según sesión guardada
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Verifica si el usuario está logueado leyendo SharedPreferences
  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('username');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      home: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Muestra un loader mientras verifica sesión
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // Si está logueado va a TasksScreen, sino LoginScreen
          if (snapshot.hasData && snapshot.data!) {
            return const TasksScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
