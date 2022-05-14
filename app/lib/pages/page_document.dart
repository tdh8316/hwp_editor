import 'package:fluent_ui/fluent_ui.dart';
import 'package:hwp_editor_app/models/model_fonts.dart';
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
              const SizedBox(height: 12),
              const Divider(),
              _buildEditor(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final DocumentPageProvider watch = context.watch<DocumentPageProvider>();
    // final DocumentPageProvider read = context.read<DocumentPageProvider>();
    return SizedBox(
      height: MediaQuery.of(context).size.height - 144,
      width: 770 * (watch.scaleFactor-0.5),
      child: Padding(
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
      _paragraphController = ParagraphController(
        text: _paragraph["text"],
        charShapes: (_paragraph["charShapes"] as List<dynamic>)
            .map((list) => (list as List).map((value) => value as int).toList())
            .toList(),
        paraShape: watch.hwpDocument["docInfo"]["paraShapeList"]
            [_paragraph["paraShapeId"]],
      );
      // 생성한 controller 추가
      DocumentPageProvider.paragraphControllers.add(_paragraphController);
    }

    // FocusNode 생성
    late final FocusNode _focusNode;
    if (DocumentPageProvider.focusNodes.length >= _paragraphs.length) {
      _focusNode = DocumentPageProvider.focusNodes[paragraphIndex];
    } else {
      _focusNode = FocusNode();
      DocumentPageProvider.focusNodes.add(_focusNode);
    }

    return ParagraphWidget(
      paragraph: _paragraphs[paragraphIndex],
      paragraphController: _paragraphController,
      focusNode: _focusNode,
    );
  }

  Widget _buildCommandBar(BuildContext context) {
    // final DocumentPageProvider watch = context.watch<DocumentPageProvider>();
    final DocumentPageProvider read = context.read<DocumentPageProvider>();
    return CommandBar(
      primaryItems: [
        CommandBarBuilderItem(
          builder: (context, mode, w) => Flyout(
            openMode: FlyoutOpenMode.press,
            controller: read.flyoutController,
            content: (BuildContext context) {
              return MenuFlyout(
                items: [
                  MenuFlyoutItem(
                    text: const Text("열기"),
                    leading: const Icon(FluentIcons.open_file),
                    onPressed: () async => await read.openDocument(context),
                  ),
                  MenuFlyoutItem(
                    text: const Text("저장"),
                    leading: const Icon(FluentIcons.save),
                    onPressed: () {
                      // TODO: Save file
                      read.flyoutController.close();
                    },
                  ),
                ],
              );
            },
            child: w,
          ),
          wrappedItem: CommandBarButton(
            icon: const Icon(FluentIcons.document),
            label: const Text("파일"),
            onPressed: () {
              read.flyoutController.open();
            },
          ),
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
    final DocumentPageProvider read = context.read<DocumentPageProvider>();
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: Row(
              // TODO: Command panel
              ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropDownButton(
              title: Text(watch.currentTextStyle.fontFamily.toString()),
              items: [
                for (String fontName in getFontNames())
                  MenuFlyoutItem(
                    text: Text(fontName),
                    onPressed: () {
                      read.currentTextStyle = read.currentTextStyle.copyWith(
                        fontFamily: fontName,
                      );
                      read.refocusOnLastFocusedWidget();
                    },
                  ),
              ],
            ),
            const SizedBox(width: 8),
            DropDownButton(
              title: Text("${watch.currentTextStyle.fontSize?.toInt()}"),
              items: [
                for (int i = 2; i <= 128; i += 2)
                  MenuFlyoutItem(
                    text: Text(i.toString()),
                    onPressed: () {
                      read.currentTextStyle = read.currentTextStyle.copyWith(
                        fontSize: i.toDouble(),
                      );
                      read.refocusOnLastFocusedWidget();
                    },
                  )
              ],
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 28,
              child: Tooltip(
                message: "진하게",
                child: ToggleButton(
                  checked: watch.currentTextStyle.fontWeight == FontWeight.bold,
                  onChanged: (bool checked) {
                    if (checked) {
                      read.currentTextStyle = read.currentTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      );
                    } else {
                      read.currentTextStyle = read.currentTextStyle.copyWith(
                        fontWeight: FontWeight.normal,
                      );
                    }
                    read.refocusOnLastFocusedWidget();
                  },
                  child: const Icon(FluentIcons.bold_korean),
                ),
              ),
            ),
            const SizedBox(width: 2),
            SizedBox(
              height: 28,
              child: Tooltip(
                message: "기울임",
                child: ToggleButton(
                  checked: watch.currentTextStyle.fontStyle == FontStyle.italic,
                  onChanged: (bool checked) {
                    if (checked) {
                      read.currentTextStyle = read.currentTextStyle.copyWith(
                        fontStyle: FontStyle.italic,
                      );
                    } else {
                      read.currentTextStyle = read.currentTextStyle.copyWith(
                        fontStyle: FontStyle.normal,
                      );
                    }
                    read.refocusOnLastFocusedWidget();
                  },
                  child: const Icon(FluentIcons.italic_korean),
                ),
              ),
            ),
            const SizedBox(width: 2),
            SizedBox(
              height: 28,
              child: Tooltip(
                message: "밑줄",
                child: ToggleButton(
                  checked: false,
                  onChanged: (bool checked) {
                    read.refocusOnLastFocusedWidget();
                  },
                  child: const Icon(FluentIcons.underline_korean),
                ),
              ),
            ),
            const SizedBox(width: 2),
          ],
        )
      ],
    );
  }
}
