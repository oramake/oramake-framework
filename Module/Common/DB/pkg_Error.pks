create or replace package pkg_Error is
/* package: pkg_Error
  Коды ошибок ( модуль Common).
*/

/* group: Стандартные коды ошибок */

/* const: SessionMarkedForKill
  Код ошибки "ORA-00031 session marked for kill"
*/
SessionMarkedForKill constant integer := -31;

/* const: ResourceBusyNowait
  Код ошибки "ORA-00054: resource busy and acquire with NOWAIT specified"
*/
ResourceBusyNowait constant integer := -54;

/* const: ParentKeyNotFound
  Код ошибки "ORA-02291: integrity constraint (...) violated - parent key not found"
*/
ParentKeyNotFound constant integer := -2291;

/* const: LookupRemoteObjectError
  Код ошибки "ORA-04052 error occurred when looking up remote object ..."
*/
LookupRemoteObjectError constant integer := -4052;

/* const: ObjectStateInvalidated
  Код ошибки "ORA-04061 existing state of string has been invalidated" (при изменении удаленного объекта)
*/
ObjectStateInvalidated constant integer := -4061;

/* const: ObjectChanged
  Код ошибки "ORA-04062: string of string has been changed" (при изменении удаленного объекта)
*/
ObjectChanged constant integer := -4062;

/* const: PackageStateDiscarded
  Код ошибки "ORA-04068: existing state of packages has been discarded"
*/
PackageStateDiscarded constant integer := -4068;

/* const: NotFoundProgramUnit
  Код ошибки "ORA-06508 PL/SQL: could not find program unit being called"
*/
NotFoundProgramUnit constant integer := -6508;

/* const: NoDataFound
  Код ошибки "ORA-00100 no data found"
*/
NoDataFound constant integer := 100;

/* group: Стандартные исключения */

/* const: UniqueKey
  Нарушено ограничение уникальности
  ( ORA-00001).
*/
UniqueKey exception;
pragma exception_init( UniqueKey, -1);

/* const: TooBigValueForInsert
  Вносимое значение слишком велико для столбца
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
  Некорректный формат числа или значения
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
  Несоответствие типа при построении OCIAnyData или доступе к нему
  ( ORA-22626).
*/
TypeMismatchAnyData exception;
pragma exception_init( TypeMismatchAnyData, -22626);

/* group: Пользовательские коды ошибок */

/* const: RowNotFound
  Строка не найдена
*/
RowNotFound constant pls_integer := -20010;

/* const: TooManyRows
  Найдено слишком много строк
*/
TooManyRows constant pls_integer := -20011;

/* const: OperatorNotRegister
  Оператор не зарегистрировался в системе
*/
OperatorNotRegister constant pls_integer := -20012;

/* const: RigthisMissed
  Недостаточно прав для редактирования глобальных параметров
*/
RigthisMissed constant pls_integer := -20013;

/* const: Empty
*/
Empty constant pls_integer := -20014;

/* const: FormatErrorConstant
  Некорректный формат числа или значения
*/
FormatErrorConstant constant pls_integer := -20015;

/* const: TooBigValue
  Значение слишком велико
*/
TooBigValue constant pls_integer := -20016;

/* const: FieldNotNull
  Поле не пустое
*/
FieldNotNull constant pls_integer := -20017;

/* const: UnknownMode
*/
UnknownMode constant pls_integer := -20018;

/* const: MailSendingError
  Ошибка при отправке письма.
*/
MailSendingError constant pls_integer := -20019;

/* const: Deleted
  Объект удален
*/
Deleted constant pls_integer := -20020;

/* const: Invalid
  Объект некорректный
*/
Invalid constant pls_integer := -20021;

/* const: TypeMismatch
  Несоответствие типов
*/
TypeMismatch constant pls_integer := -20022;

/* const: WrongPasswordLength
  Неверная длина пароля
*/
WrongPasswordLength constant pls_integer := -20023;

/* const: DtsError
  Ошибка при запуске MSDTS
*/
DtsError constant pls_integer := -20024;

/* const: InvalidCodind
  Неверная кодировка
*/
InvalidCodind constant integer := -20025;

/* const: InputDocumentTypeNotFound
  Не удалось определить тип входного документа.
*/
InputDocumentTypeNotFound constant pls_integer := -20100;

/* const: InputDocumentHandlerNotFound
  Не удалось найти обработчик входного документа.
*/
InputDocumentHandlerNotFound constant pls_integer := -20105;

/* const: DocSelStatNotSupportedMode
  Процедура GetDocSelectStatement не поддерживает указанный режим.
*/
DocSelStatNotSupportedMode constant pls_integer := -20110;

/* const: DocSelStatTooMachOrderByColumn
  Указано слишком большое количество столбцов для сортировки.
*/
DocSelStatTooMachOrderByColumn constant pls_integer := -20115;

/* const: OutputDocumentTemplateNotFound
  Не удалось найти шаблон исходящего документа.
*/
OutputDocumentTemplateNotFound constant pls_integer := -20120;

