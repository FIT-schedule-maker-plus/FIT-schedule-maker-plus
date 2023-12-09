import 'package:fit_schedule_maker_plus/models/program_course_group.dart';

/// Represents a single study program at FIT.
class StudyProgram {
  final int id;
  final String shortcut;
  final String fullName;
  List<ProgramCourseGroup> courseGroups;

  StudyProgram({
    required this.id,
    required this.fullName,
    required this.shortcut,
    required this.courseGroups,
  });

  factory StudyProgram.fromJson(Map<String, dynamic> json) => StudyProgram (
        id: json["id"],
        shortcut: json["shortcut"],
        fullName: json["fullname"],
        courseGroups: List<ProgramCourseGroup>.from(json["courseGroups"].map((group) => ProgramCourseGroup.fromJson(group)))
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "shortcut": shortcut,
        "fullname": fullName,
        "courseGroups": List<dynamic>.from(courseGroups.map((group) => group.toJson()))
      };
}
