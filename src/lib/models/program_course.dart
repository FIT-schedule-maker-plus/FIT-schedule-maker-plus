/*
 * Filename: program_course.dart
 * Project: FIT-schedule-maker-plus
 * Author: Le Duy Nguyen (xnguye27)
 * Date: 15/12/2023
 * Description: This file contains the representation of a course in a progr`ProgramCourseGroup`.
 */

/// Represent a course in a `ProgramCourseGroup`.
class ProgramCourse {
  final int courseId;
  final CourseDuty duty;

  ProgramCourse({
    required this.courseId,
    required this.duty,
  });

  factory ProgramCourse.fromJson(Map<String, dynamic> json) => ProgramCourse(
        courseId: json["course_id"],
        duty: json["duty"],
      );

  Map<String, dynamic> toJson() => {
        "course_id": courseId,
        "duty": duty.index,
      };
}

enum CourseDuty {
  compulsory, // povinny
  elective, // volitelny
  compulsoryElective, // povinne volitelny
  recommended, // doporuceny
}

extension ParseToString on CourseDuty {
  String toCzechString() {
    switch (this) {
      case CourseDuty.compulsory:
        return "Povinne předměty";
      case CourseDuty.compulsoryElective:
        return "Povinne volitelne předměty";
      case CourseDuty.elective:
        return "Volitelne předměty";
      case CourseDuty.recommended:
        return "Doporučene předměty";
      default:
        return "Unknown";
    }
  }
}
