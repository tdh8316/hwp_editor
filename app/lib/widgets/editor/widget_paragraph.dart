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
    required this.paragraphController,
    required this.focusNode,
  }) : super(key: key);

  final Map paragraph;
  final ParagraphController paragraphController;
  final FocusNode focusNode;

  @override
  State<ParagraphWidget> createState() => _ParagraphWidgetState();
}

class _ParagraphWidgetState extends State<ParagraphWidget> {
  late final Map paragraph;
  late final ParagraphController paragraphController;
  late final FocusNode focusNode;

  late String _prevText;

  @override
  void initState() {
    paragraph = widget.paragraph;
    paragraphController = widget.paragraphController;
    focusNode = widget.focusNode;

    _prevText = paragraphController.text;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DocumentPageProvider watch = context.watch<DocumentPageProvider>();
    final DocumentPageProvider read = context.read<DocumentPageProvider>();

    final TextField textField = TextField(
      focusNode: focusNode,
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
        height: paragraphController.paraShape["lineSpace"] / 100.0,
      ),
      smartQuotesType: SmartQuotesType.enabled,
      selectionHeightStyle: BoxHeightStyle.max,
      textAlign: getTextAlign(paragraphController.paraShape["alignment"]),
      maxLines: null,
      cursorColor: Colors.black,
      onTap: () => read.onParagraphCursorChanged(paragraphController),
      onChanged: (String text) {
        read.onParagraphTextChanged(
          text: text,
          prevText: _prevText,
          controller: paragraphController,
          paragraph: paragraph,
        );
        _prevText = text;
      },
      textDirection: TextDirection.ltr,
    );

    return Material(child: textField);
  }
}

class ParagraphController extends TextEditingController {
  ParagraphController({
    String? text,
    required this.charShapes,
    required this.paraShape,
  }) : super(text: text);

  List<List<int>> charShapes;
  Map paraShape;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    List<TextSpan> children = [];
    List<String> matches = [];
    String _tmpMatch = "";
    for (int i = 0; i < text.length; i++) {
      if (charShapes.map((charShape) => charShape[0]).contains(i)) {
        if (_tmpMatch.isNotEmpty) matches.add(_tmpMatch);
        _tmpMatch = "";
      }
      _tmpMatch += text[i];
    }
    matches.add(_tmpMatch);

    for (List pair in IterableZip([matches, charShapes])) {
      children.add(
        TextSpan(
          text: pair[0] as String,
          style: context
              .read<DocumentPageProvider>()
              .getTextStyleFromCharShape(
                pair[1][1] as int,
              )
              .copyWith(
                height: paraShape["lineSpace"] / 100.0,
              ),
        ),
      );
    }

    return TextSpan(
      children: children,
    );
  }

  /// 한국어가 입력 중일 때는 커서가 문자열 길이보다 한 칸 뒤임
  int getCursor({int adjust = 0}) => selection.baseOffset - adjust;

  int getCurrentCharShapeIndex({int adjust = 0}) {
    final int cursorPosition = getCursor(adjust: adjust);
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
