// ignore_for_file: non_constant_identifier_names

import 'package:fit_schedule_maker_plus/models/lesson_info.dart';

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
}

enum LessonType {
  lecture, // Přednáška
  seminar, // Demo cviko
  laboratory, // Laborator
  computerLab, // Computer laborator
  exercise, // cviko
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
      }
    }
    // Handle unknown cases
    return "Unknown";
  }
}

/// Represents a single lesson course.
class CourseLesson {
  /// When the lesson starts
  final int startsFrom;

  /// When the lesson ends
  final int endsAt;

  final LessonType type;
  final DayOfWeek dayOfWeek;

  List<LessonInfo> infos;

  CourseLesson({
    required this.dayOfWeek,
    required this.type,
    required this.startsFrom,
    required this.endsAt,
    required this.infos,
  });

  factory CourseLesson.fromJson(Map<String, dynamic> json) => CourseLesson(
        startsFrom: int.parse(json["starts_from"]),
        endsAt: int.parse(json["ends_at"]),
        type: LessonType.values[int.parse(json["type"])],
        dayOfWeek: DayOfWeek.values[int.parse(json["day_of_week"])],
        infos: List<LessonInfo>.from(json["infos"].map((info) => LessonInfo.fromJson(info))),
      );

  Map<String, dynamic> toJson() => {
        "starts_from": startsFrom,
        "ends_at": endsAt,
        "type": type.index,
        "day_of_week": dayOfWeek.index,
        "infos": List<dynamic>.from(infos.map((info) => info.toJson())),
      };
}
