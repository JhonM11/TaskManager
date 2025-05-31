import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart'; // Importa el nuevo archivo

void main() {
  runApp(const ProviderScope(child: MyApp())); // Llama a la clase MyApp del archivo app.dart
}
