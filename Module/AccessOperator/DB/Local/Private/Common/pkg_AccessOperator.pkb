create or replace package body pkg_AccessOperator is
/* package body: pkg_AccessOperator::body */



/* group: ���������� */

/* ivar: lg_logger_t
  ������������ ������ ��� ������ Logging
*/
logger lg_logger_t := lg_logger_t.GetLogger(
  moduleName => Module_Name
  , objectName => 'pkg_AccessOperator'
);



/* group: ������� */



/* group: ��������� ������� */

/* proc: addSqlCondition
  ��������� ������� � ���������� � ������ SQL-�������.
  � ������, ���� ����������� �������� ��������� �� null ( isNullValue false),
  ������� ����������� � ���� �������� �������� ��������� ��� ����� � ����������,
  � ��������� ������ ����������� ������������ �������� ������� � ����������.

  ��������� ����� ������������ ���������� ����� � ������� ���������� ���
  ���������� ������������� SQL ��� ���, ��� ���������� ����� ����������
  ����� ���� �� ������ ( ����� �������� null). ����� �������������� ������
  ����� ������� � ����������� �� ������� ����������� �������� ����������,
  ��� ��������� ������������ ������ ����� ���������� �������.

  ���������:
  searchCondition             - ����� � SQL-��������� ������, � �������
                                ����������� ������� ( ������������� ����� � SQL
                                ����� "where")
  fieldExpr                   - ��������� ��� ����� ������� ( ����������� �
                                ����� ����� �������� ���������)
  operation                   - �������� ��������� ( "=", ">=" � �.�.)
  isNullValue                 - ������� �������� null � ������� ��������
                                ���������
  parameterExpr               - ��������� ��� ���������� ( ����������� � ������
                                ����� �������� ���������, � ������ ����������
                                ":" ��� ����������� � ������ ������, ��
                                ��������� ������� �� fieldExpr � ���������
                                ������ � ����������� ":")

  ���������:
  - � ������ �������������� �������� � fieldExpr ( �� ������
    "[<alias>.]<fieldName>"), �������� parameterExpr ������ ���� ���� ������;
*/
procedure addSqlCondition(
  searchCondition in out nocopy varchar2
  , fieldExpr varchar2
  , operation varchar2
  , isNullValue boolean
  , parameterExpr varchar2 := null
)
is
  -- ������� ���������� �������� ��������
  isBinaryOp boolean := coalesce( not isNullValue, false);

-- addSqlCondition
begin
  searchCondition := searchCondition
    || case when searchCondition is not null then ' and' end
    || case when isBinaryOp then
        ' ' || fieldExpr || ' ' || operation
      end
    || ' '
    || case when parameterExpr is null then
                                      --�� ��������� ��� ���� ( ��� ������)
          ':' || substr( fieldExpr, instr( fieldExpr, '.') + 1)
        else
                                      --��������� ":", ���� ��� ���
          case when instr( parameterExpr, ':') = 0 then
            ':'
          end
          || parameterExpr
        end
      || case when not isBinaryOp then
          ' is null'
        end
  ;
end addSqlCondition;

/* iproc: addPublicGroupToOperator
  ��������� ������ ������ "��������� ����� ������������������ �������������"
  ���������� ���������.

  ������� ���������:
    operatorId                       - ������������� ���������, �������� �������� ������
    operatorIdIns                    - ������������� ���������, ������� ������ ������
    computerName                     - ��� ����������, � �������� ������������ ��������
    ipAddress                        - Ip ����� ����������, � �������� ������������ ��������

  �������� ��������� ����������.
*/
procedure addPublicGroupToOperator(
  operatorId integer
  , operatorIdIns integer
  , computerName varchar2
  , ipAddress varchar2
)
is
-- addPublicGroupToOperator
begin
  insert into op_operator_group(
    operator_id
    , group_id
    , action_type_code
    , computer_name
    , ip_address
    , change_operator_id
    , operator_id_ins
  )
  select
    operatorId as operator_id
    , g.group_id
    , pkg_AccessOperator.CreateOperatorGroup_ActTpCd
    , computerName as computer_name
    , ipAddress as ip_address
    , operatorIdIns as change_operator_id
    , operatorIdIns as operator_id_ins
  from
    op_group g
  where
    upper( g.group_name ) = upper( '��������� ����� ������������������ �������������' )
  ;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '�� ����� ������ ������ ��������� ���� ������� ��������� '
          || '��������� ������.'
        )
      , true
    );
end addPublicGroupToOperator;

/* iproc: addRoleToAdminGroup
  ������ ���� ������� ������� �������.

  ������� ���������:
    roleId                           - Id ����
    operatorId                       - Id ���������, ������������ ���������
    computerName                     - ��� ����������, � �������� ������������ ��������
    ipAddress                        - Ip ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.
*/
procedure addRoleToAdminGroup(
  roleId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- addRoleToAdminGroup
begin
  -- ������ ������
  insert into op_group_role(
    group_id
    , role_id
    , action_type_code
    , computer_name
    , ip_address
    , change_operator_id
    , operator_id
  )
  with admin_group as (
    select
      g.group_id
    from
      op_group g
    where
      upper( g.group_name) in (
        upper( '������ ������')
        , upper( '������ ������ (����� ������)')
      )
  )
  select
    t.group_id
    , t.role_id
    , pkg_AccessOperator.CreateGroupRole_ActTpCd as action_type_code
    , computerName as computer_name
    , ipAddress as ip_address
    , operatorId as change_operator_id
    , operatorId as operator_id
  from
    (
    select
      g.group_id
      , roleId as role_id
    from
      admin_group g
    minus
    select
      gr.group_id
      , gr.role_id
    from
      op_group_role gr
    inner join
      admin_group g
    on
      g.group_id = gr.group_id
      and gr.role_id = roleId
    ) t
  ;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ������ ���� ������� ������� ������� '
      || '��������� ������ ('
      || 'roleId="' || to_char( roleId ) || '"'
      || ', operatorId="' || to_char( operatorId ) || '"'
      || ').'
      , true
    );
end addRoleToAdminGroup;



/* group: ������� ��� ������ � ����������� */

/* func: createOperator
  ������� �������� ������������

  ������� ���������:
    operatorName                - ������������ ������������ �� ����� �� ���������
    operatorNameEn              - ������������ ������������ �� ���������� �����
    login                       - �����
    password                    - ������
    changePassword              - ������� ������������� ��������� ������
                                  �������������:
                                  1 � ������������ ���������� �������� ������;
                                  0 � ������������ ��� ������������� ������ ������.
    operatorIdIns               - ������������, ��������� ������
    operatorComment             - ���������� � ������
    loginAttemptGroupId         - ������ ���������� ����������
    computerName                - ��� ����������, � �������� ������������ ��������
    ipAddress                   - IP ����� ����������, � �������� ������������ ��������
   �������:
     operator_id                - ID ���������� ���������
*/
function createOperator(
  operatorName varchar2
  , operatorNameEn varchar2
  , login varchar2
  , password varchar2
  , changePassword integer
  , operatorIdIns integer
  , operatorComment varchar2 default null
  , loginAttemptGroupId integer default null
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
return integer
is
  operatorId integer;
  useLoginAttemptGroupId integer;


  /*
    ������� ������ �������� �� ������ �� ���������
  */
  function getDefaultGrpId
  return integer
  is
    dataDefault user_tab_cols.data_default%type;
    defaultGrpId integer;

  -- getDefaultGrpId
  begin
    select
      t.data_default
    into
      dataDefault
    from
      user_tab_cols t
    where
      t.table_name = 'OP_OPERATOR'
      and t.column_name = 'LOGIN_ATTEMPT_GROUP_ID'
    ;

    defaultGrpId := to_number( substr( dataDefault, 1, 4000 ) );

    return defaultGrpId;
  exception
    when others then
      return null;
  end getDefaultGrpId;

-- createOperator
begin
  pkg_Operator.IsUserAdmin( operatorIdIns, null );

  useLoginAttemptGroupId := coalesce(
    loginAttemptGroupId
    , getDefaultGrpId()
  );

  insert into op_operator(
    login
    , operator_name
    , operator_name_en
    , password
    , date_begin
    , change_password
    , operator_comment
    , login_attempt_group_id
    , action_type_code
    , computer_name
    , ip_address
    , change_operator_id
    , operator_id_ins
  )
  values(
    login
    , operatorName
    , operatorNameEn
    , pkg_Operator.getHash( password )
    , sysdate
    , changePassword
    , operatorComment
    , useLoginAttemptGroupId
    , pkg_AccessOperator.CreateOperator_ActTpCd
    , computerName
    , ipAddress
    , operatorIdIns
    , operatorIdIns
  )
  returning
    operator_id
  into
    operatorId
  ;

  -- ������ ��������� ������ ��������� ���� �������
  addPublicGroupToOperator(
    operatorId => operatorId
    , operatorIdIns => operatorIdIns
    , computerName => computerName
    , ipAddress => ipAddress
  );

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
          || ', changePassword="' || changePassword || '"'
          || ', operatorIdIns="' || operatorIdIns || '"'
          || ', operatorComment="' || operatorComment || '"'
          || ', loginAttemptGroupId="'
            || to_char( loginAttemptGroupId ) || '"'
          || ', computerName="' || computerName || '"'
          || ', ipAddress="' || ipAddress || '"'
          || ').'
        )
      , true
    );
end createOperator;

/* proc: updateOperator
  ��������� ���������� ������������ UpdateOperator

  ������� ���������:
    operatorId                  - ID ��������� ��� ���������
    operatorName                - ������������ ������������ �� ����� �� ���������
    operatorNameEn              - ������������ ������������ �� ���������� �����
    login                       - �����
    password                    - ������
    changePassword              - ������� ������������� ��������� ������
                                  �������������:
                                  1 � ������������ ���������� �������� ������;
                                  0 � ������������ ��� ������������� ������ ������.
    operatorIdIns               - ������������, ��������� ������
    operatorComment             - ���������� ���������
    loginAttemptGroupId         - ������ ���������� ����������
    computerName                - ��� ����������, � �������� ������������ ��������
    ipAddress                   - IP ����� ����������, � �������� ������������ ��������

   �������� ��������� �����������.
*/
procedure updateOperator(
  operatorId integer
  , operatorName varchar2
  , operatorNameEn varchar2
  , login varchar2
  , password varchar2
  , changePassword integer
  , operatorIdIns integer
  , operatorComment varchar2
  , loginAttemptGroupId integer default null
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- updateOperator
begin
  pkg_operator.IsUserAdmin( operatorIdIns, operatorId );

  -- ��� ���������� ������� ������� ����������� ����� ������,
  -- � ����� ����� ������ ���������, �.�. ��� ����� ������
  -- ���������� ������� pkg_Operator.setCurentOperatorId,
  -- ������� �������� ��������� �� ��-�� � , ��������������,
  -- ��������� ������ � ����������, �� �.�. ��� �������� � ����������
  -- ���������� - �������� ������.
  if password is not null then
    pkg_Operator.changePassword(
      operatorId => operatorId
      , password => password
      , operatorIdIns => operatorIdIns
    );
  end if;

  update
    op_operator t
  set
    t.operator_name = operatorName
    , t.operator_name_en = operatorNameEn
    , t.login = updateOperator.login
    , t.change_password = changePassword
    , t.operator_comment = operatorComment
    , t.login_attempt_group_id = loginAttemptGroupId
    , t.action_type_code = pkg_AccessOperator.ChangePersonalData_ActTpCd
    , t.computer_name = computerName
    , t.ip_address = ipAddress
    , t.change_date = sysdate
    , t.change_operator_id = operatorIdIns
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
   ��������� �������� ������������

   ������� ���������:
     operatorId          - �� ���������
     operatorIdIns       - �� ��������� �� �������� ����
     operatorComment     - �����������
     computerName        - ��� ����������, � �������� ������������ ��������
     ipAddress           - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.
*/
procedure deleteOperator(
  operatorId integer
  , operatorIdIns integer
  , operatorComment varchar2 default null
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- deleteOperator
begin
  pkg_operator.IsUserAdmin( operatorIdIns, operatorId );

  update
    op_operator t
  set
    t.date_finish = sysdate
    , t.operator_comment = operatorComment
    , t.curr_login_attempt_count = 0
    , t.action_type_code = pkg_AccessOperator.BlockOperator_ActTpCd
    , t.computer_name = computerName
    , t.ip_address = ipAddress
    , t.change_date = sysdate
    , t.change_operator_id = operatorIdIns
  where
    t.operator_id = operatorId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '��� �������� ��������� �������� ������ ('
          || ' operator_id="' || to_char( operatorId ) || '"'
          || ').'
        )
      , true
    );
