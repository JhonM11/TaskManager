import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prueba Técnica',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Prueba Técnica'),
        ),
        body: const Center(
          child: Text('¡Hola Mundo!'),
        ),
      ),
    );
  }
}
