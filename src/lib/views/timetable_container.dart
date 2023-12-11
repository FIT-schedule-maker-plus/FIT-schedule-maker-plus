// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fit_schedule_maker_plus/disp_timetable_gen.dart';
import 'package:fit_schedule_maker_plus/models/course_lesson.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fit_schedule_maker_plus/viewmodels/timetable.dart';
import 'package:fit_schedule_maker_plus/viewmodels/app.dart';
import 'package:fit_schedule_maker_plus/models/course.dart';

const appBarCol = Color.fromARGB(255, 52, 52, 52);
const timetableVerticalLinesColor = Color.fromARGB(255, 83, 83, 83);
const double daysBarWidth = 35;
const lessonHeight = 100;

class TimetableContainer extends StatelessWidget {
  const TimetableContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appBarCol,
      child: Column(
        children: [
          Courses(),
          SizedBox(height: 40),
          Expanded(child: Timetable()),
        ],
      ),
    );
  }
}

class Courses extends StatelessWidget {
  const Courses({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppViewModel>();
    // TODO: change watch to select
    final timetableViewModel = context.watch<TimetableViewModel>();
    // final currentTimetable = context.select((TimetableViewModel timetableViewModel) => timetableViewModel.timetables[timetableViewModel.active]);

    return timetableViewModel.currentTimetable.selected[timetableViewModel.currentTimetable.semester]!.keys.isEmpty
        ? SizedBox(height: 20)
        : Container(
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [appBarCol, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0.0, 10.0),
                    blurRadius: 15.0,
                    spreadRadius: 10.0,
                  )
                ]),
            child: Column(
              children: [
                const SizedBox(height: 17),
                const Center(
                  child: Text(
                    'Vybrané predmety',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  alignment: Alignment.center,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 60, // to apply margin in the main axis of the wrap
                    runSpacing: 10, // to apply margin in the cross axis of the wrap
                    children: timetableViewModel.currentTimetable.selected[timetableViewModel.currentTimetable.semester]!.keys
                        .map((courseId) => buildCourseWidget(app.allCourses[courseId]!, context))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 17),
              ],
            ),
          );
  }

  Widget buildCourseWidget(Course course, BuildContext context) {
    TimetableViewModel timetable = context.read<TimetableViewModel>();

    return Container(
      width: 178,
      height: 28,
      decoration: ShapeDecoration(
        color: Color(0xFF1BD30B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: Text(
                course.shortcut,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => timetable.removeCourse(course.id),
            tooltip: 'Delete',
            padding: EdgeInsets.zero,
            color: Colors.white,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class Timetable extends StatelessWidget {
  const Timetable({super.key});

  @override
  Widget build(BuildContext context) {
    AppViewModel appViewModel = context.read<AppViewModel>();
    TimetableViewModel timetableViewModel = context.watch<TimetableViewModel>();

    Iterable<int> courseIds = timetableViewModel.currentTimetable.currentContent.keys;
    bool areAllLessonsFetched = courseIds.every((courseId) => appViewModel.isCourseLessonFetched(courseId));

    return areAllLessonsFetched
        ? buildTimetable(appViewModel.getAllCourseLessonSync(courseIds), context)
        : FutureBuilder(
            future: appViewModel.getAllCourseLessonsAsync(courseIds),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  List<CourseLesson> lessons = snapshot.data!;
                  return buildTimetable(lessons, context);
                default:
                  return Center(child: CircularProgressIndicator());
              }
            });
  }

  Widget buildTimetable(List<CourseLesson> lessons, BuildContext context) {
    AppViewModel appViewModel = context.read<AppViewModel>();
    TimetableViewModel timetableViewModel = context.read<TimetableViewModel>();
    final generatedData = genDispTimetable(appViewModel, timetableViewModel, Filter.none());

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      width: double.infinity,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double parentWidth = constraints.maxWidth;
          double oneLessonWidth = parentWidth / 15;

          return Column(
            children: [
              buildTimeBar(),
              Divider(thickness: 2, height: 2, color: Colors.black),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Stack(
                    children: [
                      Column(
                        children: List.generate(5, (index) {
                          return [
                            buildWeekDay(DayOfWeek.values[index], oneLessonWidth - 1, generatedData[DayOfWeek.values[index]]!.first),
                            Divider(thickness: 2, height: 2, color: Colors.black),
                          ];
                        }).expand((item) => item).toList(),
                      ),
                      ...lessons.map((lesson) => buildLesson(lesson, oneLessonWidth - 1)),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget buildTimeBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: List.generate(
          15,
          (index) => Expanded(
            child: Text(
              '${index + 7}:00',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildWeekDay(DayOfWeek dayOfWeek, double lessonWidth, int maxHeight) {
    print("maxHeight: ${maxHeight}");
    return SizedBox(
      height: lessonHeight * (maxHeight + 1),
      child: Row(
        children: [
          SizedBox(
            width: daysBarWidth,
            child: Text(
              dayOfWeek.toCzechString(),
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: lessonWidth / 2),
            child: VerticalDivider(thickness: 1, width: 1, color: timetableVerticalLinesColor),
          ),
          ...List.generate(
            14,
            (index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: lessonWidth / 2),
              child: VerticalDivider(thickness: 1, width: 1, color: timetableVerticalLinesColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLesson(CourseLesson lesson, double oneLessonWidth) {
    return Positioned(
      left: daysBarWidth + 5 + ((lesson.startsFrom / 60) - 7) * (oneLessonWidth + 1),
      top: 100 * lesson.dayOfWeek.index + 3 + (lesson.dayOfWeek.index + 1) * 2,
      child: Container(
        color: Colors.black,
        width: (lesson.endsAt - lesson.startsFrom) / 60 * oneLessonWidth,
        height: 90,
        alignment: Alignment.center,
        child: Text(
          lesson.info,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
