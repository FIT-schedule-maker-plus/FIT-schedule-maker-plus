// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fit_schedule_maker_plus/viewmodels/app.dart';
import 'package:fit_schedule_maker_plus/views/complete_timetable.dart';
import 'package:fit_schedule_maker_plus/views/side_bar.dart';
import 'package:fit_schedule_maker_plus/views/tab_app_bar.dart';
import 'package:fit_schedule_maker_plus/views/timetable_container.dart';
import 'package:fit_schedule_maker_plus/views/timetable_variants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';

Widget getMainContent({required bool showSideBar}) {
  return DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: TabAppBar(),
      drawer: showSideBar ? SideBar() : null,
      floatingActionButton: ElevatedButton(
        child: Text("Generátor rozvrhu"),
        onPressed: () {},
      ),
      body: const TabBarView(children: <Widget>[
        TimetableContainer(),
        CompleteTimetable(),
        TimetableVariants(),
      ]),
    ),
  );
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    AppViewModel appViewModel = Provider.of<AppViewModel>(context, listen: false);

    return FutureBuilder(
      future: appViewModel.getAllCourses(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return MediaQuery.of(context).size.width > 1000
                ? Row(children: [
                    Container(
                      color: Color.fromARGB(255, 52, 52, 52),
                      child: SideBar(),
                    ),
                    Expanded(child: getMainContent(showSideBar: false))
                  ])
                : getMainContent(showSideBar: true);
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );

          default:
            return Center(
              child: Text("Error: Invalid future connection state"),
            );
        }
      },
    );
  }
}