end deleteOperator;

/* func: findOperator
   ������� ������ ������������.

   ������� ���������:
     operatorId                     - ������������� ������������
     login                          - ����� ������������
     operatorName                   - ������������ ������������ �� �����
                                      �� ���������
     operatorNameEn                 - ������������ ������������ ��
                                      ���������� �����
     loginAttemptGroupId            - ������ ���������� ����������
     deleted                        - ������� ����������� ��������� �������:
                                      0 � �� ���������� ���������;
                                      1 � ���������� ���������.
     rowCount                       -  ������������ ����������
                                      ������������ �������
     operatorIdIns                  - ������������, �������������� �����

   ������� (� ���� �������):
     operator_id                    - ������������� ������������
     login                          - ����� ������������
     operator_name                  - ������������ ������������ �� �����
                                      �� ���������
     operator_name_en               - ������������ ������������ �� ���������� �����
     date_begin                     - ���� ������ �������� ������
     date_finish                    - ���� ��������� �������� ������
     change_password                - ������� ������������� ����� ������:
                                      0 � ������ ������ �� �����;
                                      1 � ���������� ������� ������.
     date_ins                       - ���� �������� ������
     operator_id_ins                - ������������, ��������� ������
     operator_name_ins              - ������������ �� ����� �� ���������,
                                      ��������� ������
     operator_name_ins_en           - ������������ �� ���������� �����,
                                      ��������� ������
     operator_comment               - �����������, ������� ����������
     curr_login_attempt_count       - ������� ���������� ���������� ������� �����
     login_attempt_group_id         - ������ ���������� ����������
     login_attempt_group_name       - ������������ ������ ���������� ����������
     is_default                     - ������� �� ���������
     lock_type_code                 - ��� ����������
     max_login_attempt_count        - ����������� ���������� ����������
                                      ������� ����� � �������
     locking_time                   - ����� ���������� � ��������
     lock_type_name                 - ������������ ����
     block_wait_period              - ���������� ���� �������� ���������� ���������
                                      ����� ���������� ����������
*/
function findOperator(
  operatorId integer default null
  , login varchar2 default null
  , operatorName varchar2 default null
  , operatorNameEn varchar2 default null
  , loginAttemptGroupId integer default null
  , deleted integer default null
  , rowCount integer default null
  , operatorIdIns integer default null
)
return sys_refcursor
is
  sqlStr varchar2(4000);
  resultSet sys_refcursor;

-- findOperator
begin
  pkg_operator.IsUserAdmin( operatorIdIns, null );

  sqlStr := '
select
  op.operator_id
  , op.login
  , op.operator_name
  , op.operator_name_en
  , op.date_begin
  , op.date_finish
  , op.change_password
  , op.date_ins
  , op.operator_id_ins
  , (
    select
      op1.operator_name
    from
      op_operator op1
    where
      op1.operator_id = op.operator_id_ins
    ) as operator_name_ins
  , (
    select
      op1.operator_name_en
    from
      op_operator op1
    where
      op1.operator_id = op.operator_id_ins
    ) as operator_name_ins_en
  , op.operator_comment
  , op.curr_login_attempt_count
  , op.login_attempt_group_id
  , grp.login_attempt_group_name
  , grp.is_default
  , grp.lock_type_code
  , lt.lock_type_name
  , grp.max_login_attempt_count
  , grp.locking_time
  , coalesce( grp.block_wait_period, 0 ) as block_wait_period
from
  op_operator op
left join
  v_op_login_attempt_group grp
on
  op.login_attempt_group_id = grp.login_attempt_group_id
left join
  op_lock_type lt
on
  grp.lock_type_code = lt.lock_type_code
where
  1 = 1'
  ;

  if deleted = 0 then
    sqlStr := sqlStr
      || ' and ( op.date_finish is null or op.date_finish > sysdate ) '
    ;
  elsif deleted = 1 then
    sqlStr := sqlStr || ' and op.date_finish is not null ';
  end if;

  addSqlCondition(
    sqlStr
    , 'op.operator_id'
    , '='
    , operatorId is null
  );
  addSqlCondition(
    sqlStr
    , 'upper( op.login )'
    , 'like'
    , login is null
    , 'login'
  );
  addSqlCondition(
    sqlStr
    , 'upper( op.operator_name )'
    , 'like'
    , operatorName is null
    , 'operatorName'
  );
  addSqlCondition(
    sqlStr
    , 'upper(op.operator_name_en)'
    , 'like'
    , operatorNameEn is null
    , 'operatorNameEn'
  );
  addSqlCondition(
    sqlStr
    , 'op.login_attempt_group_id'
    , '='
    , loginAttemptGroupId is null
    , 'loginAttemptGroupId'
  );
  addSqlCondition(
    sqlStr
    , 'rownum'
    , '<='
    , rowCount is null
    , 'rowCount'
  );

  -- dbms_output.put_line('sql="' || sqlStr || '"');

  open
    resultSet
  for
    sqlStr
  using
    operatorId
    , upper( login )
    , upper( operatorName )
    , upper( operatorNameEn )
    , loginAttemptGroupId
    , rowCount
  ;

  -- ������ ���������
  return resultSet;

-- ����������� ��������� ����������
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�������� ������ ��� ������ ��������� ('
        || 'operatorId="' || to_char( operatorId ) || '"'
        || ', login="' || login || '"'
        || ', operatorName="' || operatorName || '"'
        || ', operatorNameEn="' || operatorNameEn || '"'
        || ', deleted="' || to_char( deleted ) || '"'
        || ', rowCount="' || to_char( rowCount ) || '"'
        || ', operatorIdIns="' || to_char( operatorIdIns ) || '"'
        || ').'
      , true
    );
end findOperator;

/* proc: restoreOperator
   ��������� �������������� ���������� ������������ RestoreOperator

   ������� ���������:
     operatorId                  - ������������, �������� ���������� ������������
     restoreOperatorId           - ������������, ������� ��������������� ������
     computerName                - ��� ����������, � �������� ������������ ��������
     ipAddress                   - IP ����� ����������, � �������� ������������ ��������

   �������� ��������� �����������.
*/
procedure restoreOperator(
  operatorId integer
  , restoreOperatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- restoreOperator
begin
  pkg_Operator.isUserAdmin(
    operatorId => restoreOperatorId
    , targetOperatorId => operatorId
  );

  update
    op_operator op
  set
    op.date_finish = null
    --, op.operator_comment = null
    , op.curr_login_attempt_count = 0
    , op.action_type_code = pkg_AccessOperator.UnblockOperator_ActTpCd
    , op.computer_name = computerName
    , op.ip_address = ipAddress
    , op.change_date = sysdate
    , op.change_operator_id = restoreOperatorId
  where
    op.operator_id = operatorId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '�� ����� �������������� ��������� ��������� ������ ('
          || 'operatorId="' || to_char( operatorId ) || '"'
          || ', restoreOperatorId="' || to_char( restoreOperatorId ) || '"'
          || ').'
        )
      , true
    );
end restoreOperator;

/* func: createOperatorHash
  ������� ������ ��������� � ���������� ��� ID.

  ������� ���������:
    operatorName               - ��� ���������
    operatorNameEn             - ��� ��������� (�� ����������)
    login                      - �����
    passwordHash               - Hash ������
    changepassword             - ���� ����� ������ ���������
    operatorIDIns              - ID ���������, ������������ ���������
    computerName               - ��� ����������, � �������� ������������ ��������
    ipAddress                  - IP ����� ����������, � �������� ������������ ��������

   �������:
     operator_id               - ID ���������� ���������
*/
function createOperatorHash(
  operatorName varchar2
  , operatorNameEn varchar2
  , login varchar2
  , passwordHash varchar2
  , changePassword integer
  , operatorIdIns integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
return integer
is
  -- ID ������ ���������
  operatorId integer;

-- createOperatorHash
begin
  -- ��������� ����� ���������
  pkg_operator.IsUserAdmin(
    operatorId => operatorIdIns
    , targetOperatorId => null
  );

  -- ������� ������
  insert into op_operator(
    operator_name
    , operator_name_en
    , login
    , password
    , change_password
    , date_begin
    , operator_id_ins
    , computer_name
    , ip_address
    , change_operator_id
  )
  values(
    operatorName
    , operatorNameEn
    , login
    , passwordHash
    , changePassword
    , sysdate
    , operatorIdIns
    , computerName
    , ipAddress
    , operatorIdIns
  )
  returning
    operator_id
  into
    operatorId
  ;

  -- ������ ��������� ������ ��������� ���� �������
  addPublicGroupToOperator(
    operatorId => operatorId
    , operatorIdIns => operatorIdIns
    , computerName => computerName
    , ipAddress => ipAddress
  );

  return operatorId;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '������ ��� �������� ��������� ('
          || ' login="' || login || '"'
          || ').'
       )
    , true
  );
end createOperatorHash;

/* func: getOperatorManuallyChanged
   ������� ��������� �������� ������� ��������� ������������.

   ������� ���������:
     operatorId                     - ������������� ������������

   �������:
     is_manually_changed            - ���� ������� ���������� ������ �� ������������
*/
function getOperatorManuallyChanged(
  operatorId integer
)
return integer
is
  isManuallyChanged integer;
  -- ����������� �� ����������� �����������
  dSql varchar2(32767) := '
select
  case when
    t.op_group_count = 1
    and t.op_role_count = 0
    and t.op_group_history_count = 0
    and t.op_role_history_count = 0
    and t.operator_id_ins = 1
    and t.change_number = 1
  then
    0
  else
    1
  end as is_manually_changed
from
  (
  select
    op.operator_id_ins
    , op.change_number
    , (
      select
        count(*)
      from
        op_operator_group g
      where
        g.operator_id = op.operator_id
        and g.user_access_flag = 1
      ) as op_group_count
    , (
      select
        count(*)
      from
        op_operator_role r
      where
        r.operator_id = op.operator_id
        and r.user_access_flag = 1
      ) as op_role_count
    , (
      select
        count(*)
      from
        oph_operator_group_history gh
      where
        gh.operator_id = op.operator_id
      ) as op_group_history_count
    , (
      select
        count(*)
      from
       oph_operator_role_history rh
      where
        rh.operator_id = op.operator_id
      ) as op_role_history_count
  from
    op_operator op
  where
    op.operator_id = :operatorId
  ) t'
  ;

