/*
 * Filename: program_course_group.dart
 * Project: FIT-schedule-maker-plus
 * Author: Le Duy Nguyen (xnguye27)
 * Date: 15/12/2023
 * Description: This file contains the representation of a group of courses for a given study program.
 */

import 'package:fit_schedule_maker_plus/models/course.dart';

/// Represents a group of courses for a given study program.
class CourseGroup {
  final Semester semester;
  final YearOfStudy yearOfStudy;
  final List<Course> courses;

  CourseGroup({
    required this.semester,
    required this.yearOfStudy,
    required this.courses,
  });

  factory CourseGroup.fromJson(Map<String, dynamic> json) => CourseGroup(
        semester: json["id"],
        yearOfStudy: json["yearOfStudy"],
        courses: json["courses"],
      );

  Map<String, dynamic> toJson() => {"semester": semester.index, "yearOfStudy": yearOfStudy.index, "courses": List<dynamic>.from(courses.map((course) => course.toJson()))};
}

enum Semester {
  winter, // zimni semester
  summer // letni semester
}

extension ParseToString on Semester {
  String toCzechString() {
    switch (this) {
      case Semester.winter:
        return "Zimní";
      case Semester.summer:
        return "Letní";
    }
  }

  String toEngString() {
    switch (this) {
      case Semester.winter:
        return "winter";
      case Semester.summer:
        return "summer";
    }
  }
}

enum YearOfStudy {
  first, // prvni rocnik
  second, // druhy rocnik
  third, // treti rocnik
  all, // libovolny
}
