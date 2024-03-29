/*
 * Filename: disp_timetable_gen.dart
 * Project: FIT-schedule-maker-plus
 * Author: Jakub Kloub (xkloub03)
 * Date: 15/12/2023
 * Description: This file encompasses the logic for filtering lessons and the representation
 *    of the currently displayed timetable. It includes information about the positions
 *    of lessons, such as their level in a given day within the week.
 */

import 'dart:math';

import 'models/course_lesson.dart';
import 'models/course.dart';
import 'models/timetable.dart';
import 'viewmodels/app.dart';
import 'viewmodels/timetable.dart';

class SpecificLesson {
  final CourseID courseID;
  final LessonID lessonID;
  int height;
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
  Set<CourseID> courses;

  /// Filter all unselected courses.
  bool allCourses;

  Filter({required this.courses, required this.allCourses});

  Filter.courses(Set<CourseID> courses) : this(courses: courses, allCourses: false);
  Filter.all() : this(courses: {}, allCourses: true);
  Filter.none() : this(courses: {}, allCourses: false);
}

void selectLesson(TimetableViewModel vm, SpecificLesson lesson) {
  lesson.selected = true;
  vm.addLesson(lesson.courseID, lesson.lessonID);
}

void deselectLesson(TimetableViewModel vm, SpecificLesson lesson) {
  lesson.selected = false;
  vm.removeLesson(lesson.courseID, lesson.lessonID);
}

class Pair<T, U> {
  T first;
  U second;
  Pair(this.first, this.second);
}

typedef DisplayedTimetable = Map<DayOfWeek, Pair<int, List<SpecificLesson>>>;

DisplayedTimetable genDispTimetableSpecific(AppViewModel avm, Timetable tim, Filter filter) {
  DisplayedTimetable res = {
    DayOfWeek.monday: Pair(0, []),
    DayOfWeek.tuesday: Pair(0, []),
    DayOfWeek.wednesday: Pair(0, []),
    DayOfWeek.thursday: Pair(0, []),
    DayOfWeek.friday: Pair(0, []),
  };
  fillDays(avm.allCourses, tim, filter, res);
  fillHeights(avm.allCourses, res);
  return res;
}

DisplayedTimetable genDispTimetable(AppViewModel avm, TimetableViewModel tvm, Filter filter) {
  DisplayedTimetable res = {
    DayOfWeek.monday: Pair(0, []),
    DayOfWeek.tuesday: Pair(0, []),
    DayOfWeek.wednesday: Pair(0, []),
    DayOfWeek.thursday: Pair(0, []),
    DayOfWeek.friday: Pair(0, []),
  };

  fillDays(avm.allCourses, tvm.currentTimetable, filter, res);
  fillHeights(avm.allCourses, res);

  return res;
}

void fillHeights(
  Map<CourseID, Course> courses,
  DisplayedTimetable outTim,
) {
  outTim.forEach((_, pair) {
    pair.second.sort((a, b) {
      final lessonA = courses[a.courseID]!.lessons[a.lessonID];
      final lessonB = courses[b.courseID]!.lessons[b.lessonID];
      if (lessonA.startsFrom != lessonB.startsFrom) {
        return lessonA.startsFrom - lessonB.startsFrom;
      }
      return courses[a.courseID]!.shortcut.compareTo(courses[b.courseID]!.shortcut);
    });

    final List<int> levels = [];

    for (var sl in pair.second) {
      final lesson = courses[sl.courseID]!.lessons[sl.lessonID];
      // Try to find a level where this lesson fits
      bool levelFound = false;
      for (int i = 0; i < levels.length; i++) {
        if (levels[i] < lesson.startsFrom) {
          levels[i] = lesson.endsAt;
          sl.height = i;
          levelFound = true;
          break;
        }
      }
      // Add new layer if it does not.
      if (!levelFound) {
        sl.height = levels.length;
        levels.add(lesson.endsAt);
      }

      pair.first = max(pair.first, sl.height);
    }
  });
}

void fillDays(Map<CourseID, Course> courses, Timetable tim, Filter filter, DisplayedTimetable outTim) {
  if (filter.allCourses) {
    tim.currentContent.forEach((courseID, lessons) {
      for (final lessonID in lessons) {
        final lesson = courses[courseID]!.lessons[lessonID];
        final sl = SpecificLesson(
          courseID: courseID,
          lessonID: lessonID,
          height: 0,
          selected: true,
        );
        outTim[lesson.dayOfWeek]!.second.add(sl);
      }
    });
    return;
  }

  final allCourseIDs = tim.currentContent.keys.toList();

  for (int i = 0; i < allCourseIDs.length; i++) {
    final courseID = allCourseIDs[i];
    final course = courses[courseID]!;

    for (int j = 0; j < course.lessons.length; j++) {
      final lesson = course.lessons[j];
      final sl = SpecificLesson(
        courseID: courseID,
        lessonID: j,
        height: 0,
        selected: tim.containsLesson(courseID, j),
      );
      // Filter only when the course isn't selected.
      if (!filter.courses.contains(courseID) || sl.selected) {
        outTim[lesson.dayOfWeek]!.second.add(sl);
      }
    }
  }
}
