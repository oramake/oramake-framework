CREATE OR REPLACE PACKAGE BODY "PKG_OPERATOR" is
/* package body: pkg_Operator::body */




/* ���������� ���������� ����� ������ */
PASSWORD_MINLENGTH CONSTANT INTEGER := 8;
/*������� ��������� ������� �������*/
PASSWORD_log_history CONSTANT INTEGER := 3;
/*���� �������� ������*/
PASSWORD_validity_period CONSTANT INTEGER := 36500;

/* ID �������� ��������� */
CURRENTOPERATORID OP_OPERATOR.OPERATOR_ID%TYPE;
/* ����� �������� ��������� */
CURRENTLOGIN OP_OPERATOR.LOGIN%TYPE;
/* ��� �������� ��������� (���) */
CURRENTOPERATORNAMERUS OP_OPERATOR.OPERATOR_NAME_RUS%TYPE;

/* proc: AddSqlCondition
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


/* proc: LOGIN
 ��������� �������� � ������������ ��������� � ��. � ������ ��������
 ����������� ��������� ������ ��������� � ���������� ������, ��� ������
 ����������� - ����������� ����������.

 ������� ���������:

 operatorID                  - ID ���������;
 operatorLogin               - ����� ��������� ( ������������ ������ ����
                               operatorID null);
 password                    - ������ ��� �������� �������;
 roleID                      - ID ���� ��� �������� ( ���� null, ��
                               �������� �� ������������);
 isCheckPassword             - ����� �� ��������� �������� ������ ( ����
                               null, �� ���������);

 ���������:
 ������� ������ �������� �� �����, ������ ����������� � ������ ��������.
*/
PROCEDURE LOGIN
 (OPERATORID INTEGER := null
 ,OPERATORLOGIN VARCHAR2 := null
 ,PASSWORD VARCHAR2 := null
 ,ROLEID INTEGER := null
 ,ISCHECKPASSWORD BOOLEAN := null
 );

/* func: ISROLE
  ��������� ������� ���� � ���������.

  ������� ���������:

  operatorID                  - ID ���������;
  roleID                      - ID ����;
  checkDate                   - ����, �� ������ ������� ����������� ������� ����;

 ������������ ��������:

 1 - �����������;
 0 - �� �����������;

*/
FUNCTION ISROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER := null
 ,ROLESHORTNAME VARCHAR2 := null
 ,MAKEERROR BOOLEAN := false
 )
 RETURN INTEGER;

/* proc: ISUSERADMIN
  ��������� ����� �� ����������������� ���������� � � ������ �� ����������
  ����������� ����������.

  ������� ���������:

  operatorID                  - ID ���������, ������������ ��������;
  targetOperatorID            - ID ���������, ��� ������� ����������� ��������;
  roleID                      - ID ����������/���������� ����;
  groupID                     - ID ����������/���������� ������;

*/
PROCEDURE ISUSERADMIN
 (OPERATORID INTEGER
 ,TARGETOPERATORID INTEGER := null
 ,ROLEID INTEGER := null
 ,GROUPID INTEGER := null
 );

/* proc: CHANGEPASSWORD
  ������ ������ � ���������.

  ������� ���������:

  operatorID                  - ID ���������;
  password                    - ������;
  newPassword                 - ����� ������;
  newPasswordConfirm          - ������������� ������;
  operatorIDIns               - ID ���������, ������������ ���������;

*/
PROCEDURE CHANGEPASSWORD
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2 := null
 ,NEWPASSWORD VARCHAR2
 ,NEWPASSWORDCONFIRM VARCHAR2 := null
 ,OPERATORIDINS INTEGER := null
 );


/* func: GETHASH
  ���������� hex-������ � MD5 ����������� ������.

  ���������:

  inputString                 - �������� ������ ��� ������� ����������� �����;

  �������� ���������

  ���������� hex-������ � MD5 ����������� ������.
*/
FUNCTION GETHASH
 (INPUTSTRING VARCHAR2
 )
 RETURN VARCHAR2
 IS
--GetHash
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
    , '������ ��� ����������� ������.'
    , true
  );
end GetHash;


/* proc: LOGIN
  ��������� �������� � ������������ ��������� � ��. � ������ ��������
  ����������� ��������� ������ ��������� � ���������� ������, ��� ������
  ����������� - ����������� ����������.

  ���������:
  operatorID                  - ID ���������;
  operatorLogin               - ����� ��������� ( ������������ ������ ����
                                operatorID null);
  password                    - ������ ��� �������� �������;
  roleID                      - ID ���� ��� �������� ( ���� null, ��
                               �������� �� ������������);
  isCheckPassword             - ����� �� ��������� �������� ������ ( ����
                               null, �� ���������);

 ���������:
������� ������ �������� �� �����, ������ ����������� � ������ ��������;

*/
PROCEDURE LOGIN
 (OPERATORID INTEGER := null
 ,OPERATORLOGIN VARCHAR2 := null
 ,PASSWORD VARCHAR2 := null
 ,ROLEID INTEGER := null
 ,ISCHECKPASSWORD BOOLEAN := null
 )
 IS
                                        --������ ���������
  rec op_operator%rowtype;
                                        --���� �������� ���� �������
  checkDate date;

--Login
begin
                                        --�������� ������� ������ ���������
  begin
    if operatorID is not null then
      select
        op.*
      into rec
      from
        op_operator op
      where
        op.operator_id = operatorID
      ;
    else
                                        --��������� ��� ����� ���������������
                                        --�������.
      select /*+ index( op) */
        op.*
      into rec
      from
        op_operator op
      where
        upper( op.login) = upper( operatorLogin)
      ;
    end if;
  exception when NO_DATA_FOUND then
    null;
  end;
                                        --��������� �����/������ ( �� ���������
                                        --������ ��-�� ��������� ������
                                        --� ������������� ������)
  if rec.operator_id is null
      or coalesce( isCheckPassword, true)
        and coalesce( rec.password <> GetHash( password), true)
      then
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
                                        --��������� ���� �������� ���������
  checkDate := sysdate;
  if checkDate < rec.date_begin or checkDate > rec.date_finish then
    raise_application_error(
      pkg_Error.RigthIsMissed
      , '������ � ������� ��������.'
    );
  end if;

                                        --��������� ������� ����
  if roleID is not null then
    IsRole(
      operatorID        => rec.operator_id
      , roleID          => roleID
    );
  end if;
                                        --��������� ������ ���������
  currentOperatorID     := rec.operator_id;
  currentLogin          := rec.login;
  currentOperatorNameRus:= rec.operator_name_rus;
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
end Login;

/* func: LOGIN
  ������������ ��������� � ���� � ���������� ��� ���������.

 ���������:

 operatorLogin               - ����� ���������;
 password                    - ������;

 �������� ���������:

 currentOperatorNameRus - ;

*/
FUNCTION LOGIN
 (OPERATORLOGIN VARCHAR2
 ,PASSWORD VARCHAR2
 )
 RETURN VARCHAR2
 IS
--Login
begin
  Login(
    operatorLogin       => operatorLogin
    , password          => password
    , isCheckPassword   => true
  );
  return currentOperatorNameRus;
end Login;


/* func: LOGIN
  ������������ ��������� � ���� � ���������� ��� ���������.

 ���������:

 operatorLogin               - ����� ���������;

 �������� ���������:

 currentOperatorNameRus - ;
)
*/
FUNCTION LOGIN
 (OPERATORLOGIN VARCHAR2
 )
 RETURN VARCHAR2
 IS
--Login
begin
  Login(
    operatorLogin       => operatorLogin
    , isCheckPassword   => false
  );
  return currentOperatorNameRus;
end Login;

/* func: LOGIN
  ������������ ��������� � ���� ( ��� �������� ������) � ���������� ���
  ��������� � ������ ������� � ���� ��������� ����, ����� �����������
  ����������.

  ���������:
 operatorLogin               - ����� ���������;
 roleID                      - ID ����;

 �������� ���������:

 currentOperatorNameRus - ;

*/
FUNCTION LOGIN
 (OPERATORLOGIN VARCHAR2
 ,ROLEID INTEGER
 )
 RETURN VARCHAR2
 IS
--Login
begin
  Login(
    operatorLogin       => operatorLogin
    , roleID            => roleID
    , isCheckPassword   => false
  );
  return currentOperatorNameRus;
end Login;

/* proc: LOGIN
  ������������ ��������� � ���� ( ��� �������� ������).

  ���������:
  operatorLogin               - ����� ���������;

*/
PROCEDURE LOGIN
 (OPERATORLOGIN VARCHAR2
 )
 IS
--Login
begin
  Login(
    operatorLogin       => operatorLogin
    , isCheckPassword   => false
  );
end Login;

/* proc: SETCURRENTUSERID
  ������������ ��������� � ���� ( ��� �������� ������).

  ���������:
 operatorID                  - ID ���������;

*/
PROCEDURE SETCURRENTUSERID
 (OPERATORID INTEGER
 )
 IS
--SetCurrentUserID
begin
  Login(
    operatorID          => operatorID
    , isCheckPassword   => false
  );
end SetCurrentUserID;

/* proc: REMOTELOGIN
   ������������ �������� ��������� � ��������� ��.

  ���������:
  dbLink                      - ��� ����� � ��������� ��;

*/
PROCEDURE REMOTELOGIN
 (DBLINK VARCHAR2
 )
 IS
--RemoteLogin
begin
                                        --�������������� � ��������� ��
  execute immediate
    'begin'
      || ' pkg_Operator.Login@' || dbLink || '( :login);'
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
end RemoteLogin;

/* proc: LOGOFF
   �������� ������� �����������;

*/
PROCEDURE LOGOFF
 IS

--Logoff
begin
  currentOperatorID           := null;
  currentLogin                := null;
  currentOperatorNameRus      := null;
end Logoff;

