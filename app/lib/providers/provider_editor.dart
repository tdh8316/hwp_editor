import 'package:fluent_ui/fluent_ui.dart';

class EditorProvider extends ChangeNotifier {
  EditorProvider({required this.hwpDocument});

  final Map<String, dynamic> hwpDocument;

  double textScaleFactor = 1.5;

  void setTextScaleFactor(double _new) {
    textScaleFactor=_new;
    notifyListeners();
  }

  TextStyle currentTextStyle = const TextStyle(
    fontFamily: "함초롬바탕",
    fontSize: 10,
    color: Colors.black,
  );

  List<FocusNode> paragraphFocusNodes = [];

  void nextFocusNode(BuildContext context) {
    final FocusNode? old = FocusScope.of(context).focusedChild;
    if (old == null) return;
    for (int i = 0; i < paragraphFocusNodes.length; i++) {
      if (old == paragraphFocusNodes[i] && paragraphFocusNodes.length > i) {
        FocusScope.of(context).requestFocus(paragraphFocusNodes[i + 1]);
        break;
      }
    }
  }

  void setParagraph(
    int sectionIndex,
    int paragraphIndex,
    String newParagraph,
  ) {
    hwpDocument["bodyText"]["sections"][sectionIndex]["paragraphs"]
        [paragraphIndex] = newParagraph;
    notifyListeners();
  }

  String getParagraph(int sectionIndex, int paragraphIndex) {
    return hwpDocument["bodyText"]["sections"][sectionIndex]["paragraphs"]
        [paragraphIndex];
  }

  Map<int, TextStyle> getCharShapes(int sectionIndex, int charShapeIndex) {
    final List charShapes = hwpDocument["bodyText"]["sections"][sectionIndex]
        ["charShapes"][charShapeIndex];

    final Map<int, TextStyle> res = {};

    for (List charShape in charShapes) {
      final int charShapePosition = charShape[0];
      final int charShapeIndex = charShape[1];
      final int faceNameIndex = hwpDocument["docInfo"]["charShapeList"]
          [charShapeIndex]["faceNameIds"][0];
      final Map<String, dynamic> faceName =
          hwpDocument["docInfo"]["hangulFaceNameList"][faceNameIndex];

      res[charShapePosition] = TextStyle(
        fontSize: hwpDocument["docInfo"]["charShapeList"][charShapeIndex]
                ["baseSize"] /
            100,
        fontFamily: faceName["name"],
      );
    }

    return res;
  }
}
