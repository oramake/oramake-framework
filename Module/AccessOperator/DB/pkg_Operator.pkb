CREATE OR REPLACE PACKAGE BODY PKG_OPERATOR is
/* package body: pkg_Operator::body */

/* ���������� ���������� ����� ������ */
Password_MinLength CONSTANT INTEGER := 8;
/*������� ��������� ������� �������*/
Password_LogHistory CONSTANT INTEGER := 3;

/* ID �������� ��������� */
CurrentOperatorId integer;

/* ����� �������� ��������� */
CurrentLogin op_operator.login%type;

/* ��� �������� ��������� (���) */
CurrentOperatorName op_operator.operator_name%type;



/* group: ������� */

/* iproc: AddSqlCondition
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
procedure AddSqlCondition(
  searchCondition in out nocopy varchar2
  , fieldExpr varchar2
  , operation varchar2
  , isNullValue boolean
  , parameterExpr varchar2 := null
)
is

                                        --������� ���������� �������� ��������
  isBinaryOp boolean := coalesce( not isNullValue, false);

--AddSqlCondition
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
end AddSqlCondition;

/* ifunc: getPasswordValidityPeriod
  ������� ��������� ����� �������� ������ � ����.

  ������� ���������:
    operatorId                                - �� ���������

  �������:
    passwordValidityPeriod                    - ���� �������� ������ � ����
*/
function getPasswordValidityPeriod(
  operatorId integer
)
return integer
is
  passwordValidityPeriod integer;

-- getPasswordValidityPeriod
begin
  select
    max( t.password_validity_period )
  into
    passwordValidityPeriod
  from
    op_operator op
  inner join
    op_login_attempt_group t
  on
    op.login_attempt_group_id = t.login_attempt_group_id
  where
    op.operator_id = operatorId
  ;

  return passwordValidityPeriod;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ��������� ����� �������� ������ � ����'
        || ' ��������� ������ ('
        || 'operatorId="' || to_char( operatorId ) || '"'
        || ').'
      , true
    );
end getPasswordValidityPeriod;

/* func: getHash
  ���������� hex-������ � MD5 ����������� ������.

  ���������:

  inputString                 - �������� ������ ��� ������� ����������� �����;

  �������:
  - ���������� hex-������ � MD5 ����������� ������;
*/
function getHash(
  inputString varchar2
)
return varchar2
is
-- getHash
begin
  return
    case when inputString is not null then
      rawtohex( utl_raw.cast_to_raw(
        dbms_obfuscation_toolkit.md5( input_string => inputString)
      ))
    else
      null
    end
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ����������� ������'
    , true
  );
end getHash;

/* func: getHashSalt
  ������� ����������� ������ � "�����".

  ������� ���������:
    password                              - ������

  �������:
    hashSalt                              - ��� ������ � "�����"
*/
function getHashSalt(
  password varchar2
)
return varchar2
is
  hashSalt varchar2(4000);
  sqlStr varchar2(32767);

-- getHashSalt
begin
  -- �������� � ������������ sql ��� ������ ������
  -- ����������� �� ������ Option, ��� � ����
  -- ������� ���������� ��� ����� �������
  -- �������������� ��������� ������
  sqlStr := '
declare
  -- ����� ��� ������ � �������
  optionList opt_option_list_t := opt_option_list_t(
    moduleName => pkg_Operator.Module_Name
  );
begin
  :hashSalt := optionList.getString(
    optionShortName => pkg_Operator.HashSalt_OptSName
    , raiseNotFoundFlag => 0
  );
end;';

  execute immediate
    sqlStr
  using
    out hashSalt
  ;

  return getHash( password || hashSalt );

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ����������� ������ � "�����" ��������� ������.'
      , true
    );
end getHashSalt;



/* group: ����������� */

/* iproc: login
  ��������� �������� � ������������ ��������� � ��. � ������ ��������
  ����������� ��������� ������ ��������� � ���������� ������, ��� ������
  ����������� - ����������� ����������.

  ������� ���������:
    operatorID                  - ID ���������;
    operatorLogin               - ����� ��������� ( ������������ ������ ����
                                  operatorID null);
    password                    - ������ ��� �������� �������;
    isCheckPassword             - ����� �� ��������� �������� ������ ( ����
                                 null, �� ���������);
    passwordHash                - ��� ������

  �������� ��������� �����������.

 ���������:
   ������� ������ �������� �� �����, ������ ����������� � ������ ��������
*/
procedure login(
  operatorId integer default null
  , operatorLogin varchar2 default null
  , password varchar2 default null
  , isCheckPassword boolean default null
  , passwordHash varchar2 default null
)
is
  -- ������ ���������
  rec op_operator%rowtype;
  -- ���� �������� ���� �������
  checkDate date;

  /*
    ��������� ��������� ���������� � ������ -
    ���� ���������� �������� ������������� ����� ������
    ���������� ���� ���� ��������� ������.
  */
  procedure setLoginInfo(
    operatorId integer
    , isSuccessfulLogin integer default 0
    , currLoginAttemptCount integer default null
    , loginAttemptGroupId integer default null
  )
  is
  pragma autonomous_transaction;
    maxLoginAttemptCount integer;
    lockTypeCode op_lock_type.lock_type_code%type;

  -- setLoginInfo
  begin
    -- ���� ��� �������� ����� - ������������� ����
    if coalesce( isSuccessfulLogin, 0 ) = 1 then
      -- ��������� ���� ��������� ������ � ���������� ����������
      -- ��������� ������� �����
      update
        op_operator op
      set
        op.last_success_login_date = sysdate
        , op.curr_login_attempt_count = 0
      where
        op.operator_id = operatorId
      ;
    -- ���� ��� ��������� ������ ������ - �����������
    -- ���������� ������� ����� ������
    elsif loginAttemptGroupId is not null then
      select
        max( grp.max_login_attempt_count )
        , max( grp.lock_type_code )
      into
        maxLoginAttemptCount
        , lockTypeCode
      from
        op_login_attempt_group grp
      where
        grp.login_attempt_group_id = loginAttemptGroupId
      ;
      -- ���� ��������� ����������� ���������� ����������
      -- ������� ����� - ��������� ���������
      if coalesce( currLoginAttemptCount, 0 ) + 1 > maxLoginAttemptCount
        and lockTypeCode != pkg_Operator.Unused_LockTypeCode
      then
        -- �������� �� ��������� - ������, ��������� ��� �� �����
        -- �������
        pkg_Operator.setCurrentUserId( 1 );

        update
          op_operator op
        set
          op.curr_login_attempt_count =
            coalesce( currLoginAttemptCount, 0 ) + 1
          , op.date_finish = sysdate
          , op.operator_comment = nvl(
              op.operator_comment
              , '�������� ������������. ���������  ��������'
                || ' ������� ����� � �������.'
            )
        where
          op.operator_id = operatorId
          -- ���� �������� ������������ - �� ��������� ���
          -- ��� ��������� ���������� ������� �����
          and op.date_finish is null
        ;
      -- ����� - ����������� ������� ��������� �������
      elsif coalesce( currLoginAttemptCount, 0 ) + 1 <= maxLoginAttemptCount
        and lockTypeCode != pkg_Operator.Unused_LockTypeCode
      then
        update
          op_operator op
        set
          op.curr_login_attempt_count =
            coalesce( currLoginAttemptCount, 0 ) + 1
        where
          op.operator_id = operatorId
        ;
      end if;
    end if;

    commit;

  exception
    when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '�� ����� ���������� ���������� � ������'
          || ' ��������� ������.'
        , true
      );
  end setLoginInfo;