/* func: GETCURRENTUSERID
   ���������� ID �������� ��������� ( ��� ���������� ����������� - �����������
����������).

*/
FUNCTION GETCURRENTUSERID
 RETURN INTEGER
 IS
--GetCurrentUserID
begin
  if currentOperatorID is null then
    raise_application_error(
      pkg_Error.OperatorNotRegister
      , '�� �� ������������������.'
        || ' ��� ����������� � ������� ��������� ������� Login.'
    );
  end if;
  return currentOperatorID;
end GetCurrentUserID;

/* func: GETCURRENTUSERNAME
���������� ��� �������� ��������� ( ��� ���������� ����������� - �����������
����������).

*/
FUNCTION GETCURRENTUSERNAME
 RETURN VARCHAR2
 IS
--GetCurrentUserName
begin
                                        --��������� �������� �����������
  if GetCurrentUserID() is null then
    null;
  end if;
  return currentOperatorNameRus;
end GetCurrentUserName;

/* func: ISROLE
  ��������� ������� ���� � ���������.

  ������� ���������:

  operatorID                  - ID ���������;
  roleID                      - ID ����;
  checkDate                   - ����, �� ������ ������� ����������� ������� ����;

 ������������ ��������:

 1 - �����������;
 0 - �� �����������;

*/
FUNCTION ISROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER := null
 ,ROLESHORTNAME VARCHAR2 := null
 ,MAKEERROR BOOLEAN := false
 )
 RETURN INTEGER
 IS
                                        --������� ������� ����
  isGrant integer := 0;
                                        --������ �� ���������
  operatorNameRus op_operator.operator_name_rus%type;
  dateBegin date;
  dateFinish date;
                                        --��� ����
  shortName op_role.short_name%type;
                                        --���� �������� ���� �������
  checkDate date;

--IsRole
begin
  begin
    select
      op.operator_name_rus
      , op.date_begin
      , op.date_finish
      , rl.short_name
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
      op.operator_id = operatorID
      and (
        rl.role_id = roleID
        or rl.short_name = roleShortName
        )
    ;
  exception when NO_DATA_FOUND then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������ �������������� ID ��������� ���'
        || case when roleID is not null then
            ' ID'
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
        || ' short_name="' || shortName || '"'
        ||').'
    );
  end if;
  return isGrant;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� �������� ������� ���� � ��������� ('
      || ' operator_id=' || to_char( operatorID)
      || case when roleID is not null then
          ', role_id=' || to_char( roleID)
        else
          ', short_name="' || to_char( roleShortName) || '"'
        end
      || ').'
    , true
  );
end IsRole;

/* func: ISROLE
  ��������� ������� ���� � ���������.

  ���������:
  operatorID                  - ID ���������;
  roleID                      - ID ����;

 ������������ ��������:
 1 - ���� �����������;
 0 - ���� �� �����������;

*/
FUNCTION ISROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 )
 RETURN INTEGER
 IS

--IsRole
begin
  return
    IsRole(
      operatorID        => operatorID
      , roleID          => roleID
      , makeError       => false
    )
  ;
end IsRole;

/* func: ISROLE
  ��������� ������� ���� � ���������.

  ���������:

  operatorID                  - ID ���������;
  roleShortName                      - ��� ����;

 ������������ ��������:

 1 - ���� �����������;
 0 - ���� �� �����������;

*/
FUNCTION ISROLE
 (OPERATORID INTEGER
 ,ROLESHORTNAME VARCHAR2
 )
 RETURN INTEGER
 IS

--IsRole
begin
  return
    IsRole(
      operatorID        => operatorID
      , roleShortName   => roleShortName
      , makeError       => false
    )
  ;
end IsRole;

/* func: ISROLE
  ��������� ������� ���� � �������� ���������.

  ���������:

  roleID                      - ID ����;

 ������������ ��������:

 1 - ���� �����������;
 0 - ���� �� �����������;

*/
FUNCTION ISROLE
 (ROLEID INTEGER
 )
 RETURN INTEGER
 IS

                                        --������� ������ ����
  isGrant integer := 0;

--IsRole
begin
  if currentOperatorID is not null then
    isGrant := IsRole(
      operatorID        => currentOperatorID
      , roleID          => roleID
      , makeError       => false
    );
  end if;
  return isGrant;
end IsRole;

/* func: ISROLE
  ��������� ������� ���� � �������� ���������.

  ���������:
  roleShortName               - ��� ����;

 ������������ ��������:

 1 - ���� �����������;
 0 - ���� �� �����������;

*/
FUNCTION ISROLE
 (ROLESHORTNAME VARCHAR2
 )
 RETURN INTEGER
 IS
                                        --������� ������ ����
  isGrant integer := 0;

--IsRole
begin
  if currentOperatorID is not null then
    isGrant := IsRole(
      operatorID        => currentOperatorID
      , roleShortName   => roleShortName
      , makeError       => false
    );
  end if;
  return isGrant;
end IsRole;

/* proc: ISROLE
 ��������� ������� ���� � ��������� � � ������ �� ���������� �����������
 ����������.

 ��������:

 operatorID                  - ID ���������;
 roleID                      - ID ����;

*/
PROCEDURE ISROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 )
 IS
                                        --������� ������� ����
  isGrant integer;

--IsRole
begin
  isGrant := IsRole(
    operatorID        => operatorID
    , roleID          => roleID
    , makeError       => true
  );
end IsRole;

/* proc: ISROLE
 ��������� ������� ���� � ��������� � � ������ �� ���������� �����������
 ����������.

 ��������:

 operatorID                  - ID ���������;
 roleShortName               - ��� ����;

*/
PROCEDURE ISROLE
 (OPERATORID INTEGER
 ,ROLESHORTNAME VARCHAR2
 )
 IS
                                       --������� ������� ����
  isGrant integer;

--IsRole
begin
  isGrant := IsRole(
    operatorID        => operatorID
    , roleShortName   => roleShortName
    , makeError       => true
  );
end IsRole;

/* proc: ISROLE
��������� ������� ���� � �������� ��������� � � ������ ���������� �����������
��� ���� ����������� ����������.

��������:

roleID                      - ID ����;
 */
PROCEDURE ISROLE
 (ROLEID INTEGER
 )
 IS
                                        --������� ������� ����
  isGrant integer;

--IsRole
begin
  isGrant := IsRole(
    operatorID        => GetCurrentUserID()
    , roleID          => roleID
    , makeError       => true
  );
end IsRole;

/* proc: ISROLE
��������� ������� ���� � �������� ��������� � � ������ ���������� �����������
��� ���� ����������� ����������.

��������:

roleShortName               - ��� ����;

*/
PROCEDURE ISROLE
 (ROLESHORTNAME VARCHAR2
 )
 IS

                                        --������� ������� ����
  isGrant integer;

--IsRole
begin
  isGrant := IsRole(
    operatorID        => GetCurrentUserID()
    , roleShortName   => roleShortName
    , makeError       => true
  );
end IsRole;

/* proc: ISUSERADMIN
  ��������� ����� �� ����������������� ���������� � � ������ �� ����������
  ����������� ����������.

  ������� ���������:

  operatorID                  - ID ���������, ������������ ��������;
  targetOperatorID            - ID ���������, ��� ������� ����������� ��������;
  roleID                      - ID ����������/���������� ����;
  groupID                     - ID ����������/���������� ������;

*/
PROCEDURE ISUSERADMIN
 (OPERATORID INTEGER
 ,TARGETOPERATORID INTEGER := null
 ,ROLEID INTEGER := null
 ,GROUPID INTEGER := null
 )
 IS

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
        , '�������� ���������,'
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
      minus
      select distinct
        opr.group_id
      from
        op_operator_group opr
      where
        opr.operator_id = operatorID
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
        , '�������� ���������,'
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

/* proc: CREATEROLE
������� ����.

���������:

roleID                      - ID ����;
roleNameRus                 - �������� ���� ( ���.);
roleNameEng                 - �������� ���� ( ���.);
shortName                   - �������� �������� ����;
description                 - ��������;
operatorID                  - ID ���������, ������������ ���������;

*/
PROCEDURE CREATEROLE
 (ROLEID INTEGER
 ,ROLENAMERUS VARCHAR2
 ,ROLENAMEENG VARCHAR2
 ,SHORTNAME VARCHAR2
 ,DESCRIPTION VARCHAR2 := null
 ,OPERATORID INTEGER
 )
 IS
--CreateRole
begin
                                        --��������� ����� ���������
  IsRole( operatorID, RoleAdmin_Role);
                                        --������� ����
  insert into
    op_role
  (
    role_id,
    role_name_rus,
    role_name_eng,
    short_name,
    description,
    operator_id
  )
  values
  (
    roleID,
    roleNameRus,
    roleNameEng,
    shortName,
    description,
    operatorID
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� �������� ���� ('
      || ' role_id=' || to_char( roleID)
      || ', short_name="' || to_char( shortName) || '"'
      || ').'
    , true
  );
end CreateRole;

/* func: CREATEROLE
������� ����.

���������:

roleNameRus                 - �������� ���� ( ���.);
roleNameEng                 - �������� ���� ( ���.);
shortName                   - �������� �������� ����;
description                 - ��������;
operatorID                  - ID ���������, ������������ ���������;

*/
function CREATEROLE
 ( ROLENAMERUS VARCHAR2
 ,ROLENAMEENG VARCHAR2
 ,SHORTNAME VARCHAR2
 ,DESCRIPTION VARCHAR2 := null
 ,OPERATORID INTEGER
 )
return integer
 IS
--CreateRole
id integer;
begin
                                        --��������� ����� ���������
  IsRole( operatorID, RoleAdmin_Role);
                                        --������� ����
  insert into
    op_role
  (
   -- role_id,
    role_name_rus,
    role_name_eng,
    short_name,
    description,
    operator_id
  )
  values
  (
   -- roleID,
    roleNameRus,
    roleNameEng,
    shortName,
    description,
    operatorID
  )
 returning role_id into id;

  return id;

exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� �������� ���� ('
      || ' role_id=' || to_char( id)
      || ', short_name="' || to_char( shortName) || '"'
      || ').'
    , true
  );
end CreateRole;


/* proc: UPDATEROLE
�������� ����.

���������:

roleID                      - ID ����;
roleNameRus                 - �������� ���� ( ���.);
roleNameEng                 - �������� ���� ( ���.);
shortName                   - �������� �������� ����;
description                 - ��������;
operatorID                  - ID ���������, ������������ ���������;

*/
PROCEDURE UPDATEROLE
 (ROLEID INTEGER
 ,ROLENAMERUS VARCHAR2
 ,ROLENAMEENG VARCHAR2
 ,SHORTNAME VARCHAR2
 ,DESCRIPTION VARCHAR2
 ,OPERATORID INTEGER
 )
 IS
--UpdateRole
begin
                                        --��������� ����� ���������
  IsRole( operatorID, RoleAdmin_Role);
                                        --�������� ����
  update
    op_role r
  set
    r.role_name_rus = roleNameRus,
    r.role_name_eng = roleNameEng,
    r.short_name = shortName,
    r.description = UpdateRole.description
  where
    r.role_id = roleID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '��� ����������� ������ �� ���� �������� ������ ('
      || ' role_id=' || to_char( roleID)
      || ').'
    , true
  );
