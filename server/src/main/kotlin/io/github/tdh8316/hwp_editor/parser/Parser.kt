package io.github.tdh8316.hwp_editor.parser

import io.github.tdh8316.hwp_editor.parser.datamodel.CharShape
import io.github.tdh8316.hwp_editor.parser.datamodel.FaceName
import io.github.tdh8316.hwp_editor.parser.datamodel.HWPDataModel
import io.github.tdh8316.hwp_editor.parser.datamodel.SectionDataModel
import kr.dogfoot.hwplib.`object`.HWPFile
import kr.dogfoot.hwplib.reader.HWPReader
import java.io.ByteArrayInputStream

class HWPParser {
    fun parseDocument(stream: ByteArrayInputStream): HWPDataModel {
        // HWP 객체 생성
        val hwpFile: HWPFile = HWPReader.fromInputStream(stream)
        val parsed = HWPDataModel()

        // DocInfo 파싱
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
                ),
            )
        }

        // bodyText/Section 파싱
        for (section in hwpFile.bodyText.sectionList) {
            // BodyText 에 Section 요소 추가
            val currentSection = SectionDataModel()
            parsed.bodyText.sections.add(currentSection)

            for (paragraph in section.paragraphs) {
                currentSection.paragraphs.add(paragraph.normalString)

                for (shape in paragraph.charShape.positonShapeIdPairList) {
                    val posShapePair = arrayListOf(
                        shape.position,
                        shape.shapeId,
                    )
                    currentSection.shapes.add(posShapePair)
                }
            }
        }

        return parsed
    }
}