-- getOperatorManuallyChanged
begin
  execute immediate
    dSql
  into
    isManuallyChanged
  using
    operatorId
  ;

  return isManuallyChanged;

exception
  when no_data_found then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '��������� �������� �� ������ ('
        || 'operatorId="' || to_char( operatorId ) || '"'
        || ').'
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ��������� �������� ������� ��������� '
        || '������������ ��������� ������ ('
        || 'operatorId="' || to_char( operatorId ) || '"'
        || ').'
    );
end getOperatorManuallyChanged;

/* proc: restoreOperator
   ��������� �������������� ���������� ������������

   ������� ���������:
     operatorId          - ID ��������� ��� ��������������
     operatorIdIns	     - ������������, ����������������� ���������
     computerName        - ��� ����������, � �������� ������������ ��������
     ipAddress           - IP ����� ����������, � �������� ������������ ��������

   �������� ��������� �����������
*/
procedure restoreOperator(
  operatorId integer
  , operatorIdIns integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- restoreOperator
begin
  pkg_operator.IsUserAdmin(operatorIdIns, operatorId);

  update
    op_operator t
  set
    t.date_finish = null
    --, t.operator_comment = null
    , t.curr_login_attempt_count = 0
    , t.action_type_code = pkg_AccessOperator.UnblockOperator_ActTpCd
    , t.computer_name = computerName
    , t.ip_address = ipAddress
    , t.change_date = sysdate
    , t.change_operator_id = operatorIdIns
  where
    t.operator_id = operatorId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ ��� �������������� ���������� ��������� ('
        || 'operator_id="' || to_char( operatorId ) || '"'
        || ', operatorIdIns="' || to_char( operatorIdIns ) || '"'
        || ', computerName="' || computerName || '"'
        || ', ipAddress="' || ipAddress || '"'
        || ').'
    , true
  );
end restoreOperator;



/* group: ������� ��� ������ � ������ */

/* iproc: setRoleUnused
  ��������� ��������� ��� ���� ����� "��������������" (�������� ����
  �� <op_operator_role> � <op_group_role>).

  ������� ���������:
    roleId                                 - ID ����
    operatorId                             - �� ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.
*/
procedure setRoleUnused(
  roleId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- setRoleUnused
begin
  -- ������� ����
  -- ��������� ��� � ip ����� ����������, � �������� ������������ ��������
  update
    op_operator_role opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteOperatorRole_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorId
  where
    opr.role_id = roleId
  ;

  -- �������� ���� � ����������
  delete
    op_operator_role opr
  where
    opr.role_id = roleId
  ;

  -- ��������� ��� � ip ����� ����������, � �������� ������������ ��������
  update
    op_group_role opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteOperatorRole_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorId
  where
    opr.role_id = roleId
  ;

  -- �������� ���� � �����
  delete
    op_group_role opr
  where
    opr.role_id = roleId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '�� ����� ��������� ��� ���� ����� "��������������" ��������� ������ ('
           || 'roleId="' || to_char( roleId ) || '"'
           || ', operatorId="' || to_char( operatorId ) || '"'
           || ', computerName="' || computerName || '"'
           || ', ipAddress="' || ipAddress || '"'
           || ').'
        )
      , true
    );
end setRoleUnused;

/* func: createRole
  ������� �������� ����.

  ������� ���������:
    roleName                               - ������������ ���� �� ����� �� ���������
    roleNameEn                             - ������������ ���� �� ���������� �����
    shortName                              - ������� ������������ ����
    description                            - �������� ���� �� ����� �� ���������
    isUnused                               - ������� �������������� ����
    operatorId                             - �� ���������

  �������:
    role_id                                - ������������� ��������� ������ ����
*/
function createRole(
  roleName varchar2
  , roleNameEn varchar2
  , shortName varchar2
  , description varchar2
  , isUnused number default 0
  , operatorId integer
)
return integer
is
  roleId integer;

-- createRole
begin
  pkg_operator.IsRole( operatorId, RoleAdmin_Role );

  insert into op_role(
    short_name
    , role_name
    , role_name_en
    , description
    , is_unused
    , change_operator_id
    , operator_id
  )
  values(
    shortName
    , roleName
    , roleNameEn
    , description
    , isUnused
    , operatorId
    , operatorId
  )
  returning
    role_id
  into
    roleId
  ;
  return roleId;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '�� ����� �������� ���� ��������� ������ ('
          || 'roleName="' || roleName || '"'
          || ', roleNameEn="' || roleNameEn || '"'
          || ', shortName="' || shortName || '"'
          || ', description="' || description || '"'
          || ', operatorId="' || to_char( operatorId ) || '"'
          || ').'
        )
      , true
    );
end createRole;

/* proc: updateRole
  ��������� �������������� ����.

  ������� ���������:
    roleId                                 - ID ����
    roleName                               - ������������ ���� �� ����� �� ���������
    roleNameEn                             - ������������ ���� �� ���������� �����
    shortName                              - ������� ������������ ����
    description                            - �������� ���� �� ����� �� ���������
    isUnused                               - ������� �������������� ����
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������
    operatorId                             - ������������, ��������� ������

  �������� ��������� �����������.
*/
procedure updateRole(
  roleId integer
  , roleName varchar2
  , roleNameEn varchar2
  , shortName varchar2
  , description varchar2
  , isUnused number default 0
  , computerName varchar2 default null
  , ipAddress varchar2 default null
  , operatorId integer
)
is
-- updateRole
begin
  pkg_operator.IsRole( operatorId, RoleAdmin_Role );

  update
    op_role t
  set
    t.short_name = shortName
    , t.role_name = roleName
    , t.role_name_en = roleNameEn
    , t.description = updateRole.description
    , t.is_unused = isUnused
    , t.change_date = sysdate
    , t.change_operator_id = operatorId
  where
    t.role_id = roleId
  ;

  -- ���� ���� ���������� ����������� ��� ���������� -
  -- �������� �� � ���������� � �����
  if coalesce( isUnused, 0 ) = 1 then
    setRoleUnused(
      roleId => roleId
      , operatorId => operatorId
      , computerName => computerName
      , ipAddress => ipAddress
    );
  end if;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '�� ����� �������������� ���� ��������� ������ ('
          || 'roleId="' || to_char( roleId ) || '"'
          || ').'
        )
      , true
    );
end updateRole;

/* proc: deleteRole
  ��������� �������� ����.

  ������� ���������:
    roleId                                 - ID ����
    operatorId                             - �� ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.
*/
procedure deleteRole(
  roleId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- deleteRole
begin
  pkg_operator.IsRole( operatorId, RoleAdmin_Role );

  -- ��������� ��� � ip ����� ����������, � �������� ������������ ��������
  update
    op_operator_role opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteOperatorRole_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorId
  where
    opr.role_id = roleId
  ;
  -- �������� ���� � ����������
  delete
    op_operator_role opr
  where
    opr.role_id = roleId
  ;

  -- ��������� ��� � ip ����� ����������, � �������� ������������ ��������
  update
    op_group_role opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteOperatorRole_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorId
  where
    opr.role_id = roleId
  ;
  -- �������� ���� � �����
  delete
    op_group_role opr
  where
    opr.role_id = roleId
  ;

  -- ��������� �� ���������, ������� ���������� ��������
  update
    op_role r
  set
    r.change_date = sysdate
    , r.change_operator_id = operatorId
  where
    r.role_id = roleId
  ;
  delete
    op_role t
  where
    t.role_id = roleId
  ;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '�� ����� �������� ���� ��������� ������ ('
           || 'roleId="' || to_char( roleId )
           || ').'
        )
      , true
    );
end deleteRole;

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



  /*
    ��������� ���������� ���� � ������ ���������������.
  */
  procedure mergeRoleToAdminGroup
  is

    -- ������������� ����
    roleId integer;

  -- mergeRoleToAdminGroup
  begin
    select
      r.role_id
    into
      roleId
    from
      v_op_role r
    where
      r.role_short_name = roleShortName
    ;
    addRoleToAdminGroup(
      roleId            => roleId
      , operatorId      => pkg_Operator.getCurrentUserId()
    );
  end mergeRoleToAdminGroup;



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
    -- ����������� ��������� ����� ��� ����������
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

  -- ��������� ���� � ������ ���������������
  mergeRoleToAdminGroup();

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

/* func: findRole
  ������� ������ ����.

  ������� ���������:
    roleId	                               - ������������� ����
    roleName	                             - ������������ ���� �� ����� �� ���������
    roleNameEn	                           - ������������ ���� �� ���������� �����
    shortName	                             - ������� ������������ ����
    description	                           - �������� ���� �� ����� �� ���������
    isUnused                               - ������� �������������� ����
    rowCount	                             - ������������ ���������� ������������ �������
    operatorId	                           - ������������, �������������� �����

  ������� (� ���� �������):
    role_id	                               - ������������� ����
    short_name	                           - ������� ������������ ����
    role_name	                             - ������������ ���� �� ����� �� ���������
    role_name_en	                         - ������������ ���� �� ���������� �����
    description	                           - �������� ���� �� ����� �� ���������
    date_ins	                             - ���� �������� ������
    operator_id	                           - ������������, ��������� ������
    operator_name	                         - ������������ �� ����� �� ���������, ��������� ������
    operator_name_en	                     - ������������ �� ���������� �����, ��������� ������
    is_unused                              - ������� �������������� ����
*/
function findRole(
  roleId integer default null
  , roleName varchar2 default null
  , roleNameEn varchar2 default null
  , shortName varchar2 default null
  , description varchar2 default null
  , isUnused number default null
  , rowCount integer default null
  , operatorId integer
)
return sys_refcursor
is
  sqlStr varchar2(32767);
  -- ������ � ����������� ������
  resultSet  sys_refcursor;

-- findRole
begin
  pkg_operator.IsRole( operatorId, RoleAdmin_Role);

  sqlStr := '
select
  opr.role_id
  , opr.short_name
  , opr.role_name
  , opr.role_name_en
  , opr.description
  , opr.date_ins
  , opr.operator_id
  , op.operator_name
  , op.operator_name_en
  , opr.is_unused
from
  op_role opr
inner join
  op_operator op
on
  op.operator_id = opr.operator_id
where
  1 = 1 '
  ;

  addSqlCondition( sqlStr, 'opr.role_id', '=', roleId is null);
  addSqlCondition( sqlStr, 'upper( opr.role_name )', 'like', roleName is null, 'roleName');
  addSqlCondition( sqlStr, 'upper( opr.role_name_en )', 'like', roleNameEn is null,'roleNameEn');
  addSqlCondition( sqlStr, 'upper( opr.short_name )', 'like', shortName is null,'shortName');
  addSqlCondition( sqlStr, 'upper( opr.description )', 'like', description is null,'description');
  addSqlCondition( sqlStr, 'opr.is_unused', '=', isUnused is null);

  addSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

  open
    resultSet
  for
    sqlStr
    || ' order by opr.role_id'
	using
    roleId
    , upper( roleName )
    , upper( roleNameEn )
    , upper( shortName )
    , upper( description )
    , isUnused
    , rowCount
  ;

  -- ������ ���������
  return resultSet;

