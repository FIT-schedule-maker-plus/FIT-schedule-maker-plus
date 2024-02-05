/*
 * Filename: export_timetable.dart
 * Project: FIT-schedule-maker-plus
 * Author: Jakub Kloub (xkloub03)
 * Date: 15/12/2023
 * Description: This file contains datastructure representing exported timetable as JSON.
 */

import '../models/timetable.dart';
import '../viewmodels/app.dart';

/// Class for representing timetable to be exported.
class ExportTimetable {
  /// Timetable to export.
  Timetable timetable;

  /// All program ids used byt this timetbale. This is used when loading the exported timetable,
  /// we need to load all programs and their lessons that this timetable is using.
  List<int> programIds;

  ExportTimetable(this.timetable, this.programIds);

  factory ExportTimetable.from({
    required Timetable timetable,
    required AppViewModel avm,
  }) {
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson() => {
        "timetable": timetable.toJson(),
        "programIds": programIds,
      };

  factory ExportTimetable.fromJson(Map<String, dynamic> json) =>
      ExportTimetable(
        Timetable.fromJson(json["timetable"]),
        List<int>.from(json["programIds"]),
      );
}
