package io.github.tdh8316.hwp_editor

import kr.dogfoot.hwplib.reader.HWPReader
import org.junit.jupiter.api.Test

class HwpEditorApplicationTests {

    @Test
    fun contextLoads() {
//        println("Hello, world!")
        val f1 = HWPReader.fromFile("../tests/text.hwp")
        val f2 = HWPReader.fromFile("../tests/text_modified.hwp")

        println("Hello, world!")

//        val bytearray = File("../tests/report.hwp").readBytes()
//
//        val parsed = HWPParser().parseDocument(
//            stream = ByteArrayInputStream(bytearray)
//        )
//        val gson = GsonBuilder().setPrettyPrinting().create()
//        val res = (gson.toJson(parsed))
//
//        val f = File("../tests/report.json")
//        f.createNewFile()
//        f.writeText(res)

//        val jsonString = File("../tests/report.json").readText()
//        // json 문자열에서 hwp 데이터 모델 생성
//        val parsedDocument: HWPDataModel = Gson().fromJson(
//            jsonString,
//            HWPDataModel::class.java,
//        )
//        // 문서 출력스트림 생성
//        val documentOutputStream: ByteArrayOutputStream = Writer().writeDocument(
//            parsedDocument,
//        )
//        val f = File("../tests/report_res.hwp")
//        f.createNewFile()
//        f.writeBytes(documentOutputStream.toByteArray())

//        val hwpFile: HWPFile = BlankFileMaker.make()
//        hwpFile.bodyText.sectionList.last().paragraphs.last().text.addString("첫번째")
//
//        val currentCharShape = hwpFile.docInfo.addNewCharShape()
//        currentCharShape.faceNameIds.hangul = 1
//        currentCharShape.baseSize = 2000
//        currentCharShape.property.isItalic = true
//        currentCharShape.property.isBold = true
//
//        val currentParaShape = hwpFile.docInfo.addNewParaShape()
//        currentParaShape.property1.alignment = Alignment.Center
//        currentParaShape.lineSpace2 = 160
//        currentParaShape.tabDefId = 0
//
//        val currentParagraph=hwpFile.bodyText.sectionList.last().addNewParagraph()
//        val header = currentParagraph.header
//        header.isLastInList = false
//        header.characterCount = 3
//        header.paraShapeId = 12
//        header.styleId = 1
//        header.charShapeCount = 1
//        header.rangeTagCount = 0
//        header.lineAlignCount = 1
//        header.instanceID = 0
//        header.isMergedByTrack = 0
//        currentParagraph.createText()
//        currentParagraph.text.addString("두번째")
//        currentParagraph.createCharShape()
//        currentParagraph.charShape.addParaCharShape(0,5)
//        // currentParagraph.charShape.addParaCharShape(2,5)
//        currentParagraph.createLineSeg()
//        val lsi = currentParagraph.lineSeg.addNewLineSegItem()
//        lsi.textStartPosition = 0
//        lsi.lineVerticalPosition = 0
//        lsi.tag.firstSegmentAtLine = true
//        lsi.tag.lastSegmentAtLine = true
//        HWPWriter.toFile(hwpFile, "../tests/result.hwp")
    }

}
