package io.github.tdh8316.hwp_editor.compiler

import kr.dogfoot.hwplib.`object`.HWPFile
import kr.dogfoot.hwplib.tool.blankfilemaker.BlankFileMaker

class HwpUtils {
     companion object {
         fun blank() {
             val hwpFile: HWPFile = BlankFileMaker.make()
         }
     }
}