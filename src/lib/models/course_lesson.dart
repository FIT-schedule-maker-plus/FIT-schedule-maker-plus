// ignore_for_file: non_constant_identifier_names

import 'package:fit_schedule_maker_plus/models/lesson_type.dart';

/// Represents a single lesson course.
class CourseLesson {
  /// When the lesson starts
  final int hour_from;

  /// When the lesson ends + 10 minutes to round to nearest hour.
  final int hour_to;

  final LessonType type;

  /// Location of the lesson. For example: B/D105
  final String location;
  final String faculty;

  CourseLesson({
    required this.hour_from,
    required this.hour_to,
    required this.type,
    required this.location,
    required this.faculty,
  });

  factory CourseLesson.fromJson(Map<String, dynamic> json) => CourseLesson(
        hour_from: int.parse(json["hour_from"]),
        hour_to: int.parse(json["hour_to"]),
        type: LessonType.values[int.parse(json["type"])],
        location: json["location"],
        faculty: json["faculty"],
      );

  Map<String, dynamic> toJson() => {
        "hour_from": hour_from,
        "hour_to": hour_to,
        "type": type.index,
        "location": location,
        "faculty": faculty,
      };
}
