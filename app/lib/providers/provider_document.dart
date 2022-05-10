import 'package:fluent_ui/fluent_ui.dart';
import 'package:hwp_editor_app/models/current_editor_state.dart';
import 'package:hwp_editor_app/widgets/editor/widget_paragraph.dart';

class DocumentPageProvider extends ChangeNotifier {
  DocumentPageProvider({required this.hwpDocument});

  final Map<String, dynamic> hwpDocument;
  static final List<ParagraphController> paragraphControllers= [];

  final CurrentEditorState editorState = CurrentEditorState();

  void setTextScaleFactor(double _new) {
    editorState.scaleFactor = _new;
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
