// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:fit_schedule_maker_plus/disp_timetable_gen.dart';
import 'package:fit_schedule_maker_plus/models/course_lesson.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fit_schedule_maker_plus/viewmodels/timetable.dart';
import 'package:fit_schedule_maker_plus/viewmodels/app.dart';
import 'package:fit_schedule_maker_plus/models/course.dart';

import '../models/timetable.dart' as model;

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
          Selector<TimetableViewModel, Filter>(
            selector: (_, vm) => vm.filter,
            builder: (context, filter, _) {
              return Expanded(
                child: Timetable(filter: filter),
              );
            }
          )
        ],
      ),
    );
  }
}

class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  bool isCollapsed = true;

  @override
  Widget build(BuildContext context) {
    final allCourses = context.select((AppViewModel vm) => vm.allCourses);
    final courseIDs = context.select((TimetableViewModel tvm) => tvm.currentTimetable.currentContent.keys.toList());
    isCollapsed = courseIDs.isEmpty;

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: isCollapsed
          ? Container(key: ValueKey(1))
          : Container(
              key: ValueKey(2),
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
              child: isCollapsed
                  ? null
                  : Column(
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
                            children: courseIDs
                                .map((courseId) => buildCourseWidget(allCourses[courseId]!, context))
                                .toList(),

                          ),
                        ),
                        const SizedBox(height: 17),
                      ],
                    ),
            ),
    );
  }

  Widget buildCourseWidget(Course course, BuildContext context) {
    bool isHiden = false;

    return Container(
      width: 180,
      height: 30,
      decoration: ShapeDecoration(
        color: Color(0xFF1BD30B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        children: [
          StatefulBuilder(builder: (ctx, setState) {
            return Tooltip(
              waitDuration: Duration(milliseconds: 500),
              message: "Skrýt",
              child: IconButton(
                onPressed: () {
                  final tvm = ctx.read<TimetableViewModel>();
                  if (isHiden) {
                    tvm.removeCourseFromFilter(course.id);
                  } else {
                    tvm.addCourseToFilter(course.id);
                  }
                  setState(() => isHiden = !isHiden);
                },
                padding: EdgeInsets.zero,
                color: Colors.white,
                icon: Icon(isHiden ? Icons.visibility_off : Icons.visibility),
              ),
            );
          }),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                course.shortcut,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Tooltip(
            waitDuration: Duration(milliseconds: 500),
            message: "Vymazat",
            child: IconButton(
              onPressed: () => context.read<TimetableViewModel>().removeCourse(course.id),
              padding: EdgeInsets.zero,
              color: Colors.white,
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}

class Timetable extends StatelessWidget {
  /// Timetable to display explicitly. This is useful when we want to display a timetable
  /// from some variant. When this is null, then we display current timetable.
  final model.Timetable? timetable;
  final Filter filter;
  const Timetable({super.key, this.timetable, required this.filter});

  @override
  Widget build(BuildContext context) {
    AppViewModel appViewModel = context.read<AppViewModel>();
    TimetableViewModel timetableViewModel = context.watch<TimetableViewModel>();

    Iterable<int> courseIds = timetableViewModel.currentTimetable.currentContent.keys;
    bool areAllLessonsFetched = courseIds.every((courseId) => appViewModel.isCourseLessonFetched(courseId));
    return areAllLessonsFetched
        ? buildTimetable(context)
        : FutureBuilder(
            future: appViewModel.getAllCourseLessonsAsync(courseIds),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return buildTimetable(context);
                default:
                  return Center(child: CircularProgressIndicator());
              }
            });
  }

  Widget buildTimetable(BuildContext context) {
    AppViewModel appViewModel = context.read<AppViewModel>();
    TimetableViewModel timetableViewModel = context.read<TimetableViewModel>();
    final generatedData = timetable == null ? genDispTimetable(appViewModel, timetableViewModel, filter) : genDispTimetableSpecific(appViewModel, timetable!, filter);

    return Container(
      padding: EdgeInsets.only(left: 30, right: 30, bottom: 30),
      width: double.infinity,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double oneLessonWidth = constraints.maxWidth / 15;

          return Column(
            children: [
              buildTimeBar(),
              Divider(thickness: 2, height: 2, color: Colors.black),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: List.generate(5, (index) {
                      return Stack(
                        children: [
                          Column(
                            children: [
                              buildWeekDay(DayOfWeek.values[index], oneLessonWidth - 1, generatedData[DayOfWeek.values[index]]!.first),
                              Divider(thickness: 2, height: 2, color: Colors.black),
                            ],
                          ),
                          ...generatedData[DayOfWeek.values[index]]!
                              .second
                              .map((specLes) => buildLesson(context, appViewModel.allCourses[specLes.courseID]!, specLes, oneLessonWidth))
                        ],
                      );
                    }),
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
    return SizedBox(
      height: lessonHeight * (maxHeight + 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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

  Widget buildLesson(BuildContext context, Course course, SpecificLesson specLes, double oneLessonWidth) {
    final lessonId = specLes.lessonID;
    final lessonLevel = specLes.height;
    const int leftOffset = 5;
    CourseLesson lesson = course.lessons[lessonId];

    Color color = switch (lesson.type) {
      LessonType.lecture => Color(0xFF1C7C26),
      LessonType.seminar => Color(0xFF21A2A2),
      LessonType.exercise => Color(0xFF286d88),
      LessonType.computerLab => Color(0xFF760505),
      LessonType.laboratory => Color(0xFF8d7626),
      _ => Colors.black,
    };

    TimetableViewModel timetableViewModel = context.read<TimetableViewModel>();

    if (!specLes.selected) {
      // color = color.withAlpha(150);
      color = color
          .withRed(max(0, color.red - (0x60 * 299 / 1000).round()))
          .withGreen(max(0, color.green - (0x60 * 587 / 1000).round()))
          .withBlue(max(0, color.blue - (0x60 * 114 / 1000).round()));
    }

    // String locations = lesson.locations.join(", ");
    String locations = lesson.infos.map((info) => info.locations).expand((loc) => loc).toSet().join(', ');
    return Positioned(
      left: daysBarWidth + leftOffset + ((lesson.startsFrom / 60) - 7) * (oneLessonWidth),
      top: lessonHeight * lessonLevel + 5,
      child: InkWell(
          onTap: () {
            if (specLes.selected) {
              deselectLesson(timetableViewModel, specLes);
            } else {
              selectLesson(timetableViewModel, specLes);
            }
          },
          child: Container(
            width: (lesson.endsAt - lesson.startsFrom) / 60 * oneLessonWidth,
            decoration: ShapeDecoration(
                color: color,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1),
                  borderRadius: BorderRadius.circular(10.0),
                )),
            height: 90,
            alignment: Alignment.center,
            child: Column(children: [
              Text(
                course.shortcut,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                lesson.infos.map((info) => info.info).toSet().join(", "),
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, fontWeight: FontWeight.w100, color: Color(0xFFC6C4C4)),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10),
              Text(
                locations,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              )
            ]),
          )),
    );
  }
}
