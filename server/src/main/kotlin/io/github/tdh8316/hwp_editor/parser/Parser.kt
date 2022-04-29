package io.github.tdh8316.hwp_editor.parser

import io.github.tdh8316.hwp_editor.parser.datamodel.*
import kr.dogfoot.hwplib.`object`.HWPFile
import kr.dogfoot.hwplib.reader.HWPReader
import java.io.ByteArrayInputStream

class HWPParser {
    fun parseDocument(stream: ByteArrayInputStream): HWPDataModel {
        // HWP 객체 생성
        val hwpFile: HWPFile = HWPReader.fromInputStream(stream)
        val parsed = HWPDataModel()

        // DocInfo 파싱
        parseDocInfo(hwpFile, parsed)

        // bodyText/Section 파싱
        parseBodyTextSections(hwpFile, parsed)


        return parsed
    }

    private fun parseDocInfo(hwpFile: HWPFile, parsed: HWPDataModel) {
        for (hangulFaceName in hwpFile.docInfo.hangulFaceNameList) {
            parsed.docInfo.hangulFaceNameList.add(
                FaceName(
                    name = hangulFaceName.name,
                    baseFontName = hangulFaceName.baseFontName,
                ),
            )
        }
        for (charShape in hwpFile.docInfo.charShapeList) {
            parsed.docInfo.charShapeList.add(
                CharShape(
                    faceNameIds = charShape.faceNameIds.array.toCollection(
                        ArrayList()
                    ),
                    baseSize = charShape.baseSize,
                    charColor = charShape.charColor.value,
                ),
            )
        }
        for (paraShape in hwpFile.docInfo.paraShapeList) {
            parsed.docInfo.paraShapeList.add(
                ParaShape(
                    alignment = paraShape.property1.alignment.ordinal
                )
            )
        }
    }

    private fun parseBodyTextSections(hwpFile: HWPFile, parsed: HWPDataModel) {
        for (section in hwpFile.bodyText.sectionList) {
            // BodyText 에 Section 요소 추가
            val currentSection = SectionDataModel()

            for (paragraph in section.paragraphs) {
                currentSection.paragraphs.add(paragraph.normalString)
                for (shape in paragraph.charShape.positonShapeIdPairList) {
                    currentSection.charShapes.add(
                        arrayListOf(
                            shape.position,
                            shape.shapeId,
                        ),
                    )
                }
                currentSection.paraShapeIds.add(paragraph.header.paraShapeId)
            }
            parsed.bodyText.sections.add(currentSection)
        }
    }
}
