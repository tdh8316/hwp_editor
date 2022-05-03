import 'package:fluent_ui/fluent_ui.dart';
import 'package:hwp_editor_app/widgets/editor/widget_editor.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({Key? key, required this.docData}) : super(key: key);

  final Map<String, dynamic> docData;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Container(
        // color: const Color.fromRGBO(66, 137, 201, 1),
        child: Column(
          children: [
            EditorWidget(docData: docData),
          ],
        ),
      ),
    );
  }
}
