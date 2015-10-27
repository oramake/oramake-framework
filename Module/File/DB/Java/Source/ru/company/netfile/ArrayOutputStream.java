package ru.company.netfile;

import java.io.ByteArrayOutputStream;



/** class: ArrayOutputStream
 * Класс для представления массива байтов в виде потока вывода.
 * Расширяет возможности стандартного класса java.io.ByteArrayOutputStream,
 * позволяя устанавливать массив назначения.
 **/
public class ArrayOutputStream extends ByteArrayOutputStream
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



  /** proc: setBuffer
   * Устанавливает массив назначения.
   **/
  public void setBuffer( byte[] buf, int off)
  {
    this.buf = buf;
    this.count = off;
  }

}
