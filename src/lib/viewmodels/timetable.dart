import 'dart:convert';
import 'package:flutter/material.dart';
import '../disp_timetable_gen.dart';
import '../models/program_course_group.dart';
import '../models/timetable.dart';
import '../utils.dart';

class TimetableViewModel extends ChangeNotifier {
  final List<Timetable> timetables;
  int active;

  final Map<int, String> _isEditing = {};

  Timetable get currentTimetable => timetables[active];
  Filter filter = Filter.none();

  TimetableViewModel({required this.timetables, this.active = 0}) {
    if (timetables.isEmpty) {
      timetables.add(Timetable(name: "default"));
    }
  }

  void addCourseToFilter(int courseId) {
    filter.courses.add(courseId);
    notifyListeners();
  }

  void removeCourseFromFilter(int courseId) {
    filter.courses.remove(courseId);
    notifyListeners();
  }

  void saveAsJson(int index) async {
    try {
      final jsonData = json.encode(timetables[index].toJson());
      saveFile(jsonData, "timetable_${timetables[index].name}.json");
    } catch (e) {
      print("Error saving file: $e");
    }
  }

  bool isEditingName({required int index}) {
    return _isEditing.containsKey(index);
  }

  void saveEditingName(int index) {
    timetables[index].name = _isEditing[index]!;
    _isEditing.remove(index);
    notifyListeners();
  }

  void updateEditingName(int index, String text) {
    _isEditing[index] = text;
  }

  void setEditingName({required int index, required bool value}) {
    if (value) {
      _isEditing[index] = timetables[index].name;
      notifyListeners();
    } else if (_isEditing.containsKey(index)) {
      _isEditing.remove(index);
      notifyListeners();
    }
  }

  void setActive({required int index}) {
    active = index;
    notifyListeners();
  }

  void createNewTimetable() {
    timetables.add(Timetable(name: "Variant name"));
    notifyListeners();
  }

  void changeSemester(Semester semester, {int? index}) {
    if (index != null) {
      timetables[index].semester = semester;
    } else {
      timetables[active].semester = semester;
    }
    notifyListeners();
  }

  void addTimetable({required Timetable timetable}) {
    timetables.add(timetable);
    notifyListeners();
  }

  void removeTimetable({required int index}) {
    timetables.removeAt(index);
    if (index == active) {
      active = 0;
      if (timetables.isEmpty) {
        timetables.add(Timetable(name: "default"));
      }
    } else if (index < active) {
      active--;
    }
    notifyListeners();
  }

  void addCourse(int courseID) {
    currentTimetable.addCourse(courseID);
    notifyListeners();
  }

  void removeCourse(int courseID) {
    currentTimetable.removeCourse(courseID);
    notifyListeners();
  }

  bool containsCourse(int courseID) {
    return currentTimetable.containsCourse(courseID);
  }

  /// Check if current timtable contains lesson.
  bool containsLesson(CourseID course, LessonID lesson) {
    return currentTimetable.containsLesson(course, lesson);
  }

  /// Add lesson to current timetable.
  void addLesson(CourseID course, LessonID lesson) {
    currentTimetable.addLesson(course, lesson);
    notifyListeners();
  }

  /// Remove lesson from current timetable.
  void removeLesson(CourseID course, LessonID lesson) {
    currentTimetable.removeLesson(course, lesson);
    notifyListeners();
  }

  /// Clear all lessons from current timetable.
  void clearLessons() {
    currentTimetable.clearLessons();
    notifyListeners();
  }
}
