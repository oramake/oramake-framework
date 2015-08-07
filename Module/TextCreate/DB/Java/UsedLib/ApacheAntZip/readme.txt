title: Apache Ant ( Zip)

Библиотека Apache Ant ( <http://ant.apache.org>) используется для создания
zip-архива, т.к. в созданном с помощью стандартных классов ( java.util.zip)
архиве имена файлов с кириллицей отображаются некорректно ( вероятно проблема
решена в JDK 7).

Версия:
- apache-ant 1.8.0

Для загрузки в БД используется часть библитеки, в каторой реализована работа с
zip-архивами ( нестандартный бинарный дистрибутив apache-ant-zip-1.8.0.jar.zip,
источник <http://www.java2s.com/Code/Jar/a/Downloadapacheantzipjar.htm>).

Список загружаемых классов ( org.apache.tools.zip):

(code)

AbstractUnicodeExtraField.class
AsiExtraField.class
CentralDirectoryParsingZipExtraField.class
ExtraFieldUtils.class
FallbackZipEncoding.class
JarMarker.class
NioZipEncoding.class
Simple8BitZipEncoding.class
Simple8BitZipEncoding$Simple8BitChar.class
UnicodeCommentExtraField.class
UnicodePathExtraField.class
UnixStat.class
UnrecognizedExtraField.class
ZipEncoding.class
ZipEncodingHelper.class
ZipEncodingHelper$SimpleEncodingHolder.class
ZipEntry.class
ZipExtraField.class
ZipFile.class
ZipFile$1.class
ZipFile$BoundedInputStream.class
ZipFile$NameAndComment.class
ZipFile$OffsetEntry.class
ZipLong.class
ZipOutputStream.class
ZipOutputStream$UnicodeExtraFieldPolicy.class
ZipShort.class

(end)

Документация:
- API documentation ( <http:apache-ant-1.8.0/docs/manual/api/org/apache/tools/zip/package-summary.html>);
