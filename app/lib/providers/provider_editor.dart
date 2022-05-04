import 'package:fluent_ui/fluent_ui.dart';

class EditorProvider extends ChangeNotifier {
  EditorProvider({required this.hwpDocument});

  final Map<String, dynamic> hwpDocument;

  final List<FocusNode> focusNodes = [];

  TextStyle currentTextStyle = const TextStyle(
    fontFamily: "함초롬바탕",
    fontSize: 10,
    color: Colors.black,
  );
  double textScaleFactor = 1.5;

  void setTextScaleFactor(double _new) {
    textScaleFactor = _new;
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
}
