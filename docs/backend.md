# Developer Back-End Guide

> Note: HWP Editor uses [hwplib](https://github.com/neolord0/hwplib), which is written in Java.

## Run parser

```kotlin
val stream = ByteArrayInputStream(bytesArray)
val parsedDocument = HWPParser().parseDocument(stream)
```

## Convert to JSON String

> Note: Use gson

```kotlin
Gson().toJson(parsedDocument)
```

## Data model

한글과컴퓨터 측에서 제공하는 [HWP5.0 문서 구조](https://www.hancom.com/etc/hwpDownload.do) 참고

### DocInfo

문서 정보를 저장하는 스트림

#### hangulFaceNameList

글꼴 정보 저장

- FaceName
  - name: String
  - baseFontName: String

#### charShapeList

글자 모양 저장

- CharShape
  - faceNameIds: ArrayList\<Int>[7]
    - 한국어, 영어, 중국어, 일본어, 기타 문자, 기호, 사용자 정의
  - baseSize: Int
    - 글자 기본 크기

### BodyText

문서 본문을 저장하는 스트림

#### Sections

- paragraphs: MutableList\<String>
  - 엔터로 구분된 문자를 저장하는 리스트
- shapes: MutableList\<ArrayList\<Long>[2]>
  - 글자 인덱스와 모양을 저장하는 리스트
