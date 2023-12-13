// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, prefer_const_constructors_in_immutables, must_be_immutable

import 'package:fit_schedule_maker_plus/viewmodels/app.dart';
import 'package:fit_schedule_maker_plus/views/complete_timetable.dart';
import 'package:fit_schedule_maker_plus/views/generator.dart';
import 'package:fit_schedule_maker_plus/views/offscreen_timetable.dart';
import 'package:fit_schedule_maker_plus/views/side_bar.dart';
import 'package:fit_schedule_maker_plus/views/tab_app_bar.dart';
import 'package:fit_schedule_maker_plus/views/timetable_container.dart';
import 'package:fit_schedule_maker_plus/views/timetable_variants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/timetable.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Selector<TimetableViewModel, int?>(
          selector: (context, vm) => vm.toExport,
          builder: (context, toExport, _) {
            if (toExport == null) {
              return Placeholder();
            }
            return OffScrTimetable(exportTimetable: toExport);
          },
        ),
        FutureBuilder(
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
        ),
      ],
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
              _animationController.status == AnimationStatus.dismissed
                  ? Positioned(
                      right: 20,
                      bottom: 20,
                      child: BlackButton(onTap: () => _animationController.forward()),
                    )
                  : Container(),
              Generator(animationController: _animationController, ofssetAnimation: _offsetAnimation),
            ],
          ),
          CompleteTimetable(),
          TimetableVariants(),
        ],
      ),
    );
  }
}

class BlackButton extends StatefulWidget {
  void Function()? onTap;
  BlackButton({this.onTap, super.key});

  @override
  State<BlackButton> createState() => _BlackButtonState();
}

class _BlackButtonState extends State<BlackButton> {
  @override
  Widget build(BuildContext context) {
    bool isHovering = false;

    return StatefulBuilder(builder: (context, setState) {
      return InkWell(
        onTap: widget.onTap,
        onHover: (value) => setState(() => isHovering = value),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Center(
            child: Text("Generátor rozvrhu", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          decoration: BoxDecoration(
              color: isHovering ? Color.fromARGB(255, 20, 20, 20) : Colors.black,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black)]),
        ),
      );
    });
  }
}

class SideBarVisibility extends StatelessWidget {
  final int activeTab;
  SideBarVisibility(this.activeTab, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: activeTab == 0 ? 315.0 : 0.0,
      decoration: BoxDecoration(
        border: Border.all(style: BorderStyle.none, width: 0),
        color: Color.fromARGB(255, 52, 52, 52),
      ),
      child: SideBar(),
    );
  }
}
