create or replace and compile java source named "OraUtil" as
// title: OraUtil
// Набор вспомогательных классов Java для Oracle.
//

package com.technology.orautil;

import java.io.*;
import java.util.*;
import java.text.*;



/** class: ArrayInputStream
 * Класс для представления массива байтов в виде потока ввода.
 * Расширяет возможности стандартного класса java.io.ByteArrayInputStream,
 * позволяя менять параметры массива-источника.
 **/
class ArrayInputStream extends ByteArrayInputStream
{

  /** func: ArrayInputStream
   * Создает объект и передает параметры конструктору суперкласса.
   **/
  public ArrayInputStream( byte[] buf)
  {
    super( buf);
  }

  /** func: setCount
   * Устанавливает число доступных для чтения элементов массива.
   **/
  public void setCount( int count)
  {
    this.count = count;
  }

  /** func: getBuffer
   * Возвращает текущий массив-источник.
   **/
  public byte[] getBuffer()
  {
    return ( this.buf);
  }

  /** func: setBuffer
   * Устанавливает массив-источник.
   **/
  public void setBuffer( byte[] buf)
  {
    this.buf = buf;
    setCount( buf.length);
  }

}






/** class: WriterOutputStream
 * Класс для конвертации байтового выходного потока в символьный.
 **/
public class WriterOutputStream extends OutputStream
{

  /** ivar: buf_
   * Буферный массив для сохранения конвертированных символов.
   **/
  private char[] buf_;

  /** ivar: arrayInput_
   * Поток для чтения массива байтов.
   **/
  private ArrayInputStream arrayInput_;

  /** ivar: inputReader_
   * Поток для конвертации байтов в символы.
   **/
  private InputStreamReader inputReader_;

  /** ivar: writer_
   * Символьный поток назначения.
   **/
  private Writer writer_;



  /** func: WriterOutputStream
   * Создает байтовый выходной поток в указанного символьного выходного потока.
   **/
  public WriterOutputStream( Writer writer)
  {
    writer_ = writer;
  }



  /** func: write
   * Записывает один байт в поток.
   **/
  public void write( int b)
    throws IOException
  {
    byte[] bytes = new byte[1];
    bytes[ 0] = (byte)b;
    char ch = (new String( bytes)).charAt( 0);
    writer_.write( ch);
  }



  /** func: write( ARRAY)
   * Записывает массив байтов в поток.
   **/
  public void write(byte[] b, int off, int len)
    throws IOException
  {
    if( arrayInput_ == null) {          // Создает потоки для конвертации
      buf_ = new char[ b.length];
      arrayInput_ = new ArrayInputStream( b);
      inputReader_ = new InputStreamReader( arrayInput_);
    }
    else if( arrayInput_.getBuffer() != b)
      arrayInput_.setBuffer( b);
    arrayInput_.reset();                // Устанавливаем параметры источника
    if( off > 0)
      arrayInput_.skip( off);
    arrayInput_.setCount( off + len);
    int toRead = len;
    while( toRead > 0) {                // Конвертируем байты в символы
      int n = inputReader_.read( buf_, 0, buf_.length);
      if( n == -1)
        break;
      writer_.write( buf_, 0, n);       // Записываем символы в выходной поток
      toRead -= n;
    }
    if( toRead != 0) {                  // Проверка, что все символы считаны
      throw new IOException(
          "Bytes not fully converted to chars (lost " + toRead + " chars)"
      );
    }
  }



  /** func: close
   * Закрывает поток и освобождает связанные с ним ресурсы.
   **/
  public void close()
    throws IOException
  {
    if( inputReader_ != null)           // Закрываем вспомогательные потоки
      inputReader_.close();
    if( writer_ != null)                // Закрываем нижележащий поток
      writer_.close();
  }

}




/** class: ArrayOutputStream
 * Класс для представления массива байтов в виде потока вывода.
 * Расширяет возможности стандартного класса java.io.ByteArrayOutputStream,
 * позволяя устанавливать массив назначения.
 **/
class ArrayOutputStream extends ByteArrayOutputStream
{

  /** func: ArrayOutputStream
   * Создает объект без распределения буферного массива.
   **/
  public ArrayOutputStream()
  {
    super( 0);
  }



  /** func: getCount
   * Возвращает число заполненных элементов массива.
   **/
  public int getCount()
  {
    return ( count);
  }



  /** func: getBuffer
   * Возвращает текущий массив назначения.
   **/
  public byte[] getBuffer()
  {
    return ( buf);
  }



  /** func: setBuffer
   * Устанавливает массив назначения.
   **/
  public void setBuffer( byte[] buf, int off)
  {
    this.buf = buf;
    this.count = off;
  }

}




/** class: ReaderInputStream
 * Класс для конвертации символьного входного потока в байтовый.
 */
public class ReaderInputStream extends InputStream
{

  /** ivar: buf_
   * Буферный массив для хранения символов.
   **/
  private char[] buf_;


  /** ivar: arrayOutput_
   * Поток для записи в массив байт.
   **/
  private ArrayOutputStream arrayOutput_;

  /** ivar: outputWriter_
   * Поток для перевода символов в байты.
   **/
  private OutputStreamWriter outputWriter_;

  /** ivar: reader_
   * Символьный поток-источник.
   **/
  private Reader reader_;



  /** func: ReaderInputStream
   * Создает байтовый поток, связанный с указанным символьным потоком.
   **/
  public ReaderInputStream( Reader reader)
  {
    reader_ = reader;
  }



  /** func: read
   * Читает один байт из потока.
   **/
  public int read()
    throws IOException
  {
    int b = reader_.read();             // Читаем символ из источника
    if( b != -1) {                      // Конвертируем в байт
      char[] ch = { (char) b };
      byte[] bytes = ( new String( ch)).getBytes();
      b = bytes[0];
      if( b < 0)                        // Приводим к диапазону [0,255]
        b = ( b & 0x7F) | 0x80 ;
    }
    return ( b);
  }



  /** func: read( ARRAY)
   * Читает несколько байт из потока и сохраняет их в указанный массив.
   **/
  public int read(byte[] b, int off, int len)
    throws IOException
  {
    if( outputWriter_ == null) {        //Создаем потоки для конвертации.
      arrayOutput_ = new ArrayOutputStream();
      outputWriter_ = new OutputStreamWriter( arrayOutput_);
    }
                                        //Распределяем символьный буфер
    if( buf_ == null || buf_.length != b.length) {
      buf_ = new char[ b.length];
    }
    arrayOutput_.setBuffer( b, off);    //Устанавливаем буфер назначения
    int n = reader_.read( buf_, 0, len);//Читаем символы
    if( n != -1) {
      outputWriter_.write( buf_, 0, n);
      outputWriter_.flush();
                                        //Число байт не соответствует символам
      if( arrayOutput_.getCount() != off + n) {
        throw new IOException(
            "Bytes count do not equal character count( "
            + ( arrayOutput_.getCount() - off)
            + " and " + n + ")."
        );
      }
                                        //Копируем данные, если буфер изменился
      byte[] b2 = arrayOutput_.getBuffer();
      if( b2 != b) {
        System.arraycopy( b2, off, b, off, len);
      }
    }
    return ( n);
  }



  /** func: close
   * Закрывает поток.
   **/
  public void close()
    throws IOException
  {
    if( outputWriter_ != null) {
      outputWriter_.close();
    }
    reader_.close();
  }

}


/