end UpdateRole;


/* func: CREATEGROUP
������� ������ � ���������� �� ID.

���������:

groupNameRus                - �������� ������ ( ���.);
groupNameEng                - �������� ������ ( ���.);
isGrantOnly                 - ���� 1, �� ������ ������������� ����� ������;
                              �������� ������ �� ���� ������ ����������;
operatorID                  - ID ���������, ������������ ��������;

�������� ���������:

groupID

*/
FUNCTION CREATEGROUP
 (GROUPNAMERUS VARCHAR2
 ,GROUPNAMEENG VARCHAR2
 ,ISGRANTONLY INTEGER := null
 ,OPERATORID INTEGER
 )
 RETURN INTEGER
 IS
                                        --ID ��������� ������
  groupID op_group.group_id%type;

--CreateGroup
begin
                                        --��������� ����� ���������
  IsRole( operatorID, RoleAdmin_Role);
                                        --��������� ������
  insert into
    op_group
  (
    group_name_rus,
    group_name_eng,
    is_grant_only,
    operator_id
  )
  values
  (
    groupNameRus,
    groupNameEng,
    coalesce( isGrantOnly, 0),
    operatorID
  )
  returning group_id into groupID;
  return groupID;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '��� �������� ������ �������� ������ ('
      || ' group_name_rus="' || groupNameRus || '"'
      || ').'
    , true
  );
end CreateGroup;

/* proc: UPDATEGROUP
�������� ������.

���������:

groupID                     - ID ������;
groupNameRus                - �������� ������ ( ���.);
groupNameEng                - �������� ������ ( ���.);
isGrantOnly                 - ���� 1, �� ������ ������������� ����� ������;
                              �������� ������ �� ���� ������ ����������;
operatorID                  - ID ���������, ������������ ���������;

*/
PROCEDURE UPDATEGROUP
 (GROUPID INTEGER
 ,GROUPNAMERUS VARCHAR2
 ,GROUPNAMEENG VARCHAR2
 ,ISGRANTONLY INTEGER
 ,OPERATORID INTEGER
 )
 IS
--UpdateGroup
begin
                                        --��������� ����� ���������
  IsRole( operatorID, RoleAdmin_Role);
                                        --�������� ������
  update
    op_group g
  set
    g.group_name_rus = groupNameRus,
    g.group_name_eng = groupNameEng,
    g.is_grant_only = isGrantOnly
  where
    g.group_id = groupID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '��� ��������� ������ �������� ������ ('
      || ' group_id=' || to_char( groupID)
      || ').'
    , true
  );
end UpdateGroup;


/* proc: CREATEGROUPROLE
�������� ���� � ������.

���������:

groupID                     - ID ������;
roleID                      - ID ����;
operatorID                  - ID ���������, ������������ ���������;

*/
PROCEDURE CREATEGROUPROLE
 (GROUPID INTEGER
 ,ROLEID INTEGER
 ,OPERATORID INTEGER
 )
 IS
--CreateGroupRole
begin
                                        --��������� ����� ���������
  IsRole( operatorID, RoleAdmin_Role);
                                        --�������� ���� � ������
  insert into
    op_group_role
  (
    group_id
    , role_id
    , operator_id
  )
  values
  (
    groupID
    , roleID
    , operatorID
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '��� ��������� ���� � ������ �������� ������ ('
      || ' role_id=' || to_char( roleID)
      || ' , role_id=' || to_char( groupID)
      || ').'
    , true
  );
end CreateGroupRole;

/* proc: DELETEGROUPROLE
������� ���� �� ������.

���������:

groupID                     - ID ������
roleID                      - ID ����
operatorID                  - ID ���������, ������������ ���������

*/
PROCEDURE DELETEGROUPROLE
 (GROUPID INTEGER
 ,ROLEID INTEGER
 ,OPERATORID INTEGER
 )
 IS
--DeleteGroupRole
begin
                                        --��������� ����� ���������
  IsRole( operatorID, RoleAdmin_Role);
                                        --������� ���� �� ������
  delete from
    op_group_role gr
  where
    gr.group_id = groupID
    and gr.role_id = roleID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '��� �������� ���� �� ������ �������� ������ ('
      || ' role_id=' || to_char( roleID)
      || ' , role_id=' || to_char( groupID)
      || ').'
    , true
  );
end DeleteGroupRole;

/* proc: CREATEGRANTGROUP
��������� ����� �� ������ ������.

���������:

groupID                     - ID ������, ������� �������� ����� ������;
grantGroupID                - ID ���������� ������;
operatorID                  - ID ���������, ������������ ���������;

*/
PROCEDURE CREATEGRANTGROUP
 (GROUPID INTEGER
 ,GRANTGROUPID INTEGER
 ,OPERATORID INTEGER
 )
 IS
--CreateGrantGroup
begin
                                        --��������� ����� ���������
  IsRole( operatorID, RoleAdmin_Role);
                                        --��������� ������
  insert into
    op_grant_group
  (
    group_id
    , grant_group_id
    , operator_id
  )
  values
  (
    groupID
    , grantGroupID
    , operatorID
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ���������� ���� �� ������ ������ ('
      || ' group_id=' || to_char( groupID)
      || ', grant_group_id=' || to_char( grantGroupID)
      || ').'
    , true
  );
end CreateGrantGroup;

/* proc: DELETEGRANTGROUP
������� ����� �� ������ ������.

���������:

groupID                     - ID ������, � ������� ������� ����� ������;
grantGroupID                - ID ���������� ������;
operatorID                  - ID ���������, ������������ ���������;

*/
PROCEDURE DELETEGRANTGROUP
 (GROUPID INTEGER
 ,GRANTGROUPID INTEGER
 ,OPERATORID INTEGER
 )
 IS
--DeleteGrantGroup
begin
                                        --��������� ����� ���������
  IsRole( operatorID, RoleAdmin_Role);
                                        --������� ������
  delete from
    op_grant_group gg
  where
    gg.group_id = groupID
    and gg.grant_group_id = grantGroupID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� �������� ���� �� ������ ������ ('
      || ' group_id=' || to_char( groupID)
      || ', grant_group_id=' || to_char( grantGroupID)
      || ').'
    , true
  );
end DeleteGrantGroup;

/* func: CREATEOPERATOR
������� ������ ��������� � ���������� ��� ID.

���������:

operatorNameRus                - ��� ���������;
operatorNameEng             - ��� ��������� (�� ����������);
login                       - �����;
password                    - ������;
changepassword              - ���� ����� ������ ���������;
operatorIDIns               - ID ���������, ������������ ���������;

*/
FUNCTION CREATEOPERATOR
 (OPERATORNAMERUS VARCHAR2
 ,OPERATORNAMEENG VARCHAR2
 ,LOGIN VARCHAR2
 ,PASSWORD VARCHAR2
 ,CHANGEPASSWORD INTEGER
 ,OPERATORIDINS INTEGER
 )
 RETURN INTEGER
 IS
                                        --ID ������ ���������
  operatorID op_operator.operator_id%type;

                                        --��� ������
  passwordHash op_operator.password%type := GetHash( password);

--CreateOperator
begin
                                        --��������� ����� ���������
  IsUserAdmin(
    operatorID          => operatorIDIns
    , targetOperatorID  => null
  );
                                        --������� ������
  insert into
    op_operator
  (
    operator_name_rus
    , operator_name_eng
    , login
    , password
    , change_password
    , operator_id_ins
  )
  values
  (
    operatorNameRus
    , operatorNameEng
    , login
    , passwordHash
    , changepassword
    , operatorIDIns
  )
  returning operator_id into operatorID;
  return ( operatorID);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� �������� ��������� ('
      || ' login="' || login || '"'
      || ').'
    , true
  );
end CreateOperator;

/* func: CreateOperatorHash
������� ������ ��������� � ���������� ��� ID.

���������:

operatorName             - ��� ���������;
operatorNameEn             - ��� ��������� (�� ����������);
login                       - �����;
passwordHash                - Hash ������;
changepassword              - ���� ����� ������ ���������;
operatorIDIns               - ID ���������, ������������ ���������;
(<body::CreateOperatorHash>)
*/
function createOperatorHash
 (operatorName varchar2
 ,operatorNameEn varchar2
 ,login           varchar2
 ,passwordHash    varchar2
 ,changePassword  integer
 ,operatorIdIns   integer
 )
 RETURN INTEGER
 IS
                                        --ID ������ ���������
  operatorID op_operator.operator_id%type;

dr op_operator%rowtype;

--��� ������
--PasswordHash op_operator.password%type;-- := GetHash( password);

--CreateOperator
begin
                                        --��������� ����� ���������
  IsUserAdmin(
    operatorID          => operatorIDIns
    , targetOperatorID  => null
  );
                                        --������� ������

     select
        op_operator_seq.nextval
       into dr.operator_id
     from dual;

     dr.operator_name_rus := operatorName;
     dr.login             := login;
     dr.password          := passwordHash;
     dr.date_begin        := sysdate;
     dr.date_finish       := null;--to_date('01.01.4000');
     dr.date_ins          := sysdate;
     dr.operator_id_ins   := operatorIdIns;
     dr.operator_name_eng := operatorNameEn;
     dr.change_password   := changePassword;
     dr.operator_name     := operatorName;
     dr.operator_name_en  := operatorNameEn;

insert into op_operator values dr;

   return dr.operator_id ;

  return ( operatorID);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� �������� ��������� ('
      || ' login="' || login || '"'
      || ').'
    , true
  );
end createOperatorHash;

/* proc: UPDATEOPERATOR
�������� ������ ���������.

���������:

operatorID                  - id ���������;
operatorNameRus             - ��� ���������;
operatorNameEng             - ��� ��������� (�� ����������);
login                       - �����;
changePassword              - ���� ����� ������;
operatorIDIns               - ID ���������, ������������ ���������;

*/
PROCEDURE UPDATEOPERATOR
 (OPERATORID INTEGER
 ,OPERATORNAMERUS VARCHAR2
 ,OPERATORNAMEENG VARCHAR2
 ,LOGIN VARCHAR2
 ,CHANGEPASSWORD INTEGER
 ,OPERATORIDINS INTEGER
 )
 IS
--UpdateOperator
begin
                                        --��������� ����� �������
  IsUserAdmin(
    operatorID          => operatorIDIns
    , targetOperatorID  => operatorID
  );
                                        --��������� ����������
  update
    op_operator opo
  set
    opo.operator_name_rus = OperatorNameRus,
    opo.operator_name_eng = OperatorNameEng,
    opo.login = UpdateOperator.Login,
    opo.change_password = ChangePassword
  where
    opo.operator_id = operatorID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ��������� ������ ��������� ('
      || ' operator_id=' || to_char( operatorID)
      || ').'
    , true
  );
end UpdateOperator;

/* proc: CHANGEPASSWORD
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
password                    - ������;
newPassword                 - ����� ������;
newPasswordConfirm          - ������������� ������;
operatorIDIns               - ID ���������, ������������ ���������;

*/
PROCEDURE CHANGEPASSWORD
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2 := null
 ,NEWPASSWORD VARCHAR2
 ,NEWPASSWORDCONFIRM VARCHAR2 := null
 ,OPERATORIDINS INTEGER := null
 )
 IS
                                        --���� ������
  passwordHash op_operator.password%type;

  cursor curPasswordLog is    --������ ��� ���������� �������
    select vh.password
    from v_op_password_hist vh
    where vh.operator_id=OPERATORID
    order by date_end desc;

  pass varchar(50);                --������������ ������
  newPasswordUpper varchar2(100);  --���������� ��� ��������� [A..Z]
  newPasswordLower varchar2(100);  --���������� ��� ��������� [a..z]
  newPasswordDigit varchar2(100);  --���������� ��� ��������� [0..9]
  newPasswordEdit  varchar2(100);  --���������� ��� ������ ������

