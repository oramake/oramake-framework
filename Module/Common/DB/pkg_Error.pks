create or replace package pkg_Error is
/* package: pkg_Error
  ���� ������ ( ������ Common).
*/

/* group: ����������� ���� ������ */

/* const: SessionMarkedForKill
  ��� ������ "ORA-00031 session marked for kill"
*/
SessionMarkedForKill constant integer := -31;

/* const: ResourceBusyNowait
  ��� ������ "ORA-00054: resource busy and acquire with NOWAIT specified"
*/
ResourceBusyNowait constant integer := -54;

/* const: ParentKeyNotFound
  ��� ������ "ORA-02291: integrity constraint (...) violated - parent key not found"
*/
ParentKeyNotFound constant integer := -2291;

/* const: LookupRemoteObjectError
  ��� ������ "ORA-04052 error occurred when looking up remote object ..."
*/
LookupRemoteObjectError constant integer := -4052;

/* const: ObjectStateInvalidated
  ��� ������ "ORA-04061 existing state of string has been invalidated" (��� ��������� ���������� �������)
*/
ObjectStateInvalidated constant integer := -4061;

/* const: ObjectChanged
  ��� ������ "ORA-04062: string of string has been changed" (��� ��������� ���������� �������)
*/
ObjectChanged constant integer := -4062;

/* const: PackageStateDiscarded
  ��� ������ "ORA-04068: existing state of packages has been discarded"
*/
PackageStateDiscarded constant integer := -4068;

/* const: NotFoundProgramUnit
  ��� ������ "ORA-06508 PL/SQL: could not find program unit being called"
*/
NotFoundProgramUnit constant integer := -6508;

/* const: NoDataFound
  ��� ������ "ORA-00100 no data found"
*/
NoDataFound constant integer := 100;

/* group: ����������� ���������� */

/* const: UniqueKey
  �������� ����������� ������������
  ( ORA-00001).
*/
UniqueKey exception;
pragma exception_init( UniqueKey, -1);

/* const: TooBigValueForInsert
  �������� �������� ������� ������ ��� �������
  ( ORA-01401).
*/
TooBigValueForInsert exception;
pragma exception_init( TooBigValueForInsert, -1401);

/* const: SeriosError
  Serios error
  ( ORA-02068).
*/
SeriosError exception;
pragma exception_init( SeriosError, -2068);

/* const: EndOfSignal
  End of signal
  ( ORA-03113).
*/
EndOfSignal exception;
pragma exception_init( EndOfSignal, -3113);

/* const: FormatError
  ������������ ������ ����� ��� ��������
  ( ORA-06502).
*/
FormatError exception;
pragma exception_init( FormatError, -6502);

/* const: GeneralCompilation
  General compilation
  ( ORA-06512).
*/
GeneralCompilation exception;
pragma exception_init( GeneralCompilation, -6512);

/* const: TypeMismatchAnyData
  �������������� ���� ��� ���������� OCIAnyData ��� ������� � ����
  ( ORA-22626).
*/
TypeMismatchAnyData exception;
pragma exception_init( TypeMismatchAnyData, -22626);

/* group: ���������������� ���� ������ */

/* const: RowNotFound
  ������ �� �������
*/
RowNotFound constant pls_integer := -20010;

/* const: TooManyRows
  ������� ������� ����� �����
*/
TooManyRows constant pls_integer := -20011;

/* const: OperatorNotRegister
  �������� �� ����������������� � �������
*/
OperatorNotRegister constant pls_integer := -20012;

/* const: RigthisMissed
  ������������ ���� ��� �������������� ���������� ����������
*/
RigthisMissed constant pls_integer := -20013;

/* const: Empty
*/
Empty constant pls_integer := -20014;

/* const: FormatErrorConstant
  ������������ ������ ����� ��� ��������
*/
FormatErrorConstant constant pls_integer := -20015;

/* const: TooBigValue
  �������� ������� ������
*/
TooBigValue constant pls_integer := -20016;

/* const: FieldNotNull
  ���� �� ������
*/
FieldNotNull constant pls_integer := -20017;

/* const: UnknownMode
*/
UnknownMode constant pls_integer := -20018;

/* const: MailSendingError
  ������ ��� �������� ������.
*/
MailSendingError constant pls_integer := -20019;

/* const: Deleted
  ������ ������
*/
Deleted constant pls_integer := -20020;

/* const: Invalid
  ������ ������������
*/
Invalid constant pls_integer := -20021;

/* const: TypeMismatch
  �������������� �����
*/
TypeMismatch constant pls_integer := -20022;

/* const: WrongPasswordLength
  �������� ����� ������
*/
WrongPasswordLength constant pls_integer := -20023;

/* const: DtsError
  ������ ��� ������� MSDTS
*/
DtsError constant pls_integer := -20024;

/* const: InvalidCodind
  �������� ���������
*/
InvalidCodind constant integer := -20025;

/* const: InputDocumentTypeNotFound
  �� ������� ���������� ��� �������� ���������.
*/
InputDocumentTypeNotFound constant pls_integer := -20100;

/* const: InputDocumentHandlerNotFound
  �� ������� ����� ���������� �������� ���������.
*/
InputDocumentHandlerNotFound constant pls_integer := -20105;

/* const: DocSelStatNotSupportedMode
  ��������� GetDocSelectStatement �� ������������ ��������� �����.
*/
DocSelStatNotSupportedMode constant pls_integer := -20110;

