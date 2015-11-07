package com.technology.oramake.file.netfile;

import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Reader;



/** class: ReaderInputStream
 * Класс для конвертации символьного входного потока в байтовый
 * ( подкласс класса java.io.InputStream)
 */
public class ReaderInputStream extends InputStream
{

  /** var: buf_
   * Буферный массив для хранения символов.
   **/
  private char[] buf_;


  /** var: arrayOutput_
   * Поток для записи в массив байт.
   **/
  private ArrayOutputStream arrayOutput_;

  /** var: outputWriter_
   * Поток для перевода символов в байты.
   **/
  private OutputStreamWriter outputWriter_;

  /** var: reader_
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



  /** proc: read
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



  /** func: read
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



  /** proc: close
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
