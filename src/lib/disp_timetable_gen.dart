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

import 'models/course.dart';
import 'models/lesson.dart';
import 'models/timetable.dart';
import 'viewmodels/app.dart';
import 'viewmodels/timetable.dart';

class SpecificLesson {
  final Lesson lesson;
  int height;

  SpecificLesson({
    required this.lesson,
    required this.height,
  });
}

class Filter {
  /// List of all courses which will have their unselected lessons filtered out.
  Set<Course> courses;

  /// Filter all unselected courses.
  bool allCourses;

  Filter({required this.courses, required this.allCourses});

  Filter.courses(Set<Course> courses) : this(courses: courses, allCourses: false);
  Filter.all() : this(courses: {}, allCourses: true);
  Filter.none() : this(courses: {}, allCourses: false);
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
  fillDays(tim, filter, res);
  fillHeights(res);
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

  fillDays(tvm.currentTimetable, filter, res);
  fillHeights(res);

  return res;
}

void fillHeights(DisplayedTimetable outTim) {
  outTim.forEach((_, pair) {
    pair.second.sort((a, b) {
      if (a.lesson.startsFrom != b.lesson.startsFrom) {
        return a.lesson.startsFrom - b.lesson.startsFrom;
      }
      return a.lesson.course.shortcut.compareTo(b.lesson.course.shortcut);
    });

    final List<int> levels = [];

    for (var sl in pair.second) {
      // Try to find a level where this lesson fits
      bool levelFound = false;
      for (int i = 0; i < levels.length; i++) {
        if (levels[i] < sl.lesson.startsFrom) {
          levels[i] = sl.lesson.endsAt;
          sl.height = i;
          levelFound = true;
          break;
        }
      }
      // Add new layer if it does not.
      if (!levelFound) {
        sl.height = levels.length;
        levels.add(sl.lesson.endsAt);
      }

      pair.first = max(pair.first, sl.height);
    }
  });
}

void fillDays(Timetable tim, Filter filter, DisplayedTimetable outTim) {
  if (filter.allCourses) {
    tim.currentContent.forEach((courseID, lessons) {
      for (final lesson in lessons) {
        final sl = SpecificLesson(
          lesson: lesson,
          height: 0,
        );
        outTim[lesson.dayOfWeek]!.second.add(sl);
      }
    });
    return;
  }

  for (var course in tim.currentContent.keys) {
    for (var lesson in course.lessons) {
      final sl = SpecificLesson(
        lesson: lesson,
        height: 0,
      );
      // Filter only when the course isn't selected.
      if (!filter.courses.contains(course) || tim.containsLesson(lesson)) {
        outTim[lesson.dayOfWeek]!.second.add(sl);
      }
    }
  }
}
