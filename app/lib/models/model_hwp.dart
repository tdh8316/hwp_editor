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