-- login
begin
  -- �������� ������� ������ ���������
  begin
    if operatorId is not null then
      select
        op.*
      into
        rec
      from
        op_operator op
      where
        op.operator_id = operatorId
      ;
    else
      -- ��������� ��� ����� ���������������
      -- �������.
      select /*+ index( op) */
        op.*
      into
        rec
      from
        op_operator op
      where
        upper( op.login ) = upper( operatorLogin )
      ;
    end if;
  exception
    when no_data_found then
      null;
  end;
  -- ��������� �����/������ ( �� ���������
  -- ������ ��-�� ��������� ������
  -- � ������������� ������)
  if rec.operator_id is null
    or (
      coalesce( isCheckPassword, true)
      and coalesce( rec.password <> GetHash( password ), true)
      -- ��� ����������� ���������� �� ������������� CRM
      -- Microsoft Dynamics
      and coalesce( getHashSalt( rec.password ) <> passwordHash, true )
    )
  then
    -- ���� ��� ������ ������������ ������ - �����������
    -- ������� ���������� �������
    setLoginInfo(
      operatorId => rec.operator_id
      , currLoginAttemptCount => rec.curr_login_attempt_count
      , loginAttemptGroupId => rec.login_attempt_group_id
    );

    raise_application_error(
      pkg_Error.IllegalArgument
      , '������ ��������'
        || case when operatorID is not null then
            ' ID ���������'
          else
            ' �����'
          end
        || ' ��� ������.'
    );
  end if;
  -- ��������� ���� �������� ���������
  checkDate := sysdate;
  if checkDate < rec.date_begin or checkDate > rec.date_finish then
    raise_application_error(
      pkg_Error.RigthIsMissed
      , '������ � ������� ��������.'
    );
  end if;

  -- ��������� ������ ���������
  CurrentOperatorId := rec.operator_id;
  CurrentLogin := rec.login;
  CurrentOperatorName := rec.operator_name;

  -- ��������� ���� ��������� ������ � ���������� ����������
  -- ��������� ������� �����
  setLoginInfo(
    operatorId => rec.operator_id
    , isSuccessfulLogin => 1
  );

exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ����������� ��������� ('
      || substr(
        case when operatorID is not null then
          ', operator_id=' || to_char( operatorID)
        end
        || case when operatorLogin is not null then
          ', login="' || operatorLogin || '"'
        end
        , 2)
      || ').'
    , true
  );
end login;

/* func: login
  ������������ ��������� � ���� �� ������ �
  ������/���� ������ � ���������� ��� ���������.

  ������� ���������:
    operatorLogin               - ����� ���������
    password                    - ������

  �������:
    current_operator_name       - ��� �������� ���������
*/
function login(
  operatorLogin varchar2
  , password varchar2
  , passwordHash varchar2 default null
)
return varchar2
is
-- login
begin
  login(
    operatorLogin => operatorLogin
    , password => password
    , isCheckPassword => true
    , passwordHash => passwordHash
  );

  return CurrentOperatorName;

end login;

/* func: login
  ������������ ��������� � ���� � ���������� ��� ���������.

  ���������:
  operatorLogin               - ����� ���������;

  �������� ���������:

 CurrentOperatorName - ;
)
*/
function login( operatorLogin varchar2)
return varchar2
is
-- login
begin
  login(
    operatorLogin       => operatorLogin
    , isCheckPassword   => false
  );
  return CurrentOperatorName;
end Login;

/* proc: login
  ������������ ��������� � ���� ( ��� �������� ������).

  ���������:
  operatorLogin               - ����� ���������
*/
procedure login(
  operatorLogin varchar2
)
is
-- login
begin
  login(
    operatorLogin       => operatorLogin
    , isCheckPassword   => false
  );
end login;

/* proc: setCurrentUserId
  ������������ ��������� � ���� ( ��� �������� ������).

  ���������:
  operatorId                  - Id ���������;
*/
procedure setCurrentUserId( operatorId integer)
is
-- setCurrentUserId
begin
  login(
    operatorId          => operatorId
    , isCheckPassword   => false
  );
end setCurrentUserId;

/* proc: remoteLogin
  ������������ �������� ��������� � ��������� ��.

  ���������:
  dbLink                      - ��� ����� � ��������� ��;
*/
procedure remoteLogin(
  dbLink varchar2
)
is
-- remoteLogin
begin
  --�������������� � ��������� ��
  execute immediate
    'begin'
      || ' pkg_Operator.login@' || dbLink || '( :login);'
    || ' end;'
  using
    in currentLogin
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ����������� �������� ��������� �� ����� "'
      || dbLink || '".'
    , true
  );
end remoteLogin;

/* proc: logoff
  �������� ������� �����������;
*/
procedure logoff
is
-- logoff
begin
  currentOperatorId           := null;
  currentLogin                := null;
  currentOperatorName         := null;
end logoff;

/* func: getCurrentUserId
   ���������� ID �������� ���������.

   ������� ���������:
     isRaiseException - ���� ������������ ���������� � ������,
                        ���� ������� �������� �� ���������
                        0 - ���� �� �������
                        1 - ���� �������

   �������:
     oprator_id       - �� �������� ���������

*/
function getCurrentUserId(
  isRaiseException integer default 1
)
return integer
is
-- getCurrentUserId
begin
  if CurrentOperatorId is null
    and coalesce(isRaiseException, 1) = 1
  then
    raise_application_error(
      pkg_Error.OperatorNotRegister
      , '�� �� ������������������.'
        || ' ��� ����������� � ������� ��������� ������� Login.'
    );
  end if;
  return CurrentOperatorId;
end getCurrentUserId;

/* func: getCurrentUserName
   ���������� ��� �������� ���������.

   ������� ���������:
     isRaiseException - ���� ����������� ���������� � ������,
                        ���� ������� �������� �� ���������
                        0 - ���� �� �������
                        1 - ���� �������

   �������:
     oprator_name     - ��� �������� ���������

*/
function getCurrentUserName(
  isRaiseException integer default 1
)
return varchar2
is
--getCurrentUserName
begin
  --��������� �������� �����������
  if getCurrentUserID(
       isRaiseException => isRaiseException
     ) is null
  then
    null;
  end if;
  return CurrentOperatorName;
end getCurrentUserName;



/* group: �������� */

/* ifunc: isRole
  ��������� ������� ���� � ���������.

  ������� ���������:

  operatorId                  - id ���������
  roleId                      - id ����
  roleShortName               - �������� ������������ ����
  checkDate                   - ����, �� ������ ������� ����������� �������
                                ����

  ������������ ��������:
  1 - �����������;
  0 - �� �����������;
*/
function isRole(
  operatorId integer
  , roleId integer := null
  , roleShortName varchar2 := null
  , makeError boolean := false
)
return integer
is
  -- ������� ������� ����
  isGrant integer := 0;
  -- ������ �� ���������
  operatorNameRus op_operator.operator_name%type;
  dateBegin date;
  dateFinish date;
  -- �������� ������������ ����
  shortName v_op_role.role_short_name%type;
  -- ���� �������� ���� �������
  checkDate date;

