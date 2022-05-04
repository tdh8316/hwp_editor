import 'package:fluent_ui/fluent_ui.dart';
import 'package:hwp_editor_app/providers/provider_editor.dart';
import 'package:hwp_editor_app/widgets/editor/widget_paragraph.dart';
import 'package:provider/provider.dart';

class EditorWidget extends StatelessWidget {
  const EditorWidget({Key? key, required this.docData}) : super(key: key);

  final Map<String, dynamic> docData;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditorProvider>(
      create: (BuildContext context) => EditorProvider(hwpDocument: docData),
      builder: (BuildContext context, _) {
        final EditorProvider watch = context.watch<EditorProvider>();
        final EditorProvider read = context.read<EditorProvider>();
        return Padding(
          padding: const EdgeInsets.all(32),
          child: MediaQuery(
            data: MediaQueryData(
              textScaleFactor: watch.textScaleFactor,
            ),
            child: _buildSections(context),
          ),
        );
      },
    );
  }

  Widget _buildSections(BuildContext context) {
    final EditorProvider watch = context.watch<EditorProvider>();
    final EditorProvider read = context.read<EditorProvider>();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: (watch.hwpDocument["bodyText"]["sections"] as List).length,
      itemBuilder: (BuildContext context, int sectionIndex) {
        return _buildParagraphs(context, sectionIndex);
      },
    );
  }

  Widget _buildParagraphs(BuildContext context, int sectionIndex) {
    final EditorProvider watch = context.watch<EditorProvider>();
    final EditorProvider read = context.read<EditorProvider>();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: (watch.hwpDocument["bodyText"]["sections"][sectionIndex]
              ["paragraphs"] as List)
          .length,
      itemBuilder: (BuildContext context, int paragraphIndex) {
        return ParagraphWidget(
          sectionIndex: sectionIndex,
          paragraphIndex: paragraphIndex,
          paragraph: watch.hwpDocument["bodyText"]["sections"][sectionIndex]
              ["paragraphs"][paragraphIndex],
        );
      },
    );
  }
}
