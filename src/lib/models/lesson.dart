/*
 * Filename: course_lesson.dart
 * Project: FIT-schedule-maker-plus
 * Author: Le Duy Nguyen (xnguye27)
 * Date: 15/12/2023
 * Description: This file contains the representation of a single lesson course.
 */

import 'package:fit_schedule_maker_plus/models/course.dart';

import 'lesson_info.dart';

class Lesson {
  /// When the lesson starts
  final int startsFrom;

  /// When the lesson ends
  final int endsAt;

  final LessonType type;
  final DayOfWeek dayOfWeek;

  /// Course this lesson belongs to.
  final Course course;

  List<LessonInfo> infos;

  Lesson({
    required this.dayOfWeek,
    required this.type,
    required this.startsFrom,
    required this.endsAt,
    required this.infos,
    required this.course,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        startsFrom: int.parse(json["starts_from"]),
        endsAt: int.parse(json["ends_at"]),
        type: LessonType.values[int.parse(json["type"])],
        dayOfWeek: DayOfWeek.values[int.parse(json["day_of_week"])],
        course: Course.fromJson(json["course"]),
        infos: List<LessonInfo>.from(
            json["infos"].map((info) => LessonInfo.fromJson(info))),
      );

  Map<String, dynamic> toJson() => {
        "starts_from": startsFrom,
        "ends_at": endsAt,
        "type": type.index,
        "day_of_week": dayOfWeek.index,
        "infos": List<dynamic>.from(infos.map((info) => info.toJson())),
      };
}

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
}

enum LessonType {
  lecture, // Přednáška
  laboratory, // Laborator
  computerLab, // Computer laborator
  exercise, // cviko
  seminar, // Demo cviko
  project, // projekt
}

extension ParseToString<T extends Enum> on T {
  String toCzechString() {
    if (this is DayOfWeek) {
      switch (this as DayOfWeek) {
        case DayOfWeek.monday:
          return "Po";
        case DayOfWeek.tuesday:
          return "Ut";
        case DayOfWeek.wednesday:
          return "St";
        case DayOfWeek.thursday:
          return "Čt";
        case DayOfWeek.friday:
          return "Pá";
      }
    } else if (this is LessonType) {
      switch (this as LessonType) {
        case LessonType.lecture:
          return "Přednáška";
        case LessonType.seminar:
          return "Demo cviko";
        case LessonType.laboratory:
          return "Laboratoř";
        case LessonType.computerLab:
          return "Cvičení s počítačovou podporou";
        case LessonType.exercise:
          return "Cvičení";
        case LessonType.project:
          return "Projekt";
      }
    }
    // Handle unknown cases
    return "Unknown";
  }
}
