import 'dart:convert';
import 'dart:io';

import 'package:app_rev1/models/model_document.dart';
import 'package:app_rev1/widgets/widget_paragraph.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart' show FlyoutController;
import 'package:flutter/material.dart';

class DocumentProvider extends ChangeNotifier {
  String _filePath = "unknown";

  String get filePath => _filePath;
  final HWPDocumentModel d = HWPDocumentModel();

  double _textScaleFactor = 1.5;

  double get textScaleFactor => _textScaleFactor;

  set textScaleFactor(double value) {
    _textScaleFactor = value;
    notifyListeners();
  }

  TextStyle _currentTextStyle = const TextStyle(
    fontFamily: "함초롬바탕",
    fontSize: 10,
    color: Colors.black,
  );

  TextStyle get currentTextStyle => _currentTextStyle;

  set currentTextStyle(TextStyle style) {
    _currentTextStyle = style;
    notifyListeners();
  }

  final FlyoutController flyoutController = FlyoutController();

  int _panelIndex = 0;

  set panelIndex(int index) {
    _panelIndex = index;
    notifyListeners();
  }

  int get panelIndex => _panelIndex;

  void refocusOnTheLastFocusedWidget() =>
      d.paragraphFocusNodes[d.lastFocusedNodeIndex].requestFocus();

  Future<void> openHWPDocument() async {
    final FilePickerResult? filePickerResult =
        await FilePicker.platform.pickFiles(
      lockParentWindow: true,
    );
    if (filePickerResult == null) return;
    await loadHWPDocument(filePickerResult.files.single.path!);
  }

  Future<void> loadHWPDocument(String filePath) async {
    String? jsonString;

    if (filePath.endsWith(".json")) {
      jsonString = File(filePath).readAsStringSync();
    }

    if (jsonString == null) {
      return;
    }
    d.loadDocument(jsonDecode(jsonString));
    _filePath = filePath;
    notifyListeners();
    flyoutController.close();
  }

  Future<void> saveHWPDocument() async {
    print(d.jsonData);
    notifyListeners();
  }

  void onParagraphCursorChanged(ParagraphController controller) {
    currentTextStyle = d.getTextStyleFromCharShape(
      controller.charShapes[controller.getCurrentCharShapeIndex()][1],
    );

    d.lastFocusedNodeIndex = d.paragraphControllers.indexOf(controller);

    notifyListeners();
  }

