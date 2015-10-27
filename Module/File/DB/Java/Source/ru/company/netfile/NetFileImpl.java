package ru.company.netfile;

import java.io.File;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;

import com.enterprisedt.net.ftp.FTPException;
import com.enterprisedt.net.ftp.FTPOutputStream;
import com.enterprisedt.net.ftp.ssh.SSHFTPOutputStream;



/** class: NetFileImpl
 * ����������� ������� ����� ��� ���������� �������� ��������.
 */
abstract class NetFileImpl
{

  /** func: getPath
   * ���������� ���� �� �����.
   */
  abstract public String getPath()
  ;



  /** func: getName
   * ���������� ��� �����.
   */
  abstract public String getName()
  ;



  /** func: checkState
   * ��������� ���������� � ����� � ��������� ��� ��� ���� null, ���� ���� ��
   * ����������.
   */
  abstract public FileType checkState()
    throws IOException, FTPException
  ;

  /** func: dir
   * ���������� ������ � ����������� � ������ �������� ��� null, ���� ���� ��
   * �������� ��������� ���� �� ����������.
   */
  abstract public FileInfo[] dir()
    throws IOException, FTPException
  ;

  /** func: getInputStream
   * ���������� ����� ��� ������ �� �����
   */
  abstract public InputStream getInputStream()
    throws IOException, FTPException
  ;

  /** func: getOutputStream
   * ���������� ����� ��� ������ � ����
   */
  abstract public OutputStream getOutputStream( boolean append)
    throws IOException, FTPException
  ;

  /** proc: copy
   * �������� ����
   */
  abstract public void copy( String toPath, boolean overwrite)
    throws IOException, FTPException
  ;

  /** proc: delete
   * ������� ����
   */
  abstract public void delete()
    throws IOException, FTPException
  ;

  /** proc: renameTo
   * �������� ��������� �������������� �����.
   *
   * ���������:
   * toPath                   - ����� ���� ( URL) � �����
   * overwrite                - ������� ���������� �����
   *
   * �������:
   * true                     - � ������ ������
   * false                    - � ������ �������
   */
  abstract public boolean renameTo( String toPath, boolean overwrite)
    throws IOException, FTPException
  ;

  /** proc: makeDirectory
   * ������ ����������.
   */
  abstract public void makeDirectory( boolean raiseException)
    throws IOException, FTPException
  ;

} // NetFileImpl
