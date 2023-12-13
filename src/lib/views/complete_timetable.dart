import 'package:flutter/material.dart';
import 'package:fit_schedule_maker_plus/views/timetable_container.dart'
    as custom_widget;

import '../disp_timetable_gen.dart';

class CompleteTimetable extends StatelessWidget {
  const CompleteTimetable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 52, 52, 52),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: custom_widget.Timetable(filter: Filter.all(), readOnly: true),
      ),
    );
  }
}
