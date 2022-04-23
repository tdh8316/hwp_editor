package io.github.tdh8316.hwp_editor

import com.google.gson.Gson
import io.github.tdh8316.hwp_editor.parser.HWPParser
import io.github.tdh8316.hwp_editor.parser.datamodel.HWPDataModel
import io.github.tdh8316.hwp_editor.writer.Writer
import org.apache.tomcat.util.codec.binary.Base64
import org.junit.jupiter.api.Test
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.File

class HwpEditorApplicationTests {

    @Test
    fun contextLoads() {
        val bytearray = File("../tests/richtext.hwp").readBytes()

        println(Base64.encodeBase64String(bytearray))

        val parsed = HWPParser().parseDocument(
            stream = ByteArrayInputStream(bytearray)
        )
        val gson = Gson()
        // println(gson.toJson(parsed).prettyPrint())

        val jsonString = """
            
            {
                "docInfo":{
                    "hangulFaceNameList":[
                        {
                            "name":"함초롬돋움",
                            "baseFontName":"HCR Dotum"
                        },
                        {
                            "name":"함초롬바탕",
                            "baseFontName":"HCR Batang"
                        }
                    ],
                    "charShapeList":[
                        {
                            "faceNameIds":[
                                1,
                                1,
                                1,
                                1,
                                1,
                                1,
                                1
                            ]
                        },
                        {
                            "faceNameIds":[
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0
                            ]
                        },
                        {
                            "faceNameIds":[
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0
                            ]
                        },
                        {
                            "faceNameIds":[
                                1,
                                1,
                                1,
                                1,
                                1,
                                1,
                                1
                            ]
                        },
                        {
                            "faceNameIds":[
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0
                            ]
                        }
                    ]
                },
                "bodyText":{
                    "sections":[
                        {
                            "paragraphs":[
                                "api 에서 입력된 문자열입니다."
                            ],
                            "shapes":[
                                [
                                    0,
                                    0
                                ]
                            ]
                        }
                    ]
                }
            }
        """.trimIndent()
//        val e = Base64.encodeBase64String(jsonString.toByteArray())
//        println(e)
//
//        val b64 = "CnsKICAgICJkb2NJbmZvIjp7CiAgICAgICAgImhhbmd1bEZhY2VOYW1lTGlzdCI6WwogICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAibmFtZSI6Iu2VqOy0iOuhrOuPi+ybgCIsCiAgICAgICAgICAgICAgICAiYmFzZUZvbnROYW1lIjoiSENSIERvdHVtIgogICAgICAgICAgICB9LAogICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAibmFtZSI6Iu2VqOy0iOuhrOuwlO2DlSIsCiAgICAgICAgICAgICAgICAiYmFzZUZvbnROYW1lIjoiSENSIEJhdGFuZyIKICAgICAgICAgICAgfQogICAgICAgIF0sCiAgICAgICAgImNoYXJTaGFwZUxpc3QiOlsKICAgICAgICAgICAgewogICAgICAgICAgICAgICAgImZhY2VOYW1lSWRzIjpbCiAgICAgICAgICAgICAgICAgICAgMSwKICAgICAgICAgICAgICAgICAgICAxLAogICAgICAgICAgICAgICAgICAgIDEsCiAgICAgICAgICAgICAgICAgICAgMSwKICAgICAgICAgICAgICAgICAgICAxLAogICAgICAgICAgICAgICAgICAgIDEsCiAgICAgICAgICAgICAgICAgICAgMQogICAgICAgICAgICAgICAgXQogICAgICAgICAgICB9LAogICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAiZmFjZU5hbWVJZHMiOlsKICAgICAgICAgICAgICAgICAgICAwLAogICAgICAgICAgICAgICAgICAgIDAsCiAgICAgICAgICAgICAgICAgICAgMCwKICAgICAgICAgICAgICAgICAgICAwLAogICAgICAgICAgICAgICAgICAgIDAsCiAgICAgICAgICAgICAgICAgICAgMCwKICAgICAgICAgICAgICAgICAgICAwCiAgICAgICAgICAgICAgICBdCiAgICAgICAgICAgIH0sCiAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICJmYWNlTmFtZUlkcyI6WwogICAgICAgICAgICAgICAgICAgIDAsCiAgICAgICAgICAgICAgICAgICAgMCwKICAgICAgICAgICAgICAgICAgICAwLAogICAgICAgICAgICAgICAgICAgIDAsCiAgICAgICAgICAgICAgICAgICAgMCwKICAgICAgICAgICAgICAgICAgICAwLAogICAgICAgICAgICAgICAgICAgIDAKICAgICAgICAgICAgICAgIF0KICAgICAgICAgICAgfSwKICAgICAgICAgICAgewogICAgICAgICAgICAgICAgImZhY2VOYW1lSWRzIjpbCiAgICAgICAgICAgICAgICAgICAgMSwKICAgICAgICAgICAgICAgICAgICAxLAogICAgICAgICAgICAgICAgICAgIDEsCiAgICAgICAgICAgICAgICAgICAgMSwKICAgICAgICAgICAgICAgICAgICAxLAogICAgICAgICAgICAgICAgICAgIDEsCiAgICAgICAgICAgICAgICAgICAgMQogICAgICAgICAgICAgICAgXQogICAgICAgICAgICB9LAogICAgICAgICAgICB7CiAgICAgICAgICAgICAgICAiZmFjZU5hbWVJZHMiOlsKICAgICAgICAgICAgICAgICAgICAwLAogICAgICAgICAgICAgICAgICAgIDAsCiAgICAgICAgICAgICAgICAgICAgMCwKICAgICAgICAgICAgICAgICAgICAwLAogICAgICAgICAgICAgICAgICAgIDAsCiAgICAgICAgICAgICAgICAgICAgMCwKICAgICAgICAgICAgICAgICAgICAwCiAgICAgICAgICAgICAgICBdCiAgICAgICAgICAgIH0KICAgICAgICBdCiAgICB9LAogICAgImJvZHlUZXh0Ijp7CiAgICAgICAgInNlY3Rpb25zIjpbCiAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICJwYXJhZ3JhcGhzIjpbCiAgICAgICAgICAgICAgICAgICAgImFwaSDsl5DshJwg7J6F66Cl65CcIOusuOyekOyXtOyeheuLiOuLpC4iCiAgICAgICAgICAgICAgICBdLAogICAgICAgICAgICAgICAgInNoYXBlcyI6WwogICAgICAgICAgICAgICAgICAgIFsKICAgICAgICAgICAgICAgICAgICAgICAgMCwKICAgICAgICAgICAgICAgICAgICAgICAgMAogICAgICAgICAgICAgICAgICAgIF0KICAgICAgICAgICAgICAgIF0KICAgICAgICAgICAgfQogICAgICAgIF0KICAgIH0KfQ=="
//        println(Base64.decodeBase64(b64).toString(Charsets.UTF_8))

        // json 문자열에서 hwp 데이터 모델 생성
//        val parsedDocument: HWPDataModel = Gson().fromJson(
//            jsonString,
//            HWPDataModel::class.java,
//        )
//
//        // 문서 출력스트림 생성
//        val documentOutputStream: ByteArrayOutputStream = Writer().writeDocument(
//            parsedDocument,
//        )
//
//        File("../tests/test.hwp").writeBytes(documentOutputStream.toByteArray())


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
