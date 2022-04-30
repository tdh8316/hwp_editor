package io.github.tdh8316.hwp_editor.parser

import io.github.tdh8316.hwp_editor.parser.datamodel.*
import kr.dogfoot.hwplib.`object`.HWPFile
import kr.dogfoot.hwplib.reader.HWPReader
import java.io.ByteArrayInputStream

class HWPParser {
    /// ByteArrayInputStream 으로부터 문서를 파싱해서 HWPDataModel 반환
    fun parseDocument(stream: ByteArrayInputStream): HWPDataModel {
        // HWP 객체 생성
        val hwpFile: HWPFile = HWPReader.fromInputStream(stream)
        
        // 데이터 모델 생성
        val parsed = HWPDataModel()

        // DocInfo 파싱
        parseDocInfo(hwpFile, parsed)

        // bodyText/Section 파싱
        parseBodyTextSections(hwpFile, parsed)
        
        return parsed
    }

    /// DocInfo 스트림을 파싱
    private fun parseDocInfo(hwpFile: HWPFile, parsed: HWPDataModel) {
        // 한글 폰트 정보 생성
        for (hangulFaceName in hwpFile.docInfo.hangulFaceNameList) {
            parsed.docInfo.hangulFaceNameList.add(
                FaceName(
                    name = hangulFaceName.name,
                    baseFontName = hangulFaceName.baseFontName,
                ),
            )
        }
        
        // 문자 모양 정보 생성
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
        
        // 문단 모양 정보 생성
        for (paraShape in hwpFile.docInfo.paraShapeList) {
            parsed.docInfo.paraShapeList.add(
                ParaShape(
                    alignment = paraShape.property1.alignment.ordinal,
                )
            )
        }
    }

    /// BodyText/Section%d 스트림을 파싱
    private fun parseBodyTextSections(hwpFile: HWPFile, parsed: HWPDataModel) {
        for (section in hwpFile.bodyText.sectionList) {
            // Section 데이터 모델 생성
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
            
            // BodyText 에 Section 요소 추가
            parsed.bodyText.sections.add(currentSection)
        }
    }
}
