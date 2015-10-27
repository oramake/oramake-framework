package ru.company.netfile;

import com.enterprisedt.net.ftp.FTPFile;



/** class: FtpFileInfo
 * Содержит информацию о файле
 * ( подкласс класса <FileInfo>)
 */
final class FtpFileInfo extends FileInfo
{

  /** var: file_
   * Информация о файле.
   **/
  private FTPFile file_;



  /** func: FtpFileInfo
   * Создает новый объект на основе файла.
   */
  public FtpFileInfo( FTPFile file)
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
    return ( ! file_.isDir());
  }



  /** func: isDirectory
   * Возвращает истину, если файл является каталогом.
   **/
  public boolean isDirectory()
  {
    return ( file_.isDir());
  }



  /** func: length
   * Размер файла в байтах.
   **/
  public long length()
  {
    return ( file_.size());
  }



  /** func: lastModified
   * Дата последней модификации.
   **/
  public java.util.Date lastModified()
  {
    return ( file_.lastModified());
  }

}
