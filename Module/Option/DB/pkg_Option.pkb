create or replace package body pkg_Option is
/* package body: pkg_Option::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_Option'
);



/* group: ������� */

/* iproc: checkRole
  ��������� ����� �� ������ � ���������� �� ������ �������� ��������� �����.

  ���������:
  operatorId                  - Id ��������� ( ���� null, �� �������
                                ��������)
  readOnlyAccessFlag          - ��������� ����� ������� ������ �� ��������
                                ������ ( 1 ��, 0 ��� ( �� ���������))
*/
procedure checkRole(
  operatorId integer
  , readOnlyAccessFlag pls_integer := null
)
is

  -- Id ���������, ����� �������� �����������
  checkOperatorId integer;

  -- ��������� ��������
  isOk integer;

begin
  checkOperatorId := coalesce( operatorId, pkg_Operator.getCurrentUserId());
  select
    count(*)
  into isOk
  from
    dual
  where
    exists
      (
      select
        null
      from
        v_op_operator_role opr
        inner join v_op_role rl
          on rl.role_id = opr.role_id
        cross join
          (
          select
            max( ov.string_value) as local_role_suffix
          from
            v_opt_option_value ov
          where
            ov.module_svn_root = pkg_OptionMain.Module_SvnRoot
            and ov.object_short_name is null
            and ov.option_short_name
              = pkg_OptionMain.LocalRoleSuffix_OptionSName
          ) opt
      where
        opr.operator_id = checkOperatorId
        and rl.role_short_name in (
          pkg_OptionMain.Admin_RoleSName
          , case when opt.local_role_suffix is not null then
              'OptAdminAllOption' || opt.local_role_suffix
            end
          , case when readOnlyAccessFlag = 1 then
              pkg_OptionMain.Show_RoleSName
            end
          , case when readOnlyAccessFlag = 1
                  and opt.local_role_suffix is not null
                then
              'OptShowAllOption' || opt.local_role_suffix
            end
        )
      )
  ;
  if isOk = 0 then
    raise_application_error(
      pkg_Error.ProcessError
      , '� ��������� ��� ���� ��'
        || case when readOnlyAccessFlag = 1 then
            ' ��������'
          else
            ' ���������'
          end
        || ' ���������� ('
        || ' checkOperatorId=' || checkOperatorId
        || ').'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ���� ������� �������� �������� ����� ('
        || ' operatorId=' || operatorId
        || ', readOnlyAccessFlag=' || readOnlyAccessFlag
        || ').'
      )
    , true
  );
end checkRole;



/* group: ����������� ��������� */

