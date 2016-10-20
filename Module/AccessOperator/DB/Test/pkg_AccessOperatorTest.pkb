create or replace package body pkg_AccessOperatorTest is
/* package body: pkg_AccessOperatorTest::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Operator.Module_Name
  , objectName  => 'pkg_AccessOperatorTest'
);



/* group: Функции */

/* func: getTestOperatorId
  Возвращает Id тестового оператора.
  Если тестового оператора не существует, он создается, если существует, то
  выданные ему роли корректируются согласно списку ( если он указан).

  Параметры:
  baseName                    - Уникальное базовое имя оператора
                                ( используется для формирования логина,
                                  по которому затем проверяется наличие
                                  оператора)
  roleSNameList               - Список кратких наименований ролей, которые
                                должны быть выданы оператору
                                ( по умолчанию роли не проверяются)

  Возврат:
  Id оператора
*/
function getTestOperatorId(
  baseName varchar2
  , roleSNameList cmn_string_table_t := null
)
return integer
is

  operatorId integer;

  operatorLogin op_operator.login%type;

  -- Признак создания оператора
  isCreated boolean := false;



  /*
    Создает тестового оператора.
  */
  procedure createOperator
  is
  begin
    insert into
      op_operator
    (
      login
      , operator_name
      , password
      , operator_id_ins
    )
    values
    (
      operatorLogin
      , baseName || ' ( тестовый оператор)'
      , 'ADB831A7FDD83DD1E2A309CE7591DFF8'
      , coalesce( pkg_Operator.getCurrentUserId( isRaiseException => 0), 1)
    )
    returning
      operator_id
    into
      operatorId
    ;
    isCreated := true;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при создании тестового оператора.'
        )
      , true
    );
  end createOperator;



  /*
    Обновляет роли, выданные оператору.
  */
  procedure refreshRole
  is
  begin
    if not isCreated then
      delete
        op_operator_role d
      where
        d.operator_id = operatorId
        and d.role_id not in
          (
          select
            rl.role_id
          from
            table( roleSNameList) t
            , v_op_role rl
          where
            rl.role_short_name = t.column_value
          )
      ;
    end if;
    if roleSNameList.count() > 0 then
      insert into
        op_operator_role
      (
        operator_id
        , role_id
        , operator_id_ins
      )
      select
        a.*
      from
        (
        select
          operatorId as operator_id
          , rl.role_id
          , coalesce( pkg_Operator.getCurrentUserId( isRaiseException => 0), 1)
            as operator_id_ins
        from
          table( roleSNameList) t
          , v_op_role rl
        where
          rl.role_short_name = t.column_value
        ) a
      where
        not exists
          (
          select
            null
          from
            op_operator_role opr
          where
            opr.operator_id = a.operator_id
            and opr.role_id = a.role_id
          )
      ;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка обновлении ролей оператора ('
          || ' operatorId=' || operatorId
          || ').'
        )
      , true
    );
  end refreshRole;



-- getTestOperatorId
begin
  operatorLogin := TestOperator_LoginPrefix || baseName;
  select
    min( t.operator_id)
  into operatorId
  from
    op_operator t
  where
    upper( t.login) = upper( operatorLogin)
  ;
  if operatorId is null then
    createOperator();
  end if;
  if roleSNameList is not null then
    refreshRole();
  end if;
  return operatorId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении Id тестового оператора ('
        || ' baseName="' || baseName || '"'
        || ').'
      )
    , true
  );
end getTestOperatorId;

end pkg_AccessOperatorTest;
/
