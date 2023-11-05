// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fit_schedule_maker_plus/viewmodels/app.dart';
import 'package:fit_schedule_maker_plus/viewmodels/timetable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

const Color subjectBarColor = Color.fromARGB(255, 22, 22, 22);
const Color activeColor = Color.fromRGBO(41, 39, 39, 1);
const Color black = Colors.black;
const Color white = Colors.white;

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: black,
      elevation: 0,
      width: 315,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildStudiumBar(context),
          buildSubjectBar(context),
        ],
      ),
    );
  }
}

Widget buildStudiumBar(BuildContext context) {
  AppViewModel appViewModel = Provider.of<AppViewModel>(context, listen: false);
  final String? activeStudy = context.select((AppViewModel appViewModel) => appViewModel.study);
  List<String> magStudiums = appViewModel.getAllMagisterStudies();

  return Container(
    color: black,
    width: 90,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset('assets/vut_logo.png'),
        SizedBox(height: 10),
        buildStudiumName("BAKALARSKE"),
        SizedBox(height: 10),
        buildStudiumButton(
          "BIT",
          activeStudy,
          () => appViewModel.changeStudy("BIT"),
        ),
        SizedBox(height: 20),
        buildStudiumName("MAGISTERSKE"),
        SizedBox(height: 10),
        Expanded(
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [white, black],
                stops: [0.8, 1],
                tileMode: TileMode.mirror,
              ).createShader(bounds);
            },
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 50),
              itemCount: magStudiums.length,
              itemBuilder: (context, index) {
                return buildStudiumButton(
                  magStudiums[index],
                  activeStudy,
                  () => appViewModel.changeStudy(magStudiums[index]),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildStudiumButton(String text, String? activeStudy, void Function() onPressed) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(3.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        disabledBackgroundColor: activeStudy == text ? activeColor : black,
        backgroundColor: black,
        surfaceTintColor: black,
        splashFactory: NoSplash.splashFactory,
        fixedSize: Size(double.infinity, 70.0),
      ),
      onPressed: activeStudy == text ? null : onPressed,
      child: Text(text, style: TextStyle(color: white, fontSize: 20)),
    ),
  );
}

Widget buildStudiumName(String name) {
  return Text(
    name,
    textAlign: TextAlign.center,
    style: TextStyle(
      color: Color.fromARGB(255, 129, 129, 129),
      fontSize: 9,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget buildSubjectBar(BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 10),
    color: subjectBarColor,
    child: SizedBox(
      width: 225,
      child: Column(children: [
        buildHeader(context),
        Divider(color: black),
        buildGradeTabs(context),
        SizedBox(height: 15),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              SubjectsExpansionTiles(Category.compulsory),
              Divider(color: black),
              SubjectsExpansionTiles(Category.compulsoryOptional),
              Divider(color: black),
              SubjectsExpansionTiles(Category.optional),
            ],
          ),
        )
      ]),
    ),
  );
}

Widget buildHeader(BuildContext context) {
  AppViewModel appViewModel = Provider.of<AppViewModel>(context, listen: false);
  final isWinterTerm = context.select((AppViewModel appViewModel) => appViewModel.isWinterTerm);

  return Row(
    mainAxisSize: MainAxisSize.max,
    children: [
      Expanded(
        child: Text("2023/24",
            textAlign: TextAlign.center,
            style: TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.w500)),
      ),
      Transform.scale(
        scale: 1,
        child: Switch(
          activeThumbImage: AssetImage("snowflake.png"),
          activeTrackColor: Color.fromARGB(255, 91, 221, 252),
          inactiveTrackColor: Color.fromARGB(255, 249, 249, 107),
          inactiveThumbColor: white,
          inactiveThumbImage: AssetImage("sun.png"),
          value: isWinterTerm,
          onChanged: (value) => appViewModel.changeTerm(value),
        ),
      ),
    ],
  );
}

Widget buildGradeTabs(BuildContext context) {
  AppViewModel appViewModel = Provider.of<AppViewModel>(context, listen: false);

  return DefaultTabController(
    initialIndex: appViewModel.grade,
    length: 3,
    child: TabBar(
      indicatorColor: Color.fromARGB(255, 27, 211, 11),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: EdgeInsets.symmetric(horizontal: 4),
      labelColor: white,
      dividerColor: Colors.transparent,
      labelPadding: EdgeInsets.all(0),
      onTap: (value) => appViewModel.changeGrade(value),
      tabs: [
        buildGradeText("1.Roc"),
        buildGradeText("2.Roc"),
        buildGradeText("3.Roc"),
      ],
    ),
  );
}

Widget buildGradeText(String grade) {
  return Text(
    grade,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
    ),
  );
}

class SubjectsExpansionTiles extends StatelessWidget {
  final Category category;
  const SubjectsExpansionTiles(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    AppViewModel appViewModel = context.watch<AppViewModel>();

    return ExpansionTile(
      tilePadding: EdgeInsets.only(right: 17, left: 5),
      initiallyExpanded: true,
      shape: OutlineInputBorder(borderSide: BorderSide.none),
      title: Text(
        category.toCzechString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      childrenPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      backgroundColor: subjectBarColor,
      collapsedIconColor: white,
      iconColor: white,
      controlAffinity: ListTileControlAffinity.leading,
      maintainState: true,
      children: appViewModel
          .filterCourses(category)
          .map((courseID) => buildSubjectButton(courseID, context))
          .toList(),
    );
  }
}

Widget buildSubjectButton(int courseID, BuildContext context) {
  TimetableViewModel timetableViewModel = Provider.of<TimetableViewModel>(context, listen: false);
  AppViewModel appViewModel = Provider.of<AppViewModel>(context, listen: false);
  bool isSelected = context
      .select((TimetableViewModel timetableViewModel) => timetableViewModel.containsCourse(courseID));

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: ElevatedButton(
      onPressed: () => timetableViewModel.containsCourse(courseID)
          ? timetableViewModel.removeCourse(courseID)
          : timetableViewModel.addCourse(courseID),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 40),
        alignment: Alignment.centerLeft,
        backgroundColor: isSelected ? activeColor : subjectBarColor,
        surfaceTintColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        elevation: 0,
      ),
      child: Text(appViewModel.allCourses[courseID]!.shortcut,
          style: TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.w400)),
    ),
  );
}
