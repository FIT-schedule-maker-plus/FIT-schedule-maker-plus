/*
 * Filename: timetable.dart
 * Project: FIT-schedule-maker-plus
 * Author: Jakub Kloub (xkloub03)
 * Date: 15/12/2023
 * Description: This file defines the TimetableViewModel class, a ChangeNotifier
 *    responsible for managing timetables, filters, and operations related
 *    to the user interface for the timetable view in the application.
 */

import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:fit_schedule_maker_plus/models/export_timetable.dart';
import 'package:flutter/material.dart';

import '../disp_timetable_gen.dart';
import '../models/program_course_group.dart';
import '../models/timetable.dart';
import '../utils.dart';
import 'app.dart';

class TimetableViewModel extends ChangeNotifier {
  final List<Timetable> timetables;
  final Map<int, String> _isEditing = {};
  Filter filter = Filter.none();
  int? _toExport;
  int active;

  /// Returns the acitve timetable
  Timetable get currentTimetable => timetables[active];

  /// Timetable to export on next build.
  int? get toExport => _toExport;
  set toExport(int? val) {
    if (_toExport != val) {
      _toExport = val;
      notifyListeners();
    }
  }

  TimetableViewModel({required this.timetables, this.active = 0}) {
    if (timetables.isEmpty) timetables.add(Timetable(name: "default"));
  }

  void addCourseToFilter(int courseId) {
    filter.courses.add(courseId);
    notifyListeners();
  }

  void removeCourseFromFilter(int courseId) {
    filter.courses.remove(courseId);
    notifyListeners();
  }

  void saveAsJson({int? index, required AppViewModel avm}) async {
    final exportTimetable = ExportTimetable.from(
      avm: avm,
      timetable: timetables[index ?? active],
    );
    try {
      saveFile(
        json.encode(exportTimetable.toJson()),
        "timetable_${exportTimetable.timetable.name}.json",
      );
    } catch (e) {
      print("Error saving file: $e");
    }
  }

  void loadFromJson(AppViewModel avm) async {
    final res = await FilePicker.platform.pickFiles(allowMultiple: false);
    try {
      final data = utf8.decode(res!.files.first.bytes!.toList());
      final exportTimetable = ExportTimetable.fromJson(jsonDecode(data));
      for (final progId in exportTimetable.programIds) {
        await avm.getProgramCourses(progId);
      }
      for (final val in exportTimetable.timetable.selected.values) {
        await avm.getAllCourseLessonsAsync(val.keys.toList());
      }
      exportTimetable.timetable.semester = Semester.winter;
      timetables.add(exportTimetable.timetable);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void saveAsPng({int? index}) {
    if (_toExport != null) {
      return;
    }
    toExport = index ?? active;
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
