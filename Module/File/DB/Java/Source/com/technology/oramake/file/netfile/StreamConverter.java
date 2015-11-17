package com.technology.oramake.file.netfile;


import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.Writer;
import java.sql.*;
import com.technology.oramake.file.netfile.ReaderInputStream;
import com.technology.oramake.file.netfile.WriterOutputStream;


/** class: StreamConverter
 * Предоставляет набор утилит для конвертации потоков.
 */
public class StreamConverter {

/** const: BUFFER_SIZE
 * Размер буфера для записи в поток
 **/
final private static int BUFFER_SIZE = 1024 * 64;

/** func: logTrace
 * Добавляет отладочную запись в лог выполнения.
 *
 * Параметры:
 * messageText                - текст сообщения
 **/
public static void logTrace( java.lang.String messageText)
  throws
    SQLException
{
  #sql {
    declare
      lg lg_logger_t := lg_logger_t.GetLogger( 'File.StreamConverter.java');
    begin
      lg.trace( :messageText);
    end;
  };
}

/** func: binaryToBinary
 * Выгружает двоичные данные из входного потока в выходной.
 *
 * outputStream               - выходной поток
 * inputStream                - входной поток
 */
public static void binaryToBinary(
  OutputStream outputStream
  , InputStream inputStream
)
throws
  java.io.IOException
{
  byte buffer[] = new byte[ BUFFER_SIZE];
  int count = 0;
  BufferedOutputStream bufferedOutputStream = new BufferedOutputStream( outputStream, BUFFER_SIZE);
  BufferedInputStream bufferedInputStream = new BufferedInputStream( inputStream, BUFFER_SIZE);
  while ( ( count = bufferedInputStream.read( buffer, 0, buffer.length)) != - 1) {
    bufferedOutputStream.write( buffer, 0, count);
  }
  bufferedOutputStream.flush();
}

/** func: binaryToChar
 * Преобразует двоичные данные в текстовые.
 *
 * writer                     - выходной поток
 * inputStream                - входной поток
 * charEncoding               - символьная кодировка ( по-умолчанию кодировка БД)
 */
public static void binaryToChar(
  Writer writer
  , InputStream inputStream
  , String charEncoding
)
throws
  java.io.IOException
  , java.io.UnsupportedEncodingException
{
  if ( charEncoding == null ) {
    OutputStream outputStream = new WriterOutputStream( writer);
    binaryToBinary( outputStream, inputStream);
  } else {
    Reader reader = new InputStreamReader( inputStream, charEncoding);
    char buffer[] = new char[ BUFFER_SIZE];
    int count = 0;
    BufferedWriter bufferedWriter = new BufferedWriter( writer, BUFFER_SIZE);
    BufferedReader bufferedReader = new BufferedReader( reader, BUFFER_SIZE);
    while( ( count = bufferedReader.read( buffer, 0, buffer.length)) != - 1) {
      bufferedWriter.write( buffer, 0, count);
    }
    bufferedWriter.flush();
  }
}

/** func: charToBinary
 * Преобразует символьные данные в текстовые.
 *
 * reader                     - входной поток
 * outputStream               - выходной поток
 * charEncoding               - символьная кодировка ( по-умолчанию кодировка БД)
 */
public static void charToBinary(
  OutputStream outputStream
  , Reader reader
  , String charEncoding
)
throws
  java.io.IOException
  , java.io.UnsupportedEncodingException
  , java.sql.SQLException
{
  if ( charEncoding == null ) {
    InputStream inputStream = new ReaderInputStream( reader);
    binaryToBinary( outputStream, inputStream);
  } else {
    Writer writer = new OutputStreamWriter( outputStream, charEncoding);
    BufferedWriter bufferedWriter = new BufferedWriter( writer, BUFFER_SIZE);
    BufferedReader bufferedReader = new BufferedReader( reader, BUFFER_SIZE);
    char buffer[] = new char[ BUFFER_SIZE];
    int count = 0;
    while( ( count = bufferedReader.read( buffer, 0, buffer.length)) != - 1) {
      bufferedWriter.write( buffer, 0, count);
    }
    bufferedWriter.flush();
  }
}

}
