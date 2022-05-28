import 'package:app_rev1/models/model_empty.dart';
import 'package:app_rev1/widgets/widget_paragraph.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HWPDocumentModel {
  Map<String, dynamic> _jsonData = emptyJsonData;

  Map<String, dynamic> get jsonData => _jsonData;

  void loadDocument(Map<String, dynamic> data) {
    _jsonData = data;
    paragraphControllers.clear();
    paragraphFocusNodes.clear();
    lastFocusedNodeIndex = 0;

    for (Map<String, dynamic> paragraphMap in getParagraphs()) {
      final ParagraphController paragraphController = ParagraphController(
        text: paragraphMap["text"],
        charShapes: (paragraphMap["charShapes"] as List<dynamic>)
            .map((list) => (list as List).map((value) => value as int).toList())
            .toList(),
        paraShapeId: paragraphMap["paraShapeId"],
      );
      paragraphControllers.add(paragraphController);
      paragraphFocusNodes.add(FocusNode());
    }
  }

  final List<ParagraphController> paragraphControllers = [
    ParagraphController(
      text: "",
      charShapes: [
        [0, 0],
      ],
      paraShapeId: 3,
    ),
  ];
  final List<FocusNode> paragraphFocusNodes = [FocusNode()];
  int lastFocusedNodeIndex = 0;

  void insertParagraphAtNext() {
    final ParagraphController currentParagraphController =
        paragraphControllers[lastFocusedNodeIndex];
    final int newIndex = lastFocusedNodeIndex + 1;

    final List<List<int>> newCharShapes = [
      [0, currentParagraphController.charShapes.last.last],
    ];

    // TODO: Create its own LineSeg
    final List newLineSeg = (getCurrentParagraph()["lineSeg"] as List).toList();
    final int newParaShapeId = currentParagraphController.paraShapeId;
    paragraphControllers.insert(
      newIndex,
      ParagraphController(
        charShapes: newCharShapes,
        paraShapeId: newParaShapeId,
      ),
    );
    paragraphFocusNodes.insert(newIndex, FocusNode());
    final Map<String, Object> newParagraphJsonData = {
      "text": "",
      "charShapes": newCharShapes,
      "paraShapeId": newParaShapeId,
      "styleId": 0,
      "lineSeg": newLineSeg,
    };
    getParagraphs().insert(
      newIndex,
      newParagraphJsonData,
    );
  }

  List getParaShapeList() {
    return jsonData["docInfo"]["paraShapeList"];
  }

  Map<String, dynamic> getParaShapeAt(int paraShapeId) {
    return getParaShapeList()[paraShapeId];
  }

  List getParagraphs() {
    return jsonData["bodyText"]["sections"][0]["paragraphs"];
  }

  Map<String, dynamic> getParagraphAt(int index) {
    return getParagraphs()[index];
  }

  Map<String, dynamic> getCurrentParagraph() => getParagraphAt(
        lastFocusedNodeIndex,
      );

  List<TextStyle> getCharShapes() {
    List<TextStyle> list = [];
    for (int i = 0;
        i < (jsonData["docInfo"]["charShapeList"] as List).length;
        i++) {
      list.add(getTextStyleFromCharShape(i));
    }
    return list;
  }

  TextStyle getTextStyleFromCharShape(int charShapeIndex) {
    final Map data = jsonData["docInfo"]["charShapeList"][charShapeIndex];
    return TextStyle(
      fontFamily: jsonData["docInfo"]["hangulFaceNameList"]
          [data["faceNameIds"][0]]["name"],
      fontSize: data["baseSize"] / 100.0,
      color: Colors.black,
      fontWeight: data["isBold"] ? FontWeight.bold : FontWeight.normal,
      fontStyle: data["isItalic"] ? FontStyle.italic : FontStyle.normal,
    );
  }

  int getCharShapeReferenceValueFromTextStyle(TextStyle textStyle) {
    final List<TextStyle> allCharShapes = getCharShapes();
    if (allCharShapes.contains(textStyle)) {
      return allCharShapes.indexOf(textStyle);
    } else {
      // 기존에 없다면 charShapeList 에 새롭게 추가
      // 폰트가 faceNameList 에 있는지 확인
      final List<String> faceNameList =
          (jsonData["docInfo"]["hangulFaceNameList"] as List)
              .map(
                (map) => map["name"] as String,
              )
              .toList(growable: false);
      late final int faceNameIndex;
      // 없으면 추가
      if (!faceNameList.contains(textStyle.fontFamily)) {
        final List faceNameMaps =
            (jsonData["docInfo"]["hangulFaceNameList"] as List);
        faceNameMaps.add(
          {
            "name": textStyle.fontFamily!,
            "baseFontName": getFontBaseName(textStyle.fontFamily!)
          },
        );
        faceNameIndex = faceNameMaps.length - 1;
      } else {
        faceNameIndex = faceNameList.indexOf(textStyle.fontFamily!);
      }

      final Map<String, Object> charShapeData = {
        "faceNameIds": List<int>.filled(7, faceNameIndex),
        "baseSize": textStyle.fontSize! * 100,
        "charColor": 0,
        "isItalic": textStyle.fontStyle == FontStyle.italic,
        "isBold": textStyle.fontWeight == FontWeight.bold,
      };

      final List charShapeList = jsonData["docInfo"]["charShapeList"] as List;
      charShapeList.add(Map<String, Object>.from(charShapeData));

      return charShapeList.length - 1;
    }
  }

  int getParaShapeReferenceValue(Map data) {
    final List paraShapeList = getParaShapeList();
    if (!paraShapeList.any((element) => mapEquals(element, data))) {
      paraShapeList.add(data);
    }
    return paraShapeList.indexWhere((element) => mapEquals(element, data));
  }
}

TextAlign getTextAlign(int value) {
  // 정렬: 양쪽=0 왼쪽=1 오른쪽=2 가운데=3 배분=4 나눔=5
  switch (value) {
    case 1:
      return TextAlign.left;
    case 2:
      return TextAlign.right;
    case 3:
      return TextAlign.center;
    default:
      return TextAlign.left;
  }
}

String getFontBaseName(String fn) {
  return {
    "맑은 고딕": "MalgunGothic",
    "함초롬바탕": "HCR Batang",
    "궁서": "Gungsuh",
  }[fn]!;
}

List<String> getAvailableFontList() {
  return ["맑은 고딕", "함초롬바탕", "궁서"];
}
