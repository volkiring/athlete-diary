import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/workout_store.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  runApp(AthleteDiaryApp(store: WorkoutStore()));
}

class AthleteDiaryApp extends StatelessWidget {
  const AthleteDiaryApp({super.key, required this.store});

  final WorkoutStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Дневник спортсмена',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        useMaterial3: true,
      ),
      home: HomeScreen(store: store),
    );
  }
}
