import 'package:fit_schedule_maker_plus/models/program_course_group.dart';
import 'package:flutter/material.dart';
import 'package:fit_schedule_maker_plus/views/timetable_container.dart' as view;
import 'package:provider/provider.dart';

import '../disp_timetable_gen.dart';
import '../viewmodels/app.dart';
import '../viewmodels/timetable.dart';

const bgColor = Color.fromARGB(255, 30, 30, 30);
const timColor = Color.fromARGB(255, 52, 52, 52);

class CompleteTimetable extends StatelessWidget {
  final bool asExport;
  final int? index;
  const CompleteTimetable({super.key, this.asExport = false, this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      padding: const EdgeInsets.only(left: 50.0, right: 50.0, bottom: 50.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildFirstNameRow(),
                buildSecondNameRow(),
              ],
            ),
          ),
          buildTimetableContainer(context),
        ],
      ),
    );
  }

  Widget buildTimetableContainer(BuildContext context) {
    final vm = context.read<TimetableViewModel>();
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(top: 20.0),
        decoration: BoxDecoration(
            color: timColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: const [
              BoxShadow(blurRadius: 20.0, spreadRadius: 5.0, color: timColor)
            ]),
        child: view.Timetable(
          filter: Filter.all(),
          readOnly: true,
          timetable: vm.timetables[index ?? vm.active],
        ),
      ),
    );
  }

  Selector<TimetableViewModel, Semester> buildSecondNameRow() {
    return Selector<TimetableViewModel, Semester>(
      selector: (context, vm) => vm.timetables[index ?? vm.active].semester,
      builder: (context, sem, _) {
        return Row(
          children: [
            Text(
              sem.toCzechString(),
              style: TextStyle(
                color: switch (sem) {
                  Semester.winter => Colors.blue,
                  Semester.summer => Colors.orange,
                },
                fontWeight: FontWeight.w200,
                fontSize: 27,
              ),
            ),
            if (!asExport)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Switch(
                  activeThumbImage: const AssetImage("images/snowflake.png"),
                  activeTrackColor: const Color.fromARGB(255, 91, 221, 252),
                  inactiveTrackColor: const Color.fromARGB(255, 249, 249, 107),
                  inactiveThumbColor: Colors.white,
                  inactiveThumbImage: const AssetImage("images/sun.png"),
                  value: sem == Semester.winter,
                  onChanged: (value) {
                    final semester = value ? Semester.winter : Semester.summer;
                    final tvm = context.read<TimetableViewModel>();
                    tvm.changeSemester(semester);
                    context.read<AppViewModel>().changeTerm(semester);
                  },
                ),
              ),
            if (!asExport)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<TimetableViewModel>().saveAsJson();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        child: const Text("Export JSON",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TimetableViewModel>().saveAsPng();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black),
                      child: const Text(
                        "Export PNG",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ],
        );
      },
    );
  }

  Row buildFirstNameRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Selector<TimetableViewModel, String>(
            selector: (context, vm) => vm.timetables[index ?? vm.active].name,
            builder: (context, timetableName, _) {
              return Text(
                timetableName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 36,
                ),
              );
            }),
      ],
    );
  }
}
