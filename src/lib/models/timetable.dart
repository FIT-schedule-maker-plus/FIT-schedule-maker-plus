/*
 * Filename: timetable.dart
 * Project: FIT-schedule-maker-plus
 * Author: Jakub Kloub xkloub03
 * Date: 15/12/2023
 * Description: This file contains the representation of a timetable.
 */

import 'package:fit_schedule_maker_plus/models/course.dart';

import 'course_group.dart';
import 'lesson.dart';

class Timetable {
  /// Unique name of the timetable used for differenciating variants
  String name;

  /// Currently chosen semester
  Semester semester = Semester.winter;

  /// Contains all information about the content of this timetable.
  Map<Semester, Map<Course, Set<Lesson>>> selected = {
    Semester.winter: {},
    Semester.summer: {},
  };

  /// selected lessons in the currently chosen semester
  Map<Course, Set<Lesson>> get currentContent => selected[semester]!;

  Timetable({
    required this.name,
    Map<Semester, Map<Course, Set<Lesson>>>? courseContent,
    this.semester = Semester.winter,
  }) {
    if (courseContent != null) {
      selected = courseContent;
    }
  }

  /// Check if current semester timetable contains a given course lesson.
  bool containsLesson(Lesson lesson) {
    return currentContent.containsKey(lesson.course) &&
        currentContent[lesson.course]!.contains(lesson);
  }

  /// Add course lesson to current semester timetable.
  void selectLesson(Lesson lesson) {
    if (currentContent[lesson.course] == null) {
      currentContent[lesson.course] = {};
    }
    currentContent[lesson.course]!.add(lesson);
  }

  /// Remove lesson from current semester timetable.
  void deselectLesson(Lesson lesson) {
    currentContent[lesson.course]!.remove(lesson);
  }

  /// Clear all lessons in current semester timetable.
  void clearLessons() {
    selected[semester] = {};
  }

  /// Add course to timetable, but without any selected lessons. This is used
  /// for the case when user selected that they have a given course, but haven't selected
  /// any lessons yet.
  void addCourse(Course course) {
    currentContent[course] = {};
  }

  /// Remove course and all its course lessons from currect semester timetable.
  void removeCourse(Course course) {
    currentContent.remove(course);
  }

  /// Check if currect semester timetable contains a given course.
  bool containsCourse(Course courseID) {
    return currentContent.containsKey(courseID);
  }

  factory Timetable.fromJson(Map<String, dynamic> json) => Timetable(name: "TODO");
  Map<String, dynamic> toJson() => {};

  @override
  bool operator ==(Object other) {
    return (other is Timetable) && semester == other.semester && name == other.name;
  }

  @override
  int get hashCode => Object.hash(selected, semester, name);
}
