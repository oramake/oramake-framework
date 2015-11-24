create or replace package pkg_FileHandlerBase is
/* package: pkg_FileHandlerBase
  ��������� ��� ������ FileHandler

  SVN root: Oracle/Module/FileHandler
*/

/* const: Module_Name
  �������� ������
*/
Module_Name constant varchar2(30) := 'FileHandler';

/* type: tabClob
  ������ clob
*/
type tabClob is table of clob;

/* group: ��������� �������� */

/* iconst: CheckCommand_Timeout
  ������� ����� ���������� ������� ������ ��� ���������
  ( � �������� )
*/
CheckCommand_Timeout integer := 1;

/* iconst: WaitRequest_Timeout
  ������� ����� ���������� ��������� �������
  ( � �������� )
*/
WaitRequest_Timeout integer := 0.4;

/* group: ��������� �������� */

/* const: Wait_RequestStateCode
  ��� ��������� "�������� ���������"
*/
Wait_RequestStateCode constant varchar2(10) := 'WAIT';

/* const: Error_RequestStateCode
  ��� ��������� "������ ���������"
*/
Error_RequestStateCode constant varchar2(10) := 'ERROR';

/* const: Processed_RequestStateCode
  ��� ��������� "������� ���������"
*/
Processed_RequestStateCode constant varchar2(10) := 'PROCESSED';

/* group: ���� �������� */

/* const: FileList_OperationCode
  ��� �������� "��������� ������ ������"
*/
FileList_OperationCode constant varchar2(10) := 'LIST';

/* const: FileList_OperationCode
  ��� �������� "��������� ������ ������������"
*/
DirList_OperationCode constant varchar2(10) := 'DIRLIST';

/* const: Copy_OperationCode
  ��� �������� "����������� �����"
*/
Copy_OperationCode constant varchar2(10) := 'COPY';

/* const: Delete_OperationCode
  ��� �������� "�������� �����"
*/
Delete_OperationCode constant varchar2(10) := 'DELETE';

/* const: LoadText_OperationCode
  ��� �������� "�������� ���������� �����"
*/
LoadText_OperationCode constant varchar2(10) := 'LOADTEXT';

/* const: LoadBinary_OperationCode
  ��� �������� "�������� ��������� �����"
*/
LoadBinary_OperationCode constant varchar2(10) := 'LOADBINARY';

/* const: UnloadText_OperationCode
  ��� �������� "�������� ���������� �����"
*/
UnloadText_OperationCode constant varchar2(10) := 'UNLOADTEXT';

/* const: Command_OperationCode
  ��� �������� "���������� ������� ������������ �������"
*/
Command_OperationCode constant varchar2(10) := 'COMMAND';

/* group: ���� ������ ������ �� cache*/

/* const: FileCacheNotExists_ErrorCode
  ���� ������� ��� ��������������
*/
FileCacheNotExists_ErrorCode constant integer := 20100;

/* const: FileCacheNotFound_ErrorCode
  ���� �� ������
*/
FileCacheNotFound_ErrorCode constant integer := 20101;

/* const: FileCacheNoData_ErrorCode
  ������ ����� �� ��������� � cache
*/
FileCacheNoData_ErrorCode constant integer := 20102;

end pkg_FileHandlerBase;
/