import 'package:flutter/material.dart';

const selTabCol = Color.fromARGB(255, 255, 255, 255);
const unsTabCol = Color.fromARGB(255, 125, 125, 125);
const appBarCol = Color.fromARGB(255, 52, 52, 52);

class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  const TabAppBar(this.tabController, {super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        centerTitle: true,
        backgroundColor: appBarCol,
        title: TabBar(
          tabAlignment: TabAlignment.center,
          labelPadding: EdgeInsets.symmetric(horizontal: 40),
          controller: tabController,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: unsTabCol,
          labelStyle: TextStyle(fontSize: 22),
          tabs: const <Widget>[
            Tab(text: 'Pracovní rozvrh'),
            Tab(text: 'Výsledný rozvrh'),
            Tab(text: 'Verze rozvrhu'),
          ],
        ));
  }

  int get newMethod => 0;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
