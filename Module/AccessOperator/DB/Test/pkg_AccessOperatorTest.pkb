create or replace package body pkg_AccessOperatorTest is
/* package body: pkg_AccessOperatorTest::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Operator.Module_Name
  , objectName  => 'pkg_AccessOperatorTest'
);



/* group: ������� */

/* func: getTestOperatorId
  ���������� Id ��������� ���������.
  ���� ��������� ��������� �� ����������, �� ���������, ���� ����������, ��
  �������� ��� ���� �������������� �������� ������ ( ���� �� ������).

  ���������:
  login                       - ����� ��������� ( ��� ������� ������������
                                � �������� ������)
  baseName                    - ���������� ������� ��� ���������
                                ( ������������ ��� ������������ ������,
                                  �� �������� ����� ����������� �������
                                  ���������). ����� ���� ����� ����
                                login ���� baseName.
  roleSNameList               - ������ ������� ������������ �����, �������
                                ������ ���� ������ ���������
                                ( �� ��������� ���� �� �����������)

  �������:
  Id ���������
*/
function getTestOperatorId(
  baseName        varchar2           := null
  , login         varchar2           := null
  , roleSNameList cmn_string_table_t := null
)
return integer
is

  operatorId integer;

  operatorLogin op_operator.login%type;

  -- ������� �������� ���������
  isCreated boolean := false;



  /*
    ������� ��������� ���������.
  */
  procedure createOperator
  is
  begin

    -- ���������� operatorId, �.�. � public-����� �� ������������� ���������
    -- ������ � ��� �������������������
    select
      max( t.operator_id)
    into operatorId
    from
      op_operator t
    ;
    operatorId := greatest( coalesce( operatorId, 0), 1000000) + 1;

    insert into
      op_operator
    (
      operator_id
      , login
      , operator_name
      , password
      , operator_id_ins
    )
    values
    (
      operatorId
      , operatorLogin
      , coalesce( login, baseName) || ' ( �������� ��������)'
      , case when
          login is null
        then
          'ADB831A7FDD83DD1E2A309CE7591DFF8'
        else
          pkg_Operator.getHash( login)
        end
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
          '������ ��� �������� ��������� ���������.'
        )
      , true
    );
  end createOperator;



  /*
    ��������� ����, �������� ���������.
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
          '������ ���������� ����� ��������� ('
          || ' operatorId=' || operatorId
          || ').'
        )
      , true
    );
  end refreshRole;



-- getTestOperatorId
begin
  if baseName is not null and login is not null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'baseName � login �� ����� ���� ������ ������������'
    );
  end if;
  operatorLogin := coalesce( login, TestOperator_LoginPrefix || baseName);
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
        '������ ��� ��������� Id ��������� ��������� ('
        || ' baseName="' || baseName || '"'
        || ').'
      )
    , true
  );
end getTestOperatorId;

/* pfunc: isUserAdmin
  ����������:
    1 � ������ ������ <pkg_Operator.isUserAdmin>
    0 � ������ ���������� � <pkg_Operator.isUserAdmin>

  ���������:
    ..
    [������ ���������� <pkg_Operator.isUserAdmin>]
    ..

  �������:
    1 � ������ ������ <pkg_Operator.isUserAdmin>
    0 � ������ ���������� � <pkg_Operator.isUserAdmin>

  ( <body::getTestOperatorId>)
*/
function isUserAdmin(
 OPERATORID INTEGER
 , TARGETOPERATORID INTEGER := null
 , ROLEID INTEGER := null
 , GROUPID INTEGER := null
)
return integer
is
-- isUserAdmin
begin
  pkg_operator.isUserAdmin(
    OPERATORID => OPERATORID
    , TARGETOPERATORID => TARGETOPERATORID
    , ROLEID => ROLEID
    , GROUPID => GROUPID
   );
   return 1;
exception when others then 
  return 0;
end isUserAdmin;


end pkg_AccessOperatorTest;
/
