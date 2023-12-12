// ignore_for_file: non_constant_identifier_names

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