--IsRole
begin
  begin
    select
      op.operator_name
      , op.date_begin
      , op.date_finish
      , rl.role_short_name
      , coalesce((
          select
            1
          from
            v_op_operator_role orv
          where
            orv.operator_id = op.operator_id
            and orv.role_id = rl.role_id
            and rownum <= 1
        ), 0)
        as is_grant
    into operatorNameRus, dateBegin, dateFinish, shortName, isGrant
    from
      op_operator op
      cross join v_op_role rl
    where
      op.operator_id = operatorId
      and (
        rl.role_id = roleId
        or rl.role_short_name = roleShortName
        )
    ;
  exception when NO_DATA_FOUND then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������ �������������� Id ��������� ���'
        || case when roleId is not null then
            ' Id'
          else
            ' ���'
          end
        || ' ����.'
    );
  end;
  --��������� ���� �������� ���������
  checkDate := sysdate;
  if checkDate < dateBegin or checkDate > dateFinish then
    isGrant := 0;
    --������� ���������� ( ���� ����)
    if makeError then
      raise_application_error(
        pkg_Error.RigthIsMissed
        , '������ � ������� ��������.'
      );
    end if;
  end if;
  --������� ���������� ( ���� ����)
  if isGrant = 0 and makeError then
    raise_application_error(
      pkg_Error.RigthIsMissed
      , '� ���, '
        || operatorNameRus
        || ', ��� ���� �� ���������� ������ �������� ('
        || ' role_short_name="' || shortName || '"'
        ||').'
    );
  end if;
  return isGrant;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� �������� ������� ���� � ��������� ('
      || ' operator_id=' || to_char( operatorId)
      || case when roleId is not null then
          ', role_id=' || to_char( roleId)
        else
          ', short_name="' || to_char( roleShortName) || '"'
        end
      || ').'
    , true
  );
end isRole;

/* func: isRole(operatorId,DEPRECATED)
  ��������� ������� ���� � ���������.

  ���������:
  operatorId                  - id ���������
  roleId                      - id ����

  ������������ ��������:
  1 - ���� �����������;
  0 - ���� �� �����������;

  ���������:
  - ���������� �������. �� ������������.
*/
function isRole(
  operatorId integer
, roleId     integer
)
return integer
is
-- isRole
begin
  return
    isRole(
      operatorId        => operatorId
      , roleId          => roleId
      , makeError       => false
    )
  ;
end isRole;

/* func: isRole(operatorId)
  ��������� ������� ���� � ���������.

  ���������:

  operatorId                  - id ���������
  roleShortName               - �������� ������������ ����

  ������������ ��������:
  1 - ���� �����������;
  0 - ���� �� �����������;
*/
function isRole(
  operatorId integer
  , roleShortName varchar2
)
return integer
is
-- isRole
begin
  return
    isRole(
      operatorId        => operatorId
      , roleShortName   => roleShortName
      , makeError       => false
    )
  ;
end isRole;

/* func: isRole
  ��������� ������� ���� � �������� ���������.

  ���������:
  roleShortName               - ��� ����;

  ������������ ��������:
  1 - ���� �����������;
  0 - ���� �� �����������;
*/
function isRole(
  roleShortName varchar2
)
return integer
is
  -- ������� ������ ����
  isGrant integer := 0;

--IsRole
begin
  if currentOperatorId is not null then
    isGrant := isRole(
      operatorId        => currentOperatorId
      , roleShortName   => roleShortName
      , makeError       => false
    );
  end if;
  return isGrant;
end isRole;

/* proc: isRole(operatorId,DEPRECATED)
  ��������� ������� ���� � ��������� � � ������ �� ���������� �����������
  ����������.

  ��������:

  operatorID                  - ID ���������;
  roleID                      - ID ����;

  ���������:
  - ���������� �������. �� ������������.
*/
procedure isRole
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 )
is
  --������� ������� ����
  isGrant integer;

--IsRole
begin
  isGrant := isRole(
    operatorID        => operatorId
  , roleID            => roleId
  , makeError         => true
  );
end isRole;

/* proc: isRole(operatorId)
  ��������� ������� ���� � ��������� � � ������ �� ���������� �����������
  ����������.

  ��������:

  operatorId                  - id ���������;
  roleShortName               - ��� ����;
*/
procedure isRole(
  operatorId integer
  , roleShortName varchar2
)
is
  -- ������� ������� ����
  isGrant integer;

-- isRole
begin
  isGrant := isRole(
    operatorId        => operatorId
    , roleShortName   => roleShortName
    , makeError       => true
  );
end isRole;

/* proc: isRole
  ��������� ������� ���� � �������� ��������� � � ������ ����������
  ����������� ��� ���� ����������� ����������.

  ��������:
  roleShortName               - ��� ����
*/
procedure isRole(
  roleShortName varchar2
)
is

  -- ������� ������� ����
  isGrant integer;

--IsRole
begin
  isGrant := isRole(
    operatorId        => getCurrentUserId()
    , roleShortName   => roleShortName
    , makeError       => true
  );
end isRole;

/* proc: isUserAdmin
  ��������� ����� �� ����������������� ���������� � � ������ �� ����������
  ����������� ����������.

  ������� ���������:

  operatorID                  - ID ���������, ������������ ��������;
  targetOperatorID            - ID ���������, ��� ������� ����������� ��������;
  roleID                      - ID ����������/���������� ����;
  groupID                     - ID ����������/���������� ������;

*/
procedure isUserAdmin
 (OPERATORID INTEGER
 ,TARGETOPERATORID INTEGER := null
 ,ROLEID INTEGER := null
 ,GROUPID INTEGER := null
 )
is

  procedure CheckGrantRole is
  --��������� ����� �� ������ ����.

    isGrant integer := 0;

  --CheckGrantRole
  begin
    select
      count(*) as is_grant
    into isGrant
    from
      v_op_operator_grant_role orv
    where
      orv.operator_id = operatorID
      and orv.role_id = roleID
      and rownum <= 1
    ;
    if isGrant = 0 then
      raise_application_error(
        pkg_Error.RigthIsMissed
        , '��� ���� �� ������ ���� ('
          || ' operator_id=' || to_char( operatorID)
          || ', role_id=' || to_char( roleID)
          || ').'
      );
    end if;
  end CheckGrantRole;



  procedure CheckGrantGroup is
  --��������� ����� �� ��������� ������� ������.

    isGrant integer := 0;

  --CheckGrantGroup
  begin
    select
      count(*) as is_grant
    into isGrant
    from
      v_op_operator_grant_group ogg
    where
      ogg.operator_id = operatorID
      and ogg.group_id = groupID
      and rownum <= 1
    ;
    if isGrant = 0 then
      raise_application_error(
        pkg_Error.RigthIsMissed
        , '��� ���� �� ������ ������ ('
          || ' operator_id=' || to_char( operatorID)
          || ', group_id=' || to_char( groupID)
          || ').'
      );
    end if;
  end CheckGrantGroup;



  procedure CheckRights is
  --���������, ��� ����� ����������� ��������� �� ������ ���� ��������������.
  --��� �� ������, ����� � �������������� �� �������� �����.

    roleID op_role.role_id%type;
    groupID op_group.group_id%type;

  --CheckRights
  begin
                                        --��������� ����������� ����
    select
      min( role_id)
    into roleID
    from
      (
      select distinct
        opr.role_id
      from
        op_operator_role opr
      where
        opr.operator_id = targetOperatorID
        and opr.user_access_flag = 1
      minus
      select
        opr.role_id
      from
        v_op_operator_role opr
      where
        opr.operator_id = operatorID
      minus
      select
        opgr.role_id
      from
        v_op_operator_grant_role opgr
      where
        opgr.operator_id = operatorID
      ) rl
    ;
    if roleID is not null then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '��������� ���������,'
          || ' �.�. � ����������� ��������� ���� �������������� ���� ('
          || ' role_id=' || to_char( roleID)
          || ').'
      );
    end if;
                                        --��������� ������
    select
      min( d.group_id)
    into groupID
    from
      (
      select distinct
        opr.group_id
      from
        op_operator_group opr
      where
        opr.operator_id = targetOperatorID
        and opr.user_access_flag = 1
      minus
      select distinct
        opr.group_id
      from
        op_operator_group opr
      where
        opr.operator_id = operatorID
        and opr.user_access_flag = 1
      minus
      select distinct
        opgr.group_id
      from
        v_op_operator_grant_group opgr
      where
        opgr.operator_id = operatorID
      ) d
    ;
    if groupID is not null then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '��������� ���������,'
          || ' �.�. ���������� �������� ������� � �������������� ������ ('
          || ' group_id=' || to_char( groupID)
          || ').'
      );
    end if;
  end CheckRights;



