package io.github.tdh8316.hwp_editor.writer

import io.github.tdh8316.hwp_editor.parser.datamodel.HWPDataModel
import kr.dogfoot.hwplib.`object`.HWPFile
import kr.dogfoot.hwplib.tool.blankfilemaker.BlankFileMaker
import kr.dogfoot.hwplib.writer.HWPWriter
import java.io.ByteArrayOutputStream

class Writer {
    fun writeDocument(document: HWPDataModel): ByteArrayOutputStream {
        // 출력스트림 생성
        val stream = ByteArrayOutputStream()

        // 빈 hwp 파일 생성
        val hwpFile: HWPFile = BlankFileMaker.make()

        // 글꼴 데이터 저장


        // 문서 본문 저장
        writeDocumentBody(document, hwpFile)

        // 출력스트림에 데이터 쓰기
        HWPWriter.toStream(hwpFile, stream)

        // 스트림 반환
        return stream
    }

    /// 문서 본문을 저장
    private fun writeDocumentBody(document: HWPDataModel, hwpFile: HWPFile) {
        // 문서에는 최소 1개 이상의 섹션이 존재하므로
        // 빈 섹션이 남지 않도록 기존의 섹션 한 번 사용
        var defaultSection = true

        for (section in document.bodyText.sections) {
            // 새로운 섹션 생성
            val currentSection = if (!defaultSection) {
                // 기존 섹션을 사용한 경우 새 섹션 추가
                hwpFile.bodyText.addNewSection()
            } else {
                // 기존 섹션이 사용되지 않은 경우 사용
                hwpFile.bodyText.sectionList.last()
            }

            // 섹션에는 최소 1개 이상의 paragraph 가 존재하므로
            // 빈 paragraph 가 생기지 않도록 기존 paragraph 한 번 사용
            var defaultParagraph = true

            for (paragraph in section.paragraphs) {
                // 섹션에 paragraph 추가
                val currentParagraph = if (!defaultParagraph) {
                    // 기존 paragraph 를 사용한 경우 새 paragraph 추가
                    currentSection.addNewParagraph()
                } else {
                    // 기존 paragraph 가 사용되지 않은 경우 사용
                    currentSection.paragraphs.last()
                }

                // paragraph 에 헤더 추가
                val header = currentParagraph.header
                header.isLastInList = true
                header.paraShapeId = 1
                header.styleId = 1
                header.charShapeCount = 1
                header.rangeTagCount = 0
                header.lineAlignCount = 1
                header.instanceID = 0
                header.isMergedByTrack = 0

                // 텍스트 추가
                currentParagraph.createText()
                currentParagraph.text.addString(paragraph)

                // 글꼴 참조 추가
                currentParagraph.createCharShape()
                currentParagraph.charShape.addParaCharShape(0, 0)

                currentParagraph.createLineSeg()
                val lsi = currentParagraph.lineSeg.addNewLineSegItem()
                lsi.textStartPosition = 0
                lsi.lineVerticalPosition = 0
                lsi.tag.firstSegmentAtLine = true
                lsi.tag.lastSegmentAtLine = true

                // 기존 paragraph 를 사용한 경우 트리거
                if (defaultParagraph)
                    defaultParagraph = false
            }
            // 기존 section 을 사용한 경우 트리거
            if (defaultSection)
                defaultSection = false
        }

    }
}