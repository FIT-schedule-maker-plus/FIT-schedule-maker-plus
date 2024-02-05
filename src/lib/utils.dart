/*
 * Filename: utils.dart
 * Project: FIT-schedule-maker-plus
 * Author: Jakub Kloub (xkloub03)
 * Date: 15/12/2023
 * Description: This file contains utility functions for saving data to files and images.
 */

import 'dart:convert';
import 'dart:js' as js;
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'models/course_lesson.dart';

void saveFile(
  dynamic data,
  String filename, {
  String mimetype = "text/plain",
}) {
  final bytes = utf8.encode(data);
  // NOTE: This requires the custom <script> element inside web/index.html.
  js.context.callMethod("saveAs", <Object>[
    html.Blob(<Object>[bytes]),
    filename,
    "$mimetype;charset=utf-8",
  ]);
}

void saveImage(
  Uint8List bytes,
  String filename, {
  String mimetype = "text/plain",
}) {
  // NOTE: This requires the custom <script> element inside web/index.html.
  js.context.callMethod("saveAs", <Object>[
    html.Blob(<Object>[bytes]),
    filename,
    "$mimetype;charset=utf-8",
  ]);
}

Color getLessonColor(LessonType type) {
  return switch (type) {
    LessonType.lecture => const Color.fromARGB(255, 22, 106, 30),
    LessonType.seminar => const Color.fromARGB(255, 38, 161, 161),
    LessonType.exercise => const Color.fromARGB(255, 21, 69, 88),
    LessonType.computerLab => const Color.fromARGB(255, 89, 3, 3),
    LessonType.laboratory => const Color.fromARGB(255, 111, 92, 24),
    LessonType.project => const Color.fromARGB(255, 177, 97, 17),
  };
}