-- ����������� ��������� ����������
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�������� ������ ��� ������ ����.'
      , true
    );
end findRole;



/* group: ������� ��� ������ � �������� */

/* iproc: setGroupUnused
  ��������� ��������� ��� ������ ����� "��������������" (�������� ������
  �� <op_operator_group>).

  ������� ���������:
    groupId                                - �� ������
    operatorId                             - �� ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.
*/
procedure setGroupUnused(
  groupId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- setGroupUnused
begin
  -- ��������� ��� � ip ����� ����������, � �������� ������������ ��������
  update
    op_operator_group opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteOperatorGroup_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorId
  where
    opr.group_id = groupId
  ;

  -- �������� ������ � ���� ����������
  delete
    op_operator_group opr
  where
    opr.group_id = groupId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '�� ����� ��������� ��� ������ ����� "��������������" ��������� ������ ('
           || 'groupId="' || to_char( groupId ) || '"'
           || ', operatorId="' || to_char( operatorId ) || '"'
           || ', computerName="' || computerName || '"'
           || ', ipAddress="' || ipAddress || '"'
           || ').'
        )
      , true
    );
end setGroupUnused;

/* func: createGroup
  ������� �������� ������.

  ������� ���������:
    groupName                              - ������������ ������ �� ����� �� ���������
    groupNameEn                            - ������������ ������ �� ���������� �����
    description                            - ��������
    isUnused                               - ������� �������������� ����
    operatorId                             - ������������, ��������� ������

  �������:
    group_id                               - �� ������
*/
function createGroup(
  groupName varchar2
  , groupNameEn varchar2
  , description varchar2 default null
  , isUnused integer default 0
  , operatorId integer
)
return integer
is
  groupId integer;

-- createGroup
begin
  pkg_operator.IsRole( operatorId, RoleAdmin_Role );

  select
    op_group_seq.nextval
  into
    groupId
  from
    dual
  ;

  insert into op_group(
    group_name
    , group_name_en
    , description
    , is_unused
    , change_operator_id
    , operator_id
  )
  values(
    groupName
    , groupNameEn
    , description
    , isUnused
    , operatorId
    , operatorId
  )
  returning
    group_id
  into
    groupId
  ;
  return groupId;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '��� �������� ������ �������� ������ ('
          || 'groupName="' || groupName || '"'
          || ', groupNameEn="' || groupNameEn || '"'
          || ', description="' || description || '"'
          || ', isUnused="' || to_char( isUnused ) || '"'
          || ', operatorId="' || to_char( operatorId ) || '"'
          || ').'
        )
      , true
    );
end createGroup;

/* proc: updateGroup
  ��������� �������������� ������.

  ������� ���������:
    groupId                                - ID ������
    groupName                              - ������������ ������ �� ����� �� ���������
    groupNameEn                            - ������������ ������ �� ���������� �����
    description                            - ��������
    isUnused                               - ������� �������������� ����
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������
    operatorId                             - ������������, ��������� ������

  �������� ��������� �����������.
*/
procedure updateGroup(
  groupId integer
  , groupName varchar2
  , groupNameEn varchar2
  , description varchar2 default null
  , isUnused number default 0
  , computerName varchar2 default null
  , ipAddress varchar2 default null
  , operatorId integer
)
is
-- updateGroup
begin
  pkg_operator.IsRole( operatorId, RoleAdmin_Role );

  update
    op_group t
  set
    t.group_name = groupName
    , t.group_name_en = groupNameEn
    , t.description = updateGroup.description
    , t.is_unused = isUnused
    , t.change_date = sysdate
    , t.change_operator_id = operatorId
  where
    t.group_id = groupId
  ;

  -- ���� ������ ���������� ����������� ��� ���������� -
  -- �������� �� � ���������� � ����� �����
  if coalesce( isUnused, 0 ) = 1 then
    setGroupUnused(
      groupId => groupId
      , operatorId => operatorId
      , computerName => computerName
      , ipAddress => ipAddress
    );
  end if;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '�� ����� �������������� ������ ��������� ������ ('
          || 'groupId="' || to_char( groupId ) || '"'
          || ').'
        )
      , true
    );
end updateGroup;

/* proc: deleteGroup
  ��������� �������� ������.

  ������� ���������:
    groupId                                - �� ������
    operatorId                             - �� ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.
*/
procedure deleteGroup(
  groupId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- deleteGroup
begin
  pkg_operator.IsRole( operatorId, RoleAdmin_Role );

  -- ��������� ��� � ip ����� ����������, � �������� ������������ ��������
  update
    op_operator_group opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteOperatorGroup_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorId
  where
    opr.group_id = groupId
  ;

  -- �������� ������ � ���� ����������
  delete
    op_operator_group opr
  where
    opr.group_id = groupId
  ;

  -- ��������� ��� � ip ����� ����������, � �������� ������������ ��������
  update
    op_group_role opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteGroupRole_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorId
  where
    opr.group_id = groupId
  ;

  -- ������� ��� ���� ������
  delete
    op_group_role opr
  where
    opr.group_id = groupId
  ;

  -- ��������� ���������, ������� ���������� ��������
  update
    op_group t
  set
    t.change_date = sysdate
    , t.change_operator_id = operatorId
  where
    t.group_id = groupId
  ;

  -- ������� ������
  delete
    op_group t
  where
    t.group_id = groupId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '�� ����� �������� ������ ��������� ������ ('
           || 'groupId="' || to_char( groupId ) || '"'
           || ').'
        )
      , true
    );
end deleteGroup;

/* func: findGroup
  ������� ������ �����.

  ������� ���������:
    groupId                                - �� ������
    groupId                                - ������������� ������
    groupName                              - ������������ ������ �� ����� �� ���������
    groupNameEn                            - ������������ ������ �� ���������� �����
    isGrantOnly                            - ������� ���������� ������ grant-������:
                                             ���� 1, �� ���������� ������ grant-������;
                                             ���� 0  ��� null, �� ���������� ��� ������.
    description                            - ��������
    isUnused                               - ������� �������������� ������
    rowCount                               - ������������ ���������� ������������ �������
    operatorId                             - ������������, �������������� �����

  ������� (� ���� �������):
    group_id                               - ������������� ������
    group_name                             - ������������ ������ �� ����� �� ���������
    group_name_en                          - ������������ ������ �� ���������� �����
    date_ins                               - ���� �������� ������
    operator_id                            - ������������, ��������� ������
    operator_name                          - ������������ �� ����� �� ���������, ��������� ������
    operator_name_en                       - ������������ �� ���������� �����, ��������� ������
    description                            - �������� ������
    is_unused                              - ������� �������������� ������
*/
function findGroup(
  groupId integer default null
  , groupName varchar2 default null
  , groupNameEn varchar2 default null
  , description varchar2 default null
  , isUnused integer default null
  , rowCount integer default null
  , operatorId integer
)
return sys_refcursor
is
  sqlStr varchar2(32767);
  -- ������ � ����������� ������
  resultSet sys_refcursor;

-- findGroup
begin
  pkg_operator.IsUserAdmin(operatorId, null);

  sqlStr := '
select
  opg.group_id
  , opg.group_name
  , opg.group_name_en
  , opg.date_ins
  , opg.operator_id
  , op.operator_name
  , op.operator_name_en
  , opg.description
  , opg.is_unused
from
  op_group opg
inner join
  op_operator op
on
  op.operator_id = opg.operator_id
where
  1 = 1 '
  ;

  addSqlCondition( sqlStr, 'opg.group_id', '=', groupId is null );
  addSqlCondition( sqlStr, 'upper( opg.group_name )', 'like', groupName is null, 'groupName' );
  addSqlCondition( sqlStr, 'upper( opg.group_name_en )', 'like', groupNameEn is null, 'groupNameEn' );
  addSqlCondition( sqlStr, 'upper( opg.description )', 'like', description is null, 'description' );
  addSqlCondition( SQLstr, 'opg.is_unused', '=', isUnused is null );
  addSqlCondition( sqlStr, 'rownum', '<=', rowCount is null, 'rowCount' );

  open
    resultSet
  for
    sqlStr
    || ' order by 1'
	using
    groupId
    , upper( groupName )
    , upper( groupNameEn )
    , upper( description )
    , isUnused
    , rowCount
  ;

  -- ������ ���������
  return resultSet;

-- ����������� ��������� ����������
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ������ ����� ��������� ������.'
      , true
    );
end findGroup;



/* group: ������� ��� ������ � ������ ��������� */


/* proc: createOperatorRole
  ��������� �������� ����� ������������ � ����.

  ������� ���������:
    operatorId                             - �� ���������
    roleId                                 - �� ����
    userAccessFlag                         - ����� �� ������������� ����
    grantOptionFlag                        - ����� �� ������ ���� ������ ����������
    operatorIdIns                          - �� �������� ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� ����������.
*/
procedure createOperatorRole(
  operatorId integer
  , roleId integer
  , userAccessFlag integer default null
  , grantOptionFlag integer default null
  , operatorIdIns	integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- createOperatorRole
begin
  pkg_Operator.IsUserAdmin(
    operatorId => operatorIdIns
    , roleId => roleId
  );

  insert into op_operator_role(
    operator_id
    , role_id
    , user_access_flag
    , grant_option_flag
    , action_type_code
    , computer_name
    , ip_address
    , change_operator_id
    , operator_id_ins
  )
  values(
    operatorId
    , roleId
    , coalesce( userAccessFlag, 1 )
    , coalesce( grantOptionFlag, 0 )
    , pkg_AccessOperator.CreateOperatorRole_ActTpCd
    , computerName
    , ipAddress
    , operatorIdIns
    , operatorIdIns
  );

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '��� ���������� ���� ��������� ��������� ������ ('
          || 'operatorId="' || to_char( operatorId ) || '"'
          || ' , roleId="' || to_char( roleId ) || '"'
          || ' , userAccessFlag="' || to_char( userAccessFlag ) || '"'
          || ' , grantOptionFlag="' || to_char( grantOptionFlag ) || '"'
          || ' , operatorIdIns="' || to_char( operatorIdIns ) || '"'
          || ' , computerName="' || computerName || '"'
          || ' , ipAddress="' || ipAddress || '"'
          || ').'
        )
    , true
  );
end createOperatorRole;

/* proc: updateOperatorRole
  ��������� �������������� ����� ������������ � ����.

  ������� ���������:
    operatorId                             - �� ���������
    roleId                                 - �� ����
    userAccessFlag                         - ����� �� ������������� ������
    grantOptionFlag                        - ����� �� ������ ������ ������ ����������
    operatorIdIns                          - �� �������� ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� ����������.

  ( <body::updateOperatorRole>)
*/
procedure updateOperatorRole(
  operatorId integer
  , roleId integer
  , userAccessFlag integer default null
  , grantOptionFlag integer default null
  , operatorIdIns	integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- updateOperatorRole
begin
  pkg_Operator.IsUserAdmin(
    operatorId => operatorIdIns
    , roleId => roleId
  );

  update
    op_operator_role
  set
    user_access_flag = coalesce( userAccessFlag, 1 )
    , grant_option_flag = coalesce( grantOptionFlag, 0 )
    , action_type_code = pkg_AccessOperator.UpdateOperatorRole_ActTpCd
    , computer_name = computerName
    , ip_address = ipAddress
    , change_operator_id = operatorIdIns
  where
    operator_id = operatorId
    and role_id = roleId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '��� ���������� ����� ���� � ��������� ��������� ������ ('
          || 'operatorId="' || to_char( operatorId ) || '"'
          || ' , roleId="' || to_char( roleId ) || '"'
          || ' , userAccessFlag="' || to_char( userAccessFlag ) || '"'
          || ' , grantOptionFlag="' || to_char( grantOptionFlag ) || '"'
          || ' , operatorIdIns="' || to_char( operatorIdIns ) || '"'
          || ' , computerName="' || computerName || '"'
          || ' , ipAddress="' || ipAddress || '"'
          || ').'
        )
    , true
  );
