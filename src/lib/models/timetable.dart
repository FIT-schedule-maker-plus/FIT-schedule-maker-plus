import 'program_course_group.dart';

class Timetable {
  /// Key: Index into List<Courses> from AppViewModel.allCourses
  /// Value: Index into List<CourseLesson> from Course.lessons
  Map<int, int> selected = {};

  /// Unique name of the timetable used for differenciating variants
  String name;

  Semester semester = Semester.winter;

  Timetable({required this.name, required this.selected});

  factory Timetable.fromJson(Map<String, dynamic> json) => Timetable(
        selected: json["selected"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "selected": selected,
        "name": name,
      };
}