/* func: createOption
  ������� ����������� �������� � ������ ��� ���� ������������ � ������� ��
  ��������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��������
  objectShortName             - �������� �������� ������� ������
                                ( �� ��������� �����������)
  objectTypeId                - Id ���� �������
                                ( �� ��������� �����������)
  optionShortName             - �������� �������� ���������
  valueTypeCode               - ��� ���� �������� ���������
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ���������� ���� ( 1 ��, 0 ��� ( �� ���������))
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ����
                                ( 1 ��, 0 ��� ( �� ���������))
  testProdSensitiveFlag       - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
                                ( 1 ��, 0 ��� ( �� ���������))
  optionName                  - �������� ���������
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
  stringListSeparator         - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������� ��������
                                ( �� ��������� ������������ ";")
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id ���������.

  ���������:
  - � ������, ���� ������������ ������ ��������, ��������� � ����������
    ������� �������� ����������� ��� ������ �������� ������;
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;
*/
function createOption(
  moduleId integer
  , objectShortName varchar2 := null
  , objectTypeId varchar2 := null
  , optionShortName varchar2
  , valueTypeCode varchar2
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , optionName varchar2
  , optionDescription varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , stringListSeparator varchar2 := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
return integer
is

  -- Id ���������� ���������
  optionId integer;

  -- Id ���������� ��������
  valueId integer;

begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  optionId := pkg_OptionMain.createOption(
    moduleId                  => moduleId
    , objectShortName         => objectShortName
    , objectTypeId            => objectTypeId
    , optionShortName         => optionShortName
    , valueTypeCode           => valueTypeCode
    , valueListFlag           => valueListFlag
    , encryptionFlag          => encryptionFlag
    , testProdSensitiveFlag   => testProdSensitiveFlag
    , accessLevelCode         => pkg_OptionMain.Full_AccessLevelCode
    , optionName              => optionName
    , optionDescription       => optionDescription
    , operatorId              => operatorId
  );
  valueId := pkg_OptionMain.createValue(
    optionId                  => optionId
    , valueTypeCode           => valueTypeCode
    , prodValueFlag           =>
        case when testProdSensitiveFlag = 1 then
          pkg_Common.isProduction()
        end
    , instanceName            => null
    , usedOperatorId          => null
    , dateValue               => dateValue
    , numberValue             => numberValue
    , stringValue             => stringValue
    , valueListSeparator      => stringListSeparator
    , operatorId              => operatorId
  );
  return optionId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ��������� ('
        || ' moduleId=' || moduleId
        || ', objectShortName="' || objectShortName || '"'
        || ', objectTypeId=' || objectTypeId
        || ', optionShortName="' || optionShortName || '"'
        || ').'
      )
    , true
  );
end createOption;

/* proc: updateOption
  �������� ����������� ��������.

  ���������:
  optionId                    - Id ���������
  valueTypeCode               - ��� ���� �������� ���������
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ���������� ���� ( 1 ��, 0 ���)
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ���� ( 1 ��, 0 ���)
  testProdSensitiveFlag       - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
                                ( 1 ��, 0 ���)
  optionName                  - �������� ���������
  optionDescription           - �������� ���������
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ��������, ������� �� ������������� ����� ������ ������������ ���������,
    ���������;
  - � ������������ �� ��� ��������� �������� testProdSensitiveFlag �������
    �������� ��������� ����������� ( ��� ���� ������ ������ �������� ���������
    �������� ��� ������������ �� ��� ��������);
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;
*/
procedure updateOption(
  optionId integer
  , valueTypeCode varchar2
  , valueListFlag integer
  , encryptionFlag integer
  , testProdSensitiveFlag integer
  , optionName varchar2
  , optionDescription varchar2
  , checkRoleFlag integer := null
  , operatorId integer := null
)
is

  -- ������� ������ ���������
  rec opt_option%rowtype;

begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  pkg_OptionMain.lockOption(
    rowData         => rec
    , optionId      => optionId
  );
  if rec.access_level_code != pkg_OptionMain.Full_AccessLevelCode then
    raise_application_error(
      pkg_Error.ProcessError
      , '��������� ��������� ����� ��������� ��������� ('
        || ' access_level_code="' || rec.access_level_code || '"'
        || ').'
    );
  end if;
  pkg_OptionMain.updateOption(
    optionId                      => optionId
    , moduleId                    => rec.module_id
    , objectShortName             => rec.object_short_name
    , objectTypeId                => rec.object_type_id
    , optionShortName             => rec.option_short_name
    , valueTypeCode               => valueTypeCode
    , valueListFlag               => valueListFlag
    , encryptionFlag              => encryptionFlag
    , testProdSensitiveFlag       => testProdSensitiveFlag
    , accessLevelCode             => rec.access_level_code
    , optionName                  => optionName
    , optionDescription           => optionDescription
    , moveProdSensitiveValueFlag  => pkg_Common.isProduction()
    , deleteBadValueFlag          => 1
    , operatorId                  => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ��������� ('
        || ' optionId=' || optionId
        || ').'
      )
    , true
  );
end updateOption;

