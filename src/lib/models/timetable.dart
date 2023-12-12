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

  /// Check if current semester timetable contains a given course lesson.
  bool containsLesson(CourseID course, LessonID lesson) {
    return currentContent.containsKey(course) &&
        currentContent[course]!.contains(lesson);
  }

  /// Add course lesson to current semester timetable.
  void addLesson(CourseID course, LessonID lesson) {
    if (currentContent[course] == null) {
      currentContent[course] = {};
    }
    currentContent[course]!.add(lesson);
  }

  /// Remove lesson from current semester timetable.
  void removeLesson(CourseID course, LessonID lesson) {
    if (!containsLesson(course, lesson)) {
      return;
    }
    currentContent[course]!.remove(lesson);
  }

  /// Clear all lessons in current semester timetable.
  void clearLessons() {
    selected[semester] = {};
  }

  /// Add course to timetable, but without any selected lessons. This is used
  /// for the case when user selected that they have a given course, but haven't selected
  /// any lessons yet.
  void addCourse(CourseID courseID) {
    currentContent[courseID] = {};
  }

  /// Remove course and all its course lessons from currect semester timetable.
  void removeCourse(CourseID courseID) {
    currentContent.remove(courseID);
  }

  /// Check if currect semester timetable contains a given course.
  bool containsCourse(CourseID courseID) {
    return currentContent.containsKey(courseID);
  }

  factory Timetable.fromJson(Map<String, dynamic> json) => Timetable(
        name: json["name"],
        courseContent: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "sel_semester": semester.index,
        "name": name,
        "selected": selected.map(
          (sem, val) => MapEntry(
            sem.index.toString(),
            val.map(
              (key, val) => MapEntry(
                key.toString(),
                val.toList(),
              ),
            ),
          ),
        ),
      };
}
