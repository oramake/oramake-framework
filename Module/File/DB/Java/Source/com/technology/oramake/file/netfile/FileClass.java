package com.technology.oramake.file.netfile;



/** class: FileClass
 * ������ ������ ( ������� ������ ������������� ����������� ��������
 * ������ <NetFileImpl>)
 */
class FileClass {

  /** const: FS
   * ���� �������� �������
   **/
  public static final FileClass FS = new FileClass();

  /** const: FTP
   * ���� ��������� �� FTP
   **/
  public static final FileClass FTP = new FileClass();

  /** const: HTTP
   * ���� ��������� �� HTTP
   **/
  public static final FileClass HTTP = new FileClass();



  /** func: FileClass
   * ����������� ��� �������������� ������������� �������� ��������
   **/
  private FileClass() {
  }



  /** func: getFileClass
   * ���������� ����� �����, ��������������� ���������� ���� ( URL).
   *
   * ���������:
   * path                     - ���� ( ��� URL) � �����
   **/
  public static FileClass getFileClass( String path)
  {
    return
      path.startsWith( "ftp://")
        ? FTP
      : path.startsWith( "http://")
        ? HTTP
      : FS
    ;
  }



  /** func: makeNetFileImpl
   * ������� � ���������� ������ ��� ������ � ������.
   *
   * ���������:
   * path                     - ���� ( ��� URL) � �����
   **/
  public NetFileImpl makeNetFileImpl( String path)
    throws
      IOException
      , FTPException
      , java.sql.SQLException
  {
    return
      this == FS
        ? new FsFile( path)
      : this == FTP
        ?  new FtpFile( path)
      : this == HTTP
        ? new HttpFile( path)
      : null
    ;
  }

}
