package ru.company.netfile;

import java.io.ByteArrayInputStream;


/** class: ArrayInputStream
 * ����� ��� ������������� ������� ������ � ���� ������ �����.
 * ��������� ����������� ������������ ������ java.io.ByteArrayInputStream,
 * �������� ������ ��������� �������-���������.
 **/
public class ArrayInputStream extends ByteArrayInputStream
{

  /** func: ArrayInputStream
   * ������� ������ � �������� ��������� ������������ �����������.
   **/
  public ArrayInputStream( byte[] buf)
  {
    super( buf);
  }

  /** proc: setCount
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

  /** proc: setBuffer
   * ������������� ������-��������.
   **/
  public void setBuffer( byte[] buf)
  {
    this.buf = buf;
    setCount( buf.length);
  }

}
