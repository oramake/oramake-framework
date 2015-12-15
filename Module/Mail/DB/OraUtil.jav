create or replace and compile java source named "OraUtil" as
// title: OraUtil
// ����� ��������������� ������� Java ��� Oracle.
//

package com.technology.orautil;

import java.io.*;
import java.util.*;
import java.text.*;



/** class: ArrayInputStream
 * ����� ��� ������������� ������� ������ � ���� ������ �����.
 * ��������� ����������� ������������ ������ java.io.ByteArrayInputStream,
 * �������� ������ ��������� �������-���������.
 **/
class ArrayInputStream extends ByteArrayInputStream
{

  /** func: ArrayInputStream
   * ������� ������ � �������� ��������� ������������ �����������.
   **/
  public ArrayInputStream( byte[] buf)
  {
    super( buf);
  }

  /** func: setCount
   * ������������� ����� ��������� ��� ������ ��������� �������.
   **/
  public void setCount( int count)
  {
    this.count = count;
  }

  /** func: getBuffer
   * ���������� ������� ������-��������.
   **/
  public byte[] getBuffer()
  {
    return ( this.buf);
  }

  /** func: setBuffer
   * ������������� ������-��������.
   **/
  public void setBuffer( byte[] buf)
  {
    this.buf = buf;
    setCount( buf.length);
  }

}






/** class: WriterOutputStream
 * ����� ��� ����������� ��������� ��������� ������ � ����������.
 **/
public class WriterOutputStream extends OutputStream
{

  /** ivar: buf_
   * �������� ������ ��� ���������� ���������������� ��������.
   **/
  private char[] buf_;

  /** ivar: arrayInput_
   * ����� ��� ������ ������� ������.
   **/
  private ArrayInputStream arrayInput_;

  /** ivar: inputReader_
   * ����� ��� ����������� ������ � �������.
   **/
  private InputStreamReader inputReader_;

  /** ivar: writer_
   * ���������� ����� ����������.
   **/
  private Writer writer_;



  /** func: WriterOutputStream
   * ������� �������� �������� ����� � ���������� ����������� ��������� ������.
   **/
  public WriterOutputStream( Writer writer)
  {
    writer_ = writer;
  }



  /** func: write
   * ���������� ���� ���� � �����.
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
   * ���������� ������ ������ � �����.
   **/
  public void write(byte[] b, int off, int len)
    throws IOException
  {
    if( arrayInput_ == null) {          // ������� ������ ��� �����������
      buf_ = new char[ b.length];
      arrayInput_ = new ArrayInputStream( b);
      inputReader_ = new InputStreamReader( arrayInput_);
    }
    else if( arrayInput_.getBuffer() != b)
      arrayInput_.setBuffer( b);
    arrayInput_.reset();                // ������������� ��������� ���������
    if( off > 0)
      arrayInput_.skip( off);
    arrayInput_.setCount( off + len);
    int toRead = len;
    while( toRead > 0) {                // ������������ ����� � �������
      int n = inputReader_.read( buf_, 0, buf_.length);
      if( n == -1)
        break;
      writer_.write( buf_, 0, n);       // ���������� ������� � �������� �����
      toRead -= n;
    }
    if( toRead != 0) {                  // ��������, ��� ��� ������� �������
      throw new IOException(
          "Bytes not fully converted to chars (lost " + toRead + " chars)"
      );
    }
  }



  /** func: close
   * ��������� ����� � ����������� ��������� � ��� �������.
   **/
  public void close()
    throws IOException
  {
    if( inputReader_ != null)           // ��������� ��������������� ������
      inputReader_.close();
    if( writer_ != null)                // ��������� ����������� �����
      writer_.close();
  }

}




/** class: ArrayOutputStream
 * ����� ��� ������������� ������� ������ � ���� ������ ������.
 * ��������� ����������� ������������ ������ java.io.ByteArrayOutputStream,
 * �������� ������������� ������ ����������.
 **/
class ArrayOutputStream extends ByteArrayOutputStream
{

  /** func: ArrayOutputStream
   * ������� ������ ��� ������������� ��������� �������.
   **/
  public ArrayOutputStream()
  {
    super( 0);
  }



  /** func: getCount
   * ���������� ����� ����������� ��������� �������.
   **/
  public int getCount()
  {
    return ( count);
  }



  /** func: getBuffer
   * ���������� ������� ������ ����������.
   **/
  public byte[] getBuffer()
  {
    return ( buf);
  }



  /** func: setBuffer
   * ������������� ������ ����������.
   **/
  public void setBuffer( byte[] buf, int off)
  {
    this.buf = buf;
    this.count = off;
  }

}




/** class: ReaderInputStream
 * ����� ��� ����������� ����������� �������� ������ � ��������.
 */
public class ReaderInputStream extends InputStream
{

  /** ivar: buf_
   * �������� ������ ��� �������� ��������.
   **/
  private char[] buf_;


  /** ivar: arrayOutput_
   * ����� ��� ������ � ������ ����.
   **/
  private ArrayOutputStream arrayOutput_;

  /** ivar: outputWriter_
   * ����� ��� �������� �������� � �����.
   **/
  private OutputStreamWriter outputWriter_;

  /** ivar: reader_
   * ���������� �����-��������.
   **/
  private Reader reader_;



  /** func: ReaderInputStream
   * ������� �������� �����, ��������� � ��������� ���������� �������.
   **/
  public ReaderInputStream( Reader reader)
  {
    reader_ = reader;
  }



  /** func: read
   * ������ ���� ���� �� ������.
   **/
  public int read()
    throws IOException
  {
    int b = reader_.read();             // ������ ������ �� ���������
    if( b != -1) {                      // ������������ � ����
      char[] ch = { (char) b };
      byte[] bytes = ( new String( ch)).getBytes();
      b = bytes[0];
      if( b < 0)                        // �������� � ��������� [0,255]
        b = ( b & 0x7F) | 0x80 ;
    }
    return ( b);
  }



  /** func: read( ARRAY)
   * ������ ��������� ���� �� ������ � ��������� �� � ��������� ������.
   **/
  public int read(byte[] b, int off, int len)
    throws IOException
  {
    if( outputWriter_ == null) {        //������� ������ ��� �����������.
      arrayOutput_ = new ArrayOutputStream();
      outputWriter_ = new OutputStreamWriter( arrayOutput_);
    }
                                        //������������ ���������� �����
    if( buf_ == null || buf_.length != b.length) {
      buf_ = new char[ b.length];
    }
    arrayOutput_.setBuffer( b, off);    //������������� ����� ����������
    int n = reader_.read( buf_, 0, len);//������ �������
    if( n != -1) {
      outputWriter_.write( buf_, 0, n);
      outputWriter_.flush();
                                        //����� ���� �� ������������� ��������
      if( arrayOutput_.getCount() != off + n) {
        throw new IOException(
            "Bytes count do not equal character count( "
            + ( arrayOutput_.getCount() - off)
            + " and " + n + ")."
        );
      }
                                        //�������� ������, ���� ����� ���������
      byte[] b2 = arrayOutput_.getBuffer();
      if( b2 != b) {
        System.arraycopy( b2, off, b, off, len);
      }
    }
    return ( n);
  }



  /** func: close
   * ��������� �����.
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
