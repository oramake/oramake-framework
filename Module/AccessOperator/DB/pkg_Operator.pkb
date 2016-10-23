create or replace package body pkg_Operator is
/* package body: pkg_Operator::body */



/* group: ���������� ������ */

/* ivar: currentOperatorId
  Id �������� ���������.
*/
currentOperatorId op_operator.operator_id%type;

/* ivar: currentLogin
  ����� �������� ���������.
*/
currentLogin op_operator.login%type;

/* ivar: currentOperatorName
  ��� �������� ���������.
*/
currentOperatorName op_operator.operator_name%type;



/* group: ������� */

/* group: ������� ��� �������� ������������� */

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

/* func: getOperator
  ��������� ������ �� ����������. � ��������� ����� *�� �����������* (
  �������� ��������� ��� ������ �������).

  ���������:
  operatorName                - ��� ���������
                                ( ����� �� like ��� ����� ��������)
                                ( �� ��������� ��� �����������)
  maxRowCount                 - ������������ ����� ������������ ������� �������
                                ( �� ��������� ��� �����������)

  ������� ( ������):
  operator_id                 - Id ���������
  operator_name               - ��� ���������
*/
function getOperator(
  operatorName varchar2 := null
  , maxRowCount integer := null
)
return sys_refcursor
is
begin
  raise_application_error(
    pkg_Error.IllegalArgument
    , 'Not implemented'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    ,  '������ ��� ��������� ������ �� ���������� ('
      || ' operatorName="' || operatorName || '"'
      || ', maxRowCount=' || maxRowCount
      || ').'
    , true
  );
end getOperator;

/* func: createOperator
  �������� ������������. ������� ��� <pkg_AccessOperator::createOperator>.
  �� ������������.
*/
function createOperator(
  operatorName      varchar2
, operatorNameEn  varchar2
, login           varchar2
, password        varchar2
, changePassword  integer
, operatorIdIns   integer
)
return integer
is
-- createOperator
begin
  return
    pkg_AccessOperator.createOperator(
      operatorName        => operatorName
    , operatorNameEn      => operatorNameEn
    , login               => login
    , password            => password
    , changePassword      => changePassword
    , operatorIdIns       => operatorIdIns
    );
end createOperator;

/* proc: deleteOperator
   �������� ������������. ������ ��� <pkg_AccessOperator::deleteOperator>.
   �� ������������.
*/
procedure deleteOperator(
  operatorId        integer
  , operatorIdIns   integer
)
is
-- deleteOperator
begin
  pkg_AccessOperator.deleteOperator(
    operatorId      => operatorId
    , operatorIdIns => operatorIdIns
  );
end deleteOperator;

/* proc: createOperatorGroup
  ��������� ���������� ������ ���������. ������ ���
  <pkg_AccessOperator::createOperatorGroup>.  �� ������������.
*/
procedure createOperatorGroup(
  operatorId      integer
  , groupId       integer
  , operatorIdIns integer
)
is
-- createOperatorGroup
begin
  pkg_AccessOperator.createOperatorGroup(
    operatorId      => operatorId
    , groupId       => groupId
    , operatorIdIns => operatorIdIns
  );
end createOperatorGroup;



/* group: ����������� */

/* iproc: login(internal)
  ��������� �������� � ������������ ��������� � ��. � ������ ��������
  ����������� ��������� ������ ��������� � ���������� ������, ��� ������
  ����������� - ����������� ����������.

  ������� ���������:
  operatorId                  - id ���������;
  operatorLogin               - ����� ��������� ( ������������ ������, ����
                                operatorId null);
  password                    - ������ ��� �������� �������;
  isCheckPassword             - ����� �� ��������� �������� ������ ( ����
                                null, �� ���������);

  ���������:
  - ������� ������ �������� �� �����, ������ ����������� � ������ ��������;
*/
procedure login(
  operatorId integer default null
  , operatorLogin varchar2 default null
  , password varchar2 default null
  , isCheckPassword boolean default null
)
is
  -- ������ ���������
  rec op_operator%rowtype;
  -- ���� �������� ���� �������
  checkDate date;

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
        upper( op.login ) = upper( operatorLogin)
      ;
    end if;
  exception
    when no_data_found then
      null;
  end;
  -- ��������� �����/������ ( �� ��������� ������ ��-�� ��������� ������ �
  -- ������������� ������)
  if rec.operator_id is null
    or (
      coalesce( isCheckPassword, true)
      and coalesce( rec.password <> getHash( password ), true)
    )
  then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������ ��������'
        || case when operatorId is not null then
            ' Id ���������'
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
  currentOperatorId := rec.operator_id;
  currentLogin := rec.login;
  currentOperatorName := rec.operator_name;

exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ����������� ��������� ('
      || substr(
        case when operatorId is not null then
          ', operator_id=' || to_char( operatorId)
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
  ������������ ��������� � ����. ���������� �������. ������������ ���������
  <login(password)>. ��������� ��� �������� �������������.

  ���������:
  operatorLogin               - ����� ���������
  password                    - ������ ���������

  �������:
  - ����� ���������
*/
function login(
  operatorLogin varchar2
  , password varchar2 := null
)
return varchar2
is
-- login
begin
  login(
    operatorLogin       => operatorLogin
    , password          => password
    , isCheckPassword   => password is not null
  );
  return currentLogin;
end login;

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

/* proc: login(password)
  ������������ ��������� � ����.

  ���������:
  operatorLogin               - ����� ���������
  password                    - ������ ���������
*/
procedure login(
  operatorLogin varchar2
  , password varchar2
)
is
-- login
begin
  login(
    operatorLogin       => operatorLogin
    , password          => password
    , isCheckPassword   => true
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
  ���������� ������������� �������� ���������.

  ������� ���������:
  isRaiseException            - ���� ������������ ���������� � ������, ����
                                ������� �������� �� ���������

  �������:
  oprator_id                  - ������������� �������� ���������
*/
function getCurrentUserId(
  isRaiseException integer default null
)
return integer
is
-- getCurrentUserId
begin
  if currentOperatorId is null
    and coalesce(isRaiseException, 1) = 1
  then
    raise_application_error(
      pkg_Error.OperatorNotRegister
      , '�� �� ������������������.'
        || ' ��� ����������� � ������� ��������� ������� Login.'
    );
  end if;
  return currentOperatorId;
end getCurrentUserId;

/* func: getCurrentUserName
  ���������� ��� �������� ���������.

  ������� ���������:
  isRaiseException            - ���� ����������� ���������� � ������, ����
                                ������� �������� �� ���������;

  �������:
  - ��� �������� ���������;
*/
function getCurrentUserName(
  isRaiseException integer default 1
)
return varchar2
is
-- getCurrentUserName
begin
  -- ��������� �������� �����������
  if getCurrentUserId(
       isRaiseException => isRaiseException
     ) is null
  then
    null;
  end if;
  return currentOperatorName;
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
  shortName op_role.role_short_name%type;
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
      cross join op_role rl
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

end pkg_Operator;
/
