import 'package:app_rev1/pages/page_document.dart';
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
      home: DocumentPage(),
    );
  }
}