/* proc: setOptionValue
  ������ ������������ � ������� �� �������� ������������ ���������.

  ���������:
  optionId                    - Id ���������
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;
*/
procedure setOptionValue(
  optionId integer
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
is

  -- ������� ������ ���������
  opt opt_option%rowtype;

  -- ������ ������������� ��������
  vlr opt_value%rowtype;

begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  pkg_OptionMain.lockOption(
    rowData         => opt
    , optionId      => optionId
  );
  if opt.access_level_code not in (
          pkg_OptionMain.Full_AccessLevelCode
          , pkg_OptionMain.Value_AccessLevelCode
        )
      then
    raise_application_error(
      pkg_Error.ProcessError
      , '������� �������� ��������� ����� ��������� ��������� ('
        || ' access_level_code="' || opt.access_level_code || '"'
        || ').'
    );
  end if;
  pkg_OptionMain.getValue(
    rowData             => vlr
    , optionId          => optionId
    , usedValueFlag     => 1
    , raiseNotFoundFlag => 0
  );
  pkg_OptionMain.setValue(
    optionId                  => optionId
    , prodValueFlag           => vlr.prod_value_flag
    , instanceName            =>
        case when vlr.value_id is not null then
          vlr.instance_name
        end
    , usedOperatorId          => null
    , dateValue               => dateValue
    , numberValue             => numberValue
    , stringValue             => stringValue
    , valueIndex              => valueIndex
    , operatorId              => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������� ������������� �������� ��������� ('
        || ' optionId=' || optionId
        || ').'
      )
    , true
  );
end setOptionValue;

/* proc: deleteOption
  ������� ����������� ��������.

  ���������:
  optionId                    - Id ���������
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;
*/
procedure deleteOption(
  optionId integer
  , checkRoleFlag integer := null
  , operatorId integer := null
)
is

  -- ������� ������ ���������
  opt opt_option%rowtype;

begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  pkg_OptionMain.lockOption(
    rowData         => opt
    , optionId      => optionId
  );
  if opt.access_level_code != pkg_OptionMain.Full_AccessLevelCode then
    raise_application_error(
      pkg_Error.ProcessError
      , '�������� ��������� ����� ��������� ��������� ('
        || ' access_level_code="' || opt.access_level_code || '"'
        || ', optionId=' || optionId
        || ').'
    );
  end if;
  pkg_OptionMain.deleteOption(
    optionId                      => optionId
    , operatorId                  => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ��������� ('
        || ' optionId=' || optionId
        || ').'
      )
    , true
  );
end deleteOption;

/* func: findOption
  ����� ����������� ����������.

  ���������:
  optionId                    - Id ���������
  moduleId                    - Id ������, � �������� ��������� ��������
  objectShortName             - �������� �������� ������� ������
                                ( ����� �� like ��� ����� ��������)
  objectTypeId                - Id ���� �������
  optionShortName             - �������� �������� ���������
                                ( ����� �� like ��� ����� ��������)
  optionName                  - �������� ���������
                                ( ����� �� like ��� ����� ��������)
  optionDescription           - �������� ���������
                                ( ����� �� like ��� ����� ��������)
  stringValue                 - ��������� ��������
                                ( ����� �� like ��� ����� ��������)
  maxRowCount                 - ������������ ����� ������������ ������� �������
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  ������� ( ������):
  option_id                   - Id ���������
  value_id                    - Id ������������� ��������
  module_id                   - Id ������, � �������� ��������� ��������
  module_name                 - �������� ������, � �������� ��������� ��������
  module_svn_root             - ���� � Subversion � ��������� �������� ������,
                                � ��������� ��������� ��������
  object_short_name           - �������� �������� ������� ������
  object_type_id              - Id ���� �������
  object_type_short_name      - �������� �������� ���� �������
  object_type_name            - �������� ���� �������
  option_short_name           - �������� �������� ���������
  value_type_code             - ��� ���� �������� ���������
  value_type_name             - �������� ���� �������� ���������
  date_value                  - �������� ��������� ���� ����
  number_value                - �������� �������� ���������
  string_value                - ��������� �������� ��������� ���� ������
                                �������� � ������������, ��������� � ����
                                list_separator ( ���� ��� ������)
  list_separator              - ������, ������������ � �������� ����������� �
                                ������ ��������
  value_list_flag             - ���� ������� ��� ��������� ������ ��������
  encryption_flag             - ���� �������� �������� ��������� �
                                ������������� ����
  test_prod_sensitive_flag    - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
  access_level_code           - ��� ������ ������� ����� ���������
  access_level_name           - �������� ������ ������� ����� ���������
  option_name                 - �������� ���������
  option_description          - �������� ���������

  ���������:
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;
*/
function findOption(
  optionId integer := null
  , moduleId integer := null
  , objectShortName varchar2 := null
  , objectTypeId integer := null
  , optionShortName varchar2 := null
  , optionName varchar2 := null
  , optionDescription varchar2 := null
  , stringValue varchar2 := null
  , maxRowCount integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
return sys_refcursor
is

  -- ������������ ������
  rc sys_refcursor;

  -- ����������� ����������� ����� �������
  dsql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  a.*
from
  (
  select
    t.*
  from
    (
    select
      t.option_id
      , t.value_id
      , t.module_id
      , t.module_name
      , t.module_svn_root
      , t.object_short_name
      , t.object_type_id
      , t.object_type_short_name
      , t.object_type_name
      , t.option_short_name
      , t.value_type_code
      , vt.value_type_name
      , t.date_value
      , t.number_value
      , case when t.list_separator is not null
              and t.value_type_code = '''
                || pkg_OptionMain.Date_ValueTypeCode || '''
              and t.encryption_flag = 0
            then
          -- ��� ��������� ������������� ������ ��� ������� ����������� �����
          replace( t.string_value, '' 00:00:00'', '''')
        else
          t.string_value
        end
        as string_value
      , t.list_separator
      , t.value_list_flag
      , t.encryption_flag
      , t.test_prod_sensitive_flag
      , t.access_level_code
      , al.access_level_name
      , t.option_name
      , t.option_description
    from
      v_opt_option_value t
      inner join opt_value_type vt
        on vt.value_type_code = t.value_type_code
      inner join opt_access_level al
        on al.access_level_code = t.access_level_code
    ) t
  where
    $(condition)
  order by
    t.module_svn_root
    , t.object_short_name nulls first
    , t.object_type_short_name
    , t.object_type_id
    , t.option_short_name
  ) a
where
  $(rownumCondition)
'
  );

-- findOption
begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId, readOnlyAccessFlag => 1);
  end if;
  dsql.addCondition(
    't.option_id =', optionId is null
  );
  dsql.addCondition(
    't.module_id =', moduleId is null
  );
  dsql.addCondition(
    'upper( t.object_short_name) like upper( :objectShortName)'
    , objectShortName is null
  );
  dsql.addCondition(
    't.object_type_id =', objectTypeId is null
  );
  dsql.addCondition(
    'upper( t.option_short_name) like upper( :optionShortName)'
    , optionShortName is null
  );
  dsql.addCondition(
    'upper( t.option_name) like upper( :optionName)'
    , optionName is null
  );
  dsql.addCondition(
    'upper( t.option_description) like upper( :optionDescription)'
    , optionDescription is null
  );
  dsql.addCondition(
    'upper( t.string_value) like upper( :stringValue)'
    , stringValue is null
  );
  dsql.useCondition( 'condition');
  dsql.addCondition(
    'rownum <= :maxRowCount', maxRowCount is null
  );
  dsql.useCondition( 'rownumCondition');
  open rc for
    dsql.getSqlText()
  using
    optionId
    , moduleId
    , objectShortName
    , objectTypeId
    , optionShortName
    , optionName
    , optionDescription
    , stringValue
    , maxRowCount
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������ ����������� ����������.'
      )
    , true
  );
end findOption;



/* group: �������� ���������� */

/* func: createValue
  ������� �������� ���������.

  ���������:
  optionId                    - Id ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                  �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  usedOperatorId              - Id ���������, ��� �������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
  stringListSeparator         - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������� ��������
                                ( �� ��������� ������������ ";")
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id �������� ���������.

  ���������:
  - � ������, ���� ������������ ������ ��������, ��������� � ����������
    ������� �������� ����������� ��� ������ �������� ������;
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;
*/
function createValue(
  optionId integer
  , prodValueFlag integer
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , stringListSeparator varchar2 := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
return integer
is

  -- Id ���������� ��������
  valueId integer;

  -- ������ ���������
  opt opt_option%rowtype;

begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  pkg_OptionMain.lockOption(
    rowData         => opt
    , optionId      => optionId
  );
  if opt.access_level_code not in (
          pkg_OptionMain.Full_AccessLevelCode
          , pkg_OptionMain.Value_AccessLevelCode
        )
      then
    raise_application_error(
      pkg_Error.ProcessError
      , '������� �������� ��������� ����� ��������� ��������� ('
        || ' access_level_code="' || opt.access_level_code || '"'
        || ').'
    );
  end if;
  valueId := pkg_OptionMain.createValue(
    optionId                  => optionId
    , valueTypeCode           => opt.value_type_code
    , prodValueFlag           => prodValueFlag
    , instanceName            => instanceName
    , usedOperatorId          => usedOperatorId
    , dateValue               => dateValue
    , numberValue             => numberValue
    , stringValue             => stringValue
    , valueListSeparator      => stringListSeparator
    , operatorId              => operatorId
  );
  return valueId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� �������� ('
        || ' optionId=' || optionId
        || ', prodValueFlag=' || prodValueFlag
        || ', instanceName="' || instanceName || '"'
        || ', usedOperatorId=' || usedOperatorId
        || ').'
      )
    , true
  );
end createValue;

/* proc: updateValue
  �������� �������� ���������.

  ���������:
  valueId                     - Id ��������
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;
*/
procedure updateValue(
  valueId integer
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
is

  -- ������ ��������
  vlr opt_value%rowtype;

  -- ������ ���������
  opt opt_option%rowtype;

begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  pkg_OptionMain.lockValue(
    rowData         => vlr
    , valueId       => valueId
  );
  pkg_OptionMain.lockOption(
    rowData         => opt
    , optionId      => vlr.option_id
  );
  if opt.access_level_code not in (
          pkg_OptionMain.Full_AccessLevelCode
          , pkg_OptionMain.Value_AccessLevelCode
        )
      then
    raise_application_error(
      pkg_Error.ProcessError
      , '������� �������� ��������� ����� ��������� ��������� ('
        || ' access_level_code="' || opt.access_level_code || '"'
        || ').'
    );
  end if;
  pkg_OptionMain.updateValue(
    valueId                   => valueId
    , valueTypeCode           => opt.value_type_code
    , dateValue               => dateValue
    , numberValue             => numberValue
    , stringValue             => stringValue
    , valueIndex              => valueIndex
    , operatorId              => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� �������� ('
        || ' valueId=' || valueId
        || ').'
      )
    , true
  );
end updateValue;

/* proc: deleteValue
  ������� �������� ���������.

  ���������:
  valueId                     - Id �������� ���������
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;
*/
procedure deleteValue(
  valueId integer
  , checkRoleFlag integer := null
  , operatorId integer := null
)
is

  -- ������ ��������
  vlr opt_value%rowtype;

  -- ������ ���������
  opt opt_option%rowtype;

begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  pkg_OptionMain.lockValue(
    rowData         => vlr
    , valueId       => valueId
  );
  pkg_OptionMain.lockOption(
    rowData         => opt
    , optionId      => vlr.option_id
  );
  if opt.access_level_code not in (
          pkg_OptionMain.Full_AccessLevelCode
          , pkg_OptionMain.Value_AccessLevelCode
        )
      then
    raise_application_error(
      pkg_Error.ProcessError
      , '�������� �������� ��������� ����� ��������� ��������� ('
        || ' access_level_code="' || opt.access_level_code || '"'
        || ').'
    );
  end if;
  pkg_OptionMain.deleteValue(
    valueId                   => valueId
    , operatorId              => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� �������� ('
        || ' valueId=' || valueId
        || ').'
      )
    , true
  );
end deleteValue;

/* func: findValue
  ����� �������� ����������� ����������.

  ���������:
  valueId                     - Id ��������
  optionId                    - Id ���������
  maxRowCount                 - ������������ ����� ������������ ������� �������
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  ������� ( ������):
  value_id                    - Id ��������
  option_id                   - Id ���������
  used_value_flag             - ���� �������� ������������� � �� ��������
                                ( 1 ��, ����� null)
  prod_value_flag             - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) �� ( 1 ������ �
                                ������������ ��, 0 ������ � �������� ��, null
                                ��� �����������)
  instance_name               - ��� ���������� ��, � ������� �����
                                �������������� �������� ( � ������� ��������,
                                null ��� �����������)
  used_operator_id            - Id ���������, ��� �������� �����
                                �������������� ��������
  used_operator_name          - ��� ���������, ��� �������� �����
                                �������������� ��������
  value_type_code             - ��� ���� �������� ���������
  value_type_name             - �������� ���� �������� ���������
  list_separator              - ������, ������������ � �������� ����������� �
                                ������ ��������
  encryption_flag             - ���� �������� �������� ��������� �
                                ������������� ����
  date_value                  - �������� ��������� ���� ����
  number_value                - �������� �������� ���������
  string_value                - ��������� �������� ��������� ���� ������
                                �������� � ������������, ��������� � ����
                                list_separator ( ���� ��� ������)

  ���������:
  - ����������� ������ ���� ������� �������� valueId ��� optionId;
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;
*/
function findValue(
  valueId integer := null
  , optionId integer := null
  , maxRowCount integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
return sys_refcursor
is

  -- ������������ ������
  rc sys_refcursor;

  -- ����������� ����������� ����� �������
  dsql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  a.*
from
  (
  select
    t.value_id
    , t.option_id
    , case when ov.value_id is not null then 1 end
      as used_value_flag
    , t.prod_value_flag
    , t.instance_name
    , t.used_operator_id
    , uo.operator_name as used_operator_name
    , t.value_type_code
    , vt.value_type_name
    , t.list_separator
    , t.encryption_flag
    , t.date_value
    , t.number_value
    , case when t.list_separator is not null
            and t.value_type_code = '''
              || pkg_OptionMain.Date_ValueTypeCode || '''
            and t.encryption_flag = 0
          then
        -- ��� ��������� ������������� ������ ��� ������� ����������� �����
        replace( t.string_value, '' 00:00:00'', '''')
      else
        t.string_value
      end
      as string_value
  from
    v_opt_value t
    inner join opt_value_type vt
      on vt.value_type_code = t.value_type_code
    left outer join v_opt_option_value ov
      on ov.value_id = t.value_id
    left outer join op_operator uo
      on uo.operator_id = t.used_operator_id
  where
    $(condition)
  order by
    t.option_id
    , t.prod_value_flag nulls first
    , t.instance_name nulls first
    , t.used_operator_id nulls first
    , t.value_id
  ) a
where
  $(rownumCondition)
'
  );

-- findValue
begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId, readOnlyAccessFlag => 1);
  end if;
  if valueId is null and optionId is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������ ���� ������� �������� valueId ��� optionId.'
    );
  end if;
  dsql.addCondition(
    't.value_id =', valueId is null
  );
  dsql.addCondition(
    't.option_id =', optionId is null
  );
  dsql.useCondition( 'condition');
  dsql.addCondition(
    'rownum <= :maxRowCount', maxRowCount is null
  );
  dsql.useCondition( 'rownumCondition');
  open rc for
    dsql.getSqlText()
  using
    valueId
    , optionId
    , maxRowCount
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������ �������� ����������� ���������� ('
        || ' valueId=' || valueId
        || ', optionId=' || optionId
        || ').'
      )
    , true
  );
