import 'package:flutter/material.dart';

import '../models/timetable.dart';
import '../models/timetable_variant.dart';

class VariantsViewModel extends ChangeNotifier {
  final List<TimetableVariant> variants;

  VariantsViewModel({required this.variants});

  void addVariant({required String name, required Timetable timetable}) {
    variants.add(TimetableVariant(name: name, timetable: timetable));
    notifyListeners();
  }

  void deleteVariant({required String name}) {
    variants.removeWhere((variant) => variant.name == name);
    notifyListeners();
  }
}
