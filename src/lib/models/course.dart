/*
 * Filename: course.dart
 * Project: FIT-schedule-maker-plus
 * Author: Le Duy Nguyen (xnguye27)
 * Date: 15/12/2023
 * Description: This file contains the representation of a single course. This course contains multiple `CourseLessons` with different times.
 */

import 'course_lesson.dart';
import 'course_prerequisite.dart';
import 'program_course_group.dart';

/// Represents a single course. This course contains multiple CourseLessons with different times
class Course {
  final int id;
  final String shortcut;
  final String fullName;
  final Semester semester;
  final CourseDuty duty;
  List<CourseLesson> lessons;
  List<CoursePrerequisite> prerequisites;
  bool loaded;

  Course({
    required this.id,
    required this.fullName,
    required this.shortcut,
    required this.lessons,
    required this.prerequisites,
    required this.semester,
    required this.duty,
    this.loaded = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json["id"],
        shortcut: json["shortcut"],
        fullName: json["fullName"],
        semester: json["semester"],
        duty: json["duty"],
        lessons: List<CourseLesson>.from(json["lessons"].map((lesson) => CourseLesson.fromJson(lesson))),
        prerequisites: List<CoursePrerequisite>.from(json["prerequisites"].map((prerequisite) => CoursePrerequisite.fromJson(prerequisite))),
        loaded: false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "shortcut": shortcut,
        "fullName": fullName,
        "semester": semester,
        "duty": duty,
        "lessons": List<dynamic>.from(lessons.map((lesson) => lesson.toJson())),
        "prerequisites": List<dynamic>.from(prerequisites.map((prerequisite) => prerequisite.toJson())),
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
