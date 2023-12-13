import 'dart:convert';
import 'dart:js' as js;
import 'dart:html' as html;

void saveFile(
  dynamic data,
  String filename, {
  String typestr = "text/plain",
}) {
  final bytes = utf8.encode(data);
  // NOTE: This requires the custom <script> element inside web/index.html.
  js.context.callMethod("saveAs", <Object>[
    html.Blob(<Object>[bytes]),
    filename,
    "$typestr;charset=utf-8",
  ]);
}
