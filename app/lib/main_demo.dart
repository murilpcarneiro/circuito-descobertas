import 'package:flutter/material.dart';

import 'app.dart';
import 'services/demo.dart';

/// Abre o app sem Firebase, com estandes fictícios em memória.
/// Rode com:  flutter run -t lib/main_demo.dart
void main() {
  Demo.ativo = true;
  runApp(const CircuitoApp());
}
