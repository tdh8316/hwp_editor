import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart'
    show TextField, Material, InputDecoration, InputBorder;
import 'package:hwp_editor_app/models/model_hwp.dart';
import 'package:hwp_editor_app/providers/provider_document.dart';
import 'package:provider/provider.dart';

class ParagraphWidget extends StatefulWidget {
  const ParagraphWidget({
    Key? key,
    required this.paragraph,
    required this.paragraphController, this.currentStyle,
  }) : super(key: key);

  final Map paragraph;
  final ParagraphController paragraphController;
  final TextStyle? currentStyle;

  @override
  State<ParagraphWidget> createState() => _ParagraphWidgetState();
}

class _ParagraphWidgetState extends State<ParagraphWidget> {
  late final ParagraphController paragraphController;

  late String _prevText;

  @override
  void initState() {
    paragraphController = widget.paragraphController;
    _prevText = paragraphController.text;
    super.initState();
  }

  void _onTextChanged(String text) {
    final Map _paragraph = widget.paragraph;

    final List<List<int>> _charShapes = (_paragraph["charShapes"] as List)
        .map((_tuple) => (_tuple as List).map((e) => e as int).toList())
        .toList();

    final int _currentCharShapeIndex =
    // TODO: non-Korean chars: adjust 2
        paragraphController.getCurrentCharShapeIndex();

    if (text.length > _prevText.length) {
      print("first");
      if (_charShapes.length >= _currentCharShapeIndex + 1) {
        print("sec");
        print(_currentCharShapeIndex);
        for (List charShape in _charShapes.slice(_currentCharShapeIndex+1)) {
          print("3rd");
          charShape[0] += 1;
        }
      }
    } else {
      // TODO: Remove text
    }
    print(_charShapes);
    _paragraph["text"] = text;
    _paragraph["charShapes"] = _charShapes;
    setState(() {
      paragraphController.charShapes = _charShapes;
    });

    _prevText = text;
  }

  @override
  Widget build(BuildContext context) {
    // final DocumentPageProvider watch = context.watch<DocumentPageProvider>();
    final DocumentPageProvider read = context.read<DocumentPageProvider>();

    final TextField textField = TextField(
      controller: paragraphController,
      decoration: const InputDecoration(
        hintText: null,
        fillColor: Colors.white,
        filled: true,
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.only(bottom: 6),
      ),
      style: widget.currentStyle?? read.editorState.currentTextStyle,
      strutStyle: StrutStyle(
        height: paragraphController.paraShape!["lineSpace"] / 100.0,
      ),
      smartQuotesType: SmartQuotesType.enabled,
      selectionHeightStyle: BoxHeightStyle.max,
      textAlign: getTextAlign(paragraphController.paraShape!["alignment"]),
      maxLines: null,
      cursorColor: Colors.black,
      onTap: () {
        read.editorState.currentTextStyle = read.getTextStyleFromCharShape(
          paragraphController
              .charShapes![paragraphController.getCurrentCharShapeIndex()][1],
        );
        read.notifyListeners();
      },
      onChanged: _onTextChanged,
    );

    return Column(
      children: [
        Material(child: textField),
        if (widget.paragraph.containsKey("table"))
          _buildTable(
            context,
            widget.paragraph["table"],
          )
        else
          Container(),
      ],
    );
  }

  Widget _buildTable(BuildContext context, Map table) {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: (table["rowList"] as List).length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          child: IntrinsicHeight(
            child: _buildRow(context, table["rowList"][index]),
          ),
          decoration: BoxDecoration(
            border: Border(
              top: index == 0
                  ? const BorderSide(
                      color: Color(0xFF000000),
                      width: 1.0,
                      style: BorderStyle.solid,
                    )
                  : BorderSide.none,
              bottom: const BorderSide(
                color: Color(0xFF000000),
                width: 1.0,
                style: BorderStyle.solid,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, Map rowItem) {
    final List cellList = rowItem["cellList"];
    return Row(
      children: [
        for (int i = 0; i < cellList.length; i++)
          Expanded(
            child: Container(
              child: _buildCell(context, cellList[i]),
              decoration: BoxDecoration(
                border: Border(
                  left: i == 0
                      ? const BorderSide(
                          color: Color(0xFF000000),
                          width: 1.0,
                          style: BorderStyle.solid,
                        )
                      : BorderSide.none,
                  right: const BorderSide(
                    color: Color(0xFF000000),
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCell(BuildContext context, Map cellItem) {
    return Column(
      children: [
        for (Map paragraph in cellItem["paragraphs"])
          Padding(
            // TODO: Adjust table padding
            padding: const EdgeInsets.all(2),
            child: ParagraphWidget(
              paragraph: paragraph,
              // TODO: Table paragraph controller
              paragraphController: ParagraphController(),
            ),
          ),
      ],
    );
  }
}

class ParagraphController extends TextEditingController {
  ParagraphController({
    String? text,
    this.charShapes,
    this.paraShape,
  }) : super(text: text);

  List<List<int>>? charShapes;
  Map? paraShape;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (charShapes == null || paraShape == null) throw NullThrownError();
    List<TextSpan> children = [];
    List<String> matches = [];
    String _tmpMatch = "";
    for (int i = 0; i < text.length; i++) {
      if (charShapes!.map((charShape) => charShape[0]).contains(i)) {
        if (_tmpMatch.isNotEmpty) matches.add(_tmpMatch);
        _tmpMatch = "";
      }
      _tmpMatch += text[i];
    }
    matches.add(_tmpMatch);

    for (List pair in IterableZip([matches, charShapes!])) {
      children.add(
        TextSpan(
          text: pair[0] as String,
          style: context
              .read<DocumentPageProvider>()
              .getTextStyleFromCharShape(
                pair[1][1] as int,
              )
              .copyWith(
                height: paraShape!["lineSpace"] / 100.0,
              ),
        ),
      );
    }

    return TextSpan(
      children: children,
    );
  }

  int getCurrentCharShapeIndex({int adjust = 1}) {
    final int cursorPosition = selection.baseOffset - adjust;
    int idx = 0;
    for (int i = 0; i < charShapes!.length; i++) {
      if (charShapes![i][0] <= cursorPosition) {
        idx = i;
      } else {
        break;
      }
    }
    return idx;
  }
}