end updateOperatorRole;

/* proc: deleteOperatorRole
  ��������� �������� ���� � ���������.

  ������� ���������:
    operatorId                             - �� ���������
    roleId                                 - �� ����
    operatorIdIns                          - �� �������� ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� ����������.
*/
procedure deleteOperatorRole(
  operatorId integer
  , roleId integer
  , operatorIdIns	integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- deleteOperatorRole
begin
  -- ��������� ����� �������
  pkg_operator.IsUserAdmin(
    operatorId => operatorIdIns
    , roleId => roleId
  );

  -- ��������� ��� � ip ����� ����������, � �������� ������������ ��������
  update
    op_operator_role opr
  set
    opr.action_type_code = pkg_AccessOperator.DeleteOperatorRole_ActTpCd
    , opr.computer_name = computerName
    , opr.ip_address = ipAddress
    , opr.change_date = sysdate
    , opr.change_operator_id = operatorIdIns
  where
    opr.operator_id = operatorId
    and opr.role_id = roleId
  ;

  -- �������� ����
  delete from
    op_operator_role opr
  where
    opr.operator_id = operatorId
    and opr.role_id = roleId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '������ ��� �������� ���� � ��������� ('
          || 'operatorId="' || to_char( operatorId ) || '"'
          || ' roleId="' || to_char( roleId ) || '"'
          || ' operatorIdIns="' || to_char( operatorIdIns ) || '"'
          || ' computerName="' || computerName || '"'
          || ' ipAddress="' || ipAddress || '"'
          || ').'
        )
      , true
    );
end deleteOperatorRole;

/* func: findOperatorRole
  ������� ������ ����� ������������ � ���� FindOperatorRole

  ������� ���������:
    operatorId                 - ������������� ������������
    roleId                     - ������������� ����
    rowCount                   - ������������ ���������� ������������ �������
    operatorIdIns              - ������������, �������������� �����

  ������� (� ���� �������):
    operator_id                - ������������� ������������
      role_id                  - ������������� ����
      short_name               - ������� ������������ ����
      role_name                - ������������ ���� �� ����� �� ���������
      role_name_en             - ������������ ���� �� ���������� �����
      description              - �������� ���� �� ����� �� ���������
      date_ins                 - ���� �������� ������
      operator_id_ins          - ������������, ��������� ������
      operator_name_ins        - ������������ �� ����� �� ���������, ��������� ������
      operator_name_ins_en     - ������������ �� ���������� �����, ��������� ������
      user_access_flag         - ������� ������� � ����
      grant_option_flag        - ������� ������ ���� � ����
*/
function findOperatorRole(
  operatorId integer default null
  , roleId integer default null
  , rowCount integer default null
  , operatorIdIns integer
)
return sys_refcursor
is
  dSql varchar2(32767);
  rc sys_refcursor;

-- findOperatorRole
begin
  pkg_Operator.IsUserAdmin( operatorIdIns, null );

  dSql := '
select
  t.operator_id
  , t.role_id
  , opr.short_name
  , opr.role_name
  , opr.role_name_en
  , opr.description
  , t.date_ins
  , t.operator_id_ins
  , (
    select
      op1.operator_name
    from
      op_operator op1
    where
      op1.operator_id = t.operator_id_ins
    ) as operator_name_ins
  , (
    select
      op1.operator_name_en
    from
      op_operator op1
    where
      op1.operator_id = t.operator_id_ins
    ) as operator_name_ins_en
  , t.user_access_flag
  , t.grant_option_flag
from
  op_operator_role t
inner join
  op_role opr
on
  opr.role_id = t.role_id
inner join
  op_operator op
on
  op.operator_id = t.operator_id_ins
where
  1 = 1'
  ;

  addSqlCondition( dSql, 't.operator_id', '=', operatorId is null );
  addSqlCondition( dSql, 't.role_id', '=', roleId is null );
  addSqlCondition( dSql, 'rownum', '<=', rowCount is null, 'rowCount' );

  open
    rc
  for
    dSql || ' order by t.operator_id , t.role_id '
	using
    operatorId
    , roleId
    , rowCount
  ;

  return rc;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�������� ������ ��� ������ ���� ���������.'
      , true
    );
end findOperatorRole;



/* group: ������� ��� ������ � �������� ��������� */

/* proc: createOperatorGroup
  ��������� ���������� ������ ���������.

  ������� ���������:
    operatorID                             - ID ���������
    groupID                                - ID ������
    userAccessFlag                         - ����� �� ������������� ������
    grantOptionFlag                        - ����� �� ������ ������ ������ ����������
    operatorIDIns                          - ID ���������, ������������ ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.
*/
procedure createOperatorGroup(
  operatorId integer
  , groupId integer
  , userAccessFlag integer default null
  , grantOptionFlag integer default null
  , operatorIdIns integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- createOperatorGroup
begin
  -- ��������� ����� �������
  pkg_operator.IsUserAdmin(
    operatorId => operatorIdIns
    , groupId => groupId
  );

  -- ������ ������ ���������
  insert into op_operator_group(
    operator_id
    , group_id
    , user_access_flag
    , grant_option_flag
    , action_type_code
    , computer_name
    , ip_address
    , change_operator_id
    , operator_id_ins
  )
  values(
    operatorId
    , groupId
    , coalesce( userAccessFlag, 0 )
    , coalesce( grantOptionFlag, 0 )
    , pkg_AccessOperator.CreateOperatorGroup_ActTpCd
    , computerName
    , ipAddress
    , operatorIdIns
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
          || ' , userAccessFlag="' || to_char( userAccessFlag ) || '"'
          || ' , grantOptionFlag="' || to_char( grantOptionFlag ) || '"'
          || ' , operatorIdIns="' || to_char( operatorIdIns ) || '"'
          || ' , computerName="' || computerName || '"'
          || ' , ipAddress="' || ipAddress || '"'
          || ').'
        )
      , true
    );
end createOperatorGroup;

/* proc: updateOperatorGroup
  ��������� �������������� ����� ������ � ���������.

  ������� ���������:
    operatorID                             - ID ���������
    groupID                                - ID ������
    userAccessFlag                         - ����� �� ������������� ������
    grantOptionFlag                        - ����� �� ������ ������ ������ ����������
    operatorIDIns                          - ID ���������, ������������ ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.

  ( <body::updateOperatorGroup>)
*/
procedure updateOperatorGroup(
  operatorId integer
  , groupId integer
  , userAccessFlag integer default null
  , grantOptionFlag integer default null
  , operatorIdIns integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- updateOperatorGroup
begin
  -- ��������� ����� �������
  pkg_operator.IsUserAdmin(
    operatorId => operatorIdIns
    , groupId => groupId
  );

  -- ��������� ����� ������ � ���������
  update
    op_operator_group
  set
    user_access_flag = coalesce( userAccessFlag, 0 )
    , grant_option_flag = coalesce( grantOptionFlag, 0 )
    , action_type_code = pkg_AccessOperator.CreateOperatorGroup_ActTpCd
    , computer_name = computerName
    , ip_address = ipAddress
    , change_operator_id = operatorIdIns
  where
    operator_id = operatorId
    and group_id = groupId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '������ ��� ���������� ����� ��������� � ������ ('
          || ' operatorId="' || to_char( operatorId ) || '"'
          || ' , groupId="' || to_char( groupId ) || '"'
          || ' , userAccessFlag="' || to_char( userAccessFlag ) || '"'
          || ' , grantOptionFlag="' || to_char( grantOptionFlag ) || '"'
          || ' , operatorIdIns="' || to_char( operatorIdIns ) || '"'
          || ' , computerName="' || computerName || '"'
          || ' , ipAddress="' || ipAddress || '"'
          || ').'
        )
      , true
    );
end updateOperatorGroup;

/* proc: deleteOperatorGroup
  ��������� �������� ������ � ���������.

  ������� ���������:
    operatorID                             - ID ���������
    groupID                                - ID ������
    operatorIDIns                          - ID ���������, ������������ ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.
*/
procedure deleteOperatorGroup(
  operatorId integer
  , groupId integer
  , operatorIdIns integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- deleteOperatorGroup
begin
  -- ��������� ����� �������
  pkg_operator.IsUserAdmin(
    operatorId => operatorIdIns
    , groupId => groupId
  );

  -- ��������� ��� � ip ����� ����������, � �������� ������������ ��������
  update
    op_operator_group opg
  set
    opg.action_type_code = pkg_AccessOperator.DeleteOperatorGroup_ActTpCd
    , opg.computer_name = computerName
    , opg.ip_address = ipAddress
    , opg.change_date = sysdate
    , opg.change_operator_id = operatorIdIns
  where
    opg.operator_id = operatorId
    and opg.group_id = groupId
  ;

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
          || ' , computerName="' || computerName || '"'
          || ' , ipAddress="' || ipAddress || '"'
          || ').'
        )
      , true
    );
end deleteOperatorGroup;

/* func: findOperatorGroup
  ������� ������ ����� ����������.

  ������� ���������:
    operatorID                             - ID ���������
    groupId                                - ������������� ������
    isActualOnly                           - ������� ������ ������ ����������������� ����������
    rowCount                               - ������������ ���������� ������������ �������
    operatorIdIns                          - ������������, �������������� �����

  ������� (� ���� �������):
    operator_id                            - ������������� ������������
    login                                  - ����� ���������
    operator_name                          - ��� ���������
    group_id                               - ������������� ������
    group_name                             - ������������ ������ �� ����� �� ���������
    group_name_en                          - ������������ ������ �� ���������� �����
    date_ins                               - ���� �������� ������
    operator_id_ins                        - ������������, ��������� ������
    operator_name_ins                      - ������������ �� ����� �� ���������, ��������� ������
    operator_name_ins_en                   - ������������ �� ���������� �����, ��������� ������
    user_access_flag                       - ������� ��������� � ������
    grant_option_flag                      - ������� ������ ���� �� ������
*/
function findOperatorGroup(
  operatorId integer default null
  , groupId integer default null
  , isActualOnly integer default null
  , rowCount integer default null
  , operatorIdIns	integer
)
return sys_refcursor
is
  sqlStr varchar2(32767);
  -- ������ � ����������� ������
  resultSet sys_refcursor;

-- findOperatorGroup
begin
  -- ��������� ��������� ���� ��� ��������� ���������� �� ������ �������
  if pkg_Operator.isRole(
       operatorId => operatorIdIns
       , roleShortName => pkg_AccessOperator.OpShowUsers_RoleSNm
     ) = 0
  then
    pkg_Operator.IsUserAdmin( operatorIdIns, null );
  end if;

  sqlStr := '
