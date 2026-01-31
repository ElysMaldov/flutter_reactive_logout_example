import 'package:flutter/material.dart';
import 'package:flutter_reactive_logout_example/config/dependencies.dart';
import 'package:flutter_reactive_logout_example/routing/router.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });
  await DependencyManager.setup();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return MaterialApp.router(
      routerConfig: appRouter.router,
      title: 'Flutter Reactive Logout Example',
      debugShowCheckedModeBanner: false,
    );
  }
}
