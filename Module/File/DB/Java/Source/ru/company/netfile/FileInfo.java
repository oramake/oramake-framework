package ru.company.netfile;



/** class: FileInfo
 * �������� ���������� � ����� ( ����������� �����).
 */
abstract public class FileInfo
{

  /** func: name
   * ��� �����.
   **/
  abstract public String name();

  /** func: isFile
   * ���������� ������, ���� ���� �������� ���������� ������.
   **/
  abstract public boolean isFile();

  /** func: isDirectory
   * ���������� ������, ���� ���� �������� ���������.
   **/
  abstract public boolean isDirectory();

  /** func: length
   * ������ ����� � ������.
   **/
  abstract public long length();

  /** func: lastModified
   * ���� ��������� �����������.
   **/
  abstract public java.util.Date lastModified();

};
