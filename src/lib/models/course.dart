// ignore_for_file: non_constant_identifier_names

import 'package:fit_schedule_maker_plus/models/course_lesson.dart';

/// Represents a single course. This course contains multiple CourseLessons with different times
class Course {
  final String shortcut;
  final String full_name;
  final List<CourseLesson> lessons;

  Course({required this.full_name, required this.shortcut, required this.lessons});

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        shortcut: json["hour_from"],
        full_name: json["hour_to"],
        lessons: List<CourseLesson>.from(json["lessons"].map((lesson) => CourseLesson.fromJson(lesson))),
      );

  Map<String, dynamic> toJson() => {
        "hour_from": shortcut,
        "hour_to": full_name,
        "lessons": List<dynamic>.from(lessons.map((lesson) => lesson.toJson())),
      };
}
