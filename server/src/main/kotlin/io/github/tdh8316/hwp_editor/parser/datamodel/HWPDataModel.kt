package io.github.tdh8316.hwp_editor.parser.datamodel


data class HWPDataModel(
    val docInfo: DocInfoDataModel,
    val bodyText: BodyTextDataModel,
) {
    constructor() : this(
        docInfo = DocInfoDataModel(),
        bodyText = BodyTextDataModel(),
    )
}
