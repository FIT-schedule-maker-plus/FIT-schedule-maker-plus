import 'package:fit_schedule_maker_plus/models/course.dart';
import 'package:fit_schedule_maker_plus/constants.dart';
import 'package:flutter/material.dart';

import '../models/timetable.dart';
import '../models/timetable_variant.dart';
import 'variants.dart';

class AppViewModel extends ChangeNotifier {
  /// Stores all variants that store all timetables. It is stored here,
  /// so we can easily serialize and deserialize this from disk
  /// together with `allCourses`.
  late VariantsViewModel varViewMod;

  AppViewModel() {
    // TODO: Load variants from disk. Also should we do it here or somehow use Future...
    varViewMod = VariantsViewModel(variants: [
      TimetableVariant(name: 'Ver. 1', timetable: Timetable(selected: {})),
      TimetableVariant(name: 'Ver. 2', timetable: Timetable(selected: {})),
      TimetableVariant(name: 'Ver. 3', timetable: Timetable(selected: {})),
    ]);
  }

  /// Stores all courses loaded from disk or from web.
  Map<int, Course> allCourses = {};
  int grade = 1;
  String year = "2023/24";
  bool isWinterTerm = true;
  String study = "BIT";

  /// Fetch all courses from https://www.fit.vut.cz/study/course/
  Future<void> getAllCourses() async {
    // await Future.delayed(Duration(milliseconds: 2000));
    allCourses = {
      1: Course(id: 1, full_name: "Algoritmy", shortcut: "IAL", lessons: []),
      2: Course(id: 2, full_name: "", shortcut: "IFJ", lessons: []),
      3: Course(id: 3, full_name: "", shortcut: "ISS", lessons: []),
      4: Course(id: 4, full_name: "", shortcut: "INP", lessons: []),
      5: Course(id: 5, full_name: "", shortcut: "IMA2", lessons: []),
      6: Course(id: 6, full_name: "", shortcut: "IPT", lessons: []),
      7: Course(id: 7, full_name: "", shortcut: "XYZ", lessons: []),
      8: Course(id: 8, full_name: "", shortcut: "ABC", lessons: []),
      9: Course(id: 9, full_name: "", shortcut: "DEF", lessons: []),
      10: Course(id: 10, full_name: "", shortcut: "GHI", lessons: []),
      11: Course(id: 11, full_name: "", shortcut: "JKL", lessons: []),
      12: Course(id: 12, full_name: "", shortcut: "MNO", lessons: []),
      13: Course(id: 13, full_name: "", shortcut: "PQR", lessons: []),
      14: Course(id: 14, full_name: "", shortcut: "STU", lessons: []),
      15: Course(id: 15, full_name: "", shortcut: "VWX", lessons: []),
      16: Course(id: 16, full_name: "", shortcut: "YZA", lessons: []),
      17: Course(id: 17, full_name: "", shortcut: "BCD", lessons: []),
      18: Course(id: 18, full_name: "", shortcut: "EFG", lessons: []),
      19: Course(id: 19, full_name: "", shortcut: "HIJ", lessons: []),
      20: Course(id: 20, full_name: "", shortcut: "KLM", lessons: []),
      21: Course(id: 21, full_name: "", shortcut: "NOP", lessons: []),
      22: Course(id: 22, full_name: "", shortcut: "QRS", lessons: []),
      23: Course(id: 23, full_name: "", shortcut: "TUV", lessons: []),
      24: Course(id: 24, full_name: "", shortcut: "WXY", lessons: []),
      25: Course(id: 25, full_name: "", shortcut: "ZAB", lessons: []),
      26: Course(id: 26, full_name: "", shortcut: "CDE", lessons: []),
      27: Course(id: 27, full_name: "", shortcut: "FGH", lessons: []),
      28: Course(id: 28, full_name: "", shortcut: "IJK", lessons: []),
      29: Course(id: 29, full_name: "", shortcut: "LMN", lessons: []),
      30: Course(id: 30, full_name: "", shortcut: "OPQ", lessons: []),
      31: Course(id: 31, full_name: "", shortcut: "RST", lessons: []),
      32: Course(id: 32, full_name: "", shortcut: "UVW", lessons: []),
      33: Course(id: 33, full_name: "", shortcut: "XYZ", lessons: []),
      34: Course(id: 34, full_name: "", shortcut: "ABC", lessons: []),
      35: Course(id: 35, full_name: "", shortcut: "DEF", lessons: []),
    };
  }

  /// Returns name of all magister studies
  List<String> getAllMagisterStudies() {
    return [
      "NBIO",
      "NISD",
      "NISY",
      "NIDE",
      "NCPS",
      "NSEC",
      "NMAT",
      "NISD",
      "NISD"
    ];
  }

  /// Changes the grade and notifies all listeners
  void changeGrade(int grade) {
    this.grade = grade;
    notifyListeners();
  }

  /// Changes the term to winter or summer and notifies all listeners
  void changeTerm(bool isWinterTerm) {
    this.isWinterTerm = isWinterTerm;
    notifyListeners();
  }

  /// Changes the year and notifies all listeners that the year has been changed
  void changeYear(String year) {
    this.year = year;
    notifyListeners();
  }

  /// Changes the stady and notifies all listeners
  void changeStudy(String study) {
    this.study = study;
    notifyListeners();
  }

  /// Return indices of all courses that satisfy the following filters: year, term, study and [category]
  List<int> filterCourses(Category category) {
    if (study != "BIT") return [];
    if (!isWinterTerm) return [30, 31, 32];

    switch (category) {
      case Category.compulsory:
        return List.generate(6, (index) => index + (grade + 1) * 6,
            growable: false);
      case Category.compulsoryOptional:
        return List.generate(4, (index) => index + ((grade + 1) * 2),
            growable: false);
      case Category.optional:
        return List.generate(5, (index) => 2 * index + (grade + 4),
            growable: false);
      default:
        return [];
    }
  }
}
