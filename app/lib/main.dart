import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hwp_editor_app/models/model_hwp.dart';
import 'package:hwp_editor_app/pages/page_document.dart';

void main() {
  runApp(const HWPEditorApplication());
}

class HWPEditorApplication extends StatelessWidget {
  const HWPEditorApplication({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: "HWP Editor",
      debugShowCheckedModeBanner: true,
      home: DocumentPage(docData: testData()),
    );
  }
}

Map<String, dynamic> testData() => jsonDecode(
      File("../tests/complexrichtext.json").readAsStringSync(),
    );
