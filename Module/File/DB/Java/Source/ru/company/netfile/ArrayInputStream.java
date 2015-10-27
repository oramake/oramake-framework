package ru.company.netfile;

import java.io.ByteArrayInputStream;


/** class: ArrayInputStream
 * Класс для представления массива байтов в виде потока ввода.
 * Расширяет возможности стандартного класса java.io.ByteArrayInputStream,
 * позволяя менять параметры массива-источника.
 **/
public class ArrayInputStream extends ByteArrayInputStream
{

  /** func: ArrayInputStream
   * Создает объект и передает параметры конструктору суперкласса.
   **/
  public ArrayInputStream( byte[] buf)
  {
    super( buf);
  }

  /** proc: setCount
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

  /** proc: setBuffer
   * Устанавливает массив-источник.
   **/
  public void setBuffer( byte[] buf)
  {
    this.buf = buf;
    setCount( buf.length);
  }

}
