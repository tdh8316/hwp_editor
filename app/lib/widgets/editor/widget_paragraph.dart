import 'package:fluent_ui/fluent_ui.dart';
import 'package:hwp_editor_app/providers/provider_editor.dart';
import 'package:provider/provider.dart';

class ParagraphWidget extends StatelessWidget {
  const ParagraphWidget({
    Key? key,
    required this.sectionIndex,
    required this.paragraphIndex,
  }) : super(key: key);

  final int sectionIndex;
  final int paragraphIndex;

  @override
  Widget build(BuildContext context) {
    final String paragraph =
        context.watch<EditorProvider>().hwpDocument["bodyText"]["sections"]
            [sectionIndex]["paragraphs"][paragraphIndex];
    final Map<int, TextStyle> charShapes =
        context.read<EditorProvider>().getCharShapes(
              sectionIndex,
              paragraphIndex,
            );

    List<String> paragraphBlocks = [];
    String tmp = "";
    final ParagraphEditingController controller = ParagraphEditingController();
    for (int i = 0; i < paragraph.length; i++) {
      if (charShapes.keys.contains(i)) {
        tmp = "";
      }
      tmp += paragraph[i];
      if (charShapes.keys.contains(i + 1)) {
        paragraphBlocks.add(tmp);
      }
    }
    paragraphBlocks.add(tmp);

    for (int i = 0; i < paragraphBlocks.length; i++) {
      controller.insertParagraphBlock(
        ParagraphBlock(
          paragraphBlocks[i],
          charShapes.values.toList(growable: false)[i],
        ),
      );
    }

    final FocusNode _focusNode = FocusNode();
    context.read<EditorProvider>().paragraphFocusNodes.add(_focusNode);

    return EditableText(
      controller: controller,
      style: context.watch<EditorProvider>().currentTextStyle,
      backgroundCursorColor: Colors.black,
      cursorColor: Colors.black,
      focusNode: _focusNode,
      scrollPhysics: const NeverScrollableScrollPhysics(),
      maxLines: null,
    );
  }
}

class ParagraphEditingController extends TextEditingController {
  ParagraphEditingController({String? text}) : super(text: text);

  final List<ParagraphBlock> _blocks = [];
  TextEditingValue? _focusValue;
  RegExp? _exp;

  void insertParagraphBlock(ParagraphBlock block) {
    if (_blocks.indexWhere((element) => element.text == block.text) < 0) {
      _blocks.add(block);
      _exp = RegExp(_blocks.map((e) => RegExp.escape(e._key)).join('|'));
    }
    insertText(block._key);
  }

  void insertText(String text) {
    TextSelection selection = value.selection;
    if (selection.baseOffset == -1) {
      if (_focusValue != null) {
        selection = _focusValue!.selection;
      } else {
        final String str = this.text + text;
        value = value.copyWith(
          text: str,
          selection: selection.copyWith(
            baseOffset: str.length,
            extentOffset: str.length,
          ),
        );
        return;
      }
    }

    String str = selection.textBefore(this.text);
    str += text;
    str += selection.textAfter(this.text);

    value = value.copyWith(
      text: str,
      selection: selection.copyWith(
        baseOffset: selection.baseOffset + text.length,
        extentOffset: selection.baseOffset + text.length,
      ),
    );
  }

  @override
  void clear() {
    _blocks.clear();
    super.clear();
  }

  @override
  set value(TextEditingValue newValue) {
    super.value = _formatValue(value, newValue);
    if (newValue.selection.baseOffset != -1) {
      _focusValue = newValue;
    } else if (_focusValue != null &&
        _focusValue!.selection.baseOffset > newValue.text.length) {
      _focusValue = null;
    }
  }

  TextEditingValue _formatValue(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue == newValue ||
        newValue.text.length >= oldValue.text.length ||
        newValue.selection.baseOffset == -1) return newValue;
    final oldText = oldValue.text;
    final delLength = oldText.length - newValue.text.length;
    String char = "";
    int offset = 0;
    if (delLength == 1) {
      char = oldText.substring(
        newValue.selection.baseOffset,
        newValue.selection.baseOffset + 1,
      );
      offset = newValue.selection.baseOffset;
    } else if (delLength == 2) {
      // two characters will be deleted on huawei
      char = oldText.substring(
        newValue.selection.baseOffset + 1,
        newValue.selection.baseOffset + 2,
      );
      offset = newValue.selection.baseOffset + 1;
    }

    if (char == _specialChar) {
      final newText = newValue.text;
      final oldStr = oldText.substring(0, offset);
      final delStr = "$oldStr{#del#}";
      String str = delStr;
      for (var element in _blocks) {
        str = str.replaceFirst("${element.text}{#del#}", "");
      }
      if (str != delStr && str != oldStr) {
        str += newValue.selection.textInside(newText) +
            newValue.selection.textAfter(newText);

        final len = newText.length - str.length;
        return newValue.copyWith(
          text: str,
          selection: newValue.selection.copyWith(
            baseOffset: newValue.selection.baseOffset - len,
            extentOffset: newValue.selection.baseOffset - len,
          ),
        );
      }
    }
    return newValue;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (!value.composing.isValid || !withComposing) {
      return _getTextSpan(text, style!);
    }

    final TextStyle composingStyle = style!.merge(
      const TextStyle(decoration: TextDecoration.underline),
    );
    return TextSpan(
      style: style,
      children: <TextSpan>[
        _getTextSpan(value.composing.textBefore(value.text), style),
        TextSpan(
          style: composingStyle,
          text: value.composing.textInside(value.text),
        ),
        _getTextSpan(value.composing.textAfter(value.text), style),
      ],
    );
  }

  TextSpan _getTextSpan(String text, TextStyle style) {
    if (_exp == null || text.isEmpty) {
      return TextSpan(text: text, style: style);
    }

    final List<TextSpan> children = [];

    text.splitMapJoin(
      _exp!,
      onMatch: (m) {
        final key = m[0];
        final ParagraphBlock block = _blocks.firstWhere(
          (element) => element._key == key,
        );
        children.add(
          TextSpan(text: key, style: block.style),
        );
        return key!;
      },
      onNonMatch: (span) {
        if (span != "") {
          children.add(
            TextSpan(text: span, style: style),
          );
        }
        return span;
      },
    );
    return TextSpan(style: style, children: children);
  }
}

final _filterCharacters = RegExp("[٩|۶]");

const _specialChar = "\u200B";

class ParagraphBlock {
  final String text;
  final TextStyle style;
  final String _key;

  ParagraphBlock(this.text, this.style)
      : _key = "${text.replaceAll(_filterCharacters, "")}$_specialChar";
}
