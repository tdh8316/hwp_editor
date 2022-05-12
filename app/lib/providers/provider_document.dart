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
    // print(_currentTextStyle);
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
      controller.charShapes[controller.getCurrentCharShapeIndex()][1],
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

    _paragraph["text"] = text;
    // charShape 에 다시 할당 (deep copy 로 옮겨졌기 때문)
    _paragraph["charShapes"] = _charShapes;
    controller.charShapes = _charShapes;

    notifyListeners();
    print("result:$_charShapes");
  }
}
