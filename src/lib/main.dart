import 'package:fit_schedule_maker_plus/views/homepage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/app.dart';
import 'viewmodels/variants.dart';

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
        ChangeNotifierProvider(
            create: (ctx) => ctx.read<AppViewModel>().varViewMod),
      ],
      child: MaterialApp(
        title: 'FIT Schedule Maker+',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true),
        home: const Homepage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
