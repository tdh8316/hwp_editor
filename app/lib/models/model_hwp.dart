import 'package:fluent_ui/fluent_ui.dart';

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

const Map<String, dynamic> emptyDocument = {
  "docInfo": {
    "hangulFaceNameList": [
      {
        "name": "함초롬돋움",
        "baseFontName": "HCR Dotum"
      },
      {
        "name": "함초롬바탕",
        "baseFontName": "HCR Batang"
      }
    ],
    "charShapeList": [
      {
        "faceNameIds": [
          1,
          1,
          1,
          1,
          1,
          1,
          1
        ],
        "baseSize": 1000,
        "charColor": 0,
        "isItalic": false,
        "isBold": false
      },
      {
        "faceNameIds": [
          0,
          0,
          0,
          0,
          0,
          0,
          0
        ],
        "baseSize": 1000,
        "charColor": 0,
        "isItalic": false,
        "isBold": false
      },
      {
        "faceNameIds": [
          0,
          0,
          0,
          0,
          0,
          0,
          0
        ],
        "baseSize": 900,
        "charColor": 0,
        "isItalic": false,
        "isBold": false
      },
      {
        "faceNameIds": [
          1,
          1,
          1,
          1,
          1,
          1,
          1
        ],
        "baseSize": 900,
        "charColor": 0,
        "isItalic": false,
        "isBold": false
      },
      {
        "faceNameIds": [
          0,
          0,
          0,
          0,
          0,
          0,
          0
        ],
        "baseSize": 900,
        "charColor": 0,
        "isItalic": false,
        "isBold": false
      }
    ],
    "paraShapeList": [
      {
        "alignment": 1,
        "lineSpace": 130,
        "tabDefId": 0
      },
      {
        "alignment": 0,
        "lineSpace": 130,
        "tabDefId": 0
      },
      {
        "alignment": 0,
        "lineSpace": 150,
        "tabDefId": 0
      },
      {
        "alignment": 0,
        "lineSpace": 160,
        "tabDefId": 0
      },
      {
        "alignment": 0,
        "lineSpace": 160,
        "tabDefId": 1
      },
      {
        "alignment": 0,
        "lineSpace": 160,
        "tabDefId": 1
      },
      {
        "alignment": 0,
        "lineSpace": 160,
        "tabDefId": 1
      },
      {
        "alignment": 0,
        "lineSpace": 160,
        "tabDefId": 1
      },
      {
        "alignment": 0,
        "lineSpace": 160,
        "tabDefId": 1
      },
      {
        "alignment": 0,
        "lineSpace": 160,
        "tabDefId": 1
      },
      {
        "alignment": 0,
        "lineSpace": 160,
        "tabDefId": 1
      },
      {
        "alignment": 0,
        "lineSpace": 160,
        "tabDefId": 0
      }
    ]
  },
  "bodyText": {
    "sections": [
      {
        "paragraphs": [
          {
            "text": "",
            "charShapes": [
              [
                0,
                0
              ]
            ],
            "paraShapeId": 3,
            "styleId": 0
          }
        ]
      }
    ]
  }
};
