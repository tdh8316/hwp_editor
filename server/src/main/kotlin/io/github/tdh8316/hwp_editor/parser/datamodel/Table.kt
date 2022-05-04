package io.github.tdh8316.hwp_editor.parser.datamodel

data class TableDataModel(
    val rowList: List<RowDataModel>,
//    val rowCount: Int,
//    val columnCount: Int,
//    val cellSpacing: Int,
//    val leftInnerMargin: Int,
//    val rightInnerMargin: Int,
//    val topInnerMargin: Int,
//    val bottomInnerMargin: Int,
//    val cellCountOfList: MutableList<Int>,
//    val borderFillId: Int,
)

data class RowDataModel(
    val cellList: List<CellDataModel>
)

data class CellDataModel(
    val header: CellHeaderDataModel,
    val paragraphs: List<ParagraphDataModel>,
)

data class CellHeaderDataModel(
    val rowIndex: Int,
    val columnIndex: Int,
    val rowSpan: Int,
    val columnSpan: Int,
    val width: Long,
    val height: Long,
    val borderFillId: Int,
    // val fieldName: String,
)