create or replace package body pkg_AccessOperator is
/* package body: pkg_AccessOperator::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Operator.Module_Name
  , objectName  => 'pkg_AccessOperator'
);



/* group: ������� */



/* group: ���� */

/* func: mergeRole
  ���������� ��� ���������� ����.

  ���������:
  roleShortName               - �������� ������������ ����
  roleName                    - ������������ ����
  roleNameEn                  - ������������ ���� �� ����������
  description                 - �������� ����

  �������:
  - ���� �� ���� �������� ( ��������� ��� ���������);
*/
function mergeRole(
  roleShortName varchar2
  , roleName varchar2
  , roleNameEn varchar2
  , description varchar2
)
return integer
is

  -- ���������� ��������� �������
  changed integer;

-- mergeRole
begin
  merge into
    v_op_role r
  using
  (
  select
    roleShortName as role_short_name
    , roleName as role_name
    , roleNameEn as role_name_en
    , description as description
  from
    dual
  minus
  select
    role_short_name
    , role_name
    , role_name_en
    , description
  from
    v_op_role
  ) s
  on (
    s.role_short_name = r.role_short_name
  )
  when not matched then insert (
    role_short_name
    , role_name
    , role_name_en
    , description
  )
  values (
    s.role_short_name
    , s.role_name
    , s.role_name_en
    , s.description
  )
  when matched then update set
    r.role_name       = s.role_name
    , r.role_name_en  = s.role_name_en
    , r.description   = s.description
  ;
  changed := sql%rowcount;
  return
    changed
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ���������� ��� ���������� ���� ('
        || 'roleShortName="' || roleShortName || '"'
        || ', roleName="' || roleName || '"'
        || ', roleNameEn="' || roleNameEn || '"'
        || ')'
      )
    , true
  );
end mergeRole;



/* group: ������������ */

/* func: createOperator
  �������� ������������.

  ������� ���������:
    operatorName                - ������������ ������������ �� ����� �� ���������
    operatorNameEn              - ������������ ������������ �� ���������� �����
    login                       - �����
    password                    - ������
    operatorIdIns               - ������������, ��������� ������
                                  ���������� �������� � ����������
    operatorComment             - ����������� ���������

   �������:
     operator_id                - ID ���������� ���������
*/
function createOperator(
  operatorName      varchar2
  , operatorNameEn  varchar2
  , login           varchar2
  , password        varchar2
  , operatorIdIns   integer
  , operatorComment varchar2 := null
)
return integer
is
  operatorId integer;

-- createOperator
begin
  -- TODO: �������� ����������� ���������� ���������
  insert into op_operator(
    login
    , operator_name
    , operator_name_en
    , password
    , date_begin
    , operator_id_ins
    , operator_comment
  )
  values(
    login
    , operatorName
    , operatorNameEn
    , pkg_Operator.getHash( password)
    , sysdate
    , operatorIdIns
    , operatorComment
  )
  returning
    operator_id
  into
    operatorId
  ;
  return operatorId;
exception
  when dup_val_on_index then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '�������� � ����� ������� ��� ���������� ('
          || ' login="' || login || '"'
          || ').'
        )
      , true
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '��� �������� ��������� �������� ������ ('
          || 'operatorName="' || operatorName || '"'
          || ', operatorNameEn="' || operatorNameEn || '"'
          || ', login="' || login || '"'
          || ', password="' || password || '"'
          || ', operatorIdIns="' || operatorIdIns || '"'
          || ').'
        )
      , true
    );
end createOperator;

/* proc: updateOperator
  ���������� ������������.

  ������� ���������:
    operatorId                  - ID ��������� ��� ���������
    operatorName                - ������������ ������������ �� ����� �� ���������
    operatorNameEn              - ������������ ������������ �� ���������� �����
    login                       - �����
    password                    - ������
    operatorIdIns               - ������������, ��������� ������
    operatorComment             - ����������� ���������

   �������� ��������� �����������.
*/
procedure updateOperator(
  operatorId        integer
  , operatorName    varchar2
  , operatorNameEn  varchar2
  , login           varchar2
  , password        varchar2
  , operatorIdIns   integer
  , operatorComment varchar2 := null
)
is
-- updateOperator
begin
  -- TODO: �������� ����������� ���������� ���������
  update
    op_operator t
  set
    t.operator_name        = operatorName
    , t.operator_name_en   = operatorNameEn
    , t.login              = updateOperator.login
    , t.operator_comment   = operatorComment
  where
    t.operator_id = operatorId
  ;
exception
  when dup_val_on_index then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '�������� � ����� ������� ��� ���������� ('
          || ' login="' || login || '"'
          || ').'
        )
      , true
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '��� ��������� ������ ��������� ��������� ������ ('
          || 'operatorId="' || to_char( operatorId ) || '"'
          || ').'
        )
      , true
    );
end updateOperator;

/* proc: deleteOperator
   �������� ������������.

   ������� ���������:
     operatorId          - �� ���������
     operatorIdIns       - �� ��������� �� �������� ����
     operatorComment     - �����������

  �������� ��������� �����������.
*/
procedure deleteOperator(
  operatorId        integer
  , operatorIdIns   integer
  , operatorComment varchar2 := null
)
is
-- deleteOperator
begin
  -- TODO: �������� ����������� �������� ���������
  update
    op_operator t
  set
    t.date_finish        = sysdate
    , t.operator_comment = operatorComment
  where
    t.operator_id = operatorId
  ;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '��� �������� ��������� �������� ������ ('
          || ' operator_id="' || to_char(operatorID) || '"'
          || ').'
        )
      , true
    );
end deleteOperator;



/* group: ������ ��������� */

/* proc: createOperatorGroup
  ��������� ���������� ������ ���������.

  ������� ���������:
    operatorId                             - ID ���������
    groupId                                - ID ������
    operatorIdIns                          - ID ���������, ������������ ���������

  �������� ��������� �����������.
*/
procedure createOperatorGroup(
  operatorId integer
  , groupId integer
  , operatorIdIns integer
)
is
-- createOperatorGroup
begin
  -- TODO: ��������� ����� �������

  -- ������ ������ ���������
  insert into op_operator_group(
    operator_id
    , group_id
    , operator_id_ins
  )
  values(
    operatorId
    , groupId
    , operatorIdIns
  );

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '������ ��� ��������� ��������� � ������ ('
          || ' operatorId="' || to_char( operatorId ) || '"'
          || ' , groupId="' || to_char( groupId ) || '"'
          || ' , operatorIdIns="' || to_char( operatorIdIns ) || '"'
          || ').'
        )
      , true
    );
end createOperatorGroup;

/* proc: deleteOperatorGroup
  ��������� �������� ������ � ���������.

  ������� ���������:
    operatorID                             - ID ���������
    groupID                                - ID ������
    operatorIDIns                          - ID ���������, ������������ ���������

  �������� ��������� �����������.
*/
procedure deleteOperatorGroup(
  operatorId integer
  , groupId integer
  , operatorIdIns integer
)
is
-- deleteOperatorGroup
begin
  -- TODO: ��������� ����� �������

  -- �������� ������
  delete from
    op_operator_group opg
  where
    opg.operator_id = operatorId
    and opg.group_id = groupId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '������ ��� ���������� ��������� �� ������ ('
          || ' operatorId="' || to_char( operatorId ) || '"'
          || ' , groupId="' || to_char( groupId ) || '"'
          || ' , operatorIdIns="' || to_char( operatorIdIns ) || '"'
          || ').'
        )
      , true
    );
end deleteOperatorGroup;

end pkg_AccessOperator;
/