--IsUserAdmin
begin
                                        --��������� ����� �� �����������������
  IsRole( operatorID, UserAdmin_Role);
                                        --��������� ����� �� ������ ����
  if roleID is not null then
    CheckGrantRole;
  end if;
                                        --��������� ����� �� ��������� � ������
  if groupID is not null then
    CheckGrantGroup;
  end if;
                                        --���������� ����� ����������
  if operatorID <> targetOperatorID then
    CheckRights;
  end if;
end IsUserAdmin;



/* group: ��������� ������ (��������� � pkg_AccessOperator) */

/* proc: checkPassword
  ��������� �������� ������.

  ������� ���������:
    operatorId          - ������������, �������� ���������� ������������
    password            - ������� ������
    newPassword         - ����� ������
    newPasswordConfirm  - ����� ������ ( �������������)
    opratorIdIns        - ������������� ���������
    passwordPolicyCode  - ��� ��������� �������� (
                          NUM_U_L - ����� + ����� � ������� �������� + ����� � ������ ��������
                          NUM_U_L_SP - ����� + ����� � ������� �������� + ����� � ������ ��������
                            + �����������
                          ). �� ��������� "NUM_U_L_SP".
*/
procedure checkPassword(
  operatorId integer
  , password varchar2 default null
  , newPassword varchar2
  , newPasswordConfirm varchar2 default null
  , operatorIdIns integer default null
  , passwordPolicyCode varchar2 default null
)
is
  passwordHash varchar2(50) := pkg_Operator.getHash( password);
  newPasswordHash varchar2(50) := pkg_Operator.getHash( newPassword);
  operatorLogin varchar2(50);
  currentPasswordHash varchar2(50);
  operatorNameEn varchar2(100);



  /*
    ������� �������� ���������� �������.
  */
  function checkPasswordHistoryRepeat(
    passwordRepeatHistory integer default Password_LogHistory
  )
  return boolean
  is
    repeatCount integer;

  -- checkPasswordHistoryRepeat
  begin
    select
      count(*)
    into
      repeatCount
    from
      (
      select
        k.password
      from
        (
        select
          ph.password
        from
          op_password_hist ph
        where
          ph.operator_id = operatorId
        order by
          ph.password_history_id desc
        ) k
      where
        rownum <= passwordRepeatHistory
      ) t
    where
      t.password = newPasswordHash
    ;

    return repeatCount > 0;
  end checkPasswordHistoryRepeat;

-- checkPassword
begin
  -- ���� ������� ������ ���������
  select
    op.password
    , op.login
    , op.operator_name_en
  into
    currentPasswordHash
    , operatorLogin
    , operatorNameEn
  from
    op_operator op
  where
    op.operator_id = operatorId
  for update of op.password nowait
  ;

  -- ��������� ����� �������
  if operatorIdIns is not null then
    isUserAdmin(
      operatorID          => operatorIdIns
      , targetOperatorID  => operatorId
    );
  else
    -- ��������� ������� ������
    if coalesce( currentPasswordHash != passwordHash, true) then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������� ������ ������ �������'
      );

    -- ��������� ����� ������
    elsif coalesce( length( newPassword), 0) < Password_MinLength then
      raise_application_error(
        pkg_Error.WrongPasswordLength
        , '����� ������ �� ����� ���� ������ '
          || Password_MinLength
          || ' ��������'
      );
    -- ����� ������ ������ ���������� �� ��������
    elsif currentPasswordHash = newPasswordHash then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '����� ������ ��������� � �������'
      );
    -- ��������� ��������� ��������
    elsif length( newPassword) =
            length( translate( newPassword, '.0123456789', '.'))
      or length( newPassword) =
           length( translate( newPassword, '.ABCDEFGHIJKLMNOPQRSTUVWXYZ', '.'))
      or length( newPassword) =
           length( translate( newPassword, '.abcdefghijklmnopqrstuvwxyz', '.'))
      -- ����. �������
      or (
        length( newPassword) =
          length( translate( newPassword, 'E!%:*()@#$^&-_+,.<>/?\{}', 'E'))
        and coalesce( passwordPolicyCode, pkg_Operator.NumULSp_PasswordPolicyCode)
          = pkg_Operator.NumULSp_PasswordPolicyCode
      )
    then
      raise_application_error(
        pkg_Error.WrongPasswordLength
        , '������ ������ ��������� ������� �� ������� ��������� '
          || '[a..z],[A..Z],[0..9]'
          || case when
               coalesce( passwordPolicyCode, pkg_Operator.NumULSp_PasswordPolicyCode)
                 = pkg_Operator.NumULSp_PasswordPolicyCode
             then
               ',[!%:*()@#$^&-_+,.<>/?\{}]'
             end
        , true
      );
    -- ��������� ���������� ����� �������
    elsif coalesce(
            newPassword != newPasswordConfirm
            , coalesce( newPassword, newPasswordConfirm) is not null
          )
    then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '����� ������ �� ��������� � ��������������'
      );
    -- ���������, ��� � ����� ������ �� ���������� �����/�������/���
    elsif instr( upper( newPassword), upper( trim( operatorLogin))) > 0
      or instr(
           upper( newPassword)
           , upper(
               trim(
                 regexp_substr( operatorNameEn, '[^ ]+', 1, 1)
               )
             )
         ) > 0
      -- ��������� ��� ������ ���� ��� ����� >=3, ����� �������,
      -- ��� � ����� �������� �����
      or (
        instr(
           upper( newPassword)
           , upper(
               trim(
                 regexp_substr( operatorNameEn, '[^ ]+', 1, 2)
               )
             )
        ) > 0
        and length( regexp_substr( operatorNameEn, '[^ ]+', 1, 2)) >= 3
      )
    then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������ �� ����� ��������� � ���� �������, ��� ��� ����� ������������'
      );

    -- ��������� ���������� �������
    elsif checkPasswordHistoryRepeat() then
      raise_application_error(
        pkg_Error.WrongPasswordLength
        , '����� ������ �� ����� ��������� ������ ��������'
      );
    end if;
  end if;
