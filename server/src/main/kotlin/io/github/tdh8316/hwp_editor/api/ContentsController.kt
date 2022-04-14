package io.github.tdh8316.hwp_editor.api

import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.io.ByteArrayOutputStream

@RestController
@RequestMapping("/api")
class ContentsController {
    @GetMapping()
    fun index(): ResponseEntity<String> {
        return ResponseEntity.ok("Hello, world!")
    }

    @GetMapping("{data}")
    fun convert(@PathVariable(value = "data") data: String): ResponseEntity<ByteArray> {
        val os: ByteArrayOutputStream = io.github.tdh8316.hwp_editor.compiler.Compile().toHwp(data)
        return ResponseEntity.ok(os.toByteArray())
    }
}
