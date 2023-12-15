/*
 * Filename: lesson_info.dart
 * Project: FIT-schedule-maker-plus
 * Author: Le Duy Nguyen (xnguye27)
 * Date: 15/12/2023
 * Description: This file contains the representation of information about lessons.
 */

class LessonInfo {
  /// Capacity of this lesson
  final int capacity;

  /// Weeks that have this lesson
  final String weeks;

  /// Info about the lesson
  final String info;

  /// Location of the lesson. For example: B/D105
  final List<String> locations;

  LessonInfo({
    required this.locations,
    required this.info,
    required this.capacity,
    required this.weeks,
  });

  factory LessonInfo.fromJson(Map<String, dynamic> json) => LessonInfo(
        locations: json["locations"],
        info: json["info"],
        weeks: json["weeks"],
        capacity: int.parse(json["capacity"]),
      );

  Map<String, dynamic> toJson() => {
        "locations": locations,
        "capacity": capacity,
        "info": info,
        "weeks": weeks,
      };
}
