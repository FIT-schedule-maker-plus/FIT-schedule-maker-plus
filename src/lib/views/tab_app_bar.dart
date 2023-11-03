// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TabAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text('FIT Schedule Maker+'),
      backgroundColor: Color.fromARGB(255, 212, 212, 212),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
