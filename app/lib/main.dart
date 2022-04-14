import 'package:flutter/material.dart';
import 'package:hwp_editor_app/pages/editor_home.dart';

void main() {
  runApp(const HWPEditorApplication());
}

class HWPEditorApplication extends StatelessWidget {
  const HWPEditorApplication({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "HWP Editor",
      debugShowCheckedModeBanner: false,
      home: EditorHomePage(),
    );
  }

}