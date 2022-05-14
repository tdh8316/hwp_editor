import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:hwp_editor_app/widgets/editor/widget_paragraph.dart';

class DocumentPageProvider extends ChangeNotifier {
  DocumentPageProvider({
    required this.hwpDocument,
  });

  Map<String, dynamic> hwpDocument;

  Future<void> openDocument(BuildContext context) async {
    FilePickerCross result = await FilePickerCross.importFromStorage(
      type: FileTypeCross.custom,
      fileExtension: "hwp, json",
    );

    if (result.path == null) return;

    hwpDocument = {};
    // Initialization
    paragraphControllers.clear();
    focusNodes.clear();
    lastFocusedNodeIndex = 0;
    _currentTextStyle = const TextStyle(
      fontFamily: "함초롬바탕",
      fontSize: 10,
      color: Colors.black,
    );

    if (result.path!.endsWith(".hwp")) {
      final File file = File(result.path!);

      final String encodedData =
          base64Encode(file.readAsBytesSync()).replaceAll("/", "_");
      final String uri = Uri.encodeFull(
        "http://localhost:8080/api/parse/$encodedData",
      );
      final http.Response response = await http.get(
        Uri.parse(uri),
      );

      if (response.statusCode != 200) {
        showDialog(
          context: context,
          builder: (_) {
            return ContentDialog(
              title: Text("Response status code ${response.statusCode}"),
              content: const Text("Check your connection and try again"),
              actions: [
                Button(
                  child: const Text("Ok"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          },
        );
        return;
      }

      hwpDocument = jsonDecode(response.body);
    } else if (result.path!.endsWith(".json")) {
      final File file = File(result.path!);
      hwpDocument = jsonDecode(file.readAsStringSync());
    }

    notifyListeners();
  }

  static final List<ParagraphController> paragraphControllers = [];
  static final List<FocusNode> focusNodes = [];
  int lastFocusedNodeIndex = 0;

  void refocusOnLastFocusedWidget() =>
      focusNodes[lastFocusedNodeIndex].requestFocus();

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

  // final TextEditingController fontSizeController = TextEditingController();
  final FlyoutController flyoutController = FlyoutController();

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

  int getCharShapeReferenceValueFromTextStyle(TextStyle textStyle) {
    final List<TextStyle> _allCharShapes = getAllCharShapes();
    if (_allCharShapes.contains(textStyle)) {
      return _allCharShapes.indexOf(textStyle);
    } else {
      // 기존에 없다면 charShapeList 에 새롭게 추가
      // 폰트가 faceNameList 에 있는지 확인
      final List<String> _faceNameList =
          (hwpDocument["docInfo"]["hangulFaceNameList"] as List)
              .map(
                (_map) => _map["name"] as String,
              )
              .toList(growable: false);
      late final int _faceNameIndex;
      // 없으면 추가
      if (!_faceNameList.contains(textStyle.fontFamily)) {
        final List _faceNameMaps =
            (hwpDocument["docInfo"]["hangulFaceNameList"] as List);
        _faceNameMaps.add(
          {"name": textStyle.fontFamily, "baseFontName": ""},
        );
        _faceNameIndex = _faceNameMaps.length - 1;
      } else {
        _faceNameIndex = _faceNameList.indexOf(textStyle.fontFamily!);
      }

      final Map _charShapeData = {
        "faceNameIds": List<int>.filled(7, _faceNameIndex),
        "baseSize": textStyle.fontSize! * 100,
        "charColor": 0,
        "isItalic": textStyle.fontStyle == FontStyle.italic,
        "isBold": textStyle.fontWeight == FontWeight.bold,
      };

      final List _charShapeList =
          hwpDocument["docInfo"]["charShapeList"] as List;
      _charShapeList.add(_charShapeData);

      return _charShapeList.length - 1;
    }
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
    // print("origin:$_charShapes");

    // 문자열 길이에 영향을 주는 변경된 문자
    String _diffChar = "";
    if (text.length > prevText.length) {
      // 텍스트가 추가됨
      for (List _pair in IterableZip([text.characters, prevText.characters])) {
        if (_pair[0] != _pair[1]) {
          _diffChar = _pair[0];
          break;
        }
      }
      if (_diffChar.isEmpty) {
        _diffChar = text.characters.last;
      }
    } else if (text.length < prevText.length) {
      // 텍스트가 지워짐
      for (List _pair in IterableZip([text.characters, prevText.characters])) {
        if (_pair[0] != _pair[1]) {
          _diffChar = _pair[1];
          break;
        }
      }
      if (_diffChar.isEmpty) {
        _diffChar = prevText.characters.last;
      }
    } else {
      // 한국어 입력중...
    }

    // 문자가 지워지거나 추가됐을 때만
    if (_diffChar.isNotEmpty) {
      // final bool _isKor = RegExp(r"^[ㄱ-ㅎㅏ-ㅣ가-힣]+$").hasMatch(_diffChar);

      // 텍스트가 추가됐을 때
      if (text.length > prevText.length) {
        final int _lastCursorIndex = controller.getCursor(
          adjust: 1,
        );
        final int _lastCharShapeIndex = controller.getCurrentCharShapeIndex(
          adjust: 1,
        );

        final TextStyle _lastTextStyle = getTextStyleFromCharShape(
          _charShapes[_lastCharShapeIndex][1],
        );
        TextStyle? _nextTextStyle;
        if (_charShapes.length > _lastCharShapeIndex + 1) {
          _nextTextStyle = getTextStyleFromCharShape(
            _charShapes[_lastCharShapeIndex + 1][1],
          );
        }

        // 현재 입력중인 textStyle 에 해당하는 charShape 참조
        final int _currentCharShapeReferenceValue =
            getCharShapeReferenceValueFromTextStyle(_currentTextStyle);

        // 현재 텍스트 스타일이 이 다음 것과 같을 때
        if (_nextTextStyle != null && currentTextStyle == _nextTextStyle) {
          // 다음 charShape 뒤로 계속 charShape 가 있으면
          if (_charShapes.length >= _lastCharShapeIndex + 2) {
            // 그 뒤의 charShape 의 position 만 추가된 문자열 길이만큼 미뤄줌
            for (List _next in _charShapes.slice(_lastCharShapeIndex + 2)) {
              _next[0] += _diffChar.length;
            }
          }
        }
        // 마지막 커서의 텍스트 스타일과 현재의 텍스트 스타일이 다를 때
        else if (_lastTextStyle != currentTextStyle) {
          // 커서가 맨 앞에 있을 때
          if (_lastCursorIndex == 0) {
            _charShapes.insert(
              0,
              [
                _lastCursorIndex,
                _currentCharShapeReferenceValue,
              ],
            );
            // 뒤의 charShape 의 position 만 추가된 문자열 길이만큼 미뤄줌
            for (List _next in _charShapes.slice(_lastCharShapeIndex + 1)) {
              _next[0] += _diffChar.length;
            }
          }
          // 여기가 마지막 charShapeIndex 일 때
          else if (_charShapes.length <= _lastCharShapeIndex + 1) {
            _charShapes.add(
              [
                _lastCursorIndex,
                _currentCharShapeReferenceValue,
              ],
            );
            _charShapes.add(
              _charShapes[_lastCharShapeIndex].toList()
                ..[0] = _lastCursorIndex + 1,
            );
          } else {
            // 일단 현재 위치에 현재 textStyle 에 상응하는 charShape 추가
            _charShapes.insert(
              _lastCharShapeIndex + 1,
              [
                _lastCursorIndex,
                _currentCharShapeReferenceValue,
              ],
            );

            if (_charShapes[_lastCharShapeIndex + 2][0] != _lastCursorIndex) {
              _charShapes.insert(
                _lastCharShapeIndex + 2,
                _charShapes[_lastCharShapeIndex].toList()
                  ..[0] = _lastCursorIndex,
              );
            }
            // 현재 charShape 뒤로 계속 charShape 가 있으면
            if (_charShapes.length >= _lastCharShapeIndex + 2) {
              // 뒤의 charShape 의 position 만 추가된 문자열 길이만큼 미뤄줌
              for (List _next in _charShapes.slice(_lastCharShapeIndex + 2)) {
                _next[0] += _diffChar.length;
              }
            }
          }
        }
        // 현재 텍스트 스타일이 이 이전 것과 같을 때
        else {
          // 현재 charShape 뒤로 계속 charShape 가 있으면
          if (_charShapes.length >= _lastCharShapeIndex + 1) {
            // 뒤의 charShape 의 position 만 추가된 문자열 길이만큼 미뤄줌
            for (List _next in _charShapes.slice(_lastCharShapeIndex + 1)) {
              _next[0] += _diffChar.length;
            }
          }
        }
      }
      // 텍스트가 제거됐을 때
      else {
        final int _charShapeIndex = controller.getCurrentCharShapeIndex(
          adjust: -1,
        );

        // 뒤로 charShape 가 계속 있으면
        final List<int> _targetIndex = [];
        if (_charShapes.length >= _charShapeIndex + 1) {
          for (int i = _charShapeIndex + 1; i < _charShapes.length; i++) {
            _charShapes[i][0] -= 1;
            if (_charShapes[i - 1][0] == _charShapes[i][0]) {
              _targetIndex.add(i - 1);
            }
          }
          for (int i in _targetIndex) {
            _charShapes.removeAt(i);
          }
        }
      }
    }

    _paragraph["text"] = text;
    // charShape 에 다시 할당 (deep copy 로 옮겨졌기 때문)
    _paragraph["charShapes"] = _charShapes;
    controller.charShapes = _charShapes;

    notifyListeners();
    // print("result:$_charShapes");
  }
}
