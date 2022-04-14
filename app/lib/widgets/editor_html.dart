import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class EditorWidget extends StatelessWidget {
  EditorWidget({Key? key}) : super(key: key);

  final HtmlEditorController _controller = HtmlEditorController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: HtmlEditor(
            controller: _controller,
            htmlEditorOptions: HtmlEditorOptions(
              shouldEnsureVisible: true
            ),
          ),
        ),
      ],
    );
  }
}
