import 'program_course_group.dart';

/// Index into AppViewModel::allCourser
typedef CourseID = int;

/// Index into Course::lessons
typedef LessonID = int;

class Timetable {
  /// Contains all information about the content of this timetable. The structure is as follows:
  /// -> Semester
  ///     -> All CourseID's that this semester Contains
  ///         -> All LessonID's this course contains.
  Map<Semester, Map<CourseID, Set<LessonID>>> selected = {
    Semester.winter: {},
    Semester.summer: {},
  };

  Map<CourseID, Set<LessonID>> get currentContent => selected[semester]!;
  Semester semester = Semester.winter;

  /// Unique name of the timetable used for differenciating variants
  String name;

  Timetable({
    required this.name,
    Map<Semester, Map<CourseID, Set<LessonID>>>? courseContent,
  }) {
    if (courseContent != null) {
      selected = courseContent;
    }
  }

  bool containsLesson({required CourseID course, required LessonID lesson}) {
    return currentContent.containsKey(course) &&
        currentContent[course]!.contains(lesson);
  }

  void addCourse(CourseID courseID) {
    currentContent[courseID] = {};
  }

  void removeCourse(CourseID courseID) {
    currentContent.remove(courseID);
  }

  bool containsCourse(CourseID courseID) {
    return currentContent.containsKey(courseID);
  }

  factory Timetable.fromJson(Map<String, dynamic> json) => Timetable(
        name: json["name"],
        courseContent: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "semester": semester,
        "name": name,
        "content": selected,
      };
}
