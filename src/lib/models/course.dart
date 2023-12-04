// ignore_for_file: non_constant_identifier_names

import 'package:fit_schedule_maker_plus/models/course_lesson.dart';

/// Represents a single course. This course contains multiple CourseLessons with different times
class Course {
  final int id;
  final String shortcut;
  final String fullName;
  List<CourseLesson> lessons;
  bool loadedLessons;

  Course({
    required this.id,
    required this.fullName,
    required this.shortcut,
    required this.lessons,
    required this.loadedLessons,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json["id"],
        shortcut: json["shortcut"],
        fullName: json["fullName"],
        lessons: List<CourseLesson>.from(json["lessons"].map((lesson) => CourseLesson.fromJson(lesson))),
        loadedLessons: false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "shortcut": shortcut,
        "fullName": fullName,
        "lessons": List<dynamic>.from(lessons.map((lesson) => lesson.toJson())),
      };
}
