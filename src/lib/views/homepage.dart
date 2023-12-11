// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fit_schedule_maker_plus/viewmodels/app.dart';
import 'package:fit_schedule_maker_plus/views/complete_timetable.dart';
import 'package:fit_schedule_maker_plus/views/generator.dart';
import 'package:fit_schedule_maker_plus/views/side_bar.dart';
import 'package:fit_schedule_maker_plus/views/tab_app_bar.dart';
import 'package:fit_schedule_maker_plus/views/timetable_container.dart';
import 'package:fit_schedule_maker_plus/views/timetable_variants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    // Set up offset animation
    _offsetAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppViewModel appViewModel = Provider.of<AppViewModel>(context, listen: false);
    _tabController.addListener(() {
      if (appViewModel.activeTabIndex != _tabController.index) {
        appViewModel.changeTab(_tabController.index);
      }
    });

    return FutureBuilder(
      future: appViewModel.getAllStudyProgram(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            bool narrowLayout = MediaQuery.of(context).size.width < 1000;
            return narrowLayout
                ? buildMainContent(true)
                : Row(
                    children: [
                      SideBarVisibility(),
                      Expanded(child: buildMainContent(false)),
                    ],
                  );
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );

          default:
            return Scaffold(
              body: Center(
                child: Text(
                  "Error: Unable to fetch study programs",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                  ),
                ),
              ),
            );
        }
      },
    );
  }

  Widget buildMainContent(bool showSidebar) {
    return Scaffold(
      appBar: TabAppBar(_tabController),
      drawer: showSidebar ? SideBar() : null,
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Stack(
            alignment: Alignment.centerRight,
            children: [
              TimetableContainer(),
              buildGeneratorButton(),
              Generator(animationController: _animationController, ofssetAnimation: _offsetAnimation),
            ],
          ),
          CompleteTimetable(),
          TimetableVariants(),
        ],
      ),
    );
  }

  Widget buildGeneratorButton() {
    return Positioned(
      right: 20,
      bottom: 20,
      child: ElevatedButton(
        child: Text("Generátor rozvrhu"),
        onPressed: () => _animationController.forward(),
      ),
    );
  }
}

class SideBarVisibility extends StatelessWidget {
  const SideBarVisibility({super.key});

  @override
  Widget build(BuildContext context) {
    bool showSidebar = context.select((AppViewModel appViewModel) => appViewModel.activeTabIndex == 0);

    return Visibility(
      visible: showSidebar,
      child: Container(
        color: Color.fromARGB(255, 52, 52, 52),
        child: SideBar(),
      ),
    );
  }
}
