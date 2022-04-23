import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart';
import 'package:hwp_editor_app/pages/page_editor_home.dart';
import 'package:hwp_editor_app/providers/provider_home.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => HomeProvider(),
      builder: (BuildContext context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/images/kw_symbol01_02.jpg"),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "광운대학교",
                          style: TextStyle(
                            fontSize: 32,
                            fontFamily: "궁서",
                            color: Color.fromRGBO(120, 34, 45, 1),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "한글 문서 편집기",
                          style: TextStyle(
                            fontSize: 32,
                            fontFamily: "궁서",
                            color: Color.fromRGBO(66, 137, 201, 1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              Button(
                child: const Padding(
                  padding: EdgeInsets.only(
                    left: 64,
                    right: 64,
                    top: 16,
                    bottom: 16,
                  ),
                  child: Text(
                    "문서 열기",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(66, 137, 201, 1),
                    ),
                  ),
                ),
                onPressed: () async {
                  Map<String, dynamic>? documentData =
                      await context.read<HomeProvider>().openDocument(context);
                  if (documentData == null) {
                    return;
                  }
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          EditorHomePage(docData: documentData),
                    ),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }
}