--ChangePassword
begin
                                        --��������� ������������� � ���������
                                        --(��� ��������) ������ ���������
  begin
    select
      op.password
    into passwordHash
    from
      op_operator op
    where
      op.operator_id = operatorID
    for update of password nowait;

  exception when NO_DATA_FOUND then     --�������� ��������� �� ������
    raise_application_error(
      pkg_Error.RowNotFound
      , '�������� �� ������.'
    );
  end;
  if operatorIDIns is not null then
                                        --��������� ����� �������
    IsUserAdmin(
      operatorID          => operatorIDIns
      , targetOperatorID  => operatorID
    );
  else
                                        --��������� ������� ������
    if coalesce( passwordHash <> GetHash( password), true) then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������� ������ ������ �������.'
      );
    end if;
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

                                        --��������� ���������� ����� �������
    if coalesce( newPassword <> newPasswordConfirm
          , coalesce( newPassword, newPasswordConfirm) is not null
        )
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        ,'����� ������ �� ��������� � ��������������.'
      );
    end if;
  end if;
                                        --������ ������ � ���������� ��� �����
                                        --������
  passwordHash := GetHash( newPassword);
  update
    op_operator op
  set
    op.password = passwordHash
    , op.change_password = 0
  where
    op.operator_id = operatorID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ����� ������ ��������� ('
      || ' operator_id=' || to_char( operatorID)
      || ').'
    , true
  );
end ChangePassword;



/* proc: changePasswordHash
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
passwordHash                    - ������;
newPasswordHash             - Hash ����� ������;
newPasswordConfirmHash      - Hash ������������� ������;
operatorIDIns               - ID ���������, ������������ ���������;
*/
procedure ChangePasswordHash
 ( operatorId             integer
 , passwordHash           varchar2 := null
 , newPasswordHash        varchar2
 , newPasswordConfirmHash varchar2 := null
 , operatorIdIns          integer := null
 )
 IS
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
        raise_application_error(  pkg_Error.RowNotFound , '�������� �� ������.');
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
        , '������� ������ ������ �������.' );

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
           ,'����� ������ �� ��������� � ��������������.' );
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

/* proc: ChangePasswordHash
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
passwordHash                - Hash ������;
operatorIDIns               - ID ���������, ������������ ���������;
*/
procedure ChangePasswordHash (operatorid integer
                             ,passwordHash varchar2
                             ,operatoridins integer
                             )
is
--ChangePasswordHash
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


/* proc: CHANGEPASSWORD
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
password                    - ������;
operatorIDIns               - ID ���������, ������������ ���������;

*/
PROCEDURE CHANGEPASSWORD
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,OPERATORIDINS INTEGER
 )
 IS
--ChangePassword
begin
  ChangePassword(
    operatorID            => operatorID
    , password            => null
    , newPassword         => password
    , newPasswordConfirm  => null
    , operatorIDIns       => operatorIDIns
  );
end ChangePassword;

/* proc: CHANGEPASSWORD
������ ������ � ���������.

���������:

operatorID                  - ID ���������;
password                    - ������;
newPassword                 - ����� ������;
newPasswordConfirm          - ������������� ������;

*/
PROCEDURE CHANGEPASSWORD
 (OPERATORID INTEGER
 ,PASSWORD VARCHAR2
 ,NEWPASSWORD VARCHAR2
 ,NEWPASSWORDCONFIRM VARCHAR2
 )
 IS
--ChangePassword
begin
  ChangePassword(
    operatorID            => operatorID
    , password            => password
    , newPassword         => newPassword
    , newPasswordConfirm  => newPasswordConfirm
    , operatorIDIns       => null
  );
end ChangePassword;

/* proc: DELETEOPERATORROLE
�������� ���� � ���������.

���������:

operatorID                  - ID ���������;
roleID                      - ID ����;
operatorIDIns               - ID ���������, ������������ ���������;

*/
PROCEDURE DELETEOPERATORROLE
 (OPERATORID INTEGER
 ,ROLEID INTEGER
 ,OPERATORIDINS INTEGER
 )
 IS
--DeleteOperatorRole
begin
                                        --��������� ����� �������
  IsUserAdmin(
    operatorID          => operatorIDIns
    , roleID            => roleID
  );
                                        --�������� ����
  delete from
    op_operator_role opr
  where
    opr.operator_id = operatorID
    and opr.role_id = roleID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ��������� ���� � ��������� ('
      || ' operator_id=' || to_char( operatorID)
      || ' , role_id=' || to_char( roleID)
      || ').'
    , true
  );
end DeleteOperatorRole;

/* proc: CREATEOPERATORGROUP
�������� ��������� � ������.

���������:

operatorID                  - ID ���������;
groupID                     - ID ������;
operatorIDIns               - ID ���������, ������������ ���������;

*/
PROCEDURE CREATEOPERATORGROUP
 (OPERATORID INTEGER
 ,GROUPID INTEGER
 ,OPERATORIDINS INTEGER
 )
 IS
