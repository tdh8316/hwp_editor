package io.github.tdh8316.hwp_editor.parser.datamodel


data class DocInfoDataModel(
    val hangulFaceNameList: MutableList<FaceName>,
    val charShapeList: MutableList<CharShape>,
    val paraShapeList: MutableList<ParaShape>,
) {
    constructor() : this(
        hangulFaceNameList = mutableListOf(),
        charShapeList = mutableListOf(),
        paraShapeList = mutableListOf(),
    )
}

data class FaceName(
    val name: String,
    val baseFontName: String,
    // FontTypeInfo
)

data class CharShape(
    val faceNameIds: ArrayList<Int> = arrayListOf(
        0, // 한국어
        0, // 영어
        0, // 중국어
        0, // 일본어
        0, // 기타 문자
        0, // 기호
        0, // 사용자 정의
    ),
    val baseSize: Int,
    val charColor: Long,
    val isItalic: Boolean,
    val isBold: Boolean,
)

data class ParaShape(
    // 정렬: 양쪽=0 왼쪽=1 오른쪽=2 가운데=3 배분=4 나눔=5
    val alignment: Int,
    val property1Value: Long,
    val leftMargin: Int,

    val lineSpace: Long,
    val tabDefId: Int,
)