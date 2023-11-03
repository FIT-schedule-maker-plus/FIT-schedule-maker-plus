class Timetable {
  /// Key: Index into List<Courses> from AppViewModel.allCourses
  ///
  /// Value: Index into List<CourseLesson> from Course.lessons
  Map<int, int> selected = {};

  Timetable({required this.selected});

  factory Timetable.fromJson(Map<String, dynamic> json) => Timetable(
        selected: json["selected"],
      );

  Map<String, dynamic> toJson() => {
        "selected": selected,
      };
}
