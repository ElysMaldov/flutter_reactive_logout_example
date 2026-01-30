import 'package:flutter/material.dart';
import 'package:flutter_reactive_logout_example/config/dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyManager.setup();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
