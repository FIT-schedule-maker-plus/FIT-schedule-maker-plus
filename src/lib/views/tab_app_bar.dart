/*
 * Filename: tab_app_bar.dart
 * Project: FIT-schedule-maker-plus
 * Author: Jakub Kloub (xkloub03)
 * Date: 15/12/2023
 * Description: This file defines the tab bar that changes content of the main page.
 */

import 'package:flutter/material.dart';

const selTabCol = Color.fromARGB(255, 255, 255, 255);
const unsTabCol = Color.fromARGB(255, 125, 125, 125);
const appBarCol = Color.fromARGB(255, 52, 52, 52);
const selectedUnderlineColor = Colors.white;
const hoverUnderlineColor = Colors.green;

class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final void Function(int) setTabIndex;

  const TabAppBar(this.tabController, this.setTabIndex, {super.key});

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.hovered)) {
        return Colors.transparent;
      }
      return Colors.red;
    }

    bool isHovered1 = false;
    bool isHovered2 = false;
    bool isHovered3 = false;

    return AppBar(
      centerTitle: true,
      backgroundColor: appBarCol,
      title: StatefulBuilder(builder: (_, setState) {
        return TabBar(
          isScrollable: true,
          indicatorColor: selectedUnderlineColor,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: unsTabCol,
          overlayColor: MaterialStateProperty.resolveWith(getColor),
          tabAlignment: TabAlignment.center,
          labelPadding: const EdgeInsets.symmetric(horizontal: 40),
          controller: tabController,
          labelStyle: const TextStyle(fontSize: 22),
          onTap: (value) => setTabIndex(value),
          tabs: <Widget>[
            MouseRegion(
              onEnter: (_) => setState(() => isHovered1 = true),
              onExit: (_) => setState(() => isHovered1 = false),
              child: Tab(
                child: Text(
                  "Pracovní rozvrh",
                  style: isHovered1 ? const TextStyle(color: Colors.green) : const TextStyle(),
                ),
              ),
            ),
            MouseRegion(
              onEnter: (_) => setState(() => isHovered2 = true),
              onExit: (_) => setState(() => isHovered2 = false),
              child: Tab(
                child: Text(
                  'Výsledný rozvrh',
                  style: isHovered2 ? const TextStyle(color: Colors.green) : const TextStyle(),
                ),
              ),
            ),
            MouseRegion(
              onEnter: (_) => setState(() => isHovered3 = true),
              onExit: (_) => setState(() => isHovered3 = false),
              child: Tab(
                child: Text(
                  'Verze rozvrhu',
                  style: isHovered3 ? const TextStyle(color: Colors.green) : const TextStyle(),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  int get newMethod => 0;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
