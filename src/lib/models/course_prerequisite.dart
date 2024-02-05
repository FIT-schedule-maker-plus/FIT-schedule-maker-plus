/*
 * Filename: course_prerequisite.dart
 * Project: FIT-schedule-maker-plus
 * Author: Le Duy Nguyen (xnguye27)
 * Date: 15/12/2023
 * Description: This file contains the representation of a course prerequisities.
 */

import 'package:fit_schedule_maker_plus/models/course_lesson.dart';

/// Contains information about course lesson requirements.
class CoursePrerequisite {
  /// number of required hours for this type of prerequisite
  final int requiredHours;

  /// Number of lessons for during the course
  final int numberOfLessons;

  /// Type of the prerequisite
  final LessonType type;

  CoursePrerequisite({
    required this.requiredHours,
    required this.numberOfLessons,
    required this.type,
  });

  /// Calculate the estimated hours per week for this prerequisite during the course
  int hoursPerWeek() {
    if (numberOfLessons == 0) return 0;
    return (requiredHours / numberOfLessons).floor();
  }

  factory CoursePrerequisite.fromJson(Map<String, dynamic> json) => CoursePrerequisite(
        requiredHours: int.parse(json["required_hours"]),
        numberOfLessons: int.parse(json["number_of_lessons"]),
        type: LessonType.values[int.parse(json["type"])],
      );

  Map<String, dynamic> toJson() => {
        "required_hours": requiredHours,
        "number_of_lessons": numberOfLessons,
        "type": type.index,
      };
}
