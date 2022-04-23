# Developer Front-End Guide

HWP Editor uses flutter to Front-End and Java/Kotlin and Spring to the Back-End.

## How to work

>Note: If you would like to know what the human-readable data mean, see `data model` section in [back-end document](backend.md)

### Parsing process

When it sends a document file to use to our server, the server parses it to json format and returns the human-readable result. Then using this, the Front-End draws the document on its editor.

### Writing process

Front-End sends human-readable json data, Back-End writes `hwp` file and returns the file.

## Editor structure
