import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:hwp_editor_app/widgets/editor/widget_paragraph.dart';

class TableWidget extends StatelessWidget {
  const TableWidget({
    required this.table,
    Key? key,
  }) : super(key: key);

  final Map table;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: (table["rowList"] as List).length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          child: IntrinsicHeight(child: _buildRow(context, table["rowList"][index])),
          decoration: BoxDecoration(
            border: Border(
              top: index == 0
                  ? const BorderSide(
                      color: Color(0xFF000000),
                      width: 1.0,
                      style: BorderStyle.solid,
                    )
                  : BorderSide.none,
              bottom: const BorderSide(
                color: Color(0xFF000000),
                width: 1.0,
                style: BorderStyle.solid,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, Map rowItem) {
    final List cellList = rowItem["cellList"];
    return Row(
      children: [
        for (int i = 0; i < cellList.length; i++)
          Expanded(
            child: Container(
              child: _buildCell(context, cellList[i]),
              decoration: BoxDecoration(
                border: Border(
                  left: i == 0
                      ? const BorderSide(
                          color: Color(0xFF000000),
                          width: 1.0,
                          style: BorderStyle.solid,
                        )
                      : BorderSide.none,
                  right: const BorderSide(
                    color: Color(0xFF000000),
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCell(BuildContext context, Map cellItem) {
    return Column(
      children: [
        for (Map paragraph in cellItem["paragraphs"])
          Padding(
            // TODO: Adjust table padding
            padding: const EdgeInsets.all(2),
            child: ParagraphWidget(
              paragraph: paragraph,
            ),
          ),
      ],
    );
  }
}
