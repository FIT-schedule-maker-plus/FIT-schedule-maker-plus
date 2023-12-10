// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fit_schedule_maker_plus/viewmodels/app.dart';
import 'package:fit_schedule_maker_plus/views/complete_timetable.dart';
import 'package:fit_schedule_maker_plus/views/side_bar.dart';
import 'package:fit_schedule_maker_plus/views/tab_app_bar.dart';
import 'package:fit_schedule_maker_plus/views/timetable_container.dart';
import 'package:fit_schedule_maker_plus/views/timetable_variants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

TabBarView buildTabBarView() {
  return TabBarView(
    children: <Widget>[
      Stack(children: [
        TimetableContainer(),
        buildGenerator(),
      ]),
      CompleteTimetable(),
      TimetableVariants(),
    ],
  );
}

Widget buildMainContent(bool showSidebar) {
  return Scaffold(
    appBar: TabAppBar(),
    drawer: showSidebar ? SideBar() : null,
    body: buildTabBarView(),
  );
}

Widget buildGenerator() {
  return Positioned(
    right: 20,
    bottom: 20,
    child: ElevatedButton(
      child: Text("Generátor rozvrhu"),
      onPressed: () {},
    ),
  );
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    AppViewModel appViewModel = Provider.of<AppViewModel>(context, listen: false);

    return FutureBuilder(
      future: appViewModel.getAllStudyProgram(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            bool narrowLayout = MediaQuery.of(context).size.width < 1000;
            return DefaultTabController(
              length: 3,
              child: narrowLayout
                  ? buildMainContent(true)
                  : Row(
                      children: [
                        Container(
                          color: Color.fromARGB(255, 52, 52, 52),
                          child: SideBar(),
                        ),
                        Expanded(child: buildMainContent(false))
                      ],
                    ),
            );
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
