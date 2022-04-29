package io.github.tdh8316.hwp_editor.parser.datamodel

data class BodyTextDataModel(
    val sections: MutableList<SectionDataModel>,
) {
    constructor() : this(sections = mutableListOf())
}

data class SectionDataModel(
    val paragraphs: MutableList<String>,
    val charShapes: MutableList<ArrayList<Long>>,
    val paraShapeIds: MutableList<Int>,
) {
    constructor() : this(
        paragraphs = mutableListOf(),
        charShapes = mutableListOf(),
        paraShapeIds = mutableListOf(),
    )
}