exception
  when no_data_found then
    raise_application_error(
      pkg_Error.RowNotFound
      , '�������� �� ������'
    );
end checkPassword;

/* iproc: changePassword
  ������ ������ � ���������.

  ���������:
    operatorID                  - ID ���������;
    password                    - ������;
    newPassword                 - ����� ������;
    newPasswordConfirm          - ������������� ������;
    operatorIDIns               - ID ���������, ������������ ���������;
*/
procedure changePassword(
  operatorId integer
  , password varchar2 default null
  , newPassword varchar2
  , newPasswordConfirm varchar2 default null
  , operatorIdIns integer default null
  , passwordPolicyCode varchar2 default null
)
is
-- changePassword
begin
  -- ������������ ��������� ��� ���������� �������� change_operator_id,
  -- ���� ����� ���� ����
  pkg_Operator.setCurrentUserId( coalesce( operatorIdIns, operatorId));

  -- �������� ������
  pkg_Operator.checkPassword(
    operatorId => operatorId
    , password => password
    , newPassword => newPassword
    , newPasswordConfirm => newPasswordConfirm
    , operatorIdIns => operatorIdIns
    , passwordPolicyCode => passwordPolicyCode
  );

  -- ������ ������ ���������
  update
    op_operator op
  set
    op.password = pkg_Operator.getHash( newPassword)
    -- ���������� ������� ������������� ����� ������
    , op.change_password = 0
  where
    op.operator_id = operatorId
  ;
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ ��� ����� ������ ��������� ('
        || ' operator_id=' || to_char( operatorId)
        || ').'
      , true
    );
end changePassword;

/* iproc: changePasswordHash
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
passwordHash                    - ������;
newPasswordHash             - Hash ����� ������;
newPasswordConfirmHash      - Hash ������������� ������;
operatorIDIns               - ID ���������, ������������ ���������;
*/
procedure changePasswordHash
 ( operatorId             integer
 , passwordHash           varchar2 := null
 , newPasswordHash        varchar2
 , newPasswordConfirmHash varchar2 := null
 , operatorIdIns          integer := null
 )
is
                                        --���� ������
   vPasswordHash op_operator.password%type;

  cursor curPasswordLog is    --������ ��� ���������� �������
    select vh.password
      from v_op_password_hist vh
    where vh.operator_id = OPERATORID
    order by date_end desc;

  pass varchar(50);                --������������ ������
  newPasswordUpper varchar2(100);  --���������� ��� ��������� [A..Z]
  newPasswordLower varchar2(100);  --���������� ��� ��������� [a..z]
  newPasswordDigit varchar2(100);  --���������� ��� ��������� [0..9]
  newPasswordEdit  varchar2(100);  --���������� ��� ������ ������

--ChangePasswordHash
begin
  -- ������������ ��������� ��� ���������� �������� change_operator_id,
  -- ���� ����� ���� ����
  pkg_Operator.setCurrentUserId( coalesce( operatorIdIns, operatorId ) );

                                        --��������� ������������� � ���������
                                        --(��� ��������) ������ ���������
  begin

    select
      op.password
    into vPasswordHash
    from
      op_operator op
    where
      op.operator_id = operatorID
    for update of password nowait;

    exception when NO_DATA_FOUND then     --�������� ��������� �� ������
        raise_application_error(  pkg_Error.RowNotFound , '�������� �� ������');
  end;

  if operatorIDIns is not null
  then
                                        --��������� ����� �������
    IsUserAdmin( operatorID        => operatorIDIns
               , targetOperatorID  => operatorID);
  else
                                        --��������� ������� ������
    if coalesce( vPasswordHash <> passwordHash, true)
    then

      raise_application_error(pkg_Error.IllegalArgument
        , '������� ������ ������ �������' );

    end if;

/* ��������������� �.�. ����� hash ������ ���������� ������
                                        --��������� ����� ������
    if coalesce( length( newPassword), 0) < pkg_Operator.Password_MinLength then
      raise_application_error(
        pkg_Error.WrongPasswordLength
        , '����� ������ �� ����� ���� ������ '
          || pkg_Operator.Password_MinLength
          || ' ��������.'
      );
    end if;

                            --��������� ��������� ��������

    newPasswordEdit:=newPassword;
    newPasswordDigit:=translate(newPasswordEdit,'.0123456789','.');

    newPasswordEdit:=newPassword;
    newPasswordUpper:=translate(newPasswordEdit,'.ABCDEFGHIJKLMNOPQRSTUVWXYZ','.');

    newPasswordEdit:=newPassword;
    newPasswordLower:=translate(newPasswordEdit,'.abcdefghijklmnopqrstuvwxyz','.');

    if (length(newPasswordEdit)=length(newPasswordDigit)) or
       (length(newPasswordEdit)=length(newPasswordUpper)) or
       (length(newPasswordEdit)=length(newPasswordLower)) then
      raise_application_error(pkg_Error.WrongPasswordLength,
      '������ ������ ��������� ������� �� ������� ��������� [a..z],[A..Z],[0..9]');
    end if;
                          --��������� ���������� �������
    open curPasswordLog;
    for element in 1..pkg_operator.password_log_history
    loop
      fetch curPasswordLog into pass;
      if GetHash(newpassword)=pass then
        raise_application_error(pkg_Error.WrongPasswordLength,
                                '����� ������ �� ����� ��������� ������ ��������');
      end if;
    end loop;
    close curPasswordLog;
*/
                                        --��������� ���������� ����� �������
    if coalesce( newPasswordHash <> newPasswordConfirmHash
          , coalesce( newPasswordHash, newPasswordConfirmHash) is not null
        )
    then
        raise_application_error(pkg_Error.IllegalArgument
           ,'����� ������ �� ��������� � ��������������' );
    end if;

  end if;

 --������ ������ � ���������� ��� �����
 --������
  vPasswordHash := newPasswordHash;--GetHash( newPassword);

  update
    op_operator op
  set
      op.password = vPasswordHash
    , op.change_password = 0
  where op.operator_id = operatorID;

exception when others then
  raise_application_error(pkg_Error.ErrorStackInfo
    , '������ ��� ����� ������ ��������� ('||' operator_id='||to_char(operatorID)||').', true );

end ChangePasswordHash;

/* proc: changePasswordHash
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
passwordHash                - Hash ������;
operatorIDIns               - ID ���������, ������������ ���������;
*/
procedure changePasswordHash (operatorid integer
                             ,passwordHash varchar2
                             ,operatoridins integer
                             )
is
-- changePasswordHash
begin

ChangePasswordHash ( operatorId             => operatorid
                   , passwordHash           => null
                   , newPasswordHash        => passwordHash
                   , newPasswordConfirmHash => null
                   , operatorIdIns          => operatoridins
                   );

end;

/* proc: changePasswordHash
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
passwordHash                    - Hash ������;
newPasswordHash             - Hash ����� ������;
newPasswordConfirmHash      - ������������� ������;
(<body::changePasswordHash>)
*/
procedure changePasswordHash
 (operatorid integer
 ,passwordHash varchar2
 ,newPasswordHash varchar2
 ,newPasswordConfirmHash varchar2
 )
is
--ChangePasswordHash
begin

