import 'package:flutter/material.dart';
import 'package:hwp_editor_app/providers/provider_editable_dialog.dart';
import 'package:hwp_editor_app/providers/provider_editor.dart';
import 'package:provider/provider.dart';

class EditorWidget extends StatelessWidget {
  EditorWidget({Key? key}) : super(key: key);

  final Map<String, dynamic> test = {
    "docInfo": {
      "hangulFaceNameList": [
        {"name": "궁서", "baseFontName": "Gungsuh"},
        {"name": "함초롬돋움", "baseFontName": "HCR Dotum"},
        {"name": "함초롬바탕", "baseFontName": "HCR Batang"}
      ],
      "charShapeList": [
        {
          "faceNameIds": [2, 2, 2, 2, 2, 2, 2]
        },
        {
          "faceNameIds": [1, 1, 1, 1, 1, 1, 1]
        },
        {
          "faceNameIds": [1, 1, 1, 1, 1, 1, 1]
        },
        {
          "faceNameIds": [2, 2, 2, 2, 2, 2, 2]
        },
        {
          "faceNameIds": [1, 1, 1, 1, 1, 1, 1]
        },
        {
          "faceNameIds": [0, 0, 0, 0, 0, 0, 0]
        }
      ]
    },
    "bodyText": {
      "sections": [
        {
          "paragraphs": [
            "이것은 제목입니다!",
            "한컴오피스 한글 문서에 작성된 텍스트입니다. 이 줄은 엔터로 구분되지 않은 상태로 작성되었습니다.",
            "엔터로 구분된 새로운 줄입니다.",
            "",
            "엔터 두 번으로 구분된 새로운 단락입니다."
          ],
          "shapes": [
            [0, 5],
            [0, 0],
            [0, 0],
            [0, 0],
            [0, 0]
          ]
        }
      ]
    }
  };

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditorProvider>(
      create: (BuildContext context) => EditorProvider(hwpDocument: test),
      builder: (BuildContext context, _) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Container(
            child: _bodyTextBuilder(context),
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _bodyTextBuilder(BuildContext context) {
    final List<Map<String, dynamic>> sections =
        context.watch<EditorProvider>().sections;
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: sections.length,
      itemBuilder: (BuildContext context, int index) {
        return _sectionBuilder(context, sections[index]);
      },
    );
  }

  Widget _sectionBuilder(BuildContext context, Map<String, dynamic> section) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: (section["paragraphs"] as List<String>).length,
      itemBuilder: (BuildContext context, int paragraphIndex) {
        return _textBuilder(context, section, paragraphIndex);
      },
    );
  }

  Widget _textBuilder(
    BuildContext context,
    Map<String, dynamic> section,
    int paragraphIndex,
  ) {
    final Widget _viewer = Text(section["paragraphs"][paragraphIndex]);
    return GestureDetector(
      onTap: () async =>
          await _showEditableDialog(context, section, paragraphIndex),
      child: _viewer,
    );
  }

  Future<void> _showEditableDialog(
    BuildContext context,
    Map<String, dynamic> section,
    int paragraphIndex,
  ) async {
    String? paragraph = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return ChangeNotifierProvider<EditableDialogProvider>(
          create: (BuildContext context) => EditableDialogProvider(),
          builder: (BuildContext context, _) {
            return SimpleDialog(
              children: [
                _editableDialogWidget(context, section, paragraphIndex),
                TextButton(
                  child: const Text("완료"),
                  onPressed: () {
                    Navigator.of(context).pop(
                      context
                          .read<EditableDialogProvider>()
                          .textEditingController
                          .text,
                    );
                  },
                )
              ],
            );
          },
        );
      },
    );
    if (paragraph != null) {
      context
          .read<EditorProvider>()
          .setParagraph(section, paragraphIndex, paragraph);
    }
  }

  Widget _editableDialogWidget(
    BuildContext context,
    Map<String, dynamic> section,
    int paragraphIndex,
  ) {
    return Column(
      children: [
        TextField(
          controller:
              context.read<EditableDialogProvider>().textEditingController
                ..text = section["paragraphs"][paragraphIndex],
        )
      ],
    );
  }
}
