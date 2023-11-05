import 'timetable.dart';

/// @breif Represents a single timetable variant.
///
/// Timetable variant is basically a tiemtable with given name. These can be exported and loaded as wanted by user.
class TimetableVariant {
  final String name;
  final Timetable timetable;

  TimetableVariant({required this.name, required this.timetable});

  factory TimetableVariant.fromJson(Map<String, dynamic> json) =>
      TimetableVariant(
        name: json["name"],
        timetable: Timetable.fromJson(json["timetable"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "timetable": timetable.toJson(),
      };
}
