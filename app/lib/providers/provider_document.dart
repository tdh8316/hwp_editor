import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hwp_editor_app/widgets/editor/widget_paragraph.dart';

class DocumentPageProvider extends ChangeNotifier {
  DocumentPageProvider({required this.hwpDocument});

  final Map<String, dynamic> hwpDocument;

  static final List<ParagraphController> paragraphControllers = [];
  static final List<FocusNode> focusNodes = [];
  int lastFocusedNodeIndex = 0;

  TextStyle _currentTextStyle = const TextStyle(
    fontFamily: "함초롬바탕",
    fontSize: 10,
    color: Colors.black,
  );

  set currentTextStyle(TextStyle _new) {
    _currentTextStyle = _new;
    notifyListeners();
    print(_currentTextStyle);
  }

  TextStyle get currentTextStyle => _currentTextStyle;

  final TextEditingController fontSizeController = TextEditingController();

  double scaleFactor = 1.5;

  void setTextScaleFactor(double _new) {
    scaleFactor = _new;
    notifyListeners();
  }

  TextStyle getTextStyleFromCharShape(int charShapeIndex) {
    final Map data = hwpDocument["docInfo"]["charShapeList"][charShapeIndex];
    return TextStyle(
      fontFamily: hwpDocument["docInfo"]["hangulFaceNameList"]
          [data["faceNameIds"][0]]["name"],
      fontSize: data["baseSize"] / 100.0,
      color: Colors.black,
      fontWeight: data["isBold"] ? FontWeight.bold : FontWeight.normal,
      fontStyle: data["isItalic"] ? FontStyle.italic : FontStyle.normal,
    );
  }

  List<TextStyle> getAllCharShapes() {
    List<TextStyle> _list = [];
    for (int i = 0;
        i < (hwpDocument["docInfo"]["charShapeList"] as List).length;
        i++) {
      _list.add(getTextStyleFromCharShape(i));
    }
    return _list;
  }

  int getCharShapeIndexFromTextStyle(TextStyle textStyle) {
    return getAllCharShapes().indexOf(textStyle);
  }

  void onParagraphCursorChanged(ParagraphController controller) {
    currentTextStyle = getTextStyleFromCharShape(
      controller.charShapes![controller.getCurrentCharShapeIndex()][1],
    );

    lastFocusedNodeIndex = paragraphControllers.indexOf(controller);

    notifyListeners();
  }

  void onParagraphTextChanged({
    required String text,
    required String prevText,
    required ParagraphController controller,
    required Map paragraph,
  }) {
    // 현재 paragraph 참조
    final Map _paragraph = paragraph;

    // 기존 charShapes 복사 (deep copy)
    final List<List<int>> _charShapes = (_paragraph["charShapes"] as List)
        .map((_tuple) => (_tuple as List).map((e) => e as int).toList())
        .toList();
    print("origin:$_charShapes");

    // 텍스트가 추가된 것이라면
    if (text.length > prevText.length) {
      // 추가된 문자열?
      String _diff = text.replaceAll(prevText, "");
      for (List _pair in IterableZip([text.characters, prevText.characters])) {
        if (_pair[0] != _pair[1]) _diff = _pair[0];
      }
      final bool _isKor = RegExp(r"^[ㄱ-ㅎㅏ-ㅣ가-힣]+$").hasMatch(_diff);
      final int _adjust = _isKor ? 0 : 1;
      final int _charShapesIndex = controller.getCurrentCharShapeIndex(
        adjust: _adjust,
      );
      // 현재 textStyle 과 커서의 charShape 가 다르다면
      if (getTextStyleFromCharShape(_charShapes[_charShapesIndex][1]) !=
          currentTextStyle) {
        final int _shapeIndex = getCharShapeIndexFromTextStyle(
          currentTextStyle,
        );
        if (_isKor) {
          if (_charShapes.length <= _charShapesIndex + 1) {
            _charShapes.add(
              [
                controller.getCursor(adjust: _adjust) - (_isKor ? 1 : 2),
                _shapeIndex,
              ],
            );
          } else {
            final List<int> _cursorPrevCharShape =
                _charShapes[_charShapesIndex];
            final List<int> _cursorNextCharShape =
                _charShapes[_charShapesIndex + 1];
            _charShapes.insert(
              _charShapesIndex + 1,
              [
                controller.getCursor(adjust: _adjust) - (_isKor ? 1 : 2),
                _shapeIndex,
              ],
            );
            // charShape 가 한 글자 간격으로 설정된게 아니라면 쪼개기
            if (_cursorPrevCharShape[0] + 1 != _cursorNextCharShape[0]) {
              List<int> _clonedPrev = _cursorPrevCharShape.toList();
              _charShapes.insert(_charShapesIndex + 2, [
                controller.getCursor(adjust: _adjust) - (_isKor ? 0 : 1),
                _clonedPrev[1],
              ]);
            }
          }
        } else {
          // TODO: non-Korean
        }
      }
      // 현재 charShape 인덱스 뒤로 계속 charShapes 가 있으면
      if (_charShapes.length >= _charShapesIndex + 1) {
        // 현재 charShape 뒤의 charShapes position += _diff.length
        for (List charShape in _charShapes.slice(_charShapesIndex + 1)) {
          charShape[0] += _diff.length;
        }
      }
    } else if (text.length < prevText.length) {
      // 제거된 문자열?
      String _diff = "";
      for (List _pair in IterableZip([text.characters, prevText.characters])) {
        if (_pair[0] != _pair[1]) _diff = _pair[1];
      }

      final int _currentCharShapeIndex = controller.getCurrentCharShapeIndex();

      if (text.length <= _charShapes.last.first && _charShapes.length > 1) {
        _charShapes.removeLast();
      }

      // 앞의 두 charShapes 의 지워진 후 position 이 동일하다면
      if (_charShapes.length > _currentCharShapeIndex + 2 &&
          _charShapes[_currentCharShapeIndex + 1][0] ==
              _charShapes[_currentCharShapeIndex + 2][0] - 1) {
        // 앞의 charShape 제거
        _charShapes.removeAt(_currentCharShapeIndex + 1);
      }
      // 현재 charShape 인덱스 뒤로 계속 charShapes 가 있으면
      if (_charShapes.length > _currentCharShapeIndex + 1) {
        // 현재 charShape 뒤의 charShapes position -= _diff.length
        for (int i = 1; _charShapes.length > i + _currentCharShapeIndex; i++) {
          _charShapes[i + _currentCharShapeIndex][0] -= _diff.length;
        }
      }
    }

    _paragraph["text"] = text;
    // charShape 에 다시 할당 (deep copy 로 옮겨졌기 때문)
    _paragraph["charShapes"] = _charShapes;
    controller.charShapes = _charShapes;

    notifyListeners();
    print("result:$_charShapes");
  }
}
