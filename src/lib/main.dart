/*
 * Filename: main.dart
 * Project: FIT-schedule-maker-plus
 * Author: Matúš Moravčík (xmorav48)
 * Date: 15/12/2023
 * Description: This file is responsible for creating the application's user interface. It utilizes
 *    the `MultiProvider` widget to manage state using providers (`AppViewModel`, `TimetableViewModel`).
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../views/homepage.dart';
import 'viewmodels/app.dart';
import 'viewmodels/timetable.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Scheduler());
}

class Scheduler extends StatelessWidget {
  const Scheduler({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppViewModel()),
        ChangeNotifierProvider(create: (ctx) => TimetableViewModel(timetables: ctx.read<AppViewModel>().timetables))
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FIT Schedule Maker+',
        theme: ThemeData(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) return const Color.fromARGB(16, 204, 204, 204);
                return null;
              }),
            ),
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Homepage(),
      ),
    );
  }
}
