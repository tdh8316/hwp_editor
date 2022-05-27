import 'dart:ui';

import 'package:app_rev1/models/model_document.dart';
import 'package:app_rev1/providers/provider_document.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParagraphWidget extends StatefulWidget {
  const ParagraphWidget({
    Key? key,
    required this.paragraphIndex,
  }) : super(key: key);

  final int paragraphIndex;

  @override
  State<ParagraphWidget> createState() => _ParagraphWidgetState();
}

class _ParagraphWidgetState extends State<ParagraphWidget> {
  late String _prevText;
  late ParagraphController paragraphController;

  @override
  Widget build(BuildContext context) {
    final DocumentProvider read = context.read<DocumentProvider>();
    final DocumentProvider watch = context.watch<DocumentProvider>();
    paragraphController = read.d.paragraphControllers[widget.paragraphIndex];
    _prevText = paragraphController.text;
    final Map paraShape =
        read.d.getParaShapeAt(paragraphController.paraShapeId);
    return IntrinsicHeight(
      child: TextField(
        focusNode: watch.d.paragraphFocusNodes[widget.paragraphIndex]
        ..onKey =read.onKeyOnParagraphWidget,
        controller: paragraphController,
        decoration: const InputDecoration(
          hintText: null,
          fillColor: Colors.white,
          filled: true,
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(bottom: 6),
        ),
        style: watch.currentTextStyle,
        strutStyle: StrutStyle(
          height: paraShape["lineSpace"] / 100.0,
        ),
        selectionHeightStyle: BoxHeightStyle.max,
        textAlign: getTextAlign(paraShape["alignment"]),
        maxLines: null,
        expands: true,
        cursorColor: Colors.black,
        // TODO: Keyboard arrow detector
        onTap: () => read.onParagraphCursorChanged(paragraphController),
        onChanged: (String text) {
          read.onParagraphTextChanged(
            text: text,
            prevText: _prevText,
            controller: paragraphController,
            paragraph: read.d.getParagraphAt(
              widget.paragraphIndex,
            ),
          );
          _prevText = text;
        },
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

class ParagraphController extends TextEditingController {
  ParagraphController({
    String? text,
    required this.charShapes,
    required this.paraShapeId,
  }) : super(text: text);
  List<List<int>> charShapes;
  int paraShapeId;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    List<TextSpan> children = [];
    List<String> matches = [];
    String tmpMatch = "";
    for (int i = 0; i < text.length; i++) {
      if (charShapes.map((charShape) => charShape[0]).contains(i)) {
        if (tmpMatch.isNotEmpty) matches.add(tmpMatch);
        tmpMatch = "";
      }
      tmpMatch += text[i];
    }
    matches.add(tmpMatch);

    for (List pair in IterableZip([matches, charShapes])) {
      children.add(
        TextSpan(
          text: pair[0] as String,
          style: context
              .read<DocumentProvider>()
              .d
              .getTextStyleFromCharShape(
                pair[1][1] as int,
              )
              .copyWith(
                height: context
                        .read<DocumentProvider>()
                        .d
                        .getParaShapeAt(paraShapeId)["lineSpace"] /
                    100.0,
              ),
        ),
      );
    }

    return TextSpan(
      children: children,
    );
  }

  /// 한국어가 입력 중일 때는 커서가 문자열 길이보다 한 칸 뒤임
  int getCursorPosition({int adjust = 0}) => selection.baseOffset - adjust;

  int getCurrentCharShapeIndex({int adjust = 0}) {
    final int cursorPosition = getCursorPosition(adjust: adjust);
    int idx = 0;
    for (int i = 0; i <= charShapes.length - 1; i++) {
      if (charShapes[i][0] < cursorPosition) {
        idx = i;
      } else {
        break;
      }
    }
    return idx;
  }
}
