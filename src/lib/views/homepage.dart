/*
 * Filename: homepage.dart
 * Project: FIT-schedule-maker-plus
 * Author: Matúš Moravčík (xmorav48)
 * Date: 15/12/2023
 * Description: This file defines the main page of application.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/app.dart';
import '../viewmodels/timetable.dart';
import '../views/complete_timetable.dart';
import '../views/generator.dart';
import '../views/offscreen_timetable.dart';
import '../views/side_bar.dart';
import '../views/tab_app_bar.dart';
import '../views/timetable_container.dart';
import '../views/timetable_variants.dart';

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
              return const Placeholder();
            }
            return OffScrTimetable(exportTimetable: toExport);
          },
        ),
        FutureBuilder(
          future: Future.wait([
            context.read<AppViewModel>().getAllStudyProgram(),
            context.read<AppViewModel>().getAllLocations(context),
          ]),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return const Content();
              case ConnectionState.waiting:
                return Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              default:
                return const Scaffold(
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

  int activeTab = 0; // the index of the open tab used to remove and add the SideBar to the widget tree

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, animationDuration: const Duration(milliseconds: 0));
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

    // Set up offset animation
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
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

  void handleChangeTab(int value) {
    setState(() {
      activeTab = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool narrowLayout = MediaQuery.of(context).size.width < 1000;
    return narrowLayout
        ? buildMainContent(true, activeTab)
        : Row(
            children: [
              activeTab == 0 ? Container(color: const Color.fromARGB(255, 52, 52, 52), child: const SideBar()) : Container(),
              Expanded(child: buildMainContent(false, activeTab)),
            ],
          );
  }

  Widget buildMainContent(bool showSidebar, int activeTab) {
    return Scaffold(
      appBar: TabAppBar(_tabController, handleChangeTab),
      drawer: showSidebar && activeTab == 0 ? const SideBar() : null,
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          Stack(
            alignment: Alignment.centerRight,
            children: [
              const TimetableContainer(),
              _animationController.status == AnimationStatus.dismissed
                  ? Positioned(
                      right: 60,
                      bottom: 20,
                      child: BlackButton(
                        onTap: () => _animationController.forward(),
                        child: const Text("Generátor rozvrhu", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    )
                  : Container(),
              Generator(animationController: _animationController, ofssetAnimation: _offsetAnimation),
            ],
          ),
          const CompleteTimetable(),
          const TimetableVariants(),
        ],
      ),
    );
  }
}

class BlackButton extends StatefulWidget {
  final void Function()? onTap;
  final EdgeInsetsGeometry? padding;
  final Widget child;

  const BlackButton({this.onTap, super.key, this.padding, required this.child});

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
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              color: isHovering ? const Color.fromARGB(255, 20, 20, 20) : Colors.black,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black)]),
          child: Center(child: widget.child),
        ),
      );
    });
  }
}
