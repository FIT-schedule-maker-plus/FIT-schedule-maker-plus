import 'package:flutter/material.dart';

import '../models/program_course_group.dart';
import '../models/timetable.dart';

class TimetableViewModel extends ChangeNotifier {
  final List<Timetable> timetables;
  int active;

  final Map<int, String> _isEditing = {};

  Timetable get currentTimetable => timetables[active];

  TimetableViewModel({required this.timetables, this.active = 0}) {
    if (timetables.isEmpty) {
      timetables.add(Timetable(name: "default"));
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
}
