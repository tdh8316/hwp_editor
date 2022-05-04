package io.github.tdh8316.hwp_editor.parser.datamodel

data class BodyTextDataModel(
    val sections: MutableList<SectionDataModel>,
) {
    constructor() : this(sections = mutableListOf())
}

data class SectionDataModel(
    val paragraphs: List<ParagraphDataModel>,
)

data class ParagraphDataModel(
    val text: String,
    val charShapes: List<ArrayList<Long>>,
    val paraShapeId: Int,
    val styleId: Short,
    val table: TableDataModel?,
)
