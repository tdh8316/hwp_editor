package io.github.tdh8316.hwp_editor.writer

import io.github.tdh8316.hwp_editor.parser.datamodel.BodyTextDataModel
import io.github.tdh8316.hwp_editor.parser.datamodel.DocInfoDataModel
import io.github.tdh8316.hwp_editor.parser.datamodel.HWPDataModel
import io.github.tdh8316.hwp_editor.parser.datamodel.ParagraphDataModel
import kr.dogfoot.hwplib.`object`.HWPFile
import kr.dogfoot.hwplib.`object`.bodytext.paragraph.Paragraph
import kr.dogfoot.hwplib.`object`.docinfo.parashape.Alignment
import kr.dogfoot.hwplib.tool.blankfilemaker.BlankFileMaker
import kr.dogfoot.hwplib.writer.HWPWriter
import java.io.ByteArrayOutputStream

class Writer {
    fun writeDocument(document: HWPDataModel): ByteArrayOutputStream {
        // 출력스트림 생성
        val stream = ByteArrayOutputStream()

        // 빈 hwp 파일 생성
        val hwpFile: HWPFile = BlankFileMaker.make()

        hwpFile.fileHeader.isCompressed = true

        // 글꼴 데이터 저장
        writeDocInfo(hwpFile, document.docInfo)

        // 문서 본문 저장
        writeBodyTextSections(hwpFile, document.bodyText)

        // 출력스트림에 데이터 쓰기
        HWPWriter.toStream(hwpFile, stream)

        // 스트림 반환
        return stream
    }

    /// 문서 정보를 저장
    private fun writeDocInfo(hwpFile: HWPFile, docInfo: DocInfoDataModel) {
//        for (faceName in docInfo.hangulFaceNameList) {
//            val currentFaceName = hwpFile.docInfo.addNewHangulFaceName()
//            currentFaceName.name = faceName.name
//            currentFaceName.baseFontName = faceName.baseFontName
//        }

        for (i in 0 until hwpFile.docInfo.charShapeList.count()) {
            hwpFile.docInfo.charShapeList[i].faceNameIds.hangul = docInfo.charShapeList[i].faceNameIds[0]
            hwpFile.docInfo.charShapeList[i].baseSize = docInfo.charShapeList[i].baseSize
            hwpFile.docInfo.charShapeList[i].charColor.value = docInfo.charShapeList[i].charColor
            hwpFile.docInfo.charShapeList[i].property.isItalic = docInfo.charShapeList[i].isItalic
            hwpFile.docInfo.charShapeList[i].property.isBold = docInfo.charShapeList[i].isBold
        }

        for (charShape in docInfo.charShapeList.slice(hwpFile.docInfo.charShapeList.count() until docInfo.charShapeList.count())) {
            val currentCharShape = hwpFile.docInfo.addNewCharShape()
            currentCharShape.faceNameIds.hangul = charShape.faceNameIds[0]
            currentCharShape.baseSize = charShape.baseSize
            currentCharShape.charColor.value = charShape.charColor
            currentCharShape.property.isItalic = charShape.isItalic
            currentCharShape.property.isBold = charShape.isBold
        }

        for (j in 0 until hwpFile.docInfo.paraShapeList.count()) {
            hwpFile.docInfo.paraShapeList[j].property1.alignment =
                when (docInfo.paraShapeList[j].alignment) {
                    0 -> Alignment.Justify
                    1 -> Alignment.Left
                    2 -> Alignment.Right
                    3 -> Alignment.Center
                    else -> Alignment.Justify
                }
            hwpFile.docInfo.paraShapeList[j].lineSpace2 = docInfo.paraShapeList[j].lineSpace
            hwpFile.docInfo.paraShapeList[j].tabDefId = docInfo.paraShapeList[j].tabDefId
        }

        for (paraShape in docInfo.paraShapeList.slice(hwpFile.docInfo.paraShapeList.count() until docInfo.paraShapeList.count())) {
            val currentParaShape = hwpFile.docInfo.addNewParaShape()
            currentParaShape.property1.alignment = when (paraShape.alignment) {
                0 -> Alignment.Justify
                1 -> Alignment.Left
                2 -> Alignment.Right
                3 -> Alignment.Center
                else -> Alignment.Justify
            }
            currentParaShape.lineSpace2 = paraShape.lineSpace
            currentParaShape.tabDefId = paraShape.tabDefId
        }
    }

    /// 문서 본문을 저장
    private fun writeBodyTextSections(hwpFile: HWPFile, bodyText: BodyTextDataModel) {
        // bodyText 에는 최소 1개 이상의 section 이 존재하므로
        // 빈 section 이 생기지 않도록 기존 section 한 번 사용
        var useDefaultSection = true
        for (section in bodyText.sections) {
            val currentSection = if (!useDefaultSection) {
                hwpFile.bodyText.addNewSection()
            } else {
                hwpFile.bodyText.sectionList.last()
            }

            // section 에는 최소 1개 이상의 paragraph 가 존재하므로
            // 빈 paragraph 가 생기지 않도록 기존 paragraph 한 번 사용
            var useDefaultParagraph = true
            for (paragraph in section.paragraphs) {
                val currentParagraph = if (!useDefaultParagraph) {
                    currentSection.addNewParagraph()

                } else {
                    currentSection.paragraphs.last()
                }

                buildParagraph(currentParagraph, paragraph)

                useDefaultParagraph = false
            }
            currentSection.paragraphs.last().header.isLastInList = true

            useDefaultSection = false
        }

    }

    private fun buildParagraph(currentParagraph: Paragraph, paragraph: ParagraphDataModel) {
        val header = currentParagraph.header
        header.isLastInList = false
        header.characterCount = paragraph.text.count().toLong()
        header.paraShapeId = paragraph.paraShapeId
        header.styleId = paragraph.styleId
        header.charShapeCount = paragraph.charShapes.count()
        header.rangeTagCount = 0
        header.lineAlignCount = 1
        header.instanceID = 0
        header.isMergedByTrack = 0

        currentParagraph.createText()
        currentParagraph.text.addString(paragraph.text)
        println(paragraph.text)

        currentParagraph.createCharShape()
        for (charShapePair in paragraph.charShapes) {
            currentParagraph.charShape.addParaCharShape(charShapePair[0], charShapePair[1])
        }

        currentParagraph.createLineSeg()
        val lsi = currentParagraph.lineSeg.addNewLineSegItem()
        lsi.textStartPosition = 0
        lsi.lineVerticalPosition = 0
        lsi.tag.firstSegmentAtLine = true
        lsi.tag.lastSegmentAtLine = true
    }
}