ChangePasswordHash ( operatorId             => operatorid
                   , passwordHash           => passwordHash
                   , newPasswordHash        => newPasswordHash
                   , newPasswordConfirmHash => newPasswordConfirmHash
                   , operatorIdIns          => null
                   );

end;

/* proc: changePassword
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
password                    - ������;
operatorIDIns               - ID ���������, ������������ ���������;

*/
procedure changePassword
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,OPERATORIDINS INTEGER
 )
is
-- changePassword
begin
  changePassword(
    operatorID            => operatorID
    , password            => null
    , newPassword         => password
    , newPasswordConfirm  => null
    , operatorIDIns       => operatorIDIns
  );
end ChangePassword;

/* proc: changePassword
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
password                    - ������;
newPassword                 - ����� ������;
newPasswordConfirm          - ������������� ������;

*/
PROCEDURE changePassword
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,NEWPASSWORD VARCHAR2
 ,NEWPASSWORDCONFIRM VARCHAR2
 )
is
--changePassword
begin
  changePassword(
    operatorID            => operatorID
    , password            => password
    , newPassword         => newPassword
    , newPasswordConfirm  => newPasswordConfirm
    , operatorIDIns       => null
  );
end changePassword;

/* proc: changePassword
������ ������ � ���������.

���������:
operatorID                  - ID ���������;
password                    - ������;
newPassword                 - ����� ������;
newPasswordConfirm          - ������������� ������;
passwordPolicyCode  - ��� ��������� �������� (
                      NUM_U_L - ����� + ����� � ������� �������� + ����� � ������ ��������
                      NUM_U_L_SP - ����� + ����� � ������� �������� + ����� � ������ ��������
                        + �����������
                      ). �� ��������� "NUM_U_L_SP".
*/
PROCEDURE changePassword(
  OPERATORID INTEGER
  , PASSWORD VARCHAR2
  , NEWPASSWORD VARCHAR2
  , NEWPASSWORDCONFIRM VARCHAR2
  , passwordPolicyCode varchar2
)
is
--changePassword
begin
  changePassword(
    operatorID            => operatorID
    , password            => password
    , newPassword         => newPassword
    , newPasswordConfirm  => newPasswordConfirm
    , operatorIDIns       => null
    , passwordPolicyCode  => passwordPolicyCode
  );
end changePassword;

/* func: getOperatorName
  ������� ������ ����� ���������.

  ������� ���������:
    operatorId                  - ID ���������

  �������:
    operator_name               - ��� ���������
*/
function getOperatorName(
  operatorId integer
)
return varchar2
is
  operatorName op_operator.operator_name%type;

-- getOperatorName
begin
  select
    op.operator_name
  into
    operatorName
  from
    op_operator op
  where
    op.operator_id = operatorId
  ;

  return operatorName;
exception
  when no_data_found then
    return null;
end getOperatorName;

/* func: isChangePassword
  ���� ������������� �������������� ����� ������.

  ������� ���������:
    operatorId                  - ID ���������

  �������:
    result                      - 0 - �� ������
                                  1 - ������
*/
function isChangePassword(
  operatorId integer
)
return number
is
  needChangePassword integer;
  currentPasswordHash varchar2(50);
  operatorBeginDate date;
  -- ���-�� ���� �������� ������
  passwordDurationDay integer;

-- isChangePassword
begin
  select
    op.change_password
    , op.password
    , op.date_begin
  into
    needChangePassword
    , currentPasswordHash
    , operatorBeginDate
  from
    op_operator op
  where
    op.operator_id = operatorId
  ;

  -- ���� ������� ����� ������ ��� ���������� - �������� �� �����
  if needChangePassword = 0
    -- �������� �.:
    -- ����� ���������, ��� � ������������ ������ = 'report'
    -- ���� ������ = 'report', ������ ���������� �������� �� ���� �������� ������
    -- �� ����������
    and currentPasswordHash != 'E98D2F001DA5678B39482EFBDF5770DC'
  then
      -- ���� ���� �������� �������� ������
      select
        trunc(
          sysdate - coalesce( max( ph.date_ins), operatorBeginDate)
        ) as password_duration_day
      into
        passwordDurationDay
      from
        op_password_hist ph
      where
        ph.operator_id = operatorId
      ;
      -- ���� ���� �������� ������ ����� - ������������� ����
      -- ������������� ����� ������
      if passwordDurationDay > getPasswordValidityPeriod( operatorId) then
        needChangePassword := 1;
      end if;
  end if;

  return needChangePassword;
exception
  when no_data_found then
    return -1;
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� �������� ������������� �������������� ����� ������'
        || ' ��������� ������.'
      , true
    );
end isChangePassword;



/* group: ������� ��� ������������ ��������� ������� ����� � ����� */

/* func: getRoles
   ������� ���������� ID ����

������� ���������:

  login - �����

�������� ���������(� ���� �������):

    role_id       -  ������������� ����
    short_name    -  ������� ������������ ����
    role_name     -  ������������ ���� �� ����� �� ���������
    role_name_en  -  ������������ ���� �� ���������� �����
    description   -  �������� ���� �� ����� �� ���������
    date_ins      -  ���� �������� ������
    operator_id   -  ������������, ��������� ������
    operator_name     -  ������������ �� ����� �� ���������, ��������� ������
    operator_name_en  -  ������������ �� ���������� �����, ��������� ������

*/
FUNCTION getRoles(login  varchar2 )
return sys_refcursor
is

--������������ ������
resultSet              sys_refcursor;
--������ � ��������

sqlText                varchar2(4000);

begin

sqlText := 'select  distinct t.Role_Id
                  , r.short_name
                  , r.role_name
                  , r.role_name_en
                  , r.description
                  , r.date_ins
                  , op2.operator_id
                  , op2.operator_name
                  , op2.operator_name_en
           from v_op_operator_role t
           join op_role r
             on r.role_id = t.role_id
           join op_operator op1
             on op1.operator_id = t.operator_id
           join op_operator op2
             on op2.operator_id = r.operator_id
           where UPPER(op1.LOGIN) = upper(:login)
      order by r.short_name    ';

  --����� �� ������

  open resultSet
      for sqlText
         using upper(login);

  return resultSet;

