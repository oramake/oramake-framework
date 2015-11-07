package com.technology.oramake.file.netfile;

import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Reader;



/** class: ReaderInputStream
 * ����� ��� ����������� ����������� �������� ������ � ��������
 * ( �������� ������ java.io.InputStream)
 */
public class ReaderInputStream extends InputStream
{

  /** var: buf_
   * �������� ������ ��� �������� ��������.
   **/
  private char[] buf_;


  /** var: arrayOutput_
   * ����� ��� ������ � ������ ����.
   **/
  private ArrayOutputStream arrayOutput_;

  /** var: outputWriter_
   * ����� ��� �������� �������� � �����.
   **/
  private OutputStreamWriter outputWriter_;

  /** var: reader_
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



  /** proc: read
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



  /** func: read
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



  /** proc: close
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
