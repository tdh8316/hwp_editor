import 'package:flutter/material.dart';
import 'package:hwp_editor_app/widgets/editor_quill.dart';

class EditorHomePage extends StatelessWidget {
  const EditorHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          EditorWidget(),
        ],
      ),
    );
  }
}