--����������� ��������� ����������
exception
  when others then
  raise_application_error(pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ���� ��� ������: '||login, true);

end getRoles;

/* func: getRoles
   ������� ���������� ID ����

������� ���������:

  operatorId - �� ���������

�������� ���������(� ���� �������):

    role_id       -  ������������� ����
    short_name    -  ������� ������������ ����
    role_name     -  ������������ ���� �� ����� �� ���������
    role_name_en  -  ������������ ���� �� ���������� �����
    description   -  �������� ���� �� ����� �� ���������
    date_ins      -  ���� �������� ������
    operator_id   -  ������������, ��������� ������
    operator_name     -  ������������ �� ����� �� ���������, ��������� ������
    operator_name_en  -  ������������ �� ���������� �����, ��������� ������

*/
FUNCTION getRoles(operatorId  integer )
return sys_refcursor
is

--������������ ������
resultSet              sys_refcursor;
--������ � ��������

sqlText                varchar2(4000);

begin

sqlText := 'select  distinct t.Role_Id
                  , r.short_name
                  , r.role_name
                  , r.role_name_en
                  , r.description
                  , r.date_ins
                  , op2.operator_id
                  , op2.operator_name
                  , op2.operator_name_en
           from v_op_operator_role t
           join op_role r
             on r.role_id = t.role_id
           join op_operator op1
             on op1.operator_id = t.operator_id
           join op_operator op2
             on op2.operator_id = r.operator_id
           where t.operator_id = :operatorId
      order by r.short_name    ';

  --����� �� ������

  open resultSet
      for sqlText
         using operatorId;

  return resultSet;

--����������� ��������� ����������
exception
  when others then
  raise_application_error(pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ���� ��� operator_id: '||operatorId, true);

end getRoles;

 /* func: getRolesShortName
     ������� ���������� short_name ����

������� ���������:

  login - �����

�������� ���������(� ���� �������):

   short_name - short_name ����;

*/
FUNCTION getRolesShortName
 (
  login        varchar2 := null
 )
return sys_refcursor
is

--������������ ������
resultSet              sys_refcursor;
--������ � ��������

sqlText                varchar2(4000);

begin

sqlText := 'select distinct (select t.short_name from op_role t
                    where t.role_id = opr.Role_Id ) short_name
     from v_op_operator_role opr
     join op_operator op
       on op.operator_id = opr.operator_id
     where 1=1 ';

  --����� �� ������
  AddSqlCondition( sqlText,'upper(op.login)', '=', login is null, 'login');

  open resultSet
      for sqlText
         using upper(login);

  return resultSet;

--����������� ��������� ����������
exception
  when others then
  raise_application_error(pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ���� ��� ������: '||login, true);

end getRolesShortName;

 /* func: getRolesShortName
     ������� ���������� short_name ����

������� ���������:

  operatorID - operatorID

�������� ���������(� ���� �������):

   short_name - short_name ����;

(<body::getRolesShortName>)
*/
FUNCTION getRolesShortName
 (
  operatorID      integer := null
 )
return sys_refcursor
is

--������������ ������
resultSet              sys_refcursor;
--������ � ��������

sqlText                varchar2(4000);

begin

sqlText := 'select distinct (select t.short_name from op_role t
                    where t.role_id = opr.Role_Id ) short_name
     from v_op_operator_role opr
     join op_operator op
       on op.operator_id = opr.operator_id
     where 1=1 ';

  --����� �� ������
  AddSqlCondition( sqlText,'opr.operator_id', '=', operatorID is null, 'login');

  open resultSet
      for sqlText
         using operatorID;

  return resultSet;

--����������� ��������� ����������
exception
  when others then
  raise_application_error(pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ���� ��� ID ���������: '||operatorID, true);

end getRolesShortName;

/* func: getOperator
  ������ �� ����������.

  ������� ���������:
  operatorName                - ��� ��������� (���.)
  operatorName_en             - ��� ��������� (����.)
  rowCount                    - ������������ ���������� ����� � ��������
                                �������. ���������� ����. ��������� ���
                                �������������.
  maxRowCount                 - ������������ ���������� ����� � ��������
                                �������. ��-��������� 25.

  ������� (� ���� �������):
  operator_id                 - id ���������
  operator_name               - ��� ���������
  operator_name_en            - ��� ��������� (����.)
  login                       - �����
*/
function getOperator(
  operatorName varchar2 default null
  , operatorName_en varchar2 default null
  , maxRowCount integer := null
  , rowCount integer default 25
)
return sys_refcursor
is
  dSql varchar2(32767);
  -- ������ � ����������� ������
  rc sys_refcursor;

-- getOperator
begin
  -- ���������� ������ ����������� �� ������ DynamicSql
  dSql := '
select
  t.operator_id
  , t.operator_name
  , t.operator_name_en
  , t.login
from
  op_operator t
where
  ' || case when
         operatorName is not null
       then
         ' upper( t.operator_name ) like upper( :operatorName ) '
       else
         ' :operatorName is null '
       end
    || case when
         operatorName_en is not null
       then
         ' and upper( t.operator_name_en ) like upper( :operatorName_en ) '
       else
         ' and :operatorName_en is null '
       end
    || case when
         coalesce( maxRowCount, rowCount, 25) is not null
       then
         ' and rownum <= :rowCount '
       else
         ' and :rowCount is null '
       end
  ;

  open
    rc
  for
    dSql
	using
	  operatorName
	  , operatorName_en
    , coalesce( maxRowCount, rowCount, 25)
  ;

  -- ������ ���������
  return rc;
-- ����������� ��������� ����������
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ���������'
    , true
  );
end getOperator;

/* func: getNoOperatorRole
  ������� ����������� ����� �������� �� ������������� ������������.

  ������� ���������:
    operatorId                              - ������������� ������������
    operatorIdIns                           - ������������, �������������� �����

  ������� (� ���� �������):
    role_id                                 -	������������� ����
    short_name                              - ������� ������������ ����
    role_name                               - ������������ ���� �� ����� �� ���������
    role_name_en                            - ������������ ���� �� ���������� �����
    description                             - �������� ���� �� ����� �� ���������
    date_ins                                - ���� �������� ������
    operator_id                             - ������������, ��������� ������
    operator_name                           - ������������ �� ����� �� ���������, ��������� ������
    operator_name_en                        - ������������ �� ���������� �����, ��������� ������
*/
function getNoOperatorRole(
  operatorId integer
  , operatorIdIns	integer
)
return sys_refcursor
is
  sqlStr varchar2(32767);
  -- ������ � ����������� ������
  resultSet  sys_refcursor;

-- getNoOperatorRole
begin
  isUserAdmin( operatorIdIns, null );

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
from
  op_role opr
inner join
  op_operator op
on
  op.operator_id = opr.operator_id
where
  opr.is_unused = 0 '
  ;

  if operatorId is not null then
    sqlStr := sqlStr
      || ' and opr.role_id not in (
             select
               vop.role_id
             from
               op_operator_role vop
             where
               vop.operator_id = :operatorId
               and vop.user_access_flag = 1
             ) '
    ;
  else
    sqlStr := sqlStr
      || ' and :operatorId is null '
    ;
  end if;

  open
    resultSet
  for
    sqlStr
    || ' order by opr.role_id'
  using
    operatorId
  ;

  -- ������ ���������
  return resultSet;

-- ����������� ��������� ����������
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ������ ���� ��������� ������.'
      , true
    );
end getNoOperatorRole;

/* func: getNoOperatorGroup
  ������� ����������� ����� �������� �� ������������� ������������.

  ������� ���������:
    operatorId                              -	������������� ������������
    operatorIdIns                           -	������������, �������������� �������

  ������� (� ���� �������):
    group_id                                - ������������� ������
    group_name                              - ������������ ������ �� ����� �� ���������
    group_name_en                           - ������������ ������ �� ���������� �����
    date_ins                                - ���� �������� ������
    operator_id                             - ������������, ��������� ������
    operator_name                           - ������������ �� ����� �� ���������, ��������� ������
    operator_name_en                        - ������������ �� ���������� �����, ��������� ������
*/
function getNoOperatorGroup(
  operatorId integer
  , operatorIdIns integer
)
return sys_refcursor
is
  sqlStr varchar2(32767);
  -- ������ � ����������� ������
  resultSet sys_refcursor;

-- getNoOperatorGroup
begin
  isUserAdmin( operatorIdIns, null );

  sqlStr := '
select
  g.group_id
  , g.group_name
  , g.group_name_en
  , g.date_ins
  , g.operator_id
  , op.operator_name
  , op.operator_name_en
