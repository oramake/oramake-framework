package ru.company.netfile;

import com.enterprisedt.net.ftp.FTPFile;



/** class: FtpFileInfo
 * �������� ���������� � �����
 * ( �������� ������ <FileInfo>)
 */
final class FtpFileInfo extends FileInfo
{

  /** var: file_
   * ���������� � �����.
   **/
  private FTPFile file_;



  /** func: FtpFileInfo
   * ������� ����� ������ �� ������ �����.
   */
  public FtpFileInfo( FTPFile file)
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
    return ( ! file_.isDir());
  }



  /** func: isDirectory
   * ���������� ������, ���� ���� �������� ���������.
   **/
  public boolean isDirectory()
  {
    return ( file_.isDir());
  }



  /** func: length
   * ������ ����� � ������.
   **/
  public long length()
  {
    return ( file_.size());
  }



  /** func: lastModified
   * ���� ��������� �����������.
   **/
  public java.util.Date lastModified()
  {
    return ( file_.lastModified());
  }

}
