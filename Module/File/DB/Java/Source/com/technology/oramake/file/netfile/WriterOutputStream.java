package com.technology.oramake.file.netfile;

import java.io.InputStreamReader;
import java.io.IOException;
import java.io.OutputStream;
import java.io.Writer;



/**
 * ����� ��� ����������� ��������� ��������� ������ � ����������.
 **/
public class WriterOutputStream extends OutputStream
{

  /**
   * �������� ������ ��� ���������� ���������������� ��������.
   **/
  private char[] buf_;

  /**
   * ����� ��� ������ ������� ������.
   **/
  private ArrayInputStream arrayInput_;

  /**
   * ����� ��� ����������� ������ � �������.
   **/
  private InputStreamReader inputReader_;

  /**
   * ���������� ����� ����������.
   **/
  private Writer writer_;



  /**
   * ������� �������� �������� ����� � ���������� ����������� ��������� ������.
   **/
  public WriterOutputStream( Writer writer)
  {
    writer_ = writer;
  }



  /**
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



  /**
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



  /**
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