--CreateOperatorGroup
begin
                                        --��������� ����� �������
  IsUserAdmin(
    operatorID          => operatorIDIns
    , groupID           => groupID
  );
                                        --�������� � ������
  insert into
    op_operator_group
  (
    operator_id,
    group_id,
    operator_id_ins
  )
  values
  (
    operatorID,
    groupID,
    operatorIDIns
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ��������� ��������� � ������ ('
      || ' operator_id=' || to_char( operatorID)
      || ' , group_id=' || to_char( groupID)
      || ').'
    , true
  );
end CreateOperatorGroup;

/* proc: DELETEOPERATORGROUP
������� ��������� �� ������.

���������:

operatorID                  - ID ���������;
groupID                     - ID ������;
operatorIDIns               - ID ���������, ������������ ���������;

*/
PROCEDURE DELETEOPERATORGROUP
 (OPERATORID INTEGER
 ,GROUPID INTEGER
 ,OPERATORIDINS INTEGER
 )
 IS
--DeleteOperatorGroup
begin
                                        --��������� ����� �������
  IsUserAdmin(
    operatorID          => operatorIDIns
    , groupID           => groupID
  );
                                        --�������� ����
  delete from
    op_operator_group opg
  where
    opg.operator_id = operatorID
    and opg.group_id = groupID
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ���������� ��������� �� ������ ('
      || ' operator_id=' || to_char( operatorID)
      || ' , group_id=' || to_char( groupID)
      || ').'
    , true
  );
end DeleteOperatorGroup;

/* func: GETOPERATORNAME
���������� ��� ���������

���������:
operatorID                  - ID ���������

�������� ���������:

��� ���������

*/
FUNCTION GETOPERATORNAME
 (OPERATORID INTEGER
 )
 RETURN VARCHAR2
 IS

   OperatorName op_operator.operator_name_rus%type;
begin
	 									--�-� min() ������������ ���
										--��������� ���������� NO_DATA_FOUND
   select min(operator_name_rus)
     into OperatorName
	 from op_operator
    where operator_id = OperatorId;

   return OperatorName;
end getOperatorName;

/* func: ISCHANGEPASSWORD
���� ������������� �������������� ����� ������
0-�� ������
1-������

���������:
operatorID                  - ID ���������

 */
FUNCTION ISCHANGEPASSWORD
 (OPERATORID INTEGER
 )
 RETURN number
 IS


  TYPE curTypePassword IS REF CURSOR  ; --��� ������ ��� ������� ����� �������� ������
  CurPassword curTypePassword;          --������
  sqlString varchar2(400);              --������ � ��������
  countPassword integer;                --���-�� ���� �������� ������

  cursor curChangePassword is           --������ ��� �������� Change_Password � Password
    select o.change_password, o.password
    from op_operator o
    where o.operator_id=OPERATORID;

  ChangePassword number;
  PasswordHash varchar2(50);

--IsChangePassword
begin
  if OPERATORID is null then
    return -1;
  end if;

  open curChangePassword;
  fetch curChangePassword into ChangePassword, PasswordHash ;
  close curChangePassword;

  if ChangePassword=1 then
    return 1;
  end if;

  if ChangePassword is null then
    return -1;
  end if;

  /*�������� �.:
  ����� ���������, ��� � ������������ ������ = 'report'
  ���� ������ = 'report', ������ ���������� �������� �� ���� �������� ������
  �� ����������
  ������ ���������� �������� ��� ������������� CL, ������� ������ � RFInfo
  ��� ��������� �������
  */
  if PasswordHash = 'E98D2F001DA5678B39482EFBDF5770DC' then
  return 0;
  end if;


                                 --�������� ���� �������� �������� ������
  sqlString:='select (sysdate-vh.date_begin) d_b
              from v_op_password_hist vh
              where vh.operator_id=:op_id
              and vh.date_end>SYSDATE';

  open CurPassword for SQLString using OPERATORID;
  fetch CurPassword into countPassword;
  close CurPassword;

  if countPassword > pkg_operator.password_validity_period then
    return 1;
  end if;

  return 0;

end ISCHANGEPASSWORD;

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
                  , op2.operator_name_rus operator_name
                  , op2.operator_name_eng operator_name_en
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
                  , op2.operator_name_rus operator_name
                  , op2.operator_name_eng operator_name_en
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
     ������� ����������

������� ���������:

    operatorName - ��� ���������(���)
    operatorName_en - ��� ���������(����.)

�������� ���������(� ���� �������):

   operator_Id - ID ���������;
   Operator_Name - ��� ���������;
   Operator_Name_en - ��� ��������� (END);
   maxRowCount                - ������������ ���������� �������

(<body::getOperator>)
*/
FUNCTION getOperator
 (
  operatorName        varchar2 := null
 ,operatorName_en     varchar2 := null
 , maxRowCount        integer  := null
 )
return sys_refcursor is

  SQLstr varchar2(2000);
  TYPE curTypeResult     IS REF CURSOR;          --��� ������ ��� ������� ����������
  curResult              curTypeResult;          --������ � ����������� ������

begin

SQLstr := '
select v.operator_id
            ,v.operator_name_rus Operator_Name
            ,v.operator_name_eng Operator_Name_en
      from op_operator v
   where 1=1 ' ;

 AddSqlCondition( SQLstr, ' upper(v.operator_name_rus)', 'like', operatorName is null,'operatorName');
 AddSqlCondition( SQLstr, ' upper(v.operator_name_eng)', 'like', operatorName_en is null,'operatorName_en');
 AddSqlCondition( SQLstr, ' rownum', '<=', maxRowCount is null,'maxRowCount');

 open  curResult FOR SQLstr
	using
		upper(operatorName)
		, upper(operatorName_en)
    , maxRowCount;


  return curResult;--������ ���������

exception  --����������� ��������� ����������
  when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ���������.'
    , true
  );
end;

/* proc: RestoreOperator
   ��������� �������������� ���������� ������������ RestoreOperator

   ������� ���������:
   operatorId	        -	������������, �������� ���������� ������������
   restoreOperatorId	-	������������, ������� ��������������� ������

*/
procedure RestoreOperator( operatorId	integer,
                           restoreOperatorId	integer)
is

begin

ISUSERADMIN(OPERATORID => restoreOperatorId
                     , TARGETOPERATORID => operatorId);

update op_operator op
  set op.date_finish = null
  where op.operator_id = operatorId;

end;

/* func: CreateOperator
   ������� �������� ������������ CreateOperator

   ������� ���������:
     operatorName	-	������������ ������������ �� ����� �� ���������
     operatorNameEn	-	������������ ������������ �� ���������� �����
     login	-	�����
     password	-	������
     changePassword	-	������� ������������� ��������� ������ �������������:
                    1 � ������������ ���������� �������� ������;
                    0 � ������������ ��� ������������� ������ ������.
     operatorIdIns	-	������������, ��������� ������

    �������� ���������:

    ID ���������� ���������
*/
function CreateOperator(operatorName	  varchar2,
                        operatorNameEn	varchar2,
                        login	          varchar2,
                        password	      varchar2,
                        changePassword	integer,
                        operatorIdIns	  integer)
return integer
is
dr op_operator%rowtype;
begin

IsUserAdmin(operatorIdIns, null);

     select
        op_operator_seq.nextval
       into dr.operator_id
     from dual;

     dr.operator_name_rus := operatorName;
     dr.login             := login;
     dr.password          := GetHash(password);
     dr.date_begin        := sysdate;
     dr.date_finish       := null;--to_date('01.01.4000');
     dr.date_ins          := sysdate;
     dr.operator_id_ins   := operatorIdIns;
     dr.operator_name_eng := operatorNameEn;
     dr.change_password   := changePassword;
     dr.operator_name     := operatorName;
     dr.operator_name_en  := operatorNameEn;

insert into op_operator values dr;

   return dr.operator_id ;

exception when others then

  raise_application_error( pkg_Error.ErrorStackInfo
    , '������ ��� �������� ��������� ('
      || ' login="' || login || '"'  || ').', true );

end;

/* proc: UpdateOperator
   ��������� ���������� ������������ UpdateOperator

   ������� ���������:
     operatorId - ID ��������� ��� ���������
     operatorName	-	������������ ������������ �� ����� �� ���������
     operatorNameEn	-	������������ ������������ �� ���������� �����
     login	-	�����
     password	-	������
     changePassword	-	������� ������������� ��������� ������ �������������:
                    1 � ������������ ���������� �������� ������;
                    0 � ������������ ��� ������������� ������ ������.
     operatorIdIns	-	������������, ��������� ������

*/
procedure UpdateOperator( operatorId	    integer,
                          operatorName	  varchar2,
                          operatorNameEn	varchar2,
                          login	          varchar2,
                          password	      varchar2,
                          changePassword	integer,
                          operatorIdIns	  integer)
is

dr op_operator%rowtype;

begin
 IsUserAdmin(operatorIdIns, null);

     dr.operator_name_rus := operatorName;
     dr.login             := login;
     dr.operator_name_eng := operatorNameEn;
     dr.change_password   := changePassword;
     dr.operator_name     := operatorName;
     dr.operator_name_en  := operatorNameEn;

 update op_operator t
   set
       t.operator_name_rus = dr.operator_name_rus
     , t.operator_name_eng = dr.operator_name_eng
     , t.operator_name     = dr.operator_name
     , t.operator_name_en  = dr.operator_name_en

     , t.login             = dr.login
     , t.change_password   = dr.change_password
   where t.operator_id = operatorId;

    if password is not null
    then
    pkg_operator.CHANGEPASSWORD( operatorId,
                                     password,
                                     operatorIdIns);
    end if;

 update op_operator t
   set t.change_password   = dr.change_password
   where t.operator_id = operatorId;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '������ ��� ��������� ������ ��������� ('
      || ' operator_id=' || to_char(operatorID) || ').'
    , true );
end;

/* proc: DeleteOperator
   ��������� �������� ������������ DeleteOperator

   ������� ���������:
     operatorId - ID ��������� ��� ��������
     operatorIdIns	-	������������, �������� ������
*/
procedure DeleteOperator( operatorId	integer,
                          operatorIdIns	integer)
is

begin
 IsUserAdmin(operatorIdIns, operatorId);

  update op_operator t
   set
       t.date_finish = sysdate
   where t.operator_id = operatorId;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '������ ��� �������� ��������� ('
      || ' operator_id=' || to_char(operatorID) || ').'
    , true );
end;

/* func: FindOperator
   ������� ������ ������������ FindOperator

   ������� ���������:
       operatorId	-	������������� ������������
       login	-	����� ������������
       operatorName	-	������������ ������������ �� ����� �� ���������
       operatorNameEn	-	������������ ������������ �� ���������� �����
       deleted	-	������� ����������� ��������� �������:  0 � �� ���������� ���������;  1 � ���������� ���������.
       rowCount	-	������������ ���������� ������������ �������
       operatorIdIns	-	������������, �������������� �����

    �������� ���������(� ���� �������):
        operator_id	-	������������� ������������
        login	-	����� ������������
        operator_name	-	������������ ������������ �� ����� �� ���������
        operator_name_en	-	������������ ������������ �� ���������� �����
        date_begin	-	���� ������ �������� ������
        date_finish	-	���� ��������� �������� ������
        change_password	-	������� ������������� ����� ������: 0 � ������ ������ �� �����; 1 � ���������� ������� ������.
        date_ins	-	���� �������� ������
        operator_id_ins	-	������������, ��������� ������
        operator_name_ins	-	������������ �� ����� �� ���������, ��������� ������
        operator_name_ins_en	-	������������ �� ���������� �����, ��������� ������
*/
function FindOperator(  operatorId	   integer,
                        login	         varchar2,
                        operatorName	 varchar2,
                        operatorNameEn	varchar2,
                        deleted	        integer,
                        rowCount	      integer,
                        operatorIdIns	  integer)
