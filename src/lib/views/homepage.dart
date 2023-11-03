// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fit_schedule_maker_plus/viewmodels/app.dart';
import 'package:fit_schedule_maker_plus/views/side_bar.dart';
import 'package:fit_schedule_maker_plus/views/tab_app_bar.dart';
import 'package:fit_schedule_maker_plus/views/timetable_container.dart';
import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    AppViewModel appViewModel = AppViewModel();

    return FutureBuilder(
      future: appViewModel.getAllCourses(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return Scaffold(
              appBar: TabAppBar(),
              drawer: SideBar(),
              floatingActionButton: ElevatedButton(
                child: Text("Generátor rozvrhu"),
                onPressed: () {},
              ),
              body: TimetableContainer(),
            );
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );

          default:
            return Center(
              child: Text("Error"),
            );
        }
      },
    );
  }
}
