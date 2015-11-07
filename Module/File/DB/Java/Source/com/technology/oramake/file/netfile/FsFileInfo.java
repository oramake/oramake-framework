package com.technology.oramake.file.netfile;

import java.io.File;
import java.io.IOException;



/** class: FsFileInfo
 * Содержит информацию о файле
 * ( подкласс класса <FileInfo>)
 */
final class FsFileInfo extends FileInfo
{

  /** var: file_
   * Информация о файле.
   **/
  private File file_;



  /** func: FsFileInfo
   * Создает новый объект на основе файла.
   */
  public FsFileInfo( File file)
  {
    file_ = file;
  }



  /** func: name
   * Имя файла.
   **/
  public String name()
  {
    return ( file_.getName());
  }



  /** func: isFile
   * Возвращает истину, если файл является регулярным файлом.
   **/
  public boolean isFile()
  {
    return ( file_.isFile());
  }



  /** func: isDirectory
   * Возвращает истину, если файл является каталогом.
   **/
  public boolean isDirectory()
  {
    return ( file_.isDirectory());
  }



  /** func: length
   * Размер файла в байтах.
   **/
  public long length()
  {
    return ( file_.length());
  }



  /** func: lastModified
   * Дата последней модификации.
   **/
  public java.util.Date lastModified()
  {
    return ( new java.util.Date( file_.lastModified()));
  }

}
