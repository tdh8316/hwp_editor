package io.github.tdh8316.hwp_editor.parser

import io.github.tdh8316.hwp_editor.parser.datamodel.*
import kr.dogfoot.hwplib.`object`.HWPFile
import kr.dogfoot.hwplib.`object`.bodytext.control.ControlTable
import kr.dogfoot.hwplib.`object`.bodytext.control.ControlType
import kr.dogfoot.hwplib.`object`.bodytext.control.table.Cell
import kr.dogfoot.hwplib.`object`.bodytext.paragraph.Paragraph
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
                    isItalic = charShape.property.isItalic,
                    isBold = charShape.property.isBold,
                ),
            )
        }

        // 문단 모양 정보 생성
        for (paraShape in hwpFile.docInfo.paraShapeList) {
            parsed.docInfo.paraShapeList.add(
                ParaShape(
                    alignment = paraShape.property1.alignment.ordinal,
                    lineSpace = paraShape.lineSpace2,
                    tabDefId = paraShape.tabDefId,
                )
            )
        }
    }

    /// BodyText/Section%d 스트림을 파싱
    private fun parseBodyTextSections(hwpFile: HWPFile, parsed: HWPDataModel) {
        for (section in hwpFile.bodyText.sectionList) {
            // BodyText 에 Section 요소 추가
            parsed.bodyText.sections.add(
                SectionDataModel(
                    paragraphs = section.paragraphs.map { buildParagraphDataModel(it) }
                ),
            )
        }
    }

    /// paragraph 데이터 모델 생성
    private fun buildParagraphDataModel(paragraph: Paragraph): ParagraphDataModel {
        return ParagraphDataModel(
            text = paragraph.normalString,
            charShapes = paragraph.charShape.positonShapeIdPairList.map { shape ->
                arrayListOf(shape.position, shape.shapeId)
            },
            paraShapeId = paragraph.header.paraShapeId,
            styleId = paragraph.header.styleId,
            table = buildTableDataModel(paragraph),
        )
    }


    private fun buildTableDataModel(paragraph: Paragraph): TableDataModel? {
        return if (paragraph.controlList != null
            && paragraph.controlList.size >= 3
            && paragraph.controlList[2].type == ControlType.Table
        ) {
            TableDataModel(
                rowList = (paragraph.controlList[2] as ControlTable).rowList.map { row ->
                    RowDataModel(
                        cellList = row.cellList.map { cell ->
                            buildCellDataModel(cell)
                        }
                    )
                },
            )
        } else {
            null
        }
    }

    /// cell 데이터 모델 생성
    private fun buildCellDataModel(cell: Cell): CellDataModel {
        return CellDataModel(
            header = CellHeaderDataModel(
                rowIndex = cell.listHeader.rowIndex,
                columnIndex = cell.listHeader.colIndex,
                rowSpan = cell.listHeader.rowSpan,
                columnSpan = cell.listHeader.colSpan,
                width = cell.listHeader.width,
                height = cell.listHeader.height,
                borderFillId = cell.listHeader.borderFillId,
                // fieldName = cell.listHeader.fieldName,
            ),
            paragraphs = cell.paragraphList.paragraphs.map { buildParagraphDataModel(it) }
        )
    }
}
