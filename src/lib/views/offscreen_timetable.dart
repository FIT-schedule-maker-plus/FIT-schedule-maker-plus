/*
 * Filename: offscreen_timetable.dart
 * Project: FIT-schedule-maker-plus
 * Author: Jakub Kloub (xkloub03)
 * Date: 15/12/2023
 * Description: This file defines offscreen timetable widget that is used for exporting timetable into a PNG.
 */

import 'dart:developer' as dev;
import 'package:fit_schedule_maker_plus/models/program_course_group.dart';
import 'package:fit_schedule_maker_plus/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../viewmodels/timetable.dart';
import 'complete_timetable.dart';

class OffScrTimetable extends StatefulWidget {
  /// Timetable to export.
  final int? exportTimetable;

  const OffScrTimetable({super.key, required this.exportTimetable});

  @override
  State<OffScrTimetable> createState() => _OffScrTimetableState();
}

class _OffScrTimetableState extends State<OffScrTimetable> {
  late ScreenshotController screenshotController;

  @override
  void initState() {
    super.initState();
    screenshotController = ScreenshotController();
  }

  void _captureWidget(TimetableViewModel vm) async {
    try {
      final image = await screenshotController.capture();
      if (image != null) {
        final tm = vm.timetables[vm.toExport!];
        saveImage(
            image, "timetable_${tm.semester.toEngString()}_${tm.name}.png",
            mimetype: "image/png");
      } else {
        dev.log("Failed capturing image.");
      }
    } catch (e) {
      dev.log("Exception caught during widget capture: $e");
    }
    vm.toExport = null;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _captureWidget(context.read<TimetableViewModel>()));

    return OverflowBox(
      // FIXME: Compute the size dynamically so that the timetable always fits.
      maxWidth: 1920,
      maxHeight: 870,
      child: Screenshot(
        controller: screenshotController,
        child: Material(
          child: CompleteTimetable(
            asExport: true,
            index: widget.exportTimetable,
          ),
        ),
      ),
    );
  }
}
