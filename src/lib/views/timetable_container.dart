import 'package:flutter/material.dart';
import 'package:fit_schedule_maker_plus/viewmodels/timetable.dart';

class TimetableContainer extends StatefulWidget {
  const TimetableContainer({super.key});

  @override
  State<TimetableContainer> createState() => _TimetableContainer();
}

class _TimetableContainer extends State<TimetableContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Courses(model: model),
        SizedBox(height: 39),
        Expanded(child: Timetable()),
      ],
    );
  }
}

class Courses extends StatelessWidget {
  const Courses({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    var courses = ["IMA2", "IPT", "INP", "IFJ", "IAL", "ISS", "BIS", "SCO", "ITU"];
    var course_widgets = courses.map(buildCourseWidget);

    return Container(
      width: double.infinity,
      color: Colors.red,
      child: Column(
        children: [
          SizedBox(height: 17),
          Center(
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
            )
          ),
          SizedBox(height: 17),
          Center(
            child: Wrap(
              spacing: 60, // to apply margin in the main axis of the wrap
              runSpacing: 10, // to apply margin in the cross axis of the wrap
              children: course_widgets.toList()
            )
          ),
          SizedBox(height: 17),
        ]
      )
    );
  }
}

class Timetable extends StatelessWidget {
  const Timetable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey,
      child: Column(
        children: [
          buildTimeWidget(),
          Container(
            width: 1084,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignCenter,
                ),
              ),
            ),
          ),
          Center(child: Text("Timetable")),
        ]
      ),
    );
  }
}

Widget buildCourseWidget(String course) {
  return Flexible(
    flex: 1,
    child: Container(
      width: 178,
      height: 28,
      decoration: ShapeDecoration(
        color: Color(0xFF1BD30B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 38.26,
            top: 2,
            child: Text(
              course,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Positioned(
            left: 150,
            top: 4,
            child: Container(
              width: 20,
              height: 20,
              child: Text("✖", style:TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    )
  );
}

Widget buildTime(String time, double padding_right) {
  return Container(
    width: 36,
    height: 15,
    // padding: EdgeInsets.only(right: padding_right),
    child: Text(
      time,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        height: 0
      )
    )
  );
}

Widget buildTimeWidget() {
  return Container(
    width: 1083,
    height: 15.71,
    child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTime("07:00", 2),
          const SizedBox(width: 39),
          buildTime("08:00", 2), // no margin
          const SizedBox(width: 39),
          buildTime("09:00", 2), // no margin
          const SizedBox(width: 39),
          buildTime("10:00", 2),
          const SizedBox(width: 39),
          buildTime("11:00", 4),
          const SizedBox(width: 39),
          buildTime("12:00", 3),
          const SizedBox(width: 39),
          buildTime("13:00", 2),
          const SizedBox(width: 39),
          buildTime("14:00", 2),
          const SizedBox(width: 39),
          buildTime("15:00", 3),
          const SizedBox(width: 39),
          buildTime("16:00", 2),
          const SizedBox(width: 39),
          buildTime("17:00", 4),
          const SizedBox(width: 39),
          buildTime("18:00", 3),
          const SizedBox(width: 39),
          buildTime("19:00", 2),
          const SizedBox(width: 39),
          buildTime("20:00", 1),
          const SizedBox(width: 39),
          buildTime("21:00", 3),
        ],
    ),
)
      ;
}
