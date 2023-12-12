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

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<AppViewModel>().getAllStudyProgram(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return Content();
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
}

class Content extends StatefulWidget {
  const Content({super.key});

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  int activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, animationDuration: Duration(milliseconds: 0));
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));

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
    bool narrowLayout = MediaQuery.of(context).size.width < 1000;
    return narrowLayout
        ? buildMainContent(true, activeTab)
        : Row(
            children: [
              SideBarVisibility(activeTab),
              Expanded(
                child: buildMainContent(false, activeTab),
              )
            ],
          );
  }

  void handleChangeTab(int value) {
    setState(() {
      activeTab = value;
    });
  }

  Widget buildMainContent(bool showSidebar, int activeTab) {
    return Scaffold(
      appBar: TabAppBar(_tabController, handleChangeTab),
      drawer: showSidebar && activeTab == 0 ? SideBar() : null,
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
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
  final int activeTab;
  SideBarVisibility(this.activeTab, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: activeTab == 0 ? 315.0 : 0.0,
      color: Color.fromARGB(255, 52, 52, 52),
      child: SideBar(),
    );
  }
}
