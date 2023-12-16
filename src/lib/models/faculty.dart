/*
 * Filename: faculty.dart
 * Project: FIT-schedule-maker-plus
 * Author: Le Duy Nguyen (xnguye27)
 * Date: 15/12/2023
 * Description: This file contains the representation of faculty, which is then use to determine the faculty of lecture room
 */

enum Faculty {
  fit,
  fekt,
  cesa,
  cvis,
  fa,
  fast,
  favu,
  fch,
  fp,
  fsi,
  icv,
  re,
  usi,
}

extension FacultyExtension on Faculty {
  String getAcronym() {
    return switch (this) {
        Faculty.fit => "FIT",
        Faculty.fekt => "FEKT",
        Faculty.cesa => "CESA",
        Faculty.cvis => "CVIS",
        Faculty.fa => "FA",
        Faculty.fast => "FAST",
        Faculty.favu => "FaVU",
        Faculty.fch => "FCH",
        Faculty.fp => "FP",
        Faculty.fsi => "FSI",
        Faculty.icv => "ICV",
        Faculty.re => "RE",
        Faculty.usi => "ÚSI",
    };
  }

  int getColorThemeInHex() {
    return switch (this) {
        Faculty.fit => 0xFF00a9e0,
        Faculty.fekt => 0xFF003da5,
        Faculty.cesa => 0xFF009db1,
        Faculty.cvis => 0xFF898d8d,
        Faculty.fa => 0xFF7a99ac,
        Faculty.fast => 0xFF658d1b,
        Faculty.favu => 0xFFe782a9,
        Faculty.fch => 0xFF00ab8e,
        Faculty.fp => 0xFF8246af,
        Faculty.fsi => 0xFF004f71,
        Faculty.usi => 0xFF211447,
        Faculty.icv || Faculty.re => 0xFFe4002b, // Don't know... Use the VUT one
    };
  }
}
