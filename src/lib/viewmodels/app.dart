import 'package:fit_schedule_maker_plus/models/course.dart';
import 'package:flutter/material.dart';

class AppViewModel extends ChangeNotifier {
  List<Course> allCourses = [];

  Future<List<Course>> getAllCourses() async {
    await Future.delayed(Duration(milliseconds: 2000));
    return Future.value([]);
  }
}
