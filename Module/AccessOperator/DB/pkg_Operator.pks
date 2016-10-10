create or replace package pkg_Operator is
/* package: pkg_Operator
  Интерфейсный пакет модуля Operator.

  SVN root: Oracle/Module/AccessOperator
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'AccessOperator';

/* const: FullAccess_GroupId
  Id группы "Полный доступ".
*/
FullAccess_GroupId constant integer := 1;



/* group: Функции */

/* pfunc: login
  Регистрирует оператора в базе. Устаревшая функция. Использовать процедуру
  <login(password)>. Оставлена для обратной совместимости.

  Параметры:
  operatorLogin               - логин оператора
  password                    - пароль оператора

  Возврат:
  - логин оператора

  ( <body::login>)
*/
function login(
  operatorLogin varchar2
  , password varchar2 := null
)
return varchar2;

/* pproc: login
  Регистрирует оператора в базе ( без проверки пароля).

  Параметры:
  operatorLogin               - логин оператора

  ( <body::login>)
*/
procedure login(
  operatorLogin varchar2
);

/* pproc: login(password)
  Регистрирует оператора в базе.

  Параметры:
  operatorLogin               - логин оператора
  password                    - пароль оператора

  ( <body::login(password)>)
*/
procedure login(
  operatorLogin varchar2
  , password varchar2
);

/* pproc: setCurrentUserId
  Регистрирует оператора в базе ( без проверки пароля).

  Параметры:
  operatorId                  - Id оператора;

  ( <body::setCurrentUserId>)
*/
procedure setCurrentUserId( operatorId integer);

/* pproc: remoteLogin
  Регистрирует текущего оператора в удаленной БД.

  Параметры:
  dbLink                      - имя линка к удаленной БД;

  ( <body::remoteLogin>)
*/
procedure remoteLogin(
  dbLink varchar2
);

/* pproc: logoff
  Отменяет текущую регистрацию;

  ( <body::logoff>)
*/
procedure logoff;

/* pfunc: getCurrentUserId
  Возвращает идентификатор текущего оператора.

  Входные параметры:
  isRaiseException            - флаг выбрасывания исключения в случае, если
                                текущий оператор не определен

  Возврат:
  oprator_id                  - идентификатор текущего оператора

  ( <body::getCurrentUserId>)
*/
function getCurrentUserId(
  isRaiseException integer default null
)
return integer;

/* pfunc: getCurrentUserName
  Возвращает имя текущего оператора.

  Входные параметры:
  isRaiseException            - флаг выставления исключения в случае, если
                                текущий оператор не определен;

  Возврат:
  - имя текущего оператора;

  ( <body::getCurrentUserName>)
*/
function getCurrentUserName(
  isRaiseException integer default 1
)
return varchar2;

/* pfunc: getOperator
  Получение данных по операторам. В настоящее время *не реализовано* (
  является заглушкой для других модулей).

  Параметры:
  operatorName                - ФИО оператора
                                ( поиск по like без учета регистра)
                                ( по умолчанию без ограничений)
  maxRowCount                 - максимальное число возвращаемых поиском записей
                                ( по умолчанию без ограничений)

  Возврат ( курсор):
  operator_id                 - Id оператора
  operator_name               - ФИО оператора

  ( <body::getOperator>)
*/
function getOperator(
  operatorName varchar2 := null
  , maxRowCount integer := null
)
return sys_refcursor;

/* pfunc: isRole(operatorId)
  Проверяет наличие роли у оператора.

  Параметры:

  operatorId                  - id оператора
  roleShortName               - короткое наименование роли

  Возвращаемые значения:
  1 - роль установлена;
  0 - роль не установлена;

  ( <body::isRole(operatorId)>)
*/
function isRole(
  operatorId integer
  , roleShortName varchar2
)
return integer;

/* pfunc: isRole
  Проверяет наличие роли у текущего оператора.

  Параметры:
  roleShortName               - имя роли;

  Возвращаемые значения:
  1 - роль установлена;
  0 - роль не установлена;

  ( <body::isRole>)
*/
function isRole(
  roleShortName varchar2
)
return integer;

/* pproc: isRole(operatorId)
  Проверяет наличие роли у оператора и в случае ее отсутствия выбрасывает
  исключение.

  Параметр:

  operatorId                  - id оператора;
  roleShortName               - имя роли;

  ( <body::isRole(operatorId)>)
*/
procedure isRole(
  operatorId integer
  , roleShortName varchar2
);

/* pproc: isRole
  Проверяет наличие роли у текущего оператора и в случае отсутствия
  регистрации или роли выбрасывает исключение.

  Параметр:
  roleShortName               - имя роли

  ( <body::isRole>)
*/
procedure isRole(
  roleShortName varchar2
);

end pkg_Operator;
/
