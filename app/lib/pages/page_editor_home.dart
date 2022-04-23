import 'package:flutter/material.dart';
import 'package:hwp_editor_app/widgets/widget_editor.dart';

class EditorHomePage extends StatelessWidget {
  const EditorHomePage({Key? key, required this.docData}) : super(key: key);

  final Map<String, dynamic> docData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(66, 137, 201, 1),
        child: Column(
          children: [
            EditorWidget(docData: docData),
          ],
        ),
      ),
    );
  }
}
