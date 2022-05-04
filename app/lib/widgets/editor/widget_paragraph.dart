import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart'
    show TextField, Material, InputDecoration, InputBorder;
import 'package:hwp_editor_app/models/model_hwp.dart';
import 'package:hwp_editor_app/providers/provider_editor.dart';
import 'package:provider/provider.dart';

class ParagraphWidget extends StatelessWidget {
  const ParagraphWidget({
    Key? key,
    this.sectionIndex,
    this.paragraphIndex,
    required this.paragraph,
  }) : super(key: key);

  final int? sectionIndex;
  final int? paragraphIndex;
  final Map paragraph;

  @override
  Widget build(BuildContext context) {
    final EditorProvider watch = context.watch<EditorProvider>();
    final EditorProvider read = context.read<EditorProvider>();

    final FocusNode focusNode = FocusNode();
    final Map paraShape =
        watch.hwpDocument["docInfo"]["paraShapeList"][paragraph["paraShapeId"]];
    final ParagraphController paragraphController = ParagraphController(
      text: paragraph["text"],
      charShapes: (paragraph["charShapes"] as List<dynamic>)
          .map((list) => (list as List).map((value) => value as int).toList())
          .toList(),
      paraShape: paraShape,
    );

    return Material(
      child: TextField(
        controller: paragraphController,
        focusNode: focusNode,
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
        smartQuotesType: SmartQuotesType.enabled,
        selectionHeightStyle: BoxHeightStyle.max,
        textAlign: getTextAlign(paraShape["alignment"]),
        maxLines: null,
        cursorColor: Colors.black,
      ),
    );
  }
}

class ParagraphController extends TextEditingController {
  ParagraphController({
    String? text,
    required this.charShapes,
    required this.paraShape,
  }) : super(text: text);

  final List<List<int>> charShapes;
  final Map paraShape;

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
              .read<EditorProvider>()
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
}
