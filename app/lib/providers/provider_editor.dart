import 'package:flutter/material.dart';

class EditorProvider extends ChangeNotifier {
  EditorProvider({required this.hwpDocument});

  final Map<String, dynamic> hwpDocument;

  List get sections =>
      hwpDocument["bodyText"]["sections"] as List;

  void setParagraph(Map<String, dynamic > section, int paragraphIndex, String paragraph) {
    section["paragraphs"][paragraphIndex] = paragraph;
    notifyListeners();
  }
}
