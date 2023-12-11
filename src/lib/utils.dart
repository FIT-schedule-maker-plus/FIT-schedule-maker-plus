import 'models/timetable.dart';
import 'viewmodels/timetable.dart';

class SpecificLesson {
  final CourseID courseID;
  final LessonID lessonID;
  final int height;
  bool selected;

  SpecificLesson({
    required this.courseID,
    required this.lessonID,
    required this.height,
    required this.selected,
  });
}

class Filter {
  /// List of all courses which will have their unselected lessons filtered out.
  List<CourseID> courses;

  /// Filter all unselected courses.
  bool allCourses;

  Filter({required this.courses, required this.allCourses});

  Filter.courses(List<CourseID> courses)
      : this(courses: courses, allCourses: false);
  Filter.all() : this(courses: [], allCourses: true);
  Filter.none() : this(courses: [], allCourses: false);
}

void selectLesson(
  TimetableViewModel vm,
  SpecificLesson lesson,
) {
  lesson.selected = true;
  vm.addLesson(lesson.courseID, lesson.lessonID);
}

void deselectLesson(
  TimetableViewModel vm,
  SpecificLesson lesson,
) {
  lesson.selected = false;
  vm.removeLesson(lesson.courseID, lesson.lessonID);
}
