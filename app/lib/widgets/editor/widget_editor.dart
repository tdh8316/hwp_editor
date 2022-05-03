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
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Container(
            child: MediaQuery(
              data: MediaQueryData(
                textScaleFactor:
                    context.watch<EditorProvider>().textScaleFactor,
              ),
              child: _bodyTextBuilder(context),
            ),
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _bodyTextBuilder(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 720,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: context
            .watch<EditorProvider>()
            .hwpDocument["bodyText"]["sections"]
            .length,
        itemBuilder: (BuildContext context, int sectionIndex) {
          return _sectionBuilder(context, sectionIndex);
        },
      ),
    );
  }

  Widget _sectionBuilder(BuildContext context, int sectionIndex) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: context
          .watch<EditorProvider>()
          .hwpDocument["bodyText"]["sections"][sectionIndex]["paragraphs"]
          .length,
      itemBuilder: (BuildContext context, int paragraphIndex) {
        return _paragraphBuilder(
          context,
          sectionIndex,
          paragraphIndex,
        );
      },
    );
  }

  Widget _paragraphBuilder(
      BuildContext context, int sectionIndex, int paragraphIndex) {
    return ParagraphWidget(
      sectionIndex: sectionIndex,
      paragraphIndex: paragraphIndex,
    );
  }
}
