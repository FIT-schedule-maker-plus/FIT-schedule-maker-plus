// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fit_schedule_maker_plus/viewmodels/app.dart';
import 'package:fit_schedule_maker_plus/viewmodels/timetable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/program_course.dart';
import '../models/program_course_group.dart';
import '../models/study.dart';

const Color subjectBarColor = Color.fromARGB(255, 22, 22, 22);
const Color activeColor = Color.fromRGBO(41, 39, 39, 1);
const Color black = Colors.black;
const Color white = Colors.white;

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    int tabIndex = context.select((AppViewModel appViewModel) => appViewModel.activeTabIndex);

    return tabIndex != 0
        ? Container()
        : Drawer(
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
  final activeStudy = context.select((AppViewModel appViewModel) => appViewModel.currentStudyProgram);
  Map<int, StudyProgram> studies = appViewModel.allStudyPrograms;
  final int studyTypeCount = StudyType.values.length + 1;

  return Container(
    color: black,
    width: 90,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset('assets/vut_logo.png'),
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
            child: ListView.separated(
              itemCount: studyTypeCount,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              separatorBuilder: (contex, index) => buildStudiumName(StudyType.values[index]),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(padding: EdgeInsets.zero);
                } else {
                  List<StudyProgram> studyPrograms = studies.values.where((study) => study.type == StudyType.values[index - 1]).toList();
                  return Column(
                    children: studyPrograms.map((study) => buildStudiumButton(study, activeStudy, appViewModel)).toList()
                      ..add(SizedBox(height: index + 1 == studyTypeCount ? 50 : 0)),
                  );
                }
              },
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildStudiumButton(StudyProgram study, int activeStudy, AppViewModel appViewModel) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
    child: Tooltip(
      waitDuration: Duration(milliseconds: 1000),
      message: study.fullName,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(3.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                disabledBackgroundColor: study.id == activeStudy ? activeColor : black,
                backgroundColor: black,
                surfaceTintColor: black,
                splashFactory: NoSplash.splashFactory,
                fixedSize: Size(double.infinity, 70.0),
              ),
              onPressed: study.id == activeStudy
                  ? null
                  : () {
                      if (study.duration < appViewModel.allStudyPrograms[appViewModel.currentStudyProgram]!.duration) {
                        appViewModel.changeGrade(YearOfStudy.values[study.duration - 1]);
                      }
                      appViewModel.changeStudy(study.id);
                    },
              child: Text(study.shortcut, style: TextStyle(color: white, fontSize: 20)),
            ),
          )
        ],
      ),
    ),
  );
}

Widget buildStudiumName(StudyType studyType) {
  return Padding(
    padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
    child: Text(
      studyType.toCzechString(),
      textAlign: TextAlign.center,
      style: TextStyle(color: Color.fromARGB(255, 129, 129, 129), fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );
}

Widget buildSubjectBar(BuildContext context) {
  AppViewModel appViewModel = Provider.of<AppViewModel>(context, listen: false);

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
          child: appViewModel.isProgramCourseGroupFetched()
              ? buildAllSubjectList(appViewModel.getProgramCourseGroup())
              : FutureBuilder(
                  future: appViewModel.getProgramCourses(appViewModel.currentStudyProgram),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                      case ConnectionState.active:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      default:
                        return buildAllSubjectList(appViewModel.getProgramCourseGroup());
                    }
                  },
                ),
        )
      ]),
    ),
  );
}

Widget buildAllSubjectList(ProgramCourseGroup programCourseGroup) {
  return ListView(
    shrinkWrap: true,
    children: [
      SubjectsExpansionTiles(CourseDuty.compulsory, programCourseGroup),
      Divider(color: black),
      SubjectsExpansionTiles(CourseDuty.compulsoryElective, programCourseGroup),
      Divider(color: black),
      SubjectsExpansionTiles(CourseDuty.elective, programCourseGroup),
    ],
  );
}

Widget buildHeader(BuildContext context) {
  AppViewModel appViewModel = Provider.of<AppViewModel>(context, listen: false);
  TimetableViewModel timetableViewModel = Provider.of<TimetableViewModel>(context, listen: false);
  final currentSemester = context.select((AppViewModel appViewModel) => appViewModel.currentSemester);

  return Row(
    mainAxisSize: MainAxisSize.max,
    children: [
      Expanded(
        child: Text(appViewModel.currentYear, textAlign: TextAlign.center, style: TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.w500)),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: Transform.scale(
          scale: 0.9,
          child: Switch(
            activeThumbImage: AssetImage("snowflake.png"),
            activeTrackColor: Color.fromARGB(255, 91, 221, 252),
            inactiveTrackColor: Color.fromARGB(255, 249, 249, 107),
            inactiveThumbColor: white,
            inactiveThumbImage: AssetImage("sun.png"),
            value: currentSemester == Semester.winter,
            onChanged: (value) {
              Semester semester = value ? Semester.winter : Semester.summer;
              appViewModel.changeTerm(semester);
              timetableViewModel.changeSemester(semester);
            },
          ),
        ),
      ),
    ],
  );
}

Widget buildGradeTabs(BuildContext context) {
  AppViewModel appViewModel = Provider.of<AppViewModel>(context, listen: false);
  YearOfStudy grade = context.select((AppViewModel appViewModel) => appViewModel.currentGrade);
  int duration = appViewModel.allStudyPrograms[appViewModel.currentStudyProgram]!.duration;

  return DefaultTabController(
    initialIndex: grade.index,
    length: duration,
    child: TabBar(
      indicatorColor: Color.fromARGB(255, 27, 211, 11),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: EdgeInsets.symmetric(horizontal: 4),
      labelColor: white,
      dividerColor: Colors.transparent,
      labelPadding: EdgeInsets.all(0),
      onTap: (index) => appViewModel.changeGrade(YearOfStudy.values[index]),
      tabs: List.generate(duration, (year) => buildGradeText("${year + 1}.Roc")),
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
  final CourseDuty courseDuty;
  final ProgramCourseGroup programCourseGroup;
  const SubjectsExpansionTiles(this.courseDuty, this.programCourseGroup, {super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.only(right: 17, left: 5),
      initiallyExpanded: true,
      shape: OutlineInputBorder(borderSide: BorderSide.none),
      title: Text(
        courseDuty.toCzechString(),
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
      children: programCourseGroup.courses.where((course) => course.duty == courseDuty).map((course) => SubjectButton(course)).toList(),
    );
  }
}

class SubjectButton extends StatelessWidget {
  final ProgramCourse programCourse;
  const SubjectButton(this.programCourse, {super.key});

  @override
  Widget build(BuildContext context) {
    TimetableViewModel timetableViewModel = Provider.of<TimetableViewModel>(context, listen: false);
    AppViewModel appViewModel = Provider.of<AppViewModel>(context, listen: false);
    bool isSelected = context.select((TimetableViewModel timetableViewModel) => timetableViewModel.containsCourse(programCourse.courseId));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: ElevatedButton(
        onPressed: () => isSelected ? timetableViewModel.removeCourse(programCourse.courseId) : timetableViewModel.addCourse(programCourse.courseId),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 40),
          alignment: Alignment.centerLeft,
          backgroundColor: isSelected ? activeColor : subjectBarColor,
          surfaceTintColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          elevation: 0,
        ),
        child: Text(
          appViewModel.allCourses[programCourse.courseId]!.shortcut,
          style: TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
