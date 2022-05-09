import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePageProvider extends ChangeNotifier {
  Future<Map<String, dynamic>?> openDocument(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ["hwp"],
    );

    if (result == null) return null;

    final File file = File(result.files.single.path!);

    final String encodedData =
        base64Encode(file.readAsBytesSync()).replaceAll("/", "_");
    final String uri = Uri.encodeFull(
      "http://localhost:8080/api/parse/$encodedData",
    );
    final http.Response response = await http.get(
      Uri.parse(uri),
    );

    if (response.statusCode != 200) {
      return null;
    }

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    return jsonData;
  }
}