from
  op_group g
inner join
  op_operator op
on
  op.operator_id = g.operator_id
where
  g.is_unused = 0 '

  ;

  if operatorId is not null then
    sqlStr := sqlStr
      || ' and g.group_id not in (
             select
               vop.group_id
             from
               op_operator_group vop
             where
               vop.operator_id = :operatorId
             ) '
    ;
  else
    sqlStr := sqlStr
      || ' and :operatorId is null '
    ;
  end if;

  open
    resultSet
  for
    sqlStr || ' order by g.group_id'
  using
    operatorId
  ;

  -- ������ ���������
  return resultSet;

-- ����������� ��������� ����������
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ������ �����, �������� �� �������������'
        || ' ������������ ��������� ������.'
      , true
    );
end getNoOperatorGroup;

/* func: getNoGroupRole
  ������� ����������� ����� �������� �� ������������� ������.

  ������� ���������:
    groupId                                 - ������������� ������
    operatorId                              - ������������, �������������� �������

  ������� (� ���� �������):
    role_id                                 - ������������� ����
    short_name                              - ������� ������������ ����
    role_name                               - ������������ ���� �� ����� �� ���������
    role_name_en                            - ������������ ���� �� ���������� �����
    description                             - �������� ���� �� ����� �� ���������
    date_ins                                - ���� �������� ������
    operator_id                             - ������������, ��������� ������
    operator_name                           - ������������ �� ����� �� ���������, ��������� ������
    operator_name_en                        - ������������ �� ���������� �����, ��������� ������
*/
function getNoGroupRole(
  groupId integer
  , operatorId integer
)
return sys_refcursor
is
  sqlStr varchar2(32767);
  -- ������ � ����������� ������
  resultSet  sys_refcursor;

-- getNoGroupRole
begin
  isRole( operatorID, RoleAdmin_Role );

  sqlStr := '
select
  r.role_id
  , r.short_name
  , r.role_name
  , r.role_name_en
  , r.description
  , r.date_ins
  , op.operator_id
  , op.operator_name
  , op.operator_name_en
from
  op_role r
inner join
  op_operator op
on
  op.operator_id = r.operator_id
where
  r.is_unused = 0 '
  ;

  if operatorId is not null then
    sqlStr := sqlStr
      || ' and r.role_id not in (
             select
               gr.role_id
             from
               op_group_role gr
             where
               gr.group_id = :groupId
           ) '
    ;
  else
    sqlStr := sqlStr
      || ' and :groupId is null '
    ;
  end if;

  open
    resultSet
  for
    sqlStr || ' order by r.role_id'
  using
    groupId
  ;

  -- ������ ���������
  return resultSet;

-- ����������� ��������� ����������
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ������ �����, �������� �� ������������� ������,'
        || ' ��������� ������.'
      , true
    );
end getNoGroupRole;

/* func: getRole
  ������� ������������ ������ �����.

  ������� ���������:
    roleName                         - ����� ��� ������ ����

  ������� (� ���� �������):
    role_id                          - �� ����
    role_name                        - ������������ ����
*/
function getRole(
  roleName varchar2
)
return sys_refcursor
is
  -- ������ � ����������� ������
  resultSet sys_refcursor;

-- getRole
begin
  open
    resultSet
  for
    select
      t.role_id
      , t.role_name
    from
      op_role t
    where
      (
      upper( t.short_name ) like upper( '%' || roleName || '%' )
      or upper( t.description ) like upper( '%' || roleName || '%' )
      or upper( t.role_name ) like upper( '%' || roleName || '%' )
      or upper( t.role_name_en ) like upper( '%' || roleName || '%' )
      )
      and t.is_unused = 0
    order by
      1
    ;

  -- ������ ���������
  return resultSet;

-- ����������� ��������� ����������
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ������������ ������ ����� ��������� ������.'
      , true
    );
end getRole;

/* func: getGroup
  ������� ������������ ������ �����.

  ������� ���������:
    groupName                        - ����� ��� ������ ������

  ������� (� ���� �������):
    group_id                         - �� ����
    group_name                       - ������������ ����
*/
function getGroup(
  groupName varchar2
)
return sys_refcursor
is
  -- ������ � ����������� ������
  resultSet sys_refcursor;

-- getGroup
begin
  open
    resultSet
  for
    select
      t.group_id
      , t.group_name
    from
      op_group t
    where
      (
      upper( t.group_name ) like upper( '%' || groupName || '%' )
      or upper( t.group_name_en ) like upper( '%' || groupName || '%' )
      )
      and t.is_unused = 0
    order by
      1
    ;

  -- ������ ���������
  return resultSet;

-- ����������� ��������� ����������
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ������������ ������ ����� ��������� ������.'
      , true
    );
end getGroup;

/* func: getOperatorIDByLogin
   ������� ���������� ID ��������� �� ������

   ������� ���������:
   login - ����� ���������

   �������� ���������:
    ID ���������
*/
function getOperatorIDByLogin(login varchar2 )
return integer
is
operatorID integer;
vLogin varchar2(50);
begin

vLogin := login;

 select t.operator_id
    into operatorID
   from op_operator t
   where UPPER(t.login) = UPPER(vLogin);

return operatorID;

exception  --����������� ��������� ����������
  when NO_DATA_FOUND then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������: ID ��������� �� ������ ��� ������: '||vLogin, true);
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ID ���������.', true);
end;

/* func: GetRoleID
   ������� ���������� ID ���� �� �������� ������������
*/
function GetRoleID(roleName	varchar2)
return integer
is
RoleID integer;
vRoleName varchar2(255);
begin

vRoleName := roleName;

 select t.role_id
    into RoleID
   from op_role t
   where UPPER(t.role_name) = UPPER(vRoleName)
       or UPPER(t.role_name_en) = UPPER(vRoleName)
       or UPPER(t.short_name) = UPPER(vRoleName);

return RoleID;

exception  --����������� ��������� ����������
  when NO_DATA_FOUND then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������: ID ���� �� ������ ��� role_name: '||vRoleName, true);
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ID ����.', true);
end;

/* func: GetGroupID
   ������� ���������� ID ������ �� �������� ������������
*/
function GetGroupID(groupName	varchar2)
return integer
is

groupID integer;
vgroupName varchar2(255);
begin

vgroupName := groupName;

 select t.group_id
    into groupID
   from op_group t
   where UPPER(t.group_name) = UPPER(vgroupName)
     or UPPER(t.group_name_en) = UPPER(vgroupName);

return groupID;

exception  --����������� ��������� ����������
  when NO_DATA_FOUND then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������: ID ������ �� ������ ��� group_name: '||vgroupName, true);
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ID ����.', true);
end;



/* group: ������� ��� ������ � ������������ */

/* func: getLockType
   ������� ������������ ������ ����� ����������.

   ������� ��������� �����������.

   ������� (� ���� �������):
     lock_type_code               - ��� ���� ����������
     lock_type_name               - ������������ ����
*/
function getLockType
return sys_refcursor
is
  resultSet sys_refcursor;
-- getLockType
begin
  open
    resultSet
  for
  select
    lt.lock_type_code
    , lt.lock_type_name
  from
    op_lock_type lt
  ;

  return resultSet;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ������������ ������ ����� ���������� ��������� ������.'
      , true
    );
end getLockType;

end pkg_Operator;
/