select
  opg.operator_id
  , op.login
  , op.operator_name
  , opg.group_id
  , g.group_name
  , g.group_name_en
  , opg.date_ins
  , opg.operator_id_ins
  , opins.operator_name as operator_name_ins
  , opins.operator_name_en as operator_name_ins_en
  , opg.user_access_flag
  , opg.grant_option_flag
from
  op_operator_group opg
inner join
  op_group g
on
  opg.group_id = g.group_id
inner join
  op_operator op
on
  opg.operator_id = op.operator_id
  ' || case when
         coalesce( isActualOnly, 0 ) = 1
       then
         'and op.date_finish is null'
       end
  || '
inner join
  op_operator opins
on
  opg.operator_id_ins = opins.operator_id
where
  1=1 '
  ;

  addSqlCondition( sqlStr, 'opg.operator_id', '=', operatorId is null );
  addSqlCondition( sqlStr, 'opg.group_id', '=', groupId is null );
  addSqlCondition( sqlStr, 'rownum', '<=', rowCount is null, 'rowCount' );

  open
    resultSet
  for
    sqlStr
    || ' order by opg.group_id, op.operator_name'
	using
    operatorId
    , groupId
    , rowCount
  ;

  -- ������ ���������
  return resultSet;

-- ����������� ��������� ����������
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '�� ����� ������ ����� ���������� ��������� ������ ('
          || 'operatorId="' || to_char( operatorId ) || '"'
          || ', groupId="' || to_char( groupId ) || '"'
          || ', rowCount="' || to_char( rowCount ) || '"'
          || ', operatorIdIns="' || to_char( operatorIdIns ) || '"'
          || ').'
        )
      , true
    );
end findOperatorGroup;




/* group: ������� ��� ������ �� ������� ����-������*/

/* proc: createGroupRole
  ��������� ���������� ���� � ������.

  ������� ���������:
    groupID                                - ID ������
    roleID                                 - ID ����
    operatorID                             - ID ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.
*/
procedure createGroupRole(
  groupId integer
  , roleId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- createGroupRole
begin
  -- ��������� ����� ���������
  pkg_operator.IsRole( operatorID, RoleAdmin_Role );

  -- �������� ���� � ������
  insert into op_group_role(
    group_id
    , role_id
    , action_type_code
    , computer_name
    , ip_address
    , change_operator_id
    , operator_id
  )
  values(
    groupId
    , roleId
    , pkg_AccessOperator.CreateGroupRole_ActTpCd
    , computerName
    , ipAddress
    , operatorId
    , operatorId
  );

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '��� ��������� ���� � ������ �������� ������ ('
          || ' groupId="' || to_char( groupId ) || '"'
          || ', roleId="' || to_char( roleId ) || '"'
          || ', operatorId="' || to_char( operatorId ) || '"'
          || ', computerName="' || computerName || '"'
          || ', ipAddress="' || ipAddress || '"'
          || ').'
        )
      , true
    );
end createGroupRole;

/* proc: deleteGroupRole
  ��������� �������� ���� �� ������.

  ������� ���������:
    groupID                                - ID ������
    roleID                                 - ID ����
    operatorID                             - ID ���������
    computerName                           - ��� ����������, � �������� ������������ ��������
    ipAddress                              - IP ����� ����������, � �������� ������������ ��������

  �������� ��������� �����������.
*/
procedure deleteGroupRole(
  groupId integer
  , roleId integer
  , operatorId integer
  , computerName varchar2 default null
  , ipAddress varchar2 default null
)
is
-- deleteGroupRole
begin
  -- ��������� ����� ���������
  pkg_operator.IsRole( operatorID, RoleAdmin_Role );

  -- ��������� ��� � ip ����� ����������, � �������� ������������ ��������
  update
    op_group_role gr
  set
    gr.action_type_code = pkg_AccessOperator.DeleteGroupRole_ActTpCd
    , gr.computer_name = computerName
    , gr.ip_address = ipAddress
    , gr.change_date = sysdate
    , gr.change_operator_id = operatorId
  where
    gr.group_id = groupId
    and gr.role_id = roleId
  ;

  -- ������� ���� �� ������
  delete from
    op_group_role gr
  where
    gr.group_id = groupId
    and gr.role_id = roleId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '��� �������� ���� �� ������ �������� ������ ('
          || ' groupId="' || to_char( groupId ) || '"'
          || ', roleId="' || to_char( roleId ) || '"'
          || ', operatorId="' || to_char( operatorId ) || '"'
          || ', computerName="' || computerName || '"'
          || ', ipAddress="' || ipAddress || '"'
          || ').'
        )
      , true
    );
end deleteGroupRole;

/* func: findGroupRole
  ������� ������ ����� ������ � ���� FindGroupRole

  ������� ���������:
    groupId	-	������������� ������
    roleId	-	������������� ����
    rowCount	-	������������ ���������� ������������ �������
    operatorId	-	������������, �������������� �����

  �������� ���������(� ���� �������):
    group_id	-	������������� ������
    role_id	-	������������� ����
    short_name	-	������� ������������ ����
    role_name	-	������������ ���� �� ����� �� ���������
    role_name_en	-	������������ ���� �� ���������� �����
    description	-	�������� ���� �� ����� �� ���������
    date_ins	-	���� �������� ������
    operator_id	-	������������, ��������� ������
    operator_name	-	������������ �� ����� �� ���������, ��������� ������
    operator_name_en	-	������������ �� ���������� �����, ��������� ������
*/
function findGroupRole(
  groupId integer default null
  , roleId integer default null
  , rowCount integer default null
  , operatorId integer
)
return sys_refcursor
is
  dSql varchar2(32767);
  rc sys_refcursor;

-- findGroupRole
begin
  -- ��������� ��������� ���� ��� ��������� ���������� �� ������ �������
  if pkg_Operator.isRole(
       operatorId => operatorId
       , roleShortName => pkg_AccessOperator.OpShowUsers_RoleSNm
     ) = 0
     and pkg_Operator.isRole(
           operatorId => operatorId
           , roleShortName => pkg_AccessOperator.RoleAdmin_Role
         ) = 0
  then
    raise_application_error(
      pkg_Error.RigthisMissed
      , '������������ ���� ��� ��������� ������ ������-����.'
    );
  end if;

  dSql := '
select
  gr.group_id
  , gr.role_id
  , r.short_name
  , r.role_name
  , r.role_name_en
  , r.description
  , gr.date_ins
  , op.operator_id
  , op.operator_name
  , op.operator_name_en
from
  op_group_role gr
inner join
  op_role r
on
  r.role_id = gr.role_id
inner join
  op_operator op
on
  op.operator_id = gr.operator_id
where
  1 = 1'
  ;

  addSqlCondition( dSql, 'gr.group_id', '=', groupId is null );
  addSqlCondition( dSql, 'gr.role_id', '=', roleId is null );
  addSqlCondition( dSql, 'rownum', '<=', rowCount is null, 'rowCount' );

  open
    rc
  for
    dSql || ' order by gr.group_id, gr.role_id'
	using
    groupId
    , roleId
    , rowCount
  ;

  -- ������ ���������
  return rc;

-- ����������� ��������� ����������
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�������� ������ ��� ������ ������ ������-����.'
    , true
  );
end findGroupRole;

/* func: operatorLoginReport
  ����� �� �������.

  ������� ���������:
    operatorDateInsFrom             - ���� �������� ��������� �
    operatorDateInsTo               - ���� �������� ��������� ��
    AccessOperatorId                - ID ���������
    AccessOperatorName              - ��� ���������
    operatorBlockEnsign             - ������� ����������
    groupId                         - ID ������
    groupDateInsFrom                - ���� ���������� � ����� �
    groupDateInsTo                  - ���� ���������� � ������ ��
    roleId                          - ID ����
    roleDateInsFrom                 - ���� ���������� ���� �
    roleDateInsTo                   - ���� ���������� ���� ��
    rowCount                        - ����� �����

  �������( � ���� �������):
    operator_id                     - ID ���������
    operator_name                   - ��� ���������
    employee_name                   - ��� � ����������� �����������
    login                           - �����
    branch_name                     - �������� �������
    operator_block_ensign           - ������� ����������
    date_ins                        - ���� �������� ��������
    operator_name_ins               - ��� ���������
    date_finish                     - ���� ��������� �������� ������ � ���������
    group_id                        - ID ������
    group_name                      - �������� ������
    group_date_ins                  - ���� ���������� ��������� � �����
    group_operator_name_ins         - ��� ��������� ������� ������� � ������
    role_id                         - ID ����
    role_name                       - �������� ����
    role_date_ins                   - ���� ���������� ���� ���������
    role_operator_name_ins          - ��� ��������� ������� ����� ����
*/
function operatorLoginReport(
  operatorDateInsFrom date
  , operatorDateInsTo date
  , accessOperatorId integer
  , accessOperatorName varchar2
  , operatorBlockEnsign integer
  , groupId integer
  , groupDateInsFrom date
  , groupDateInsTo date
  , roleId integer
  , roleDateInsFrom date
  , roleDateInsTo date
  , rowCount integer
  , operatorId integer
)
return sys_refcursor
is
  rc sys_refcursor;
  searchCondition varchar2(4000);
  dSql varchar2(32767) := '
select
  t.operator_id
  , t.operator_name
  , t.employee_name
  , t.login
  , t.branch_name
  , t.operator_block_ensign
  , t.date_ins
  , t.operator_name_ins
  , t.date_finish
  , t.group_id
  , t.group_name
  , t.group_date_ins
  , t.group_operator_name_ins
  , t.role_id
  , t.role_name
  , t.role_date_ins
  , t.role_operator_name_ins
from
  (
  select
    op.operator_id
    , op.operator_name
    , emp.first_name_rus || '' '' || emp.middle_name_rus
        || '' '' || emp.last_name_rus as employee_name
    , op.login
    , br.branch_name_rus as branch_name
    , case when
        op.date_finish is null
      then
        1
      else
        2
      end as operator_block_ensign
    , op.date_ins
    , (
      select
        opins.operator_name
      from
        op_operator opins
      where
        opins.operator_id = op.operator_id_ins
      ) as operator_name_ins
    , op.date_finish
    , opr.source_group_id as group_id
    , g.group_name
    , case when
        opr.source_group_id is not null
      then
        opr.date_ins
      end as group_date_ins
    , (
      select
        gop.operator_name
      from
        op_operator gop
      where
        gop.operator_id = opr.operator_id_ins
        and opr.source_group_id is not null
      ) as group_operator_name_ins
    , opr.role_id
    , r.role_name
    , case when
        opr.source_group_id is null
      then
        opr.date_ins
      end as role_date_ins
    , (
      select
        rop.operator_name
      from
        op_operator rop
      where
        rop.operator_id = opr.operator_id_ins
        and opr.source_group_id is null
      ) as role_operator_name_ins
  from
    op_operator op
  left join
    v_emp_employee emp
  on
    emp.employee_operator_id = op.operator_id
  left join
    v_ps_branch br
  on
    br.branch_id = emp.branch_id
  left join
    v_op_operator_role opr
  on
    opr.operator_id = op.operator_id
  left join
    op_group g
  on
    g.group_id = opr.source_group_id
  left join
    v_op_role r
  on
    r.role_id = opr.role_id
  where
    $(searchCondition)
    ' || case when
           operatorBlockEnsign = 1
         then
           ' and op.date_finish is null '
         when
           operatorBlockEnsign = 2
         then
           ' and op.date_finish is not null '
         end
      || case when
           groupDateInsFrom is not null
           or groupDateInsTo is not null
         then
           ' and opr.source_group_id is not null '
         when
           roleDateInsFrom is not null
           or roleDateInsTo is not null
         then
           ' and opr.source_group_id is null '
         end
  || '
  ) t
