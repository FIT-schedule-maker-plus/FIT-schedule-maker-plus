// ignore_for_file: non_constant_identifier_names

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
}

extension ParseToString on DayOfWeek {
  String toCzechString() {
    switch (this) {
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
      default:
        return "Unknown";
    }
  }
}

enum LessonType {
  lecture, // Přednáška
  seminar, // Demo cviko
  laboratory, // Laborator
  computerLab, // Computer laborator
  exercise, // cviko
}

/// Represents a single lesson course.
class CourseLesson {
  /// When the lesson starts
  final int startsFrom;

  /// When the lesson ends
  final int endsAt;

  final LessonType type;
  final DayOfWeek dayOfWeek;

  /// Location of the lesson. For example: B/D105
  final List<String> locations;
  final int capacity;

  /// Note attached to this lesson
  final String note;
  final String info;
  // final String faculty; // Cannot scrape this info tho...

  CourseLesson({
    required this.dayOfWeek,
    required this.type,
    required this.startsFrom,
    required this.endsAt,
    required this.locations,
    required this.note,
    required this.info,
    required this.capacity,
    // required this.faculty,
  });

  factory CourseLesson.fromJson(Map<String, dynamic> json) => CourseLesson(
        startsFrom: int.parse(json["starts_from"]),
        endsAt: int.parse(json["ends_at"]),
        type: LessonType.values[int.parse(json["type"])],
        dayOfWeek: DayOfWeek.values[int.parse(json["day_of_week"])],
        locations: json["locations"],
        info: json["info"],
        note: json["note"],
        capacity: int.parse(json["capacity"]),
        // faculty: json["faculty"],
      );

  Map<String, dynamic> toJson() => {
        "starts_from": startsFrom,
        "ends_at": endsAt,
        "type": type.index,
        "day_of_week": dayOfWeek.index,
        "locations": locations,
        "capacity": capacity,
        "info": info,
        "note": note,
        // "faculty": faculty,
      };
}
