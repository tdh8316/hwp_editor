import 'package:fluent_ui/fluent_ui.dart';
import 'package:hwp_editor_app/pages/page_home.dart';

void main() {
  runApp(const HWPEditorApplication());
}

class HWPEditorApplication extends StatelessWidget {
  const HWPEditorApplication({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const FluentApp(
      title: "HWP Editor",
      debugShowCheckedModeBanner: true,
      home: HomePage(),
    );
  }
}
