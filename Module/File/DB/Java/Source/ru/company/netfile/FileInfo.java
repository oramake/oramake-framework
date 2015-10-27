package ru.company.netfile;



/** class: FileInfo
 * Содержит информацию о файле ( абстрактный класс).
 */
abstract public class FileInfo
{

  /** func: name
   * Имя файла.
   **/
  abstract public String name();

  /** func: isFile
   * Возвращает истину, если файл является регулярным файлом.
   **/
  abstract public boolean isFile();

  /** func: isDirectory
   * Возвращает истину, если файл является каталогом.
   **/
  abstract public boolean isDirectory();

  /** func: length
   * Размер файла в байтах.
   **/
  abstract public long length();

  /** func: lastModified
   * Дата последней модификации.
   **/
  abstract public java.util.Date lastModified();

};
