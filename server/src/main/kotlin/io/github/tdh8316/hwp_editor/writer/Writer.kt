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

        for (section in document.bodyText.sections) {
            // 새로운 섹션 생성

        }

    }
}
