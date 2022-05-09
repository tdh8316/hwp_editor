import 'package:fluent_ui/fluent_ui.dart';
import 'package:hwp_editor_app/providers/provider_document.dart';
import 'package:hwp_editor_app/widgets/editor/widget_editor.dart';
import 'package:provider/provider.dart';

class DocumentPage extends StatelessWidget {
  const DocumentPage({
    Key? key,
    required this.docData,
  }) : super(key: key);

  final Map<String, dynamic> docData;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: ChangeNotifierProvider<DocumentPageProvider>(
        create: (BuildContext context) => DocumentPageProvider(),
        builder: (BuildContext context, _) {
          final DocumentPageProvider watch =
              context.watch<DocumentPageProvider>();
          final DocumentPageProvider read =
              context.read<DocumentPageProvider>();
          return Column(
            children: [
              SizedBox(
                child: EditorWidget(docData: docData),
                height: MediaQuery.of(context).size.height,
                width: 770,
                // width: MediaQuery.of(context).size.width,
              ),
            ],
          );
        },
      ),
    );
  }
}
