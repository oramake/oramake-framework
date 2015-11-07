package com.technology.oramake.file.netfile;

import java.io.InputStreamReader;
import java.io.IOException;
import java.io.OutputStream;
import java.io.Writer;



/**
 * Класс для конвертации байтового выходного потока в символьный.
 **/
public class WriterOutputStream extends OutputStream
{

  /**
   * Буферный массив для сохранения конвертированных символов.
   **/
  private char[] buf_;

  /**
   * Поток для чтения массива байтов.
   **/
  private ArrayInputStream arrayInput_;

  /**
   * Поток для конвертации байтов в символы.
   **/
  private InputStreamReader inputReader_;

  /**
   * Символьный поток назначения.
   **/
  private Writer writer_;



  /**
   * Создает байтовый выходной поток в указанного символьного выходного потока.
   **/
  public WriterOutputStream( Writer writer)
  {
    writer_ = writer;
  }



  /**
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



  /**
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



  /**
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