/* const: OutputDocumentHandlerNotFound
  Не удалось найти обработчик исходящего документа.
*/
OutputDocumentHandlerNotFound constant pls_integer := -20125;

/* const: CreateDocumentTemplateNotFound
  Не удалось найти шаблон исходного документа.
*/
CreateDocumentTemplateNotFound constant pls_integer := -20130;

/* const: CreateDocumentHandlerNotFound
  Не удалось найти обработчик создания документа.
*/
CreateDocumentHandlerNotFound constant pls_integer := -20135;

/* const: BatchNotFound
  Не найден пакет заданий для выполнения
*/
BatchNotFound constant pls_integer := -20140;

/* const: ExecJobInterrupted
  Выполнение заданий было прервано из-за ошибки
*/
ExecJobInterrupted constant pls_integer := -20145;

/* const: ErrorInfo
  Дополнительная информация об ошибке
*/
ErrorInfo constant integer := -20150;

/* const: ErrorStackInfo
  Информация о месте возникновения исключения
*/
ErrorStackInfo constant integer := -20150;

/* const: VariableAlreadyExist
  Переменная уже существует и не может быть изменена
*/
VariableAlreadyExist constant integer := -20155;

/* const: VariableNotDefined
  Переменная не определена
*/
VariableNotDefined constant integer := -20160;

/* const: ScheduleNotSet
  Не задано расписание запуска пакета
*/
ScheduleNotSet constant integer := -20165;

/* const: InvalidExitValue
  Выполнение команды завершилось с некорректным выходным значением.
*/
InvalidExitValue constant integer := -20170;

/* const: FileAlreadyExists
  Файл уже существует
*/
FileAlreadyExists constant integer := -20175;

/* const: FileNotFound
  Файл не найден
*/
FileNotFound constant integer := -20180;

/* const: ProcessError
  Ошибка при обработке запроса
*/
ProcessError constant integer := -20185;

/* const: ProcessTimeout
  Истекло время ожидания обработки запроса
*/
ProcessTimeout constant integer := -20190;

/* const: IllegalArgument
  Передано некорретное значение аргумента
*/
IllegalArgument constant integer := -20195;

/* const: PipeError
  Ошибка при выполнении операции с каналом через dbms_pipe
*/
PipeError constant integer := -20200;

/* const: ChangeDeletedObject
  Попытка изменения исторических данных по удаленному объекту
*/
ChangeDeletedObject constant integer := -20205;

/* const: ObjectAlreadyExists
  Объект уже существует
*/
ObjectAlreadyExists constant integer := -20210;

/* const: UndeletePresentObject
  Попытка восстановления исторических данных объекта, которые не были удалены
*/
UndeletePresentObject constant integer := -20215;

/* const: PartialError
  Часть данных обработана с ошибкой
*/
PartialError constant integer := -20220;

/* const: PosNotFound
  Магазин не найден
*/
PosNotFound constant integer := -20225;

/* const: GoodsNotFound
  Товар не найден
*/
GoodsNotFound constant integer := -20226;

/* const: AccountNotFound
  Счет не найден
*/
AccountNotFound constant integer := -20227;

/* const: EmployeeNotFound
  Сотрудник не найден
*/
EmployeeNotFound constant integer := -20230;

/* const: ForbiddenToOutbound
  The client is marked for excluding from outbound.
*/
ForbiddenToOutbound constant integer := -20235;

/* const: RegionNotFound
  Не удалось найти регион в справочнике регионов.
*/
RegionNotFound constant pls_integer := -20240;

/* const: CityNotFound
  Не удалось найти город в справочнике городов.
*/
CityNotFound constant pls_integer := -20245;

/* const: StreetTypeNotFound
  Не удалось найти тип улицы в справочнике типов улиц.
*/
StreetTypeNotFound constant pls_integer := -20250;

/* const: ProcessErrors
  Ошибки при обработке элементов
*/
ProcessErrors constant integer := -20255;

/* const: ProcessDataErrors
  Ошибки при обработке элементов из-за отсутствия данных в справочниках
*/
ProcessDataErrors constant integer := -20260;

/* const: PhoneCodeNotFound
  Не найден телефонный код местности
*/
PhoneCodeNotFound constant integer := -20265;

/* const: SlaveElementsFound
  Найдены подчиненные элементы
*/
SlaveElementsFound constant integer := -20270;

/* const: RequestNotFound
  Запрос не найден
*/
RequestNotFound constant integer := -20275;

/* const: UncaughtJavaException
  Необработанное исключение Java
*/
UncaughtJavaException constant integer := -29532;

/* const: WorkspaceAlreadyExists
  Аналитическая рабочая область уже существует.
*/
WorkspaceAlreadyExists constant integer := -33270;

/* const: WorkspaceNotContainObject
  Аналитическая рабочая область не содержит указанный объект.
*/
WorkspaceNotContainObject constant integer := -34494;

end pkg_Error;
/