end findValue;



/* group: ����������� */

/* func: getObjectType
  ���������� ���� ��������.

  ������� ( ������):
  object_type_id              - Id ���� �������
  object_type_short_name      - �������� �������� ���� �������
  object_type_name            - �������� ���� �������
  module_name                 - �������� ������, � �������� ��������� ���
                                �������
  module_svn_root             - ���� � Subversion � ��������� �������� ������,
                                � ��������� ��������� ��� �������
  ( ���������� �� object_type_name, object_type_id)
*/
function getObjectType
return sys_refcursor
is

  -- ������������ ������
  rc sys_refcursor;

begin
  open rc for
    select
      t.object_type_id
      , t.object_type_short_name
      , t.object_type_name
      , t.module_name
      , t.module_svn_root
    from
      v_opt_object_type t
    order by
      t.object_type_name
      , t.object_type_id
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������� ����� ��������.'
      )
    , true
  );
end getObjectType;

/* func: getValueType
  ���������� ���� �������� ����������.

  ������� ( ������):
  value_type_code             - ��� ���� �������� ���������
  value_type_name             - �������� ���� �������� ���������

  ( ���������� �� value_type_name)
*/
function getValueType
return sys_refcursor
is

  -- ������������ ������
  rc sys_refcursor;

begin
  open rc for
    select
      t.value_type_code
      , t.value_type_name
    from
      opt_value_type t
    order by
      t.value_type_name
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������� ����� �������� ����������.'
      )
    , true
  );
