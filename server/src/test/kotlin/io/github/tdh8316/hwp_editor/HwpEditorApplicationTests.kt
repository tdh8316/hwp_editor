package io.github.tdh8316.hwp_editor

import com.google.gson.GsonBuilder
import io.github.tdh8316.hwp_editor.parser.HWPParser
import org.junit.jupiter.api.Test
import java.io.ByteArrayInputStream
import java.io.File

class HwpEditorApplicationTests {

    @Test
    fun contextLoads() {
        val bytearray = File("../tests/empty.hwp").readBytes()

        // println(Base64.encodeBase64String(bytearray))

        val parsed = HWPParser().parseDocument(
            stream = ByteArrayInputStream(bytearray)
        )
        val gson = GsonBuilder().setPrettyPrinting().create()
        val res = (gson.toJson(parsed))

        val f = File("../tests/empty.json")
        f.createNewFile()
        f.writeText(res)

    }

}