return sys_refcursor
is

  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --������ � ����������� ������

begin

 IsUserAdmin(operatorIdIns, null);

SQLstr := 'select op.operator_id
                , op.login
                , op.operator_name
                , op.operator_name_en
                , op.date_begin
                , op.date_finish
                , op.change_password
                , op.date_ins
                , op.operator_id_ins
                , ( select op1.operator_name_rus
                      from op_operator op1
                       where op1.operator_id = op.operator_id_ins) operator_name_ins
                , ( select op1.operator_name_en
                      from op_operator op1
                       where op1.operator_id = op.operator_id_ins) operator_name_ins_en
          from op_operator op
          where 1=1' ;

 if deleted = 0
 then
   SQLstr := SQLstr || ' and (op.date_finish is null  or op.date_finish > sysdate ) ';

 elsif deleted = 1
 then
    SQLstr := SQLstr || ' and op.date_finish is not null ';

 end if;

 AddSqlCondition( SQLstr, 'op.operator_id', '=', operatorId is null);
 AddSqlCondition( SQLstr, 'upper(op.login)', 'like', login is null, 'login');
 AddSqlCondition( SQLstr, 'upper(op.operator_name)', 'like', operatorName is null,'operatorName');
 AddSqlCondition( SQLstr, 'upper(op.operator_name_en)', 'like', operatorNameEn is null,'operatorNameEn');
 AddSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

 open  curResult
    FOR SQLstr
	    using operatorId,
            upper(login),
            upper(operatorName),
            upper(operatorNameEn),
            rowCount;

  --������ ���������
  return curResult;

exception  --����������� ��������� ����������
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ���������.', true);

end;

/* proc: RestoreOperator
   ��������� �������������� ���������� ������������

   ������� ���������:
     operatorId - ID ��������� ��� ��������
     operatorIdIns	-	������������, �������� ������
*/
procedure RestoreOperator( operatorId	integer,
                          operatorIdIns	integer)
is
begin
 IsUserAdmin(operatorIdIns, operatorId);

  update op_operator t
   set
       t.date_finish = NULL--to_date('01.01.4000')
   where t.operator_id = operatorId;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '������ ��� ������������� ���������� ��������� ('
      || ' operator_id=' || to_char(operatorID) || ').'
    , true );

end;

/* func: CreateRole
   ������� �������� ���� CreateRole

   ������� ���������:
      roleName	-	������������ ���� �� ����� �� ���������
      roleNameEn	-	������������ ���� �� ���������� �����
      shortName	-	������� ������������ ����
      description	-	�������� ���� �� ����� �� ���������
      operatorId	-	������������, ��������� ������

   �������� ���������:
      ������������� ��������� ������ ����
*/
function CreateRole( roleName	    varchar2,
                     roleNameEn	  varchar2,
                     shortName	  varchar2,
                     description	varchar2,
                     operatorId	  integer)
return integer
is
dr op_role%rowtype;

begin

  IsRole( operatorID, RoleAdmin_Role);

  select
     op_role_seq.nextval
   into dr.role_id
  from dual;

  dr.role_name_rus   := roleName;
  dr.short_name      := shortName;
  dr.date_ins        := sysdate;
  dr.operator_id     := operatorId;
  dr.role_name_eng   := roleNameEn;
  dr.description     := description;
  dr.role_name       := roleName;
  dr.role_name_en    := roleNameEn;

  insert into op_role values dr;

return dr.role_id;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '������ ��� �������� ���� ('
      || ' role_id=' || to_char(dr.role_id)
      || ', short_name="' || to_char( shortName) || '"' || ').', true);

end;

/* proc: UpdateRole
   ��������� ���������� ���� UpdateRole

   ������� ���������:
      roleId - ID ����
      roleName	-	������������ ���� �� ����� �� ���������
      roleNameEn	-	������������ ���� �� ���������� �����
      shortName	-	������� ������������ ����
      description	-	�������� ���� �� ����� �� ���������
      operatorId	-	������������, ��������� ������

*/
procedure UpdateRole( roleId	     integer,
                      roleName	   varchar2,
                      roleNameEn	 varchar2,
                      shortName	   varchar2,
                      description	 varchar2,
                      operatorId	 integer)
is
dr op_role%rowtype;
begin

  IsRole( operatorID, RoleAdmin_Role);

  dr.role_name_rus   := roleName;
  dr.short_name      := shortName;
  dr.date_ins        := sysdate;
  dr.operator_id     := operatorId;
  dr.role_name_eng   := roleNameEn;
  dr.description     := description;
  dr.role_name       := roleName;
  dr.role_name_en    := roleNameEn;

   update op_role t
     set
        t.role_name_rus = dr.role_name_rus
      , t.short_name    = dr.short_name
      , t.role_name_eng = dr.role_name_eng
      , t.description   = dr.description
      , t.role_name     = dr.role_name
      , t.role_name_en  = dr.role_name_en
   where t.role_id =  roleId;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '������ ��� ��������� ���� ('
      || ' role_id=' || to_char(roleId)
      || ', short_name="' || to_char( shortName) || '"' || ').', true);

end;

/* proc: DeleteRole
   ��������� �������� ���� DeleteRole

   ������� ���������:
      roleId - ID ����
      operatorId	-	������������, ��������� ������
*/
procedure DeleteRole( roleId	integer,
                      operatorId	integer)
is

begin
  IsRole( operatorID, RoleAdmin_Role);

  delete OP_GROUP_ROLE t
    where t.role_id = roleId;

  delete op_role t
    where t.role_id = roleId;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '������ ��� �������� ���� ('
      || ' role_id=' || to_char(roleId) || ').', true);

end;

/* func: FindRole
   ������� ������ ���� FindRole

   ������� ���������:
      roleId	        -	������������� ����
      roleName	      -	������������ ���� �� ����� �� ���������
      roleNameEn	    -	������������ ���� �� ���������� �����
      shortName	      -	������� ������������ ����
      description	    -	�������� ���� �� ����� �� ���������
      rowCount	      -	������������ ���������� ������������ �������
      operatorId	    -	������������, �������������� �����

   �������� ���������(� ���� �������):
      role_id	          -	������������� ����
      short_name	      -	������� ������������ ����
      role_name	        -	������������ ���� �� ����� �� ���������
      role_name_en	    -	������������ ���� �� ���������� �����
      description	      -	�������� ���� �� ����� �� ���������
      date_ins	        -	���� �������� ������
      operator_id	      -	������������, ��������� ������
      operator_name	    -	������������ �� ����� �� ���������, ��������� ������
      operator_name_en	-	������������ �� ���������� �����, ��������� ������
*/
function FindRole(  roleId	     integer,
                    roleName	   varchar2,
                    roleNameEn	 varchar2,
                    shortName	   varchar2,
                    description	 varchar2,
                    rowCount	   integer,
                    operatorId	 integer)
return sys_refcursor
is

  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --������ � ����������� ������

begin

  IsRole( operatorID, RoleAdmin_Role);

SQLstr := 'select  opr.role_id,
                   opr.short_name,
                   opr.role_name,
                   opr.role_name_en,
                   opr.description,
                   opr.date_ins,
                   opr.operator_id,
                   op.operator_name,
                   op.operator_name_en
            from op_role opr
            join op_operator op
              on op.operator_id = opr.operator_id
            where 1=1 ' ;


 AddSqlCondition( SQLstr, 'opr.role_id', '=', roleId is null);
 AddSqlCondition( SQLstr, 'upper(opr.role_name)', 'like', roleName is null, 'roleName');
 AddSqlCondition( SQLstr, 'upper(opr.role_name_en)', 'like', roleNameEn is null,'roleNameEn');
 AddSqlCondition( SQLstr, 'upper(opr.short_name)', 'like', shortName is null,'shortName');
 AddSqlCondition( SQLstr, 'upper(opr.description)', 'like', description is null,'description');
 AddSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

 open  curResult
    FOR SQLstr || ' order by opr.role_id'
	    using roleId,
            upper(roleName),
            upper(roleNameEn),
            upper(shortName),
            upper(description),
            rowCount;

  --������ ���������
  return curResult;

exception  --����������� ��������� ����������
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ����.', true);


end;

/* func: CreateGroup
   ������� �������� ������ CreateGroup

   ������� ���������:
      groupName	-	������������ ������ �� ����� �� ���������
      groupNameEn	-	������������ ������ �� ���������� �����
      isGrantOnly	-	������� grant-������: ���� 1, �� ������ ������������� ����� ������ �������� ������ �� ���� ������ �������������
      operatorId	-	������������, ��������� ������

   �������� ���������:

     ������������� ��������� ������ ������
*/
function CreateGroup( groupName	  varchar2,
                      groupNameEn	varchar2,
                      isGrantOnly	number,
                      operatorId	integer)
return integer
is
dr op_group%rowtype;

begin

  IsRole( operatorID, RoleAdmin_Role);

   select
       op_group_seq.nextval
     into dr.group_id
    from dual;

  dr.group_name_rus  := groupName;
  dr.date_ins        := sysdate;
  dr.operator_id     := operatorId;
  dr.group_name_eng  := groupNameEn;
  dr.is_grant_only   := isGrantOnly;
  dr.group_name      := groupName;
  dr.group_name_en   := groupNameEn;

insert into op_group  values dr;

return dr.group_id;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '��� �������� ������ �������� ������ ('
      || ' group_name_rus="' || groupName || '"' || ').' , true);

end;

