/*
 * Filename: main.dart
 * Project: FIT-schedule-maker-plus
 * Author: Jakub Kloub (xkloub03)
 * Date: 15/12/2023
 * Description: This file contains utility functions for saving data to files and images.
 */

import 'dart:convert';
import 'dart:js' as js;
import 'dart:html' as html;
import 'dart:typed_data';

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
