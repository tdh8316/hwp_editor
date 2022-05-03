class SectionDataModel {
  SectionDataModel(this.paragraphs);

  final List<String> paragraphs;
}

class HWPDocument {
  HWPDocument({
    required this.bodyText,
  });

  final List<SectionDataModel> bodyText;

  HWPDocument.fromJson(Map<String, dynamic> data) : bodyText = data["bodyText"];
}
