package com.technology.oramake.file.netfile;

import java.io.File;
import java.io.IOException;



/** class: FsFileInfo
 * �������� ���������� � �����
 * ( �������� ������ <FileInfo>)
 */
final class FsFileInfo extends FileInfo
{

  /** var: file_
   * ���������� � �����.
   **/
  private File file_;



  /** func: FsFileInfo
   * ������� ����� ������ �� ������ �����.
   */
  public FsFileInfo( File file)
  {
    file_ = file;
  }



  /** func: name
   * ��� �����.
   **/
  public String name()
  {
    return ( file_.getName());
  }



  /** func: isFile
   * ���������� ������, ���� ���� �������� ���������� ������.
   **/
  public boolean isFile()
  {
    return ( file_.isFile());
  }



  /** func: isDirectory
   * ���������� ������, ���� ���� �������� ���������.
   **/
  public boolean isDirectory()
  {
    return ( file_.isDirectory());
  }



  /** func: length
   * ������ ����� � ������.
   **/
  public long length()
  {
    return ( file_.length());
  }



  /** func: lastModified
   * ���� ��������� �����������.
   **/
  public java.util.Date lastModified()
  {
    return ( new java.util.Date( file_.lastModified()));
  }

}
