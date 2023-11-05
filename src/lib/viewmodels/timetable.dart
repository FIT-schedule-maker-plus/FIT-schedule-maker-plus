import 'package:flutter/material.dart';

class TimetableViewModel extends ChangeNotifier {
  // Represents unique IDs of courses
  Set<int> courses = {};

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