/* const: DocSelStatTooMachOrderByColumn
  ������� ������� ������� ���������� �������� ��� ����������.
*/
DocSelStatTooMachOrderByColumn constant pls_integer := -20115;

/* const: OutputDocumentTemplateNotFound
  �� ������� ����� ������ ���������� ���������.
*/
OutputDocumentTemplateNotFound constant pls_integer := -20120;

/* const: OutputDocumentHandlerNotFound
  �� ������� ����� ���������� ���������� ���������.
*/
OutputDocumentHandlerNotFound constant pls_integer := -20125;

/* const: CreateDocumentTemplateNotFound
  �� ������� ����� ������ ��������� ���������.
*/
CreateDocumentTemplateNotFound constant pls_integer := -20130;

/* const: CreateDocumentHandlerNotFound
  �� ������� ����� ���������� �������� ���������.
*/
CreateDocumentHandlerNotFound constant pls_integer := -20135;

/* const: BatchNotFound
  �� ������ ����� ������� ��� ����������
*/
BatchNotFound constant pls_integer := -20140;

/* const: ExecJobInterrupted
  ���������� ������� ���� �������� ��-�� ������
*/
ExecJobInterrupted constant pls_integer := -20145;

/* const: ErrorInfo
  �������������� ���������� �� ������
*/
ErrorInfo constant integer := -20150;

/* const: ErrorStackInfo
  ���������� � ����� ������������� ����������
*/
ErrorStackInfo constant integer := -20150;

/* const: VariableAlreadyExist
  ���������� ��� ���������� � �� ����� ���� ��������
*/
VariableAlreadyExist constant integer := -20155;

/* const: VariableNotDefined
  ���������� �� ����������
*/
VariableNotDefined constant integer := -20160;

/* const: ScheduleNotSet
  �� ������ ���������� ������� ������
*/
ScheduleNotSet constant integer := -20165;

/* const: InvalidExitValue
  ���������� ������� ����������� � ������������ �������� ���������.
*/
InvalidExitValue constant integer := -20170;

/* const: FileAlreadyExists
  ���� ��� ����������
*/
FileAlreadyExists constant integer := -20175;

/* const: FileNotFound
  ���� �� ������
*/
FileNotFound constant integer := -20180;

/* const: ProcessError
  ������ ��� ��������� �������
*/
ProcessError constant integer := -20185;

/* const: ProcessTimeout
  ������� ����� �������� ��������� �������
*/
ProcessTimeout constant integer := -20190;

/* const: IllegalArgument
  �������� ����������� �������� ���������
*/
IllegalArgument constant integer := -20195;

/* const: PipeError
  ������ ��� ���������� �������� � ������� ����� dbms_pipe
*/
PipeError constant integer := -20200;

/* const: ChangeDeletedObject
  ������� ��������� ������������ ������ �� ���������� �������
*/
ChangeDeletedObject constant integer := -20205;

/* const: ObjectAlreadyExists
  ������ ��� ����������
*/
ObjectAlreadyExists constant integer := -20210;

/* const: UndeletePresentObject
  ������� �������������� ������������ ������ �������, ������� �� ���� �������
*/
UndeletePresentObject constant integer := -20215;

/* const: PartialError
  ����� ������ ���������� � �������
*/
PartialError constant integer := -20220;

/* const: PosNotFound
  ������� �� ������
*/
PosNotFound constant integer := -20225;

/* const: GoodsNotFound
  ����� �� ������
*/
GoodsNotFound constant integer := -20226;

/* const: AccountNotFound
  ���� �� ������
*/
AccountNotFound constant integer := -20227;

/* const: EmployeeNotFound
  ��������� �� ������
*/
EmployeeNotFound constant integer := -20230;

/* const: ForbiddenToOutbound
  The client is marked for excluding from outbound.
*/
ForbiddenToOutbound constant integer := -20235;

/* const: RegionNotFound
  �� ������� ����� ������ � ����������� ��������.
*/
RegionNotFound constant pls_integer := -20240;

/* const: CityNotFound
  �� ������� ����� ����� � ����������� �������.
*/
CityNotFound constant pls_integer := -20245;

/* const: StreetTypeNotFound
  �� ������� ����� ��� ����� � ����������� ����� ����.
*/
StreetTypeNotFound constant pls_integer := -20250;

/* const: ProcessErrors
  ������ ��� ��������� ���������
*/
ProcessErrors constant integer := -20255;

/* const: ProcessDataErrors
  ������ ��� ��������� ��������� ��-�� ���������� ������ � ������������
*/
ProcessDataErrors constant integer := -20260;

/* const: PhoneCodeNotFound
  �� ������ ���������� ��� ���������
*/
PhoneCodeNotFound constant integer := -20265;

/* const: SlaveElementsFound
  ������� ����������� ��������
*/
SlaveElementsFound constant integer := -20270;

/* const: RequestNotFound
  ������ �� ������
*/
RequestNotFound constant integer := -20275;

/* const: UncaughtJavaException
  �������������� ���������� Java
*/
UncaughtJavaException constant integer := -29532;

/* const: WorkspaceAlreadyExists
  ������������� ������� ������� ��� ����������.
*/
WorkspaceAlreadyExists constant integer := -33270;

/* const: WorkspaceNotContainObject
  ������������� ������� ������� �� �������� ��������� ������.
*/
WorkspaceNotContainObject constant integer := -34494;

end pkg_Error;
/