order by
  t.operator_name
  , t.group_name'
  ;

-- operatorLoginReport
begin
  -- �������� ����
  if pkg_Operator.IsRole( operatorId, 'OpShowUsers' ) = 0 then
    raise_application_error(
      pkg_Error.RigthisMissed
      , logger.ErrorStack(
          '������������ ���� ��� ������������ ������ �� '
          || '������� ����������.'
        )
      , true
    );
  end if;

  -- ������� ������
  addSqlCondition(
    searchCondition
    , 'trunc( op.date_ins )'
    , '>='
    , operatorDateInsFrom is null
    , 'operatorDateInsFrom'
  );
  addSqlCondition(
    searchCondition
    , 'trunc( op.date_ins )'
    , '<='
    , operatorDateInsTo is null
    , 'operatorDateInsTo'
  );
  addSqlCondition(
    searchCondition
    , 'op.operator_id'
    , '='
    , accessOperatorId is null
    , 'accessOperatorId'
  );
  addSqlCondition(
    searchCondition
    , 'upper( op.operator_name )'
    , 'like'
    , accessOperatorName is null
    , 'accessOperatorName'
  );
  addSqlCondition(
    searchCondition
    , 'opr.source_group_id'
    , '='
    , groupId is null
    , 'groupId'
  );
  addSqlCondition(
    searchCondition
    , 'trunc( opr.date_ins )'
    , '>='
    , groupDateInsFrom is null
    , 'groupDateInsFrom'
  );
  addSqlCondition(
    searchCondition
    , 'trunc( opr.date_ins )'
    , '<='
    , groupDateInsTo is null
    , 'groupDateInsTo'
  );
  addSqlCondition(
    searchCondition
    , 'opr.role_id'
    , '='
    , roleId is null
    , 'roleId'
  );
  addSqlCondition(
    searchCondition
    , 'trunc( opr.date_ins )'
    , '>='
    , roleDateInsFrom is null
    , 'roleDateInsFrom'
  );
  addSqlCondition(
    searchCondition
    , 'trunc( opr.date_ins )'
    , '<='
    , roleDateInsTo is null
    , 'roleDateInsTo'
  );
  addSqlCondition(
    searchCondition
    , 'rownum'
    , '<='
    , rowCount is null
    , 'rowCount'
  );
  logger.Debug(
    'sql="' || replace( dSql, '$(searchCondition)', searchCondition ) || '"'
  );

  open
    rc
  for
    replace( dSql, '$(searchCondition)', searchCondition )
	using
    operatorDateInsFrom
    , operatorDateInsTo
    , accessOperatorId
    , upper( AccessOperatorName )
    , groupId
    , groupDateInsFrom
    , groupDateInsTo
    , roleId
    , roleDateInsFrom
    , roleDateInsTo
    , rowCount
  ;

  return rc;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '�� ����� ������������ ������ �� ������� ���������� '
          || '��������� ������.'
        )
      , true
    );
end operatorLoginReport;

/* func: autoUnlockOperator
   ������� �������������� ������������ ����������, � ������� ��������� ������ ��������� ����������.

   ������� ���������:
     operatorId                   - ������������� ���������

   �������:
     operator_unlocked_count      - ���������� ���������������� ����������
*/
function autoUnlockOperator(
  operatorId integer
)
return integer
is
-- unlockOperator
begin
  -- ������������ ����������
  update
    op_operator op
  set
    op.date_finish = null
    , op.curr_login_attempt_count = 0
    , op.change_operator_id = operatorId
  where
    exists(
      select
        null
      from
        v_op_login_attempt_group g
      where
        -- ��������� ����������
        g.lock_type_code = pkg_Operator.Temporal_LockTypeCode
        and g.login_attempt_group_id = op.login_attempt_group_id
        and g.max_login_attempt_count < op.curr_login_attempt_count
        and g.locking_time < ( sysdate - op.date_finish ) * 24 * 60 * 60
    )
  ;
  return sql%rowcount;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorInfo
      , '�� ����� �������������� ������������ ���������� ��������� ������.'
      , true
    );
end autoUnlockOperator;



/* group: ������� ��� ������ � �������� ���������� */


/* func: createLoginAttemptGroup
   ������� �������� ������ ���������� ����������.

   ������� ���������:
     loginAttemptGroupName        - ������������ ������
     isDefault                    - ������� �� ���������
     lockTypeCode                 - ��� ����������
     maxLoginAttemptCount         - ����������� ���������� ����������
                                    ������� ����� � �������
     lockingTime                  - ����� ���������� � ��������
     usedForCl                    - ������������ ��� CL
     blockWaitPeriod              - ���������� ����, ���������� ���������� ���������
                                    ��� ���������� ����������
     operatorId                   - ������������, ��������� ������

   �������:
     login_attempt_group_id       - ������������� ��������� ������
*/
function createLoginAttemptGroup(
  loginAttemptGroupName varchar2
  , isDefault number default 0
  , lockTypeCode varchar2
  , maxLoginAttemptCount integer default null
  , lockingTime integer default null
  , usedForCl number default 0
  , blockWaitPeriod integer default null
  , operatorId integer
)
return integer
is
  loginAttemptGroupId integer;

-- createLoginAttemptGroup
begin
  -- �������� ����
  pkg_Operator.isRole(
    operatorId => operatorId
    , roleShortName => pkg_Operator.OpLoginAttmptGrpAdmin_RoleName
  );

  if coalesce( isDefault, 0 ) = 1 then
    update
      op_login_attempt_group grp
    set
      grp.is_default = 0
    where
      grp.is_default = 1
    ;
  end if;

  -- ��������� ������
  insert into op_login_attempt_group(
    login_attempt_group_name
    , is_default
    , lock_type_code
    , max_login_attempt_count
    , used_for_cl
    , locking_time
    , block_wait_period
    , change_operator_id
    , operator_id
  )
  values(
    loginAttemptGroupName
    , isDefault
    , lockTypeCode
    , maxLoginAttemptCount
    , usedForCl
    , lockingTime
    , blockWaitPeriod
    , operatorId
    , operatorId
  )
  returning login_attempt_group_id into loginAttemptGroupId
  ;

  return loginAttemptGroupId;

exception
  when dup_val_on_index then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ � ����� ������ ��� ���������� ���� ���� ����������� ������ '
        || '���������� ��� CL ('
        || 'loginAttemptGroupName="' || loginAttemptGroupName || '"'
        || ', used_for_cl="' || to_char( usedForCl ) || '"'
        || ').'
      , true
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� �������� ������ ���������� ���������� ��������� ������ ('
        || 'loginAttemptGroupName="' || loginAttemptGroupName || '"'
        || ', isDefault="' || to_char( isDefault ) || '"'
        || ', lockTypeCode="' || lockTypeCode || '"'
        || ', maxLoginAttemptCount="' || to_char( maxLoginAttemptCount ) || '"'
        || ', lockingTime="' || to_char( lockingTime ) || '"'
        || ', usedForCl="' || to_char( usedForCl ) || '"'
        || ', blockWaitPeriod="' || to_char( blockWaitPeriod ) || '"'
        || ', operatorId="' || to_char( operatorId ) || '"'
        || ').'
      , true
    );
end createLoginAttemptGroup;

/* proc: updateLoginAttemptGroup
   ��������� �������������� ������ ���������� ����������.

   ������� ���������:
     loginAttemptGroupId          - �� ������
     loginAttemptGroupName        - ������������ ������
     isDefault                    - ������� �� ���������
     lockTypeCode                 - ��� ����������
     maxLoginAttemptCount         - ����������� ���������� ����������
                                    ������� ����� � �������
     lockingTime                  - ����� ���������� � ��������
     usedForCl                    - ������������ ��� CL
     blockWaitPeriod              - ���������� ����, ���������� ���������� ���������
                                    ��� ���������� ����������
     operatorId                   - ������������,��������� ������

   �������� ��������� �����������.
*/
procedure updateLoginAttemptGroup(
  loginAttemptGroupId integer
  , loginAttemptGroupName varchar2
  , isDefault number default 0
  , lockTypeCode varchar2
  , maxLoginAttemptCount integer default null
  , lockingTime integer default null
  , usedForCl number default null
  , blockWaitPeriod integer default null
  , operatorId integer
)
is
-- updateLoginAttemptGroup
begin
  -- �������� ����
  pkg_Operator.isRole(
    operatorId => operatorId
    , roleShortName => pkg_Operator.OpLoginAttmptGrpAdmin_RoleName
  );

  if coalesce( isDefault, 0 ) = 1 then
    update
      op_login_attempt_group grp
    set
      grp.is_default = 0
    where
      grp.is_default = 1
    ;
  end if;

  update
    op_login_attempt_group grp
  set
    grp.login_attempt_group_name = loginAttemptGroupName
    , grp.is_default = isDefault
    , grp.lock_type_code = lockTypeCode
    , grp.max_login_attempt_count = maxLoginAttemptCount
    , grp.used_for_cl = usedForCl
    , grp.locking_time = lockingTime
    , grp.block_wait_period = blockWaitPeriod
    , grp.change_date = sysdate
    , grp.change_operator_id = operatorId
  where
    grp.login_attempt_group_id = loginAttemptGroupId
  ;

exception
  when dup_val_on_index then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ � ����� ������ ��� ���������� ���� ���� ����������� ������ '
        || '���������� ��� CL ('
        || 'loginAttemptGroupName="' || loginAttemptGroupName || '"'
        || ', used_for_cl="' || to_char( usedForCl ) || '"'
        || ').'
      , true
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� �������������� ������ ���������� ���������� ��������� ������ ('
        || 'loginAttemptGroupId="' || to_char( loginAttemptGroupId ) || '"'
        || ', loginAttemptGroupName="' || loginAttemptGroupName || '"'
        || ', isDefault="' || to_char( isDefault ) || '"'
        || ', lockTypeCode="' || lockTypeCode || '"'
        || ', maxLoginAttemptCount="' || to_char( maxLoginAttemptCount ) || '"'
        || ', lockingTime="' || to_char( lockingTime ) || '"'
        || ', usedForCl="' || to_char( usedForCl ) || '"'
        || ', blockWaitPeriod="' || to_char( blockWaitPeriod ) || '"'
        || ', operatorId="' || to_char( operatorId ) || '"'
        || ').'
      , true
    );
end updateLoginAttemptGroup;

/* proc: deleteLoginAttemptGroup
   ��������� �������� ������ ���������� ����������.

   ������� ���������:
     loginAttemptGroupId          - �� ������
     operatorId                   - �� ���������

   �������� ��������� �����������.
*/
procedure deleteLoginAttemptGroup(
  loginAttemptGroupId integer
  , operatorId integer
)
is
  loginAttemptGroupRec op_login_attempt_group%rowtype;
  -- ���� ������� � ������ ����������������� �������������
  isUnblockedUsrInGrpExists integer;

