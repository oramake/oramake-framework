package ru.company.netfile;



/** class: FileType
 * ����� ��� ������������ �������������� ����� ������
 */
class FileType {

  /** const: FILE
   * ������� ���������� ����
   **/
  public static final FileType FILE       = new FileType();

  /** const: DIRECTORY
   * �������
   **/
  public static final FileType DIRECTORY  = new FileType();

  /** const: UNKNOWN
   * ���� ������������ ����
   **/
  public static final FileType UNKNOWN    = new FileType();



  /** func: FileType
   * ����������� ��� �������������� ������������� �������� ��������
   **/
  private FileType() {
  }

}
