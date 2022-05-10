import 'package:fluent_ui/fluent_ui.dart';
import 'package:hwp_editor_app/providers/provider_document.dart';
import 'package:hwp_editor_app/widgets/editor/widget_paragraph.dart';
import 'package:provider/provider.dart';

class DocumentPage extends StatelessWidget {
  const DocumentPage({
    Key? key,
    required this.docData,
  }) : super(key: key);

  final Map<String, dynamic> docData;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: ChangeNotifierProvider<DocumentPageProvider>(
        create: (BuildContext context) => DocumentPageProvider(
          hwpDocument: docData,
        ),
        builder: (BuildContext context, _) {
          final DocumentPageProvider watch =
              context.watch<DocumentPageProvider>();
          // final DocumentPageProvider read = context.read<DocumentPageProvider>();

          return Column(
            children: [
              _buildCommandBar(context),
              CommandBarCard(
                child: Column(
                  children: [
                    SizedBox(
                      height: 60,
                      child: Row(),
                    ),
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 20,
                      ),
                      child: Row(
                        children: [
                          Selector<DocumentPageProvider, TextStyle>(
                            selector: (_, provider) =>
                                provider.editorState.currentTextStyle,
                            builder: (_, TextStyle style, __) => Row(
                              children: [
                                DropDownButton(
                                  title: Text(style.fontFamily.toString()),
                                  items: [
                                    MenuFlyoutItem(
                                      text: Text("함초롬바탕"),
                                      onPressed: () {},
                                    ),MenuFlyoutItem(
                                      text: Text("맑은 고딕"),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                                Text("bold:${style.fontWeight == FontWeight.bold}/"),
                                Text("italic:${style.fontStyle?.index == 1}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                child: _buildEditor(context),
                height: MediaQuery.of(context).size.height - 144,
                width: 770,
                // width: MediaQuery.of(context).size.width,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final DocumentPageProvider watch = context.watch<DocumentPageProvider>();
    // final DocumentPageProvider read = context.read<DocumentPageProvider>();
    return Padding(
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: MediaQuery(
              data: MediaQueryData(
                textScaleFactor: watch.editorState.scaleFactor,
              ),
              child: _buildSections(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSections(BuildContext context) {
    final DocumentPageProvider watch = context.watch<DocumentPageProvider>();
    // final DocumentPageProvider read = context.read<DocumentPageProvider>();
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: (watch.hwpDocument["bodyText"]["sections"] as List).length,
        itemBuilder: (BuildContext context, int sectionIndex) {
          return _buildParagraphs(context, sectionIndex);
        },
      ),
    );
  }

  Widget _buildParagraphs(BuildContext context, int sectionIndex) {
    final DocumentPageProvider watch = context.watch<DocumentPageProvider>();
    // final DocumentPageProvider read = context.read<DocumentPageProvider>();
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: (watch.hwpDocument["bodyText"]["sections"][sectionIndex]
              ["paragraphs"] as List)
          .length,
      itemBuilder: (BuildContext context, int paragraphIndex) {
        return _buildParagraph(
          // sectionIndex: sectionIndex,
          // paragraphIndex: paragraphIndex,
          context,
          sectionIndex,
          paragraphIndex,
        );
      },
    );
  }

  static Widget _buildParagraph(
    BuildContext context,
    int sectionIndex,
    int paragraphIndex,
  ) {
    final DocumentPageProvider watch = context.watch<DocumentPageProvider>();
    // final DocumentPageProvider read = context.read<DocumentPageProvider>();
    final List _paragraphs =
        watch.hwpDocument["bodyText"]["sections"][sectionIndex]["paragraphs"];
    final Map _paragraph = _paragraphs[paragraphIndex];

    late final ParagraphController _paragraphController;
    if (DocumentPageProvider.paragraphControllers.length >=
        _paragraphs.length) {
      _paragraphController =
          DocumentPageProvider.paragraphControllers[paragraphIndex];
    } else {
      _paragraphController = ParagraphController();
      final Map paraShape = watch.hwpDocument["docInfo"]["paraShapeList"]
          [_paragraph["paraShapeId"]];

      _paragraphController.paraShape = paraShape;
      _paragraphController.text = _paragraph["text"];
      _paragraphController.charShapes = (_paragraph["charShapes"]
              as List<dynamic>)
          .map((list) => (list as List).map((value) => value as int).toList())
          .toList();
      DocumentPageProvider.paragraphControllers.add(_paragraphController);
    }

    return ParagraphWidget(
      paragraph: _paragraphs[paragraphIndex],
      paragraphController: _paragraphController,
      currentStyle: watch.editorState.currentTextStyle,
    );
  }

  Widget _buildCommandBar(BuildContext context) {
    return CommandBar(
      primaryItems: [
        CommandBarButton(
          label: const Text("파일"),
          onPressed: () {},
        ),
        const CommandBarSeparator(),
        CommandBarButton(
          icon: const Icon(FluentIcons.edit),
          label: const Text("편집"),
          onPressed: () {},
        ),
        CommandBarButton(
          icon: const Icon(FluentIcons.insert),
          label: const Text("입력"),
          onPressed: () {},
        ),
        CommandBarButton(
          icon: const Icon(FluentIcons.format_painter),
          label: const Text("서식"),
          onPressed: () {},
        ),
      ],
    );
  }
}