end getValueType;



/* group: ����������� ������ ������� */

/* func: findModule
  ����� ����������� �������.

  ���������:
  moduleId                    - Id ������
  moduleName                  - �������� ������
                                ( ����� �� like ��� ����� ��������)
  maxRowCount                 - ������������ ����� ������������ ������� �������

  ������� ( ������):
  module_id                   - Id ������
  module_name                 - �������� ������
  svn_root                    - ���� � Subversion � ��������� �������� ������,
*/
function findModule(
  moduleId integer := null
  , moduleName varchar2 := null
  , maxRowCount integer := null
)
return sys_refcursor
is

  -- ������������ ������
  rc sys_refcursor;

  -- ����������� ����������� ����� �������
  dsql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  a.*
from
  (
  select
    t.module_id
    , t.module_name
    , t.svn_root
  from
    v_mod_module t
  where
    $(condition)
  order by
    t.module_name
    , t.svn_root
  ) a
where
  $(rownumCondition)
'
  );

-- findModule
begin
  dsql.addCondition(
    't.module_id =', moduleId is null
  );
  dsql.addCondition(
    'upper( t.module_name) like upper( :moduleName)'
    , moduleName is null
  );
  dsql.useCondition( 'condition');
  dsql.addCondition(
    'rownum <= :maxRowCount', maxRowCount is null
  );
  dsql.useCondition( 'rownumCondition');
  open rc for
    dsql.getSqlText()
  using
    moduleId
    , moduleName
    , maxRowCount
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������ ����������� �������.'
      )
    , true
  );
end findModule;

/* func: getOperator
  ��������� ������ �� ����������.

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
  return
    pkg_Operator.getOperator(
      operatorName  => operatorName
      , maxRowCount    => maxRowCount
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ������ �� ���������� ('
        || ' operatorName="' || operatorName || '"'
        || ', maxRowCount=' || maxRowCount
        || ').'
      )
    , true
  );
end getOperator;

end pkg_Option;
/
