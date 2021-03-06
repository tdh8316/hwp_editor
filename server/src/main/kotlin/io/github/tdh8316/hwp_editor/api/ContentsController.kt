package io.github.tdh8316.hwp_editor.api

import com.google.gson.Gson
import io.github.tdh8316.hwp_editor.parser.HWPParser
import io.github.tdh8316.hwp_editor.parser.datamodel.HWPDataModel
import io.github.tdh8316.hwp_editor.writer.Writer
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.*

@RestController
@RequestMapping("/api")
class ContentsController {
    @GetMapping("test/parse-file/{filePath}")
    fun readFromFileTest(
        @PathVariable(value = "filePath") filePath: String,
    ): ResponseEntity<String> {
        val file = File("../tests/${filePath}")
        val parsed = HWPParser().parseDocument(
            stream = ByteArrayInputStream(file.readBytes())
        )
        val jsonString = Gson().toJson(parsed)

        return ResponseEntity.ok(jsonString)
    }

    /// 문서를 파싱해서 json 문자열 응답으로 반환하는 컨트롤러
    @GetMapping("parse/{byteArrayData}")
    fun parse(
        @PathVariable(value = "byteArrayData") _encodedByteArrayData: String,
    ): ResponseEntity<String> {
        // base64 형식의 데이터를 바이트 배열로 변환
        val byteArrayData = Base64.getUrlDecoder().decode(_encodedByteArrayData)
        // 인자로 전달된 바이트스트림으로 입력 스트림 생성
        val stream = ByteArrayInputStream(byteArrayData)

        // 문서 파싱
        val parsedDocument = HWPParser().parseDocument(stream)

        // 파싱된 문서를 json 문자열로 변환
        val jsonString = Gson().toJson(parsedDocument)

        // json 문자열 전달
        return ResponseEntity.ok(jsonString)
    }

    /// json 문자열 데이터를 문서로 작성해서 bytearray 응답으로 반환하는 컨트롤러
    @GetMapping("write/{jsonString}")
    fun write(
        @PathVariable(value = "jsonString") _encodedJsonString: String,
    ): ResponseEntity<ByteArray> {
        // base64 형식의 데이터를 json 문자열의 문자열로 변환
        val jsonString = String(Base64.getUrlDecoder().decode(_encodedJsonString), Charsets.UTF_8)

        // json 문자열에서 hwp 데이터 모델 생성
        val parsedDocument: HWPDataModel = Gson().fromJson(
            jsonString,
            HWPDataModel::class.java,
        )

        // 문서 출력스트림 생성
        val documentOutputStream: ByteArrayOutputStream = Writer().writeDocument(
            parsedDocument,
        )

        // 출력스트림에서 bytearray 데이터로 변환 후 전달
        return ResponseEntity.ok(
            documentOutputStream.toByteArray(),
        )
    }
}
