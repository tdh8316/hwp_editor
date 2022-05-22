import 'package:app_rev1/providers/provider_document.dart';
import 'package:app_rev1/widgets/widget_paragraph.dart';
import 'package:fluent_ui/fluent_ui.dart'
    show
        CommandBar,
        CommandBarBuilderItem,
        Flyout,
        FlyoutOpenMode,
        MenuFlyoutItem,
        MenuFlyout,
        FluentIcons,
        CommandBarButton,
        CommandBarSeparator,
        ToggleButton,
        DropDownButton;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DocumentPage extends StatelessWidget {
  const DocumentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ChangeNotifierProvider<DocumentProvider>(
        create: (_) => DocumentProvider(),
        builder: (BuildContext context, Widget? child) {
          return Scaffold(
            body: Column(
              children: [
                _buildCommandBar(context),
                [
                  _buildEditPanel(context),
                  _buildInsertPanel(context),
                  _buildFormatPanel(context),
                ][context.watch<DocumentProvider>().panelIndex],
                const SizedBox(height: 8),
                _buildEditor(context),
              ],
            ),
            bottomSheet: Row(
              children: [
                Text(context.watch<DocumentProvider>().filePath),
                const SizedBox(
                  height: 16,
                  child: VerticalDivider(),
                ),
                Text(
                  context.watch<DocumentProvider>().currentTextStyle.toString(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: InteractiveViewer(
          scaleEnabled: false,
          child: Container(
            color: Colors.white,
            width: 770,
            child: MediaQuery(
              data: MediaQueryData(
                textScaleFactor:
                    context.watch<DocumentProvider>().textScaleFactor,
              ),
              child: _buildSections(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSections(BuildContext context) {
    return _buildParagraphs(context);
  }

  Widget _buildParagraphs(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: context.read<DocumentProvider>().d.getParagraphs().length,
      itemBuilder: (BuildContext context, int paragraphIndex) {
        return ParagraphWidget(
          paragraphIndex: paragraphIndex,
        );
      },
    );
  }

  Widget _buildCommandBar(BuildContext context) {
    final DocumentProvider read = context.read<DocumentProvider>();
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
                    onPressed: () async => await read.openHWPDocument(),
                  ),
                  MenuFlyoutItem(
                    text: const Text("Open test file..."),
                    leading: const Icon(FluentIcons.open_file),
                    onPressed: () async => await read.loadHWPDocument(
                      "../tests/report.json",
                    ),
                  ),
                  MenuFlyoutItem(
                    text: const Text("저장"),
                    leading: const Icon(FluentIcons.save),
                    onPressed: () async => await read.saveHWPDocument(),
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
          onPressed: () => read.panelIndex = 0,
        ),
        CommandBarButton(
          icon: const Icon(FluentIcons.insert),
          label: const Text("삽입"),
          onPressed: () => read.panelIndex = 1,
        ),
        CommandBarButton(
          icon: const Icon(FluentIcons.format_painter),
          label: const Text("서식"),
          onPressed: () => read.panelIndex = 2,
        ),
      ],
    );
  }

  Widget _buildEditPanel(BuildContext context) {
    final DocumentProvider read = context.read<DocumentProvider>();
    final DocumentProvider watch = context.watch<DocumentProvider>();
    return Row(
      children: [
        Tooltip(
          message: "글씨체",
          child: DropDownButton(
            title: Text(watch.currentTextStyle.fontFamily.toString()),
            items: [
              // TODO: More fonts
              for (String fontName in ["함초롬바탕"])
                MenuFlyoutItem(
                  text: Text(fontName),
                  onPressed: () {
                    read.currentTextStyle = read.currentTextStyle.copyWith(
                      fontFamily: fontName,
                    );
                    read.refocusOnTheLastFocusedWidget();
                  },
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: "글자 크기",
          child: DropDownButton(
            title: Text("${watch.currentTextStyle.fontSize?.toInt()}"),
            items: [
              for (int i = 2; i <= 128; i += 2)
                MenuFlyoutItem(
                  text: Text(i.toString()),
                  onPressed: () {
                    read.currentTextStyle = read.currentTextStyle.copyWith(
                      fontSize: i.toDouble(),
                    );
                    read.refocusOnTheLastFocusedWidget();
                  },
                )
            ],
          ),
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
                read.refocusOnTheLastFocusedWidget();
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
                read.refocusOnTheLastFocusedWidget();
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
                // TODO: Underline
                read.refocusOnTheLastFocusedWidget();
              },
              child: const Icon(FluentIcons.underline_korean),
            ),
          ),
        ),
        const SizedBox(width: 2),
      ],
    );
  }

  Widget _buildInsertPanel(BuildContext context) {
    return Row(
      children: const [
        Text("삽입"),
      ],
    );
  }

  Widget _buildFormatPanel(BuildContext context) {
    return Row(
      children: const [
        Text("서식"),
      ],
    );
  }
}
