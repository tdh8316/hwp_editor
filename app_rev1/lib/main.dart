import 'package:hwp_editor_app/pages/page_document.dart';
import 'package:fluent_ui/fluent_ui.dart' show FluentApp;
import 'package:flutter/material.dart';

void main() {
  runApp(const HWPEditorApp());
}

class HWPEditorApp extends StatelessWidget {
  const HWPEditorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const FluentApp(
      locale: Locale("en", "US"),
      home: DocumentPage(),
    );
  }
}
