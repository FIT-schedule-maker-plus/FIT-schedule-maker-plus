import 'package:fit_schedule_maker_plus/models/program_course_group.dart';

enum StudyType {
  bachelor,
  magister,
}

extension ParseToString on StudyType {
  String toCzechString() {
    switch (this) {
      case StudyType.bachelor:
        return "Bakalárske";
      case StudyType.magister:
        return "Magisterské";
      default:
        return "Unknown";
    }
  }
}

/// Represents a single study program at FIT.
class StudyProgram {
  final int id;
  final String shortcut;
  final String fullName;
  final StudyType type;
  final int duration;
  List<ProgramCourseGroup> courseGroups;

  StudyProgram({
    required this.id,
    required this.fullName,
    required this.shortcut,
    required this.courseGroups,
    required this.type,
    required this.duration,
  });

  factory StudyProgram.fromJson(Map<String, dynamic> json) => StudyProgram(
      id: json["id"],
      shortcut: json["shortcut"],
      fullName: json["fullname"],
      type: json["type"],
      duration: json["duration"],
      courseGroups: List<ProgramCourseGroup>.from(json["courseGroups"].map((group) => ProgramCourseGroup.fromJson(group))));

  Map<String, dynamic> toJson() => {
        "id": id,
        "shortcut": shortcut,
        "fullname": fullName,
        "type": type,
        "duration": duration,
        "courseGroups": List<dynamic>.from(courseGroups.map((group) => group.toJson()))
      };
}
