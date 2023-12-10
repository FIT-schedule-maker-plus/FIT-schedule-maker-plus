// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fit_schedule_maker_plus/viewmodels/timetable.dart';
import 'package:fit_schedule_maker_plus/viewmodels/app.dart';
import 'package:fit_schedule_maker_plus/models/course.dart';

class TimetableContainer extends StatefulWidget {
  const TimetableContainer({super.key});

  @override
  State<TimetableContainer> createState() => _TimetableContainer();
}

class _TimetableContainer extends State<TimetableContainer> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Courses(),
        SizedBox(height: 39),
        Expanded(child: Timetable()),
      ],
    );
  }
}

class Courses extends StatelessWidget {
  const Courses({super.key});

  @override
  Widget build(BuildContext context) {
    var app = context.read<AppViewModel>();
    var timetable = context.watch<TimetableViewModel>();

    List<Widget> courseWidgets = timetable.courses[timetable.semester]!.map((id) => app.allCourses[id]!).map((id) => buildCourseWidget(id, context)).toList();

    return Container(
      width: double.infinity,
      color: Colors.red,
      child: Column(
        children: [
          const SizedBox(height: 17),
          const Center(
            child: Text(
              'Vybrané predmety',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 0,
              ),
            ),
          ),
          const SizedBox(height: 17),
          Center(
              child: Wrap(
                  spacing: 60, // to apply margin in the main axis of the wrap
                  runSpacing: 10, // to apply margin in the cross axis of the wrap
                  children: courseWidgets)),
          const SizedBox(height: 17),
        ],
      ),
    );
  }
}

class Timetable extends StatelessWidget {
  const Timetable({super.key});

  @override
  Widget build(BuildContext context) {
    var timeWidget = SizedBox(
        width: 1083,
        height: 15.71,
        child: ListView.separated(
          itemCount: 15,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 39),
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
                width: 36,
                height: 15,
                child: Text('${index + 7}:00',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    )));
          },
        ));

    return Container(
      width: double.infinity,
      color: Colors.grey,
      child: Column(children: [
        timeWidget,
        Container(
          width: 1084,
          decoration: const ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 2,
                strokeAlign: BorderSide.strokeAlignCenter,
              ),
            ),
          ),
        ),
        const Center(child: Text("Po")),
        const Center(child: Text("Ut")),
        const Center(child: Text("St")),
        const Center(child: Text("Ct")),
        const Center(child: Text("Pa")),
      ]),
    );
  }
}

Widget buildCourseWidget(Course course, BuildContext context) {
  TimetableViewModel timetable = context.read<TimetableViewModel>();

  return Container(
    width: 178,
    height: 28,
    decoration: ShapeDecoration(
      color: const Color(0xFF1BD30B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
          icon: const Icon(Icons.close),
        ),
      ],
    ),
  );
}
