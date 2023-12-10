import 'package:flutter/material.dart';

import '../models/program_course_group.dart';
import '../models/timetable.dart';

class TimetableViewModel extends ChangeNotifier {
  // Represents unique IDs of courses
  Map<Semester, Set<int>> courses = {Semester.winter: {}, Semester.summer: {}};
  Semester semester = Semester.winter;

  final List<Timetable> timetables;
  int active;

  TimetableViewModel({required this.timetables, this.active = 0}) {
    if (timetables.isEmpty) {
      timetables.add(Timetable(name: "default", selected: {}));
    }
  }

  void setActive({required int index}) {
    active = index;
    notifyListeners();
  }

  void changeSemester(Semester semester) {
    this.semester = semester;
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
        timetables.add(Timetable(name: "default", selected: {}));
      }
    }
    notifyListeners();
  }

  void addCourse(int courseID) {
    courses[semester]!.add(courseID);
    notifyListeners();
  }

  void removeCourse(int courseID) {
    courses[semester]!.remove(courseID);
    notifyListeners();
  }

  bool containsCourse(int courseID) {
    return courses[semester]!.contains(courseID);
  }
}
