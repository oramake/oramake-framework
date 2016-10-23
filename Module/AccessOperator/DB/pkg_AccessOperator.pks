create or replace package pkg_AccessOperator is
/* package: pkg_AccessOperator
  Пакет для изменения данных модуля.

  SVN root: Oracle/Module/AccessOperator
*/



/* group: Функции */



/* group: Роли */

/* pfunc: mergeRole
  Добавление или обновление роли.

  Параметры:
  roleShortName               - короткое наименование роли
  roleName                    - наименование роли
  roleNameEn                  - наименование роли на английском
  description                 - описание роли

  Возврат:
  - была ли роль изменена ( добавлена или обновлена);

  ( <body::mergeRole>)
*/
function mergeRole(
  roleShortName varchar2
  , roleName varchar2
  , roleNameEn varchar2
  , description varchar2
)
return integer;



/* group: Пользователи */

/* pfunc: createOperator
  Создание пользователя.

  Входные параметры:
    operatorName                - Наименование пользователя на языке по умолчанию
    operatorNameEn              - Наименование пользователя на английском языке
    login                       - Логин
    password                    - Пароль
    changePassword              - Признак необходимости изменения пароля
                                  пользователем:
                                  1 – пользователю необходимо изменить пароль;
                                  0 – пользователю нет необходимости менять пароль.
    operatorIdIns               - Пользователь, создавший запись
                                  ожидающего привязки к сотруднику
    operatorComment             - коментарий оператора

   Возврат:
     operator_id                - ID созданного оператора

  ( <body::createOperator>)
*/
function createOperator(
  operatorName      varchar2
  , operatorNameEn  varchar2
  , login           varchar2
  , password        varchar2
  , changePassword  integer
  , operatorIdIns   integer
  , operatorComment varchar2 := null
)
return integer;

/* pproc: updateOperator
  Обновление пользователя.

  Входные параметры:
    operatorId                  - ID оператора для изменения
    operatorName                - Наименование пользователя на языке по умолчанию
    operatorNameEn              - Наименование пользователя на английском языке
    login                       - Логин
    password                    - Пароль
    changePassword              - Признак необходимости изменения пароля
                                  пользователем:
                                  1 – пользователю необходимо изменить пароль;
                                  0 – пользователю нет необходимости менять пароль.
    operatorIdIns               - Пользователь, создавший запись
    operatorComment             - коментарий оператора

   Выходные параметры отсутствуют.

  ( <body::updateOperator>)
*/
procedure updateOperator(
  operatorId        integer
  , operatorName    varchar2
  , operatorNameEn  varchar2
  , login           varchar2
  , password        varchar2
  , changePassword  integer
  , operatorIdIns   integer
  , operatorComment varchar2 := null
);

/* pproc: deleteOperator
   Удаление пользователя.

   Входные параметры:
     operatorId          - ИД оператора
     operatorIdIns       - ИД оператора дл проверки прав
     operatorComment     - Комментарии

  Выходные параметры отсутствуют.

  ( <body::deleteOperator>)
*/
procedure deleteOperator(
  operatorId        integer
  , operatorIdIns   integer
  , operatorComment varchar2 := null
);



/* group: Группы оператора */

/* pproc: createOperatorGroup
  Процедура назначения группы оператору.

  Входные параметры:
    operatorId                             - ID оператора
    groupId                                - ID группы
    operatorIdIns                          - ID оператора, выполняющего процедуру

  Выходные параметры отсутствуют.

  ( <body::createOperatorGroup>)
*/
procedure createOperatorGroup(
  operatorId integer
  , groupId integer
  , operatorIdIns integer
);

/* pproc: deleteOperatorGroup
  Процедура удаления группы у оператора.

  Входные параметры:
    operatorID                             - ID оператора
    groupID                                - ID группы
    operatorIDIns                          - ID оператора, выполняющего процедуру

  Выходные параметры отсутствуют.

  ( <body::deleteOperatorGroup>)
*/
procedure deleteOperatorGroup(
  operatorId integer
  , groupId integer
  , operatorIdIns integer
);

end pkg_AccessOperator;
/
