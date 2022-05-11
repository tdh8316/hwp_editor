import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hwp_editor_app/widgets/editor/widget_paragraph.dart';

class DocumentPageProvider extends ChangeNotifier {
  DocumentPageProvider({required this.hwpDocument});

  final Map<String, dynamic> hwpDocument;

  static final List<ParagraphController> paragraphControllers = [];

  TextStyle currentTextStyle = const TextStyle(
    fontFamily: "함초롬바탕",
    fontSize: 10,
    color: Colors.black,
  );

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
      fontWeight: data["isBold"] ? FontWeight.bold : null,
      fontStyle: data["isItalic"] ? FontStyle.italic : null,
    );
  }

  void onParagraphCursorChanged(ParagraphController controller) {
    currentTextStyle = getTextStyleFromCharShape(
      controller.charShapes![controller.getCurrentCharShapeIndex()][1],
    );

    notifyListeners();
  }

  void onParagraphTextChanged(
      {required String text,
      required String prevText,
      required ParagraphController controller,
      required Map paragraph}) {
    // 현재 paragraph 참조
    final Map _paragraph = paragraph;

    // 기존 charShapes 복사 (deep copy)
    final List<List<int>> _charShapes = (_paragraph["charShapes"] as List)
        .map((_tuple) => (_tuple as List).map((e) => e as int).toList())
        .toList();
    // print("origin:${_charShapes}");

    // 텍스트가 추가된 것이라면
    if (text.length > prevText.length) {
      // 추가된 문자열?
      String _diff = "";
      for (List _pair in IterableZip([text.characters, prevText.characters])) {
        if (_pair[0] != _pair[1]) _diff = _pair[0];
      }

      final int _currentCharShapeIndex = controller.getCurrentCharShapeIndex(
          // 만약 한국어 이외의 문자가 추가된 것이라면 - 1
          adjust: RegExp(r"^[ㄱ-ㅎㅏ-ㅣ가-힣]+$").hasMatch(_diff) ? 0 : 1);
      // 현재 charShape 인덱스 뒤로 계속 charShapes 가 있으면
      if (_charShapes.length >= _currentCharShapeIndex + 1) {
        // 현재 charShape 뒤의 charShapes position += _diff.length
        for (List charShape in _charShapes.slice(_currentCharShapeIndex + 1)) {
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

      // 앞의 두 charShapes 의 지워진 후 position 이 동일하다면
      if (_charShapes.length > _currentCharShapeIndex + 2 &&
          _charShapes[_currentCharShapeIndex + 1][0] ==
              _charShapes[_currentCharShapeIndex + 2][0] - 1) {
        // 앞의 charShape 제거
        _charShapes.removeAt(_currentCharShapeIndex + 1);
      }
      // 현재 charShape 인덱스 뒤로 계속 charShapes 가 있으면
      if (_charShapes.length > _currentCharShapeIndex + 2) {
        // 현재 charShape 뒤의 charShapes position -= _diff.length
        for (int i = 1; _charShapes.length > i + _currentCharShapeIndex; i++) {
          _charShapes[i + _currentCharShapeIndex][0] -= _diff.length;
        }
      } else {
        if (text.length <= _charShapes.last.first) {
          _charShapes.removeLast();
        }
      }
    }
    _paragraph["text"] = text;
    _paragraph["charShapes"] = _charShapes;

    controller.charShapes = _charShapes;
    // print("result:${_charShapes}");
    notifyListeners();
  }
}
