import 'package:flutter/material.dart';

const selTabCol = Color.fromARGB(255, 255, 255, 255);
const unsTabCol = Color.fromARGB(255, 125, 125, 125);
const appBarCol = Color.fromARGB(255, 52, 52, 52);

class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TabAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        centerTitle: true,
        backgroundColor: appBarCol,
        title: const TabBar(
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: unsTabCol,
          labelStyle: TextStyle(fontSize: 22),
          tabs: <Widget>[
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
