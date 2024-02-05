/*
 * Filename: study.dart
 * Project: FIT-schedule-maker-plus
 * Author: Le Duy Nguyen (xnguye27)
 * Date: 15/12/2023
 * Description: This file contains the representation of a a single study program at FIT.
 */

import 'course_group.dart';

/// Represents a single study program at FIT.
class StudyProgram {
  final int id;
  final String shortcut;
  final String fullName;
  final StudyType type;
  final int duration;
  List<CourseGroup> courseGroups;

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
      courseGroups:
          List<CourseGroup>.from(json["courseGroups"].map((group) => CourseGroup.fromJson(group))));

  Map<String, dynamic> toJson() => {
        "id": id,
        "shortcut": shortcut,
        "fullname": fullName,
        "type": type,
        "duration": duration,
        "courseGroups": List<dynamic>.from(courseGroups.map((group) => group.toJson())),
      };
}

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
        return "Magisterske";
      default:
        return "Unknown";
    }
  }
}
