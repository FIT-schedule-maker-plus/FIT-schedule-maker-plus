// ignore_for_file: non_constant_identifier_names

/// Represents a single course. This course contains multiple CourseLessons with different times
class Course {
  final String shortcut;
  final String full_name;

  Course({required this.full_name, required this.shortcut});
}
