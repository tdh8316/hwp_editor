package io.github.tdh8316.hwp_editor.compiler

import kr.dogfoot.hwplib.`object`.HWPFile
import kr.dogfoot.hwplib.tool.blankfilemaker.BlankFileMaker
import kr.dogfoot.hwplib.writer.HWPWriter
import java.io.ByteArrayOutputStream

class Compile {
    fun toHwp(data: String): ByteArrayOutputStream {
        val hwpFile: HWPFile = BlankFileMaker.make()

        hwpFile.bodyText.addNewSection().addNewParagraph()
        hwpFile.bodyText.sectionList[0].getParagraph(0).text.addString(data)

        val stream = ByteArrayOutputStream()
        HWPWriter.toStream(hwpFile, stream)

        return stream
    }
}