/* proc: UpdateGroup
   ��������� ���������� ������ UpdateGroup

   ������� ���������:
      groupId - ID ������
      groupName	-	������������ ������ �� ����� �� ���������
      groupNameEn	-	������������ ������ �� ���������� �����
      isGrantOnly	-	������� grant-������: ���� 1, �� ������ ������������� ����� ������ �������� ������ �� ���� ������ �������������
      operatorId	-	������������, ��������� ������
*/
procedure UpdateGroup(  groupId	    integer,
                        groupName	  varchar2,
                        groupNameEn	varchar2,
                        isGrantOnly	number,
                        operatorId	integer)
is
dr op_group%rowtype;

begin
  IsRole( operatorID, RoleAdmin_Role);

  dr.group_name_rus  := groupName;
  dr.date_ins        := sysdate;
  dr.operator_id     := operatorId;
  dr.group_name_eng  := groupNameEn;
  dr.is_grant_only   := isGrantOnly;
  dr.group_name      := groupName;
  dr.group_name_en   := groupNameEn;

  update op_group t
    set t.group_name_rus =  dr.group_name_rus
      , t.group_name_eng =  dr.group_name_eng
      , t.is_grant_only  =  dr.is_grant_only
      , t.group_name     =  dr.group_name
      , t.group_name_en  =  dr.group_name_en
  where t.group_id =  groupId;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '������ ��� ��������� ������ ('
      || ' group_id=' || to_char(groupId)
      || ', group_name="' || to_char(groupName) || '"' || ').', true);
end;

/* proc: DeleteGroup
   ��������� �������� ������ DeleteGroup

  ������� ���������:
      groupId - ID ������
      operatorId	-	������������, ��������� ������

*/
procedure DeleteGroup(  groupId	    integer,
                        operatorId	integer)
is
begin

  IsRole( operatorID, RoleAdmin_Role);

  delete op_group t
     where t.group_id = groupId;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '��� �������� ������ �������� ������ ('
      || ' group_id=' || to_char( groupID)|| ').', true);

end;

/* func: FindGroup
   ������� ������ ������ FindGroup

   ������� ���������:
      groupId	-	������������� ������
      groupName	-	������������ ������ �� ����� �� ���������
      groupNameEn	-	������������ ������ �� ���������� �����
      isGrantOnly	-	������� ���������� ������ grant-������:      ���� 1, �� ���������� ������ grant-������;      ���� 0  ��� null, �� ���������� ��� ������.
      rowCount	-	������������ ���������� ������������ �������
      operatorId	-	������������, �������������� �����

   �������� ���������(� ���� �������):
      group_id	-	������������� ������
      group_name	-	������������ ������ �� ����� �� ���������
      group_name_en	-	������������ ������ �� ���������� �����
      is_grant_only	-	������� grant-������:      ���� 1, �� ������ ������������� ����� ������ �������� ������ �� ���� ������ �������������      date_ins	date	���� �������� ������
      operator_id	-	������������, ��������� ������
      operator_name	-	������������ �� ����� �� ���������, ��������� ������
      operator_name_en	-	������������ �� ���������� �����, ��������� ������
*/
function FindGroup( groupId	     integer,
                    groupName	   varchar2,
                    groupNameEn	 varchar2,
                    isGrantOnly	 number,
                    rowCount	   integer,
                    operatorId	 integer)
return sys_refcursor
is

  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --������ � ����������� ������

begin

 IsUserAdmin(operatorId, null);

SQLstr := 'select  opg.group_id,
                   opg.group_name,
                   opg.group_name_en,
                   opg.is_grant_only,
                   opg.date_ins,
                   opg.operator_id,
                   op.operator_name,
                   op.operator_name_en
              from op_group opg
              join op_operator op
                on op.operator_id = opg.operator_id
              where 1=1 '  ;

 if isGrantOnly = 1
 then
 SQLstr := SQLstr || ' and opg.is_grant_only = 1 ';

 end if;

 AddSqlCondition( SQLstr, 'opg.group_id', '=', groupId is null);
 AddSqlCondition( SQLstr, 'upper(opg.group_name)', 'like', groupName is null, 'groupName');
 AddSqlCondition( SQLstr, 'upper(opg.group_name_en)', 'like', groupNameEn is null,'groupNameEn');
-- AddSqlCondition( SQLstr, 'opg.is_grant_only', 'like', isGrantOnly is null);
 AddSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

 open  curResult
    FOR SQLstr || ' order by 1'
	    using groupId,
            upper(groupName),
            upper(groupNameEn),
--            isGrantOnly,
            rowCount;

  --������ ���������
  return curResult;

exception  --����������� ��������� ����������
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ����.', true);
end;

/* proc: CreateOperatorRole
   ��������� �������� ����� ������������ � ���� CreateOperatorRole
*/
procedure CreateOperatorRole(  operatorId	  integer,
                              roleId	      integer,
                              operatorIdIns	integer)
is
dr op_operator_role%rowtype;
begin

  IsUserAdmin(
    operatorID          => operatorIDIns
    , roleID            => roleID
  );

 dr.operator_id      := operatorId;
 dr.role_id          := roleId;
 dr.date_ins         := sysdate;
 dr.operator_id_ins  := operatorIdIns;

 insert into op_operator_role values dr;

exception when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '��� ��������� ���� � ������ �������� ������ ('
      || ' role_id=' || to_char( roleID) || ').' , true );

end;

/* func: FindOperatorRole
   ������� ������ ����� ������������ � ���� FindOperatorRole

   ������� ���������:
      operatorId	    -	������������� ������������
      roleId	        -	������������� ����
      rowCount	      -	������������ ���������� ������������ �������
      operatorIdIns	  -	������������, �������������� �����

   �������� ���������(� ���� �������):
      operator_id	    -	������������� ������������
      role_id	        -	������������� ����
      short_name	    -	������� ������������ ����
      role_name	      -	������������ ���� �� ����� �� ���������
      role_name_en	  -	������������ ���� �� ���������� �����
      description	    -	�������� ���� �� ����� �� ���������
      date_ins	      -	���� �������� ������
      operator_id_ins	-	������������, ��������� ������
      operator_name_ins	    -	������������ �� ����� �� ���������, ��������� ������
      operator_name_ins_en	-	������������ �� ���������� �����, ��������� ������
*/
function FindOperatorRole(  operatorId	integer,
                            roleId	    integer,
                            rowCount	  integer,
                            operatorIdIns	integer)
return sys_refcursor
is

  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --������ � ����������� ������

begin

IsUserAdmin(operatorIdIns, null);

SQLstr := ' select t.operator_id
                 , t.role_id
                 , opr.short_name
                 , opr.role_name
                 , opr.role_name_en
                 , opr.description
                 , t.date_ins
                 , t.operator_id_ins
                , ( select op1.operator_name_rus
                      from op_operator op1
                       where op1.operator_id = t.operator_id_ins) operator_name_ins
                , ( select op1.operator_name_en
                      from op_operator op1
                       where op1.operator_id = t.operator_id_ins) operator_name_ins_en
            from op_operator_role t
            join op_role opr
              on opr.role_id = t.role_id
            join op_operator op
              on op.operator_id = t.operator_id_ins
            where 1=1 ' ;

 AddSqlCondition( SQLstr, 't.operator_id', '=', operatorId is null);
 AddSqlCondition( SQLstr, 't.role_id', '=', roleId is null);
 AddSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

 open  curResult
    FOR SQLstr || ' order by t.operator_id , t.role_id '
	    using operatorId,
            roleId,
            rowCount;

  --������ ���������
  return curResult;

exception  --����������� ��������� ����������
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ����.', true);

end;

/* func: GetNoOperatorRole
   ������� ����������� ����� �������� �� ������������� ������������ GetNoOperatorRole

   ������� ���������:
      operatorId	    -	������������� ������������
      operatorIdIns	  -	������������, �������������� �����

   �������� ���������(� ���� �������):
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
function GetNoOperatorRole( operatorId	integer,
                            operatorIdIns	integer)
return sys_refcursor
is
  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --������ � ����������� ������

begin

IsUserAdmin(operatorIdIns, null);

SQLstr := ' select opr.role_id
           , opr.short_name
           , opr.role_name
           , opr.role_name_en
           , opr.description
           , opr.date_ins
           , opr.operator_id
           , op.operator_name
           , op.operator_name_en
      from op_role opr
      join op_operator op
        on op.operator_id = opr.operator_id
      where 1=1' ;

if operatorId is not null
then

      SQLstr := SQLstr|| '  and opr.role_id not in ( select vop.role_id
                                 from op_operator_role vop
                                where vop.operator_id = :operatorId
                                )  ';

       open  curResult
          FOR SQLstr || ' order by opr.role_id   '
            using operatorId;

else

       open  curResult
          FOR SQLstr || ' order by opr.role_id';
end if;

  --������ ���������
  return curResult;

exception  --����������� ��������� ����������
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ����.', true);

end;

/* func: FindOperatorGroup
   ������� ������ ����� ������������ � ������ FindOperatorGroup

   ������� ���������:
      operatorId	-	������������� ������������
      groupId	-	������������� ������
      rowCount	-	������������ ���������� ������������ �������
      operatorIdIns	-	������������, �������������� �����

   �������� ���������(� ���� �������):
      operator_id	-	������������� ������������
      group_id	-	������������� ������
      group_name	-	������������ ������ �� ����� �� ���������
      group_name_en	-	������������ ������ �� ���������� �����
      is_grant_only	-	������� grant-������:���� 1, �� ������ ������������� ����� ������ �������� ������ �� ���� ������ �������������date_ins	date	���� �������� ������
      operator_id_ins	-	������������, ��������� ������
      operator_name_ins	-	������������ �� ����� �� ���������, ��������� ������
      operator_name_ins_en	-	������������ �� ���������� �����, ��������� ������
*/
function FindOperatorGroup( operatorId	  integer,
                            groupId	      integer,
                            rowCount	    integer,
                            operatorIdIns	integer)
