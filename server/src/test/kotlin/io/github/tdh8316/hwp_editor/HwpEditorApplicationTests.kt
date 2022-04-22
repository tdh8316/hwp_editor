package io.github.tdh8316.hwp_editor

import com.google.gson.Gson
import io.github.tdh8316.hwp_editor.parser.HWPParser
import org.junit.jupiter.api.Test
import java.io.File

class HwpEditorApplicationTests {

    @Test
    fun contextLoads() {
        val parsed = HWPParser().parseHwp(
            data = File("../tests/plaintext.hwp").readBytes()
        )
        val gson = Gson()
        println(gson.toJson(parsed).prettyPrint())
    }

}

fun Any.prettyPrint(): String {

    var indentLevel = 0
    val indentWidth = 4

    fun padding() = "".padStart(indentLevel * indentWidth)

    val toString = toString()

    val stringBuilder = StringBuilder(toString.length)

    var i = 0
    while (i < toString.length) {
        when (val char = toString[i]) {
            '(', '[', '{' -> {
                indentLevel++
                stringBuilder.appendLine(char).append(padding())
            }
            ')', ']', '}' -> {
                indentLevel--
                stringBuilder.appendLine().append(padding()).append(char)
            }
            ',' -> {
                stringBuilder.appendLine(char).append(padding())
                // ignore space after comma as we have added a newline
                val nextChar = toString.getOrElse(i + 1) { char }
                if (nextChar == ' ') i++
            }
            else -> {
                stringBuilder.append(char)
            }
        }
        i++
    }

    return stringBuilder.toString()
}
