import 'package:fit_schedule_maker_plus/models/timetable.dart';

import '../viewmodels/app.dart';

/// Class for representing timetable to be exported.
class ExportTimetable {
  Timetable timetable;
  List<int> programIds;

  ExportTimetable(this.timetable, this.programIds);

  factory ExportTimetable.from({
    required Timetable timetable,
    required AppViewModel avm,
  }) {
    final usedCourseIds = timetable.selected.keys
        .map((k) => timetable.selected[k]!.keys)
        .expand((l) => l)
        .toList();
    Set<int> programIds = avm.allStudyPrograms.keys.where((id) {
      return avm.allStudyPrograms[id]!.courseGroups.any(
        (group) => group.courses.any(
          (course) => usedCourseIds.contains(course.courseId),
        ),
      );
    }).toSet();

    return ExportTimetable(timetable, programIds.toList());
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
