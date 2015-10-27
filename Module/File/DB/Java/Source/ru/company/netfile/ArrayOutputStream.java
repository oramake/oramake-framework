package ru.company.netfile;

import java.io.ByteArrayOutputStream;



/** class: ArrayOutputStream
 * ����� ��� ������������� ������� ������ � ���� ������ ������.
 * ��������� ����������� ������������ ������ java.io.ByteArrayOutputStream,
 * �������� ������������� ������ ����������.
 **/
public class ArrayOutputStream extends ByteArrayOutputStream
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



  /** proc: setBuffer
   * ������������� ������ ����������.
   **/
  public void setBuffer( byte[] buf, int off)
  {
    this.buf = buf;
    this.count = off;
  }

}
