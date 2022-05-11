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
          return Column(
            children: [
              _buildCommandBar(context),
              _buildCommandPanel(context),
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
                textScaleFactor: watch.scaleFactor,
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
          context,
          sectionIndex,
          paragraphIndex,
        );
      },
    );
  }

  Widget _buildParagraph(
    BuildContext context,
    int sectionIndex,
    int paragraphIndex,
  ) {
    final DocumentPageProvider watch = context.watch<DocumentPageProvider>();
    // final DocumentPageProvider read = context.read<DocumentPageProvider>();

    // build 할 paragraph 참조
    final List _paragraphs =
        watch.hwpDocument["bodyText"]["sections"][sectionIndex]["paragraphs"];
    final Map _paragraph = _paragraphs[paragraphIndex];

    // ParagraphController 생성
    late final ParagraphController _paragraphController;
    // 기존의 controller 가 있다면 그것으로 사용
    if (DocumentPageProvider.paragraphControllers.length >=
        _paragraphs.length) {
      _paragraphController =
          DocumentPageProvider.paragraphControllers[paragraphIndex];
    } else {
      // 없다면 새로 생성
      _paragraphController = ParagraphController();
      // 값 초기화
      _paragraphController.paraShape = watch.hwpDocument["docInfo"]
          ["paraShapeList"][_paragraph["paraShapeId"]];
      _paragraphController.text = _paragraph["text"];
      _paragraphController.charShapes = (_paragraph["charShapes"]
              as List<dynamic>)
          .map((list) => (list as List).map((value) => value as int).toList())
          .toList();
      // 생성한 controller 추가
      DocumentPageProvider.paragraphControllers.add(_paragraphController);
    }

    return ParagraphWidget(
      paragraph: _paragraphs[paragraphIndex],
      paragraphController: _paragraphController,
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

  Widget _buildCommandPanel(BuildContext context) {
    final DocumentPageProvider watch = context.watch<DocumentPageProvider>();
    // final DocumentPageProvider read = context.read<DocumentPageProvider>();
    return CommandBarCard(
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
                DropDownButton(
                  title: Text(watch.currentTextStyle.fontFamily.toString()),
                  items: [
                    MenuFlyoutItem(
                      text: Text("함초롬바탕"),
                      onPressed: () {},
                    ),
                    MenuFlyoutItem(
                      text: Text("맑은 고딕"),
                      onPressed: () {},
                    ),
                  ],
                ),
                Text(
                    "bold:${watch.currentTextStyle.fontWeight == FontWeight.bold}/"),
                Text("italic:${watch.currentTextStyle.fontStyle?.index == 1}"),
              ],
            ),
          )
        ],
      ),
    );
  }
}
