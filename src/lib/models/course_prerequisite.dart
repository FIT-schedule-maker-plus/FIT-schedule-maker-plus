// ignore_for_file: non_constant_identifier_names

enum PrerequisiteType {
  lecture,
  seminar,
  laborator,
  exercise,
  project,
  pcLab,
}

class CoursePrerequisite {
  /// number of required hours for this type of prerequisite
  final int requiredHours;
  /// Number of lessons for during the course
  final int numberOfLessons;
  /// Type of the prerequisite
  final PrerequisiteType type;

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
        type: PrerequisiteType.values[int.parse(json["type"])],
      );

  Map<String, dynamic> toJson() => {
        "required_hours": requiredHours,
        "number_of_lessons": numberOfLessons,
        "type": type.index,
      };
}
