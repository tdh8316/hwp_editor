import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart'
    show
        CommandBar,
        CommandBarBuilderItem,
        CommandBarButton,
        CommandBarSeparator,
        DropDownButton,
        FluentIcons,
        Flyout,
        FlyoutOpenMode,
        MenuFlyout,
        MenuFlyoutItem,
        MenuFlyoutSeparator,
        ToggleButton;
import 'package:flutter/material.dart';
import 'package:hwp_editor_app/models/model_document.dart';
import 'package:hwp_editor_app/providers/provider_document.dart';
import 'package:hwp_editor_app/widgets/widget_paragraph.dart';
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: [
                    _buildEditPanel(context),
                    _buildInsertPanel(context),
                    _buildFormatPanel(context),
                  ][context.watch<DocumentProvider>().panelIndex],
                ),
                const SizedBox(height: 8),
                _buildEditor(context),
              ],
            ),
            bottomSheet: _buildBottomSheet(context),
          );
        },
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final DocumentProvider watch = context.watch<DocumentProvider>();
    final DocumentProvider read = context.read<DocumentProvider>();
    return Expanded(
      child: SingleChildScrollView(
        child: InteractiveViewer(
          scaleEnabled: false,
          child: GestureDetector(
            onTap: () => read.d.paragraphFocusNodes[0].requestFocus(),
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(Platform.isAndroid ? 8 : 128),
                child: SizedBox(
                  width: 610,
                  child: MediaQuery(
                    data: MediaQueryData(
                      textScaleFactor: watch.textScaleFactor,
                    ),
                    child: _buildSections(context),
                  ),
                ),
              ),
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
        return Padding(
          // TODO: Exact line padding
          padding: const EdgeInsets.only(bottom: 8),
          child: ParagraphWidget(
            paragraphIndex: paragraphIndex,
          ),
        );
      },
    );
  }

  Widget _buildCommandBar(BuildContext context) {
    final DocumentProvider read = context.read<DocumentProvider>();
    return CommandBar(
      primaryItems: [
        CommandBarBuilderItem(
          builder: (BuildContext context, _, Widget w) {
            return Flyout(
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
                      text: const Text("저장"),
                      leading: const Icon(FluentIcons.save),
                      onPressed: () async => await read.saveHWPDocument(),
                    ),
                    const MenuFlyoutSeparator(),
                    MenuFlyoutItem(
                      text: const Text("DEBUG: 열기(localhost)"),
                      leading: const Icon(FluentIcons.open_file),
                      onPressed: () async {
                        await read.loadHWPDocumentOnLocalHost();
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text("DEBUG: 저장(localhost)"),
                      leading: const Icon(FluentIcons.save),
                      onPressed: () async {
                        await read.saveHWPDocumentOnLocalHost();
                      },
                    ),
                    MenuFlyoutItem(
                      text: const Text("DEBUG: Show json data"),
                      leading: const Icon(FluentIcons.device_bug),
                      onPressed: () => read.showJsonData(context),
                    ),
                  ],
                );
              },
              child: w,
            );
          },
          wrappedItem: CommandBarButton(
            icon: const Icon(FluentIcons.document),
            label: const Text("파일"),
            onPressed: () {
              read.flyoutController.open();
            },
          ),
        ),
        const CommandBarSeparator(),
        // CommandBarButton(
        //   icon: const Icon(FluentIcons.edit),
        //   label: const Text("편집"),
        //   onPressed: () => read.panelIndex = 0,
        // ),
        // CommandBarButton(
        //   icon: const Icon(FluentIcons.insert),
        //   label: const Text("삽입"),
        //   onPressed: () => read.panelIndex = 1,
        // ),
        // CommandBarButton(
        //   icon: const Icon(FluentIcons.format_painter),
        //   label: const Text("서식"),
        //   onPressed: () => read.panelIndex = 2,
        // ),
      ],
    );
  }

  Widget _buildEditPanel(BuildContext context) {
    final DocumentProvider read = context.read<DocumentProvider>();
    final DocumentProvider watch = context.watch<DocumentProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Tooltip(
          message: "글씨체",
          child: DropDownButton(
            title: Text(watch.currentTextStyle.fontFamily.toString()),
            items: [
              for (String fontName in getAvailableFontList())
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
        // SizedBox(
        //   height: 28,
        //   child: Tooltip(
        //     message: "밑줄",
        //     child: ToggleButton(
        //       checked: false,
        //       onChanged: (bool checked) {
        //         // TODO: Underline
        //         read.refocusOnTheLastFocusedWidget();
        //       },
        //       child: const Icon(FluentIcons.underline_korean),
        //     ),
        //   ),
        // ),
        const SizedBox(width: 8),
        SizedBox(
          height: 28,
          child: Tooltip(
            message: "왼쪽 정렬",
            child: ToggleButton(
              checked: [0, 1].contains(
                read.d.getParaShapeAt(watch.currentParaShapeId)["alignment"],
              ),
              onChanged: (bool checked) {
                // Deep copy
                Map<String, int> origin = Map<String, int>.from(
                  read.d.getParaShapeAt(
                    read.currentParaShapeId,
                  ),
                );
                origin["alignment"] = 0;
                read.currentParaShapeId = read.d.getParaShapeReferenceValue(
                  origin,
                );
                read.refocusOnTheLastFocusedWidget();
              },
              child: const Icon(FluentIcons.align_left),
            ),
          ),
        ),
        const SizedBox(width: 2),
        SizedBox(
          height: 28,
          child: Tooltip(
            message: "가운데 정렬",
            child: ToggleButton(
              checked: [3].contains(
                read.d.getParaShapeAt(watch.currentParaShapeId)["alignment"],
              ),
              onChanged: (bool checked) {
                // Deep copy
                Map<String, int> origin = Map<String, int>.from(
                  read.d.getParaShapeAt(
                    read.currentParaShapeId,
                  ),
                );
                origin["alignment"] = 3;
                read.currentParaShapeId = read.d.getParaShapeReferenceValue(
                  origin,
                );
                read.refocusOnTheLastFocusedWidget();
              },
              child: const Icon(FluentIcons.align_center),
            ),
          ),
        ),
        const SizedBox(width: 2),
        SizedBox(
          height: 28,
          child: Tooltip(
            message: "오른쪽 정렬",
            child: ToggleButton(
              checked: [2].contains(
                read.d.getParaShapeAt(watch.currentParaShapeId)["alignment"],
              ),
              onChanged: (bool checked) {
                // Deep copy
                Map<String, int> origin = Map<String, int>.from(
                  read.d.getParaShapeAt(
                    read.currentParaShapeId,
                  ),
                );
                origin["alignment"] = 2;
                read.currentParaShapeId = read.d.getParaShapeReferenceValue(
                  origin,
                );
                read.refocusOnTheLastFocusedWidget();
              },
              child: const Icon(FluentIcons.align_right),
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

  Widget _buildBottomSheet(BuildContext context) {
    final DocumentProvider read = context.read<DocumentProvider>();
    final DocumentProvider watch = context.watch<DocumentProvider>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text(watch.filePath),
          const SizedBox(
            height: 16,
            child: VerticalDivider(),
          ),
          Text(
            "${watch.d.lastFocusedNodeIndex + 1}:"
            "${read.currentParagraphController.getCursorPosition()}",
          ),
        ],
      ),
    );
  }
}
