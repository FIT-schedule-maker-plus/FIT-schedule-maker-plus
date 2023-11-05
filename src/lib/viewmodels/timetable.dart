import 'package:flutter/material.dart';

import '../models/timetable.dart';

class TimetableViewModel extends ChangeNotifier {
  // Represents unique IDs of courses
  Set<int> courses = {};

  final List<Timetable> timetables;
  int active;

  TimetableViewModel({required this.timetables, this.active = 0}) {
    if (timetables.isEmpty) {
      timetables.add(Timetable(name: "default", selected: {}));
    }
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
        timetables.add(Timetable(name: "default", selected: {}));
      }
    }
    notifyListeners();
  }

  void addCourse(int courseID) {
    courses.add(courseID);
    notifyListeners();
  }

  void removeCourse(int courseID) {
    courses.remove(courseID);
    notifyListeners();
  }

  bool containsCourse(int courseID) {
    return courses.contains(courseID);
  }
}
