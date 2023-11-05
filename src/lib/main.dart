import 'package:fit_schedule_maker_plus/views/homepage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/app.dart';
import 'viewmodels/timetable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppViewModel()),
        ChangeNotifierProvider(create: (_) => TimetableViewModel()),
      ],
      child: MaterialApp(
        title: 'FIT Schedule Maker+',
        theme: ThemeData(
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered)) return Color.fromARGB(16, 204, 204, 204);
                  return null;
                }),
              ),
            ),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true),
        home: const Homepage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
