import 'package:fit_schedule_maker_plus/models/course.dart';
import 'package:flutter/material.dart';

import '../models/timetable.dart';
import '../models/timetable_variant.dart';
import 'variants.dart';

class AppViewModel extends ChangeNotifier {
  /// Stores all courses loaded from disk or from web.
  /// FIXME: How will we determine that it is to be loaded from web?
  /// NOTE:  Maybe we should alwaays load from disk if available and
  ///        only load from web, when the user asks for it..
  List<Course> allCourses = [];

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

  Future<List<Course>> getAllCourses() async {
    // FIXME: Set this.allCourses to some value.
    // TODO: Deserialize from disk or scrape from net.
    // await Future.delayed(Duration(milliseconds: 2000));
    return Future.value([]);
  }
}