  void onParagraphTextChanged({
    required String text,
    required String prevText,
    required ParagraphController controller,
    required Map paragraph,
  }) {
    // 기존 charShapes 복사 (deep copy)
    final List<List<int>> charShapes = (paragraph["charShapes"] as List)
        .map((tuple) => (tuple as List).map((e) => e as int).toList())
        .toList();
    // print("origin:$_charShapes");

    // 문자열 길이에 영향을 주는 변경된 문자
    String diffChar = "";
    if (text.length > prevText.length) {
      // 텍스트가 추가됨
      for (List pair in IterableZip([text.characters, prevText.characters])) {
        if (pair[0] != pair[1]) {
          diffChar = pair[0];
          break;
        }
      }
      if (diffChar.isEmpty) {
        diffChar = text.characters.last;
      }
    } else if (text.length < prevText.length) {
      // 텍스트가 지워짐
      for (List pair in IterableZip([text.characters, prevText.characters])) {
        if (pair[0] != pair[1]) {
          diffChar = pair[1];
          break;
        }
      }
      if (diffChar.isEmpty) {
        diffChar = prevText.characters.last;
      }
    } else {
      // 한국어 입력중...
    }

    // 문자가 지워지거나 추가됐을 때만
    if (diffChar.isNotEmpty) {
      // final bool _isKor = RegExp(r"^[ㄱ-ㅎㅏ-ㅣ가-힣]+$").hasMatch(_diffChar);

      // 텍스트가 추가됐을 때
      if (text.length > prevText.length) {
        final int lastCursorIndex = controller.getCursor(
          adjust: 1,
        );
        final int lastCharShapeIndex = controller.getCurrentCharShapeIndex(
          adjust: 1,
        );

        final TextStyle lastTextStyle = d.getTextStyleFromCharShape(
          charShapes[lastCharShapeIndex][1],
        );
        TextStyle? nextTextStyle;
        if (charShapes.length > lastCharShapeIndex + 1) {
          nextTextStyle = d.getTextStyleFromCharShape(
            charShapes[lastCharShapeIndex + 1][1],
          );
        }

        // 현재 입력중인 textStyle 에 해당하는 charShape 참조
        final int currentCharShapeReferenceValue =
            d.getCharShapeReferenceValueFromTextStyle(_currentTextStyle);

        // 현재 텍스트 스타일이 이 다음 것과 같을 때
        if (nextTextStyle != null && currentTextStyle == nextTextStyle) {
          // 다음 charShape 뒤로 계속 charShape 가 있으면
          if (charShapes.length >= lastCharShapeIndex + 2) {
            // 그 뒤의 charShape 의 position 만 추가된 문자열 길이만큼 미뤄줌
            for (List next in charShapes.slice(lastCharShapeIndex + 2)) {
              next[0] += diffChar.length;
            }
          }
        }
        // 마지막 커서의 텍스트 스타일과 현재의 텍스트 스타일이 다를 때
        else if (lastTextStyle != currentTextStyle) {
          // 커서가 맨 앞에 있을 때
          if (lastCursorIndex == 0) {
            charShapes.insert(
              0,
              [
                lastCursorIndex,
                currentCharShapeReferenceValue,
              ],
            );
            // 뒤의 charShape 의 position 만 추가된 문자열 길이만큼 미뤄줌
            for (List next in charShapes.slice(lastCharShapeIndex + 1)) {
              next[0] += diffChar.length;
            }
          }
          // 여기가 마지막 charShapeIndex 일 때
          else if (charShapes.length <= lastCharShapeIndex + 1) {
            charShapes.add(
              [
                lastCursorIndex,
                currentCharShapeReferenceValue,
              ],
            );
            charShapes.add(
              charShapes[lastCharShapeIndex].toList()
                ..[0] = lastCursorIndex + 1,
            );
          } else {
            // 일단 현재 위치에 현재 textStyle 에 상응하는 charShape 추가
            charShapes.insert(
              lastCharShapeIndex + 1,
              [
                lastCursorIndex,
                currentCharShapeReferenceValue,
              ],
            );

            if (charShapes[lastCharShapeIndex + 2][0] != lastCursorIndex) {
              charShapes.insert(
                lastCharShapeIndex + 2,
                charShapes[lastCharShapeIndex].toList()..[0] = lastCursorIndex,
              );
            }
            // 현재 charShape 뒤로 계속 charShape 가 있으면
            if (charShapes.length >= lastCharShapeIndex + 2) {
              // 뒤의 charShape 의 position 만 추가된 문자열 길이만큼 미뤄줌
              for (List next in charShapes.slice(lastCharShapeIndex + 2)) {
                next[0] += diffChar.length;
              }
            }
          }
        }
        // 현재 텍스트 스타일이 이 이전 것과 같을 때
        else {
          // 현재 charShape 뒤로 계속 charShape 가 있으면
          if (charShapes.length >= lastCharShapeIndex + 1) {
            // 뒤의 charShape 의 position 만 추가된 문자열 길이만큼 미뤄줌
            for (List next in charShapes.slice(lastCharShapeIndex + 1)) {
              next[0] += diffChar.length;
            }
          }
        }
      }
      // 텍스트가 제거됐을 때
      else {
        final int charShapeIndex = controller.getCurrentCharShapeIndex(
          adjust: -1,
        );

        // 뒤로 charShape 가 계속 있으면
        final List<int> targetIndex = [];
        if (charShapes.length >= charShapeIndex + 1) {
          for (int i = charShapeIndex + 1; i < charShapes.length; i++) {
            charShapes[i][0] -= 1;
            if (charShapes[i - 1][0] == charShapes[i][0]) {
              targetIndex.add(i - 1);
            }
          }
          for (int i in targetIndex) {
            charShapes.removeAt(i);
          }
        }
      }
    }

    paragraph["text"] = text;
    // charShape 에 다시 할당 (deep copy 로 옮겨졌기 때문)
    paragraph["charShapes"] = charShapes;
    controller.charShapes = charShapes;

    notifyListeners();
    // print("result:$_charShapes");
  }
}