-- deleteLoginAttemptGroup
begin
  -- �������� ����
  pkg_Operator.isRole(
    operatorId => operatorId
    , roleShortName => pkg_Operator.OpLoginAttmptGrpAdmin_RoleName
  );
  -- ��������� ��������� ������
  select
    *
  into
    loginAttemptGroupRec
  from
    op_login_attempt_group t
  where
    t.login_attempt_group_id = loginAttemptGroupId
  ;

  -- ��������, ���������� �� ����������������� ���������,
  -- ����������� � ��������� ������
  select
    max( 1 )
  into
    isUnblockedUsrInGrpExists
  from
    dual
  where
    exists(
      select
        null
      from
        op_operator op
      where
        op.login_attempt_group_id = loginAttemptGroupId
    )
  ;

  -- ������������ ���������
  -- ������ �� ������ ���� � ������ �� ���������
  if loginAttemptGroupRec.Is_Default = 1 then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '���������� ������� ������ � ��������� �� ���������.'
      , true
    );
  -- � ������ �� ������ ���� ��������� ����������������� ���������
  elsif isUnblockedUsrInGrpExists is not null then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '���������� ������� ������, ��� ��� ���������� '
        || '����������������� ������������, ����������� � ���� ������.'
      , true
    );
  end if;

  -- ������� ������
  update
    op_login_attempt_group grp
  set
    grp.deleted = 1
    , grp.change_date = sysdate
    , grp.change_operator_id = operatorId
  where
    grp.login_attempt_group_id = loginAttemptGroupId
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� �������� ������ ���������� ���������� ��������� ������ ('
        || 'loginAttemptGroupId="' || to_char( loginAttemptGroupId ) || '"'
        || ', operatorId="' || to_char( operatorId ) || '"'
        || ').'
      , true
    );
end deleteLoginAttemptGroup;

/* func: findLoginAttemptGroup
   ������� ������ ������ ���������� ����������.

   ������� ���������:
     loginAttemptGroupId          - �� ������
     loginAttemptGroupName        - ������������ ������
     isDefault                    - ������� �� ���������
     lockTypeCode                 - ��� ����������
     maxRowCount                  - ���������� ������� � �������
     operatorId                   - ������������,��������� ������

   ������� (� ���� �������):
     login_attempt_group_id       - ������������� ������
     login_attempt_group_name     - ������������ ������
     is_default                   - ������� �� ���������
     lock_type_code               - ��� ����������
     lock_type_name               - ������������ ����
     max_login_attempt_count      - ����������� ���������� ����������
                                    ������� ����� � �������
     locking_time                 - ����� ���������� � ��������
     used_for_cl                  - ������� ������������� ��� CL
     block_wait_period            - ���������� ����, ���������� ���������� ���������
                                    ��� ���������� ����������
*/
function findLoginAttemptGroup(
  loginAttemptGroupId integer default null
  , loginAttemptGroupName varchar2 default null
  , isDefault number default null
  , lockTypeCode varchar2 default null
  , maxRowCount number default null
  , operatorId integer default null
)
return sys_refcursor
is
  resultSet sys_refcursor;
  sqlStr varchar2(4000);

-- findLoginAttemptGroup
begin
  -- �������� ����
  pkg_Operator.isRole(
    operatorId => operatorId
    , roleShortName => pkg_Operator.OpLoginAttmptGrpAdmin_RoleName
  );

  -- ��������� ������
  sqlStr :='
select
  grp.login_attempt_group_id
  , grp.login_attempt_group_name
  , grp.is_default
  , grp.lock_type_code
  , lt.lock_type_name
  , grp.max_login_attempt_count
  , grp.locking_time
  , grp.used_for_cl
  , grp.block_wait_period
from
  op_login_attempt_group grp
inner join
  op_lock_type lt
on
  grp.lock_type_code = lt.lock_type_code
  and grp.deleted = 0'
  ;

  addSqlCondition(
    sqlStr
    , 'grp.login_attempt_group_id'
    , '='
    , loginAttemptGroupId is null
    , 'loginAttemptGroupId'
  );
  addSqlCondition(
    sqlStr
    , 'upper( trim( grp.login_attempt_group_name ) )'
    , 'like'
    , loginAttemptGroupName is null
    , 'loginAttemptGroupName'
  );
  addSqlCondition(
    sqlStr
    , 'grp.is_default'
    , '='
    , isDefault is null
    , 'isDefault'
  );
  addSqlCondition(
    sqlStr
    , 'grp.lock_type_code'
    , '='
    , lockTypeCode is null
    , 'lockTypeCode'
  );
  addSqlCondition(
    sqlStr
    , 'rownum'
    , '<='
    , maxRowCount is null
    , 'maxRowCount'
  );

  open
    resultSet
  for
    sqlStr
  using
    loginAttemptGroupId
    , upper( trim( loginAttemptGroupName ) )
    , isDefault
    , lockTypeCode
    , maxRowCount
  ;

  return resultSet;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ������ ������ ���������� ���������� ��������� ������ ('
        || 'loginAttemptGroupId="' || to_char( loginAttemptGroupId ) || '"'
        || ', loginAttemptGroupName="' || loginAttemptGroupName || '"'
        || ', isDefault="' || to_char( isDefault ) || '"'
        || ', lockTypeCode="' || lockTypeCode || '"'
        || ', maxRowCount="' || to_char( maxRowCount ) || '"'
        || ', operatorId="' || to_char( operatorId ) || '"'
        || ').'
      , true
    );
end findLoginAttemptGroup;

/* func: getLoginAttemptGroup
   ������� ��������� ������ ������ ���������� ����������.

   ������� ���������:
     lockTypeCode                 - ��� ����������

   ������� (� ���� �������):
     login_attempt_group_id       - ������������� ������
     login_attempt_group_name     - ������������ ������
     is_default                   - ������� �� ���������
     lock_type_code               - ��� ����������
     lock_type_name               - ������������ ����
     max_login_attempt_count      - ����������� ���������� ����������
                                    ������� ����� � �������
     locking_time                 - ����� ���������� � ��������
     block_wait_period            - ���������� ����, ���������� ���������� ���������
                                    ��� ���������� ����������
*/
function getLoginAttemptGroup(
  lockTypeCode varchar2 default null
)
return sys_refcursor
is
  resultSet sys_refcursor;
  sqlStr varchar2(4000);

-- getLoginAttemptGroup
begin
  -- ��������� ������
  sqlStr := '
select
  grp.login_attempt_group_id
  , grp.login_attempt_group_name
  , grp.is_default
  , grp.lock_type_code
  , lt.lock_type_name
  , grp.max_login_attempt_count
  , grp.locking_time
  , grp.used_for_cl
  , grp.block_wait_period
from
  op_login_attempt_group grp
inner join
  op_lock_type lt
on
  grp.lock_type_code = lt.lock_type_code
  and grp.deleted = 0
  and grp.used_for_cl = 0'
  ;
  addSqlCondition(
    sqlStr
    , 'grp.lock_type_code'
    , '='
    , lockTypeCode is null
    , 'lockTypeCode'
  );

  open
    resultSet
  for
    sqlStr
  using
    lockTypeCode
  ;

  return resultSet;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ��������� ������ ������ ���������� ���������� '
        || ' ��������� ������ ('
        || 'lockTypeCode="' || lockTypeCode || '"'
        || ').'
      , true
    );
end getLoginAttemptGroup;

/* proc: changeLoginAttemptGroup
   ��������� �������� ����� ������ ���������� ����������.

   ������� ���������:
     oldLoginAttemptGroupId       - ������������� ������, � �������
                                    �������������� �������
     newLoginAttemptGroupId       - ������������� ������, �� �������
                                    �������������� �������
     operatorId                   - �� ���������

   �������� ��������� �����������.
*/
procedure changeLoginAttemptGroup(
  oldLoginAttemptGroupId integer
  , newLoginAttemptGroupId integer
  , operatorId integer
)
is
-- changeLoginAttemptGroup
begin
  -- �������� ����
  pkg_Operator.isRole(
    operatorId => operatorId
    , roleShortName => pkg_Operator.OpLoginAttmptGrpAdmin_RoleName
  );

  -- ������������ ��������� ��� ���������� �������� change_operator_id,
  -- ���� ����� ���� ����
  pkg_Operator.setCurrentUserId( operatorId );

  -- ������ ������
  update
    op_operator op
  set
    op.login_attempt_group_id = newLoginAttemptGroupId
  where
    op.login_attempt_group_id = oldLoginAttemptGroupId
    and op.date_finish is null
  ;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� �������� ����� ������ ���������� ���������� '
        || ' ��������� ������ ('
        || 'oldLoginAttemptGroupId="'
          || to_char( oldLoginAttemptGroupId ) || '"'
        || ', newLoginAttemptGroupId="'
          || to_char( newLoginAttemptGroupId ) || '"'
        || ', operatorId="' || to_char( operatorId ) || '"'
        || ').'
      , true
    );
end changeLoginAttemptGroup;



/* group: ������� �� ������ ��������� ���� */

/* proc: setAdminGroup
  ������� ������ ����������������� ����� ��������� �� ������

  ���������:
  targetOperatorId            - �������������, �������� �������� �����
  groupId                     - ������������� ������
  operatorId                  - ������������� ������������
*/
procedure setAdminGroup(
  targetOperatorId            integer
, groupId                     integer
, operatorId                  integer
)
is
-- setAdminGroup
begin
  pkg_Operator.IsUserAdmin( operatorId, null );

  update
    op_operator_group
  set
    grant_option_flag = 1
  where
    group_id = groupId
    and operator_id = targetOperatorId
  ;

  if sql%rowcount = 0 then
    insert into
      op_operator_group
    (
      operator_id
    , group_id
    , user_access_flag
    , grant_option_flag
    , operator_id_ins
    )
    values (
      targetOperatorId
    , groupId
    , 0
    , 1
    , operatorId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������ ����������������� ����� ���������. ('
      || 'targetOperatorId=' || to_char(targetOperatorId)
      || ', groupId=' || to_char(groupId)
      || ', operatorId=' || to_char(operatorId)
      || ').'
      )
    , true
  );
end setAdminGroup;

/* proc: setAdminRole
  ������� ������ ����������������� ����� ��������� �� ����

  ���������:
  targetOperatorId            - �������������, �������� �������� �����
  roleId                      - ������������� ����
  operatorId                  - ������������� ������������
*/
procedure setAdminRole(
  targetOperatorId            integer
, roleId                      integer
, operatorId                  integer
)
is
-- setAdminRole
begin
  pkg_Operator.IsUserAdmin( operatorId, null );

  update
    op_operator_role
  set
    grant_option_flag = 1
  where
    role_id = roleId
    and operator_id = targetOperatorId
  ;

  if sql%rowcount = 0 then
    insert into
      op_operator_role
    (
      operator_id
    , role_id
    , user_access_flag
    , grant_option_flag
    , operator_id_ins
    )
    values (
      targetOperatorId
    , roleId
    , 0
    , 1
    , operatorId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������ ����������������� ����� ���������. ('
      || 'targetOperatorId=' || to_char(targetOperatorId)
      || ', roleId=' || to_char(roleId)
      || ', operatorId=' || to_char(operatorId)
      || ').'
      )
    , true
  );
end setAdminRole;

end pkg_AccessOperator;
/
