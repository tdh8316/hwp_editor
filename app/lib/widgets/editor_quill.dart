import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class EditorWidget extends StatelessWidget {
  EditorWidget({Key? key}) : super(key: key);

  final QuillController _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: QuillEditor.basic(
            controller: _controller,
            readOnly: false,
          ),
        ),
      ],
    );
  }
}
