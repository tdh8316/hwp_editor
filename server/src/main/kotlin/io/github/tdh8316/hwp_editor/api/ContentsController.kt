package io.github.tdh8316.hwp_editor.api

import com.google.gson.Gson
import io.github.tdh8316.hwp_editor.parser.HWPParser
import io.github.tdh8316.hwp_editor.prettier
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.io.ByteArrayOutputStream
import java.io.File

@RestController
@RequestMapping("/api")
class ContentsController {
    @GetMapping("test/output-stream/{data}")
    fun outputStreamTest(@PathVariable(value = "data") data: String): ResponseEntity<ByteArray> {
        val os: ByteArrayOutputStream = io.github.tdh8316.hwp_editor.compiler.Compile().toHwp(data)
        return ResponseEntity.ok(os.toByteArray())
    }

    @GetMapping("test/parse-file/{filePath}")
    fun readFromFileTest(@PathVariable(value = "filePath") filePath: String): ResponseEntity<String> {
        val parsed = HWPParser().parseHwp(
            data = File("../tests/${filePath}").readBytes()
        )
        val jsonString = Gson().toJson(parsed).prettier()

        return ResponseEntity.ok(jsonString)
    }
}