return sys_refcursor
is
  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --������ � ����������� ������

begin

IsUserAdmin(operatorIdIns, null);

SQLstr := ' select opg.operator_id,
                   opg.group_id,
                   g.group_name,
                   g.group_name_en,
                   g.is_grant_only,
                   opg.date_ins,
                   opg.operator_id_ins
                , ( select op1.operator_name_rus
                      from op_operator op1
                       where op1.operator_id = opg.operator_id_ins) operator_name_ins
                , ( select op1.operator_name_en
                      from op_operator op1
                       where op1.operator_id = opg.operator_id_ins) operator_name_ins_en

              from op_operator_group opg
              join op_group g
                on g.group_id = opg.group_id
              join op_operator op
               on op.operator_id = opg.operator_id_ins
              where 1=1 ' ;


 AddSqlCondition( SQLstr, 'opg.operator_id', '=', operatorId is null);
 AddSqlCondition( SQLstr, 'opg.group_id', '=', groupId is null);
 AddSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

 open  curResult
    FOR SQLstr || ' order by  opg.group_id, op.operator_name'
	    using operatorId,
            groupId,
            rowCount;

  --������ ���������
  return curResult;

exception  --����������� ��������� ����������
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ������ �����.', true);

end;

/* func: GetNoOperatorGroup
   ������� ����������� ����� �������� �� ������������� ������������ GetNoOperatorGroup

   ������� ���������:
     operatorId	-	������������� ������������
     operatorIdIns	-	������������, �������������� �������

   �������� ���������(� ���� �������):
      group_id	-	������������� ������
      group_name	-	������������ ������ �� ����� �� ���������
      group_name_en	-	������������ ������ �� ���������� �����
      is_grant_only	-	������� grant-������:���� 1, �� ������ ������������� ����� ������ �������� ������ �� ���� ������ �������������date_ins	date	���� �������� ������
      operator_id	-	������������, ��������� ������
      operator_name	-	������������ �� ����� �� ���������, ��������� ������
      operator_name_en	-	������������ �� ���������� �����, ��������� ������
*/
function GetNoOperatorGroup(  operatorId	    integer,
                              operatorIdIns	integer)
return sys_refcursor
is
  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --������ � ����������� ������

begin

IsUserAdmin(operatorIdIns, null);

SQLstr := '  select g.group_id
                  , g.group_name
                  , g.group_name_en
                  , g.is_grant_only
                  , g.date_ins
                  , g.operator_id
                  , op.operator_name
                  , op.operator_name_en
                  from op_group g
                  join op_operator op
                    on op.operator_id = g.operator_id
                  where 1=1 ' ;

if operatorId is not null
then

      SQLstr := SQLstr|| '  and g.group_id not in ( select vop.group_id
                                 from op_operator_group vop
                                where vop.operator_id = :operatorId
                                )  ';

       open  curResult
          FOR SQLstr || ' order by g.group_id '
            using operatorId;

else

       open  curResult
          FOR SQLstr || ' order by g.group_id ';
end if;


  --������ ���������
  return curResult;

exception  --����������� ��������� ����������
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ �����.', true);

end;

/* func: FindGroupRole
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
function FindGroupRole( groupId	     integer,
                        roleId	     integer,
                        rowCount	   integer,
                        operatorId	 integer)
return sys_refcursor
is
  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --������ � ����������� ������

begin

  IsRole( operatorID, RoleAdmin_Role);

SQLstr := 'select  gr.group_id,
                   gr.role_id,
                   r.short_name,
                   r.role_name,
                   r.role_name_en,
                   r.description,
                   gr.date_ins,
                   op.operator_id,
                   op.operator_name,
                   op.operator_name_en
            from op_group_role gr
            join op_role r
              on r.role_id = gr.role_id
            join op_operator op
              on op.operator_id = gr.operator_id
            where 1=1  ' ;


 AddSqlCondition( SQLstr, 'gr.group_id', '=', groupId is null);
 AddSqlCondition( SQLstr, 'gr.role_id', '=', roleId is null);
 AddSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

 open  curResult
    FOR SQLstr || ' order by gr.group_id , gr.role_id'
	    using groupId,
            roleId,
            rowCount;

  --������ ���������
  return curResult;

exception  --����������� ��������� ����������
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ������.', true);

end;

/* func: GetNoGroupRole
   ������� ����������� ����� �������� �� ������������� ������ GetNoGroupRole

   ������� ���������:
      groupId	-	������������� ������
      operatorId	-	������������, �������������� �������

   �������� ���������(� ���� �������):
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
function GetNoGroupRole( groupId	integer,
                         operatorId	integer)
return sys_refcursor
is
  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --������ � ����������� ������

begin

 IsRole( operatorID, RoleAdmin_Role);

SQLstr := ' select
                   r.role_id,
                   r.short_name,
                   r.role_name,
                   r.role_name_en,
                   r.description,
                   r.date_ins,
                   op.operator_id,
                   op.operator_name,
                   op.operator_name_en
            from op_role r
            join op_operator op
              on op.operator_id = r.operator_id
            where 1=1  ' ;

if operatorId is not null
then

      SQLstr := SQLstr|| '  and r.role_id not in ( select gr.role_id
                                     from op_group_role gr
                                     where gr.group_id = :groupId )';

       open  curResult
          FOR SQLstr || ' order by r.role_id '
            using groupId;

else

       open  curResult
          FOR SQLstr || ' order by r.role_id ';
end if;


  --������ ���������
  return curResult;

exception  --����������� ��������� ����������
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ �����.', true);

end;

/* func: FindGrantGroup
   ������� ������ ����� grant-������ � ������ FindGrantGroup

   ������� ���������:
      groupId	-	������������� ������
      grantGroupId	-	������������� ������, ������� ��������� �������� (����������)
      rowCount	-	������������ ���������� ������������ �������
      operatorId	-	������������, �������������� �����

   �������� ���������(� ���� �������):
      group_id	-	������������� ������
      grant_group_id	-	������������� ������, ������� ��������� �������� (����������)
      grant_group_name	-	������������ ������ �� ����� �� ���������
      grant_group_name_en	-	������������ ������ �� ���������� �����
      is_grant_only	-	������� grant-������:      ���� 1, �� ������ ������������� ����� ������ �������� ������ �� ���� ������ �������������      date_ins	date	���� �������� ������
      operator_id	-	������������, ��������� ������
      operator_name	-	������������ �� ����� �� ���������, ��������� ������
      operator_name_en	-	������������ �� ���������� �����, ��������� ������
*/
function FindGrantGroup(  groupId	      integer,
                          grantGroupId	integer,
                          rowCount	    integer,
                          operatorId	  integer)
return sys_refcursor
is
  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --������ � ����������� ������

begin

  IsRole( operatorID, RoleAdmin_Role);

SQLstr := 'select  gg.group_id,
                   gg.grant_group_id,
                   g.group_name grant_group_name,
                   g.group_name_en grant_group_name_en,
                   g.is_grant_only is_grant_only,
                   gg.date_ins,
                   gg.operator_id,
                   op.operator_name,
                   op.operator_name_en
              from op_grant_group gg
              join op_group g
               on g.group_id = gg.grant_group_id
              join op_operator op
               on op.operator_id = gg.operator_id
              where 1=1 ' ;


 AddSqlCondition( SQLstr, 'gg.group_id', '=', groupId is null);
 AddSqlCondition( SQLstr, 'gg.grant_group_id', '=', grantGroupId is null);
 AddSqlCondition( sqlStr,'rownum', '<=', rowCount is null, 'rowCount');

 open  curResult
    FOR SQLstr || ' order by gg.group_id ,  gg.grant_group_id'
	    using groupId,
            grantGroupId,
            rowCount;

  --������ ���������
  return curResult;

exception  --����������� ��������� ����������
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ ������.', true);

end;

/* func: GetNoGrantGroup
   ������� ����������� ����� �������� �� ������������� grant-������ GetNoGrantGroup

   ������� ���������:
      groupId	-	������������� ������
      operatorId	-	������������, �������������� �������

   �������� ���������( � ���� �������):
      group_id	-	������������� ������
      group_name	-	������������ ������ �� ����� �� ���������
      group_name_en	-	������������ ������ �� ���������� �����
      is_grant_only	-	������� grant-������:      ���� 1, �� ������ ������������� ����� ������ �������� ������ �� ���� ������ �������������      date_ins	date	���� �������� ������
      operator_id	-	������������, ��������� ������
      operator_name	-	������������ �� ����� �� ���������, ��������� ������
      operator_name_en	-	������������ �� ���������� �����, ��������� ������
*/
function GetNoGrantGroup( groupId	integer,
                          operatorId	integer)
return sys_refcursor
is
  SQLstr varchar2(2000);
  curResult  sys_refcursor;          --������ � ����������� ������

begin

 IsRole( operatorID, RoleAdmin_Role);

SQLstr := 'select g.group_id,
                   g.group_name,
                   g.group_name_en,
                   g.is_grant_only,
                   g.date_ins,
                   g.operator_id,
                   op.operator_name,
                   op.operator_name_en
              from op_group g
              join op_operator op
                on op.operator_id = g.operator_id
              where 1=1 ' ;

if groupId is not null
then

      SQLstr := SQLstr|| '   and g.group_id not in ( select gg.grant_group_id
                            from op_grant_group gg
                             where gg.group_id = :groupId
                             )   ';

       open  curResult
          FOR SQLstr || ' order by g.group_id '
            using groupId;

else

       open  curResult
          FOR SQLstr || ' order by g.group_id ';
end if;


  --������ ���������
  return curResult;

exception  --����������� ��������� ����������
  when others then
  raise_application_error( pkg_Error.ErrorStackInfo
    , '�������� ������ ��� ������ �����.', true);

end;

end pkg_Operator;
/
