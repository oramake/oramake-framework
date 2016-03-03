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
        inner join op_role rl
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
        and rl.short_name in (
          'GlobalOptionAdmin'
          , case when opt.local_role_suffix is not null then
              'OptAdminAllOption' || opt.local_role_suffix
            end
          , case when readOnlyAccessFlag = 1 then
              'OptShowAllOption'
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
  rec opt_option_new%rowtype;

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
  opt opt_option_new%rowtype;

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
  - ��� ����������� ��������� ������������� � ������ �������� option_id ��
    ������� opt_option, �������������� � ������� opt_option_new, ���������
    ��������� �������� ������� �� ���������� ������;
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

  -- Id ��������� � opt_option_new
  newOptionId integer;

  -- ������� ������ ���������
  opt opt_option_new%rowtype;



  /*
    ���������� Id ��������� � opt_option_new ( �.�. ������� ����� ����
    ������� � �� ��������� option_id �� opt_option).
  */
  procedure getNewOptionId
  is
  begin
    select
      min( t.option_id)
    into newOptionId
    from
      opt_option_new t
    where
      t.option_id = optionId
    ;
    if newOptionId is null then
      select
        min( t.option_id)
      into newOptionId
      from
        opt_option_new t
      where
        t.old_option_short_name =
          (
          select
            case when
              opt.option_short_name
                like '%_' || pkg_OptionMain.OldTestOption_Suffix
            then
              substr(
                opt.option_short_name, 1, length( opt.option_short_name) - 4
              )
            else
              opt.option_short_name
            end
            as prod_option_short_name
          from
            opt_option opt
          where
            opt.option_id = optionId
          )
      ;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ����������� Id ��������� � opt_option_new.'
        )
      , true
    );
  end getNewOptionId;



  /*
    �������� �� ���������� ������ ( ��������� ��� �������������).
  */
  procedure deleteOptionOld
  is
  begin
    if operatorId is not null then
      pkg_Operator.setCurrentUserId( operatorId);
    end if;

    delete from
      opt_option_value
    where
      option_id = optionId
    ;
    delete from
      opt_option
    where
      option_id = optionId
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� �� ���������� ������.'
        )
      , true
    );
  end deleteOptionOld;



-- deleteOption
begin
  if coalesce( checkRoleFlag, 1) != 0 then
    checkRole( operatorId);
  end if;
  getNewOptionId();
  if newOptionId is not null then
    pkg_OptionMain.lockOption(
      rowData         => opt
      , optionId      => newOptionId
    );
    if opt.access_level_code != pkg_OptionMain.Full_AccessLevelCode then
      raise_application_error(
        pkg_Error.ProcessError
        , '�������� ��������� ����� ��������� ��������� ('
          || ' access_level_code="' || opt.access_level_code || '"'
          || ', newOptionId=' || newOptionId
          || ').'
      );
    end if;
  end if;
  if optionId = newOptionId then
    pkg_OptionMain.deleteOption(
      optionId                      => optionId
      , operatorId                  => operatorId
    );
  else
    deleteOptionOld();
  end if;
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
  opt opt_option_new%rowtype;

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
  opt opt_option_new%rowtype;

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
  opt opt_option_new%rowtype;

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
      , rowCount    => maxRowCount
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



/* group: ���������� ������� */

/* func: getOptionDate(optionShortName)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
function getOptionDate(
  optionShortName varchar2
)
return date
is
  -- �������� �����
  dateValue date;
begin
  select
    datetime_value
  into
    dateValue
  from
    v_opt_option
  where
    option_short_name = optionShortName
  ;
  return
    dateValue
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� �������� ����� ���� ('
        || ' optionShortName="' || optionShortName || '"'
        || ')'
      )
    , true
  );
end getOptionDate;

/* func: getOptionString(optionShortName)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
function getOptionString(
  optionShortName varchar2
)
return varchar2
is
  -- �������� �����
  stringValue v_opt_option.string_value%type;
begin
  select
    string_value
  into
    stringValue
  from
    v_opt_option
  where
    option_short_name = optionShortName
  ;
  return
    stringValue;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ���������� �������� �����('
        || ' optionShortName="' || optionShortName || '"'
        || ')'
      )
    , true
  );
end getOptionString;

/* func: getOptionNumber(optionShortName)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
function getOptionNumber(
  optionShortName varchar2
)
return number
is
  -- �������� �����
  numberValue v_opt_option.integer_value%type;
begin
  select
    integer_value
  into
    numberValue
  from
    v_opt_option
  where
    option_short_name = optionShortName
  ;
  return
    numberValue;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� �������� ����� ����� ('
        || ' optionShortName="' || optionShortName || '"'
        || ')'
      )
    , true
  );
end getOptionNumber;

/* proc: addOptionDate(optionShortName)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure addOptionDate(
  optionShortName varchar2
  , optionName varchar2
  , defaultDateValue varchar2 := null
)
is

  cursor optionCur is
    select
      option_id
      , option_name
      , datetime_value
    from
      v_opt_option
    where
      option_short_name = optionShortName
  ;

  optionRec optionCur%rowtype;
begin
  open optionCur;
  fetch optionCur into optionRec;
  if optionCur%found then
    logger.info(
      '����� ����������: ( '
      || 'optionShortName="' || optionShortName || '"'
      || ', optionName="' || optionRec.option_name || '"'
      || ', option_id=' || to_char( optionRec.option_id)
      || ', date_value="' || optionRec.datetime_value || '"'
      || ')'
    );
  else
    optionRec.option_id := pkg_Option.createOption(
      optionName => optionName
      , optionShortName => optionShortName
      , isGlobal => 1
      -- ����
      , maskId => 4
      , datetimeValue => defaultDateValue
      , integerValue => null
      , stringValue => null
      , operatorId => pkg_Operator.getCurrentUserId()
    );
    logger.info(
      '����� �������: ( '
      || 'optionShortName="' || optionShortName || '"'
      || ', optionName="' || optionName || '"'
      || ', option_id=' || to_char( optionRec.option_id)
      || ', date_value="' || defaultDateValue || '"'
      || ')'
    );
  end if;
  close optionCur;
exception when others then
  if optionCur%isopen then
    close optionCur;
  end if;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ����������� �����('
        || 'optionShortName="' || optionShortName || '"'
        || ', optionName="' || optionName || '"'
        || ', defaultDateValue="' || defaultDateValue || '"'
        || ')'
      )
    , true
  );
end addOptionDate;

/* proc: addOptionNumber(optionShortName)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure addOptionNumber(
  optionShortName varchar2
  , optionName varchar2
  , defaultNumberValue varchar2 := null
)
is

  cursor optionCur is
    select
      option_id
      , option_name
      , integer_value
    from
      v_opt_option
    where
      option_short_name = optionShortName
  ;

  optionRec optionCur%rowtype;
begin
  open optionCur;
  fetch optionCur into optionRec;
  if optionCur%found then
    logger.info(
      '����� ����������: ( '
      || 'optionShortName="' || optionShortName || '"'
      || ', optionName="' || optionRec.option_name || '"'
      || ', option_id=' || to_char( optionRec.option_id)
      || ', number_value="' || optionRec.integer_value || '"'
      || ')'
    );
  else
    optionRec.option_id := pkg_Option.createOption(
      optionName => optionName
      , optionShortName => optionShortName
      , isGlobal => 1
      -- �����
      , maskId => 1
      , datetimeValue => null
      , integerValue => defaultNumberValue
      , stringValue => null
      , operatorId => pkg_Operator.getCurrentUserId()
    );
    logger.info(
      '����� �������: ( '
      || 'optionShortName="' || optionShortName || '"'
      || ', optionName="' || optionName || '"'
      || ', option_id=' || to_char( optionRec.option_id)
      || ', number_value="' || defaultNumberValue || '"'
      || ')'
    );
  end if;
  close optionCur;
exception when others then
  if optionCur%isopen then
    close optionCur;
  end if;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ����������� �����('
        || 'optionShortName="' || optionShortName || '"'
        || ', optionName="' || optionName || '"'
        || ', defaultNumberValue="' || defaultNumberValue || '"'
        || ')'
      )
    , true
  );
end addOptionNumber;

/* proc: addOptionString(optionShortName)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure addOptionString(
  optionShortName varchar2
  , optionName varchar2
  , defaultStringValue varchar2 := null
)
is

  cursor optionCur is
    select
      option_id
      , option_name
      , string_value
    from
      v_opt_option
    where
      option_short_name = optionShortName
  ;

  optionRec optionCur%rowtype;
begin
  open optionCur;
  fetch optionCur into optionRec;
  if optionCur%found then
    logger.info(
      '����� ����������: ( '
      || 'optionShortName="' || optionShortName || '"'
      || ', optionName="' || optionRec.option_name || '"'
      || ', option_id=' || to_char( optionRec.option_id)
      || ', string_value="' || optionRec.string_value || '"'
      || ')'
    );
  else
    optionRec.option_id := pkg_Option.createOption(
      optionName => optionName
      , optionShortName => optionShortName
      , isGlobal => 1
      -- ������
      , maskId => 3
      , datetimeValue => null
      , integerValue => null
      , stringValue => defaultStringValue
      , operatorId => pkg_Operator.getCurrentUserId()
    );
    logger.info(
      '����� �������: ( '
      || 'optionShortName="' || optionShortName || '"'
      || ', optionName="' || optionName || '"'
      || ', option_id=' || to_char( optionRec.option_id)
      || ', string_value="' || defaultStringValue || '"'
      || ')'
    );
  end if;
  close optionCur;
exception when others then
  if optionCur%isopen then
    close optionCur;
  end if;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ����������� �����('
        || 'optionShortName="' || optionShortName || '"'
        || ', optionName="' || optionName || '"'
        || ', defaultStringValue="' || defaultStringValue || '"'
        || ')'
      )
    , true
  );
end addOptionString;

/* iproc: getOptionId
  ���������� �������.
*/
procedure getOptionId(
  optionId in opt_option_value.option_id%type
  , localOptionId out opt_option_value.option_id%type
  , globalOptionId out opt_option_value.option_id%type
)
is

IsGlobal opt_Option.Is_Global%Type;     --������� ����������� ���������
BEGIN
  begin
  select Is_Global into IsGlobal        --���� getOptionId.OptionID ���
  from opt_Option                       --���������� ����������, �� IsGlobal := 1
  where Option_ID = getOptionId.OptionID;
  Exception                             --�������������� ��������� � ����������� �� ����������
    When No_Data_Found then
    Raise_Application_Error(pkg_Error.RowNotFound,'��������� � ��������������� '||getOptionId.OptionID||' �� ���������� !');
  end;
if IsGlobal = 0 then
  Begin						            --���� � �������� ��������� ��� �������
  LocalOptionID := OptionID;            --��������� ��������
    begin
    select Link_Global_Local into GlobalOptionID
    from opt_Option
    where Option_ID = getOptionId.OptionID;
    Exception                           --���������������� ����������� ��������� �� ����������
      When No_Data_Found then
      GlobalOptionID := null;
    end;
  End;
else
  Begin                                 --���� � �������� ��������� ��� �������
  GlobalOptionID := OptionID;           --���������� ��������
    begin
    select Link_Global_Local into LocalOptionID
    from opt_Option
    where Option_ID = getOptionId.OptionID;
    Exception                           --���������������� ��������� ��������� �� ����������
      When No_Data_Found then
      LocalOptionID := null;
    end;
  End;
End if;
end getOptionId;

/* ifunc: getOptionShortName
  ���������� �������.
*/
function getOptionShortName(
  moduleName varchar2
  , moduleOptionName varchar2
)
return varchar2
is
-- getOptionShortName
begin
  return
    moduleName || '.' || moduleOptionName
  ;
end getOptionShortName;

/* ifunc: readOptionLocal
  ���������� �������.
*/
function readOptionLocal(
  optionId in opt_option_value.option_id%type
)
return opt_option_value%rowtype
is

Result opt_Option_Value%RowType;

BEGIN
Begin
select * into Result
from opt_Option_Value ov
where	ov.Option_ID = readOptionLocal.OptionID and
		ov.Operator_ID = pkg_Operator.GetCurrentUserID and
		ov.Date_Ins = (select max(ov2.Date_Ins)
			from opt_Option_Value ov2
			where	ov2.Option_ID = ov.Option_ID and
				ov2.Operator_ID = ov.Operator_ID);
Exception                               --�������� �� ��������� �������� �����
  When No_Data_Found then
    Result := null;
End;
RETURN Result;
end readOptionLocal;

/* ifunc: readOptionGlobal
  ���������� �������.
*/
function readOptionGlobal(
  optionId in opt_option_value.option_id%type
)
return opt_option_value%rowtype
is

Result opt_Option_Value%RowType;

BEGIN
Begin
select * into Result
from opt_Option_Value ov
where	ov.Option_ID = readOptionGlobal.OptionID and
		ov.Date_Ins = (select max(ov2.Date_Ins)
			from opt_Option_Value ov2
			where	ov2.Option_ID = ov.Option_ID);
Exception                               --�������� �� ��������� �������� �����
  When No_Data_Found then
    Result := null;
End;
RETURN Result;
end readOptionGlobal;

/* func: getOptionDate(optionId)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
function getOptionDate(
  optionId in opt_option_value.option_id%type
)
return opt_option_value.datetime_value%type
is

LocalOptionID  opt_Option.Option_ID%Type; --����� ���������� ���������
GlobalOptionID opt_Option.Option_ID%Type; --����� ����������� ���������
OptionValues   opt_Option_Value%RowType;  --���� ������ �� ������� �������� ����������
BEGIN                                   --���������� ����� ����������������
                                        --���������� � ����������� ���������
getOptionId(OptionID,LocalOptionID,GlobalOptionID);
if LocalOptionID is not null then       --���� � ����������� ���� ���������������
                                        --��������� �������� - ��������� ��� ��������
  OptionValues := readOptionLocal(LocalOptionID);
end if;
if(OptionValues.DateTime_Value is null)and(GlobalOptionID is not null) then
  OptionValues := readOptionGlobal(GlobalOptionID);
end if;
RETURN OptionValues.DateTime_Value;
end getOptionDate;

/* func: getOptionInteger(optionId)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
function getOptionInteger(
  optionId in opt_option_value.option_id%type
)
return opt_option_value.integer_value%type
is

LocalOptionID  opt_Option.Option_ID%Type; --����� ���������� ���������
GlobalOptionID opt_Option.Option_ID%Type; --����� ����������� ���������
OptionValues   opt_Option_Value%RowType;  --���� ������ �� ������� �������� ����������
BEGIN                                   --���������� ����� ����������������
                                        --���������� � ����������� ���������
getOptionId(OptionID,LocalOptionID,GlobalOptionID);
if LocalOptionID is not null then
  OptionValues := readOptionLocal(LocalOptionID);
end if;
if(OptionValues.Integer_Value is null)and(GlobalOptionID is not null) then
  OptionValues := readOptionGlobal(GlobalOptionID);
end if;
RETURN OptionValues.Integer_Value;
end getOptionInteger;

/* func: getOptionString(optionId)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
function getOptionString(
  optionId in opt_option_value.option_id%type
)
return opt_option_value.string_value%type
is

LocalOptionID  opt_Option.Option_ID%Type; --����� ���������� ���������
GlobalOptionID opt_Option.Option_ID%Type; --����� ����������� ���������
OptionValues   opt_Option_Value%RowType;  --���� ������ �� ������� �������� ����������
BEGIN                                   --���������� ����� ����������������
                                        --���������� � ����������� ���������
getOptionId(OptionID,LocalOptionID,GlobalOptionID);
if LocalOptionID is not null then
  OptionValues := readOptionLocal(LocalOptionID);
end if;
if(OptionValues.String_Value is null)and(GlobalOptionID is not null) then
  OptionValues := readOptionGlobal(GlobalOptionID);
end if;
RETURN OptionValues.String_Value;
end getOptionString;

/* func: getOptionDate
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
function getOptionDate(
  moduleName varchar2
  , moduleOptionName varchar2
)
return date
is

  -- Id ��������� � ��� ��������
  optionId integer;
  prodValueFlag integer;

  -- ������ ��������
  vlr opt_value%rowtype;

begin
  pkg_OptionMain.getOptionInfoOld(
    optionId            => optionId
    , prodValueFlag     => prodValueFlag
    , moduleName        => moduleName
    , moduleOptionName  => moduleOptionName
    , raiseNotFoundFlag => 1
  );
  pkg_OptionMain.getValue(
    rowData                 => vlr
    , optionId              => optionId
    , prodValueFlag         => prodValueFlag
    , instanceName          => null
    , usedOperatorId        => null
    , valueTypeCode         => pkg_OptionMain.Date_ValueTypeCode
    , valueIndex            => null
    , raiseNotFoundFlag     => 1
  );
  return vlr.date_value;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� �������� ����� ���� ('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ')'
      )
    , true
  );
end getOptionDate;

/* func: getOptionString
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
function getOptionString(
  moduleName varchar2
  , moduleOptionName varchar2
)
return varchar2
is

  -- Id ��������� � ��� ��������
  optionId integer;
  prodValueFlag integer;

  -- ������ ��������
  vlr opt_value%rowtype;

begin
  pkg_OptionMain.getOptionInfoOld(
    optionId            => optionId
    , prodValueFlag     => prodValueFlag
    , moduleName        => moduleName
    , moduleOptionName  => moduleOptionName
    , raiseNotFoundFlag => 1
  );
  pkg_OptionMain.getValue(
    rowData                 => vlr
    , optionId              => optionId
    , prodValueFlag         => prodValueFlag
    , instanceName          => null
    , usedOperatorId        => null
    , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
    , valueIndex            => null
    , raiseNotFoundFlag     => 1
  );
  return vlr.string_value;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ���������� �������� �����('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ')'
      )
    , true
  );
end getOptionString;

/* func: getOptionNumber
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
function getOptionNumber(
  moduleName varchar2
  , moduleOptionName varchar2
)
return number
is

  -- Id ��������� � ��� ��������
  optionId integer;
  prodValueFlag integer;

  -- ������ ��������
  vlr opt_value%rowtype;

begin
  pkg_OptionMain.getOptionInfoOld(
    optionId            => optionId
    , prodValueFlag     => prodValueFlag
    , moduleName        => moduleName
    , moduleOptionName  => moduleOptionName
    , raiseNotFoundFlag => 1
  );
  pkg_OptionMain.getValue(
    rowData                 => vlr
    , optionId              => optionId
    , prodValueFlag         => prodValueFlag
    , instanceName          => null
    , usedOperatorId        => null
    , valueTypeCode         => pkg_OptionMain.Number_ValueTypeCode
    , valueIndex            => null
    , raiseNotFoundFlag     => 1
  );
  return vlr.number_value;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� �������� ����� ����� ('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ')'
      )
    , true
  );
end getOptionNumber;

/* proc: setDateTime(optionId)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure setDateTime(
  optionid in opt_option_value.option_id%type
  , value in opt_option_value.datetime_value%type
)
is
BEGIN
  checkRole( operatorId => null);
insert into opt_Option_Value
(Option_ID,Datetime_Value)
values(OptionID,Value);
end setDatetime;

/* proc: setString(optionId)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure setString(
  optionid in opt_option_value.option_id%type
  , value in opt_option_value.string_value%type
)
is
BEGIN
  checkRole( operatorId => null);
insert into opt_Option_Value
(Option_ID,String_Value)
values(OptionID,Value);
end setString;

/* proc: setInteger(optionId)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure setInteger(
  optionId in opt_option_value.option_id%type
  , value in opt_option_value.integer_value%type
)
is
BEGIN
  checkRole( operatorId => null);
insert into opt_Option_Value
(Option_ID,Integer_Value)
values(OptionID,Value);
end setInteger;

/* proc: setDate
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure setDate(
  moduleName varchar2
  , moduleOptionName varchar2
  , dateValue date
)
is
begin
  setDateTime(
    optionId =>
      pkg_OptionMain.getOldOptionId(
        moduleName => moduleName
        , moduleOptionName => moduleOptionName
      )
    , value => dateValue
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� �������� ��������� ('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', dateValue={' || to_char( dateValue, 'dd.mm.yyyy hh24:mi:ss') || '}'
      )
    , true
  );
end setDate;

/* proc: setString
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure setString(
  moduleName varchar2
  , moduleOptionName varchar2
  , stringValue varchar2
)
is
begin
  setString(
    optionId =>
      pkg_OptionMain.getOldOptionId(
        moduleName => moduleName
        , moduleOptionName => moduleOptionName
      )
    , value => stringValue
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� �������� ��������� ('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', stringValue="' || stringValue || '"'
      )
    , true
  );
end setString;

/* proc: setNumber
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure setNumber(
  moduleName varchar2
  , moduleOptionName varchar2
  , numberValue number
)
is
begin
  setInteger(
    optionId =>
      pkg_OptionMain.getOldOptionId(
        moduleName => moduleName
        , moduleOptionName => moduleOptionName
      )
    , value => numberValue
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� �������� ��������� ('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', numberValue=' || to_char( numberValue)
      )
    , true
  );
end setNumber;

/* func: createOption
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
function createOption(
  optionName opt_option.option_name%type
  , optionShortName opt_option.option_short_name%type
  , isGlobal opt_option.is_global%type
  , maskId opt_option.mask_id%type
  , dateTimeValue opt_option_value.datetime_value%type
  , integerValue opt_option_value.integer_value%type
  , stringValue opt_option_value.string_value%type
  , operatorId in op_operator.operator_id%type
)
return opt_option.option_id%type
is

  OptionId opt_option.option_id%type;
begin
  checkRole( operatorId);
  insert
    into opt_option
      (option_id, option_name
      , option_short_name, is_global
      , operator_id, mask_id)
    values
      (null, OptionName
      , OptionShortName, IsGlobal
      , OperatorId, MaskId)
    returning Option_Id into OptionId;

  insert
    into opt_option_value
      (option_value_id, option_id
      , datetime_value, integer_value, string_value
      , operator_Id)
    values
      (null, OptionId
      , DatetimeValue, IntegerValue, StringValue
      , OperatorId);

  return OptionId;
exception                               --����������� ��������� ����������
  when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '�������� ������ ��� �������� ��������� �������� ��������� ������ "'
    || OptionName || '"'
    , true
  );
end createOption;

/* func: createOption
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
function createOption(
  optionName opt_option.option_name%type
  , optionShortName opt_option.option_short_name%type
  , isGlobal opt_option.is_global%type
  , maskId opt_option.mask_id%type
  , stringValue varchar2
  , operatorId op_operator.operator_id%type
)
return integer
is

  OptionId opt_option.option_id%type;
  StorageRuleId integer;
BEGIN
  begin
    select Storage_Rule_Id
    into StorageRuleId
    from doc_mask
    where Mask_Id = MaskId;
  exception when no_data_found then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ��������� ��� ������ (Mask_Id = '
      || to_char(MaskId) || ')'
      , true
    );
  end;

  case StorageRuleId
    when StorageRuleInteger then
      OptionId := createOption(OptionName
        , OptionShortName
        , IsGlobal
        , MaskId
        , null
        , to_number (replace (StringValue, '.', substr (to_char (0.1, 'tm9'), 1, 1)))
        , null
        , OperatorId);
    when StorageRuleString then
      OptionId := createOption(OptionName
        , OptionShortName
        , IsGlobal
        , MaskId
        , null
        , null
        , StringValue
        , OperatorId);
    when StorageRuleDate then
      OptionId := createOption(OptionName
        , OptionShortName
        , IsGlobal
        , MaskId
        , to_date(StringValue, 'dd.mm.yyyy hh24:mi:ss')
        , null
        , null
        , OperatorId);
    else
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '�� ��������� ��� ������ (Mask_Id = '
        || to_char(MaskId) || ')'
        , true
      );
  end case;

  return OptionId;
exception                               --����������� ��������� ����������
  when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '�������� ������ ��� �������� ��������� �������� ��������� ������ "'
    || OptionName || '"'
    , true
  );
end createOption;

/* proc: updateOption
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure updateOption(
  optionId in opt_option.option_id%type
  , dateTimeValue in opt_option_value.datetime_value%type
  , integerValue in opt_option_value.integer_value%type
  , stringValue in opt_option_value.string_value%type
  , operatorId in op_operator.operator_id%type
)
is
BEGIN
  checkRole( operatorId);
  insert into opt_Option_Value
    (Option_ID
    , Datetime_Value, Integer_Value, String_Value
    , Operator_id)
  values(OptionID
    , DateTimeValue, IntegerValue, StringValue
    , OperatorId);
exception                               --����������� ��������� ����������
  when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '�������� ������ ��� �������������� ��������� �������� ��������� ������ (Option_Id = '
    || to_char(OptionId) || ')'
    , true
  );
end updateOption;

/* proc: updateOption
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure updateOption(
  optionId in opt_option.option_id%type
  , optionName in opt_option.option_name%type
  , optionShortName in opt_option.option_short_name%type
  , isGlobal in opt_option.is_global%type
  , maskId in opt_option.mask_id%type
  , dateTimeValue in opt_option_value.datetime_value%type
  , integerValue in opt_option_value.integer_value%type
  , stringValue in opt_option_value.string_value%type
  , operatorId in op_operator.operator_id%type
)
is
begin
  checkRole( operatorId);
  if operatorId is not null then
    pkg_Operator.setCurrentUserId( operatorId);
  end if;

  update opt_option
    set
      option_name = OptionName
      , option_short_name = OptionShortName
      , is_global = IsGlobal
      , mask_id = MaskId
    where Option_Id = OptionId;

  insert into opt_Option_Value
    (Option_ID
    , Datetime_Value, Integer_Value, String_Value
    , Operator_id)
  values(OptionID
    , DateTimeValue, IntegerValue, StringValue
    , OperatorId);

exception                               --����������� ��������� ����������
  when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '�������� ������ ��� �������������� ����� ������ ��������� �������� ��������� ������ "'
    || OptionName || '"'
    , true
  );
end updateOption;

/* proc: updateOption
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure updateOption(
  optionId in opt_option.option_id%type
  , maskId in opt_option.mask_id%type
  , stringValue in varchar2
  , operatorId in op_operator.operator_id%type
)
is

  StorageRuleId integer;
BEGIN

  begin
    select Storage_Rule_Id
    into StorageRuleId
    from doc_mask
    where Mask_Id = MaskId;
  exception when no_data_found then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ��������� ��� ������ (Mask_Id = '
      || to_char(MaskId) || ')'
      , true
    );
  end;

  case StorageRuleId
    when StorageRuleInteger then
      updateOption(OptionId
        , null
        , to_number (replace (StringValue, '.', substr (to_char (0.1, 'tm9'), 1, 1)))
        , null
        , OperatorId);
    when StorageRuleString then
      updateOption(OptionId
        , null
        , null
        , StringValue
        , OperatorId);
    when StorageRuleDate then
      updateOption(OptionId
        , to_date(StringValue, 'dd.mm.yyyy hh24:mi:ss')
        , null
        , null
        , OperatorId);
    else
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '�� ��������� ��� ������ (Mask_Id = '
        || to_char(MaskId) || ')'
        , true
      );
  end case;

exception                               --����������� ��������� ����������
  when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '�������� ������ ��� �������������� ��������� �������� ��������� ������ (Option_Id = '
    || to_char(OptionId) || ', value "' || StringValue || '")'
    , true
  );
end updateOption;

/* proc: updateOption
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure updateOption(
  optionId opt_option.option_id%type
  , optionName opt_option.option_name%type
  , optionShortName opt_option.option_short_name%type
  , isGlobal opt_option.is_global%type
  , maskId opt_option.mask_id%type
  , stringValue varchar2
  , operatorId op_operator.operator_id%type
)
is

  StorageRuleId integer;
BEGIN
  begin
    select Storage_Rule_Id
    into StorageRuleId
    from doc_mask
    where Mask_Id = MaskId;
  exception when no_data_found then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ��������� ��� ������ (Mask_Id = '
      || to_char(MaskId) || ')'
      , true
    );
  end;

  case StorageRuleId
    when StorageRuleInteger then
      updateOption(OptionId
        , OptionName
        , OptionShortName
        , IsGlobal
        , MaskId
        , null
        , to_number (replace (StringValue, '.', substr (to_char (0.1, 'tm9'), 1, 1)))
        , null
        , OperatorId);
    when StorageRuleString then
      updateOption(OptionId
        , OptionName
        , OptionShortName
        , IsGlobal
        , MaskId
        , null
        , null
        , StringValue
        , OperatorId);
    when StorageRuleDate then
      updateOption(OptionId
        , OptionName
        , OptionShortName
        , IsGlobal
        , MaskId
        , to_date(StringValue, 'dd.mm.yyyy hh24:mi:ss')
        , null
        , null
        , OperatorId);
    else
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '�� ��������� ��� ������ (Mask_Id = '
        || to_char(MaskId) || ')'
        , true
      );
    end case;

exception                               --����������� ��������� ����������
  when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '�������� ������ ��� �������������� ����� ������ ��������� �������� ��������� ������ "'
    || OptionName || '"'
    , true
  );
end updateOption;

/* proc: addOptionDate
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure addOptionDate(
  moduleName varchar2
  , moduleOptionName varchar2
  , optionName varchar2
  , defaultDateValue varchar2 := null
)
is
begin
  pkg_OptionMain.addOptionWithValueOld(
    moduleName          => moduleName
    , moduleOptionName  => moduleOptionName
    , valueTypeCode     => pkg_OptionMain.Date_ValueTypeCode
    , optionName        => optionName
    , dateValue         => defaultDateValue
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ����������� �����('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', optionName="' || optionName || '"'
        || ', defaultDateValue="' || defaultDateValue || '"'
        || ')'
      )
    , true
  );
end addOptionDate;

/* proc: addOptionNumber
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure addOptionNumber(
  moduleName varchar2
  , moduleOptionName varchar2
  , optionName varchar2
  , defaultNumberValue varchar2 := null
)
is
begin
  pkg_OptionMain.addOptionWithValueOld(
    moduleName          => moduleName
    , moduleOptionName  => moduleOptionName
    , valueTypeCode     => pkg_OptionMain.Number_ValueTypeCode
    , optionName        => optionName
    , numberValue       => defaultNumberValue
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ����������� �����('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', optionName="' || optionName || '"'
        || ', defaultNumberValue="' || defaultNumberValue || '"'
        || ')'
      )
    , true
  );
end addOptionNumber;

/* proc: addOptionString
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.
*/
procedure addOptionString(
  moduleName varchar2
  , moduleOptionName varchar2
  , optionName varchar2
  , defaultStringValue varchar2 := null
)
is
begin
  pkg_OptionMain.addOptionWithValueOld(
    moduleName          => moduleName
    , moduleOptionName  => moduleOptionName
    , valueTypeCode     => pkg_OptionMain.String_ValueTypeCode
    , optionName        => optionName
    , stringValue       => defaultStringValue
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ����������� �����('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', optionName="' || optionName || '"'
        || ', defaultStringValue="' || defaultStringValue || '"'
        || ')'
      )
    , true
  );
end addOptionString;



/* group:	���������� ������������ ������� */

/* func: getMask
  ���������� �������.
*/
function getMask return sys_refcursor
is
  resultSet sys_refcursor;
begin
  open resultSet for
    select
      mask_id
    , mask_name
  from doc_mask;

  return resultSet;

end getMask;

/* func: findOption( DEPRECATED)
  ���������� �������.
*/
function findOption
(
    optionId        integer  := null
  , optionName	    varchar2 := null
  , optionShortName	varchar2 := null
  , batchShortName	varchar2 := null
  , isGlobal	      number   := null
  , maskId	        integer  := null
  , optionValue	    varchar2 := null
  , maxRowCount	    integer  := null
  , operatorId	    integer  := null
) return sys_refcursor
is
  -- ������� ������
  searchCondition varchar2 (4000);
  -- ������������ ������
  resultSet sys_refcursor;
  -- ������ � ��������
  dynamicSql dyn_dynamic_sql_t :=  dyn_dynamic_sql_t( '
    select *
    from
    (
      select
          option_id
        , option_name
        , option_short_name
        , is_global
        , mask_id
        , mask_name
        , case mask_id
            when 1 then replace (to_char (integer_value), '','', ''.'')
            when 2 then replace (to_char (integer_value), '','', ''.'')
            when 3 then string_value
            when 4 then to_char (datetime_value, ''dd.mm.yyyy hh24:mi:ss'')
          end as option_value'
|| case when batchShortName is not null then
'
        , opb.batch_short_name'
end
|| '
      from opt_option o
      inner join
      (
        select
            option_id
          , max (datetime_value) keep (dense_rank last order by date_ins) as datetime_value
          , max (integer_value) keep (dense_rank last order by date_ins) as integer_value
          , max (string_value) keep (dense_rank last order by date_ins) as string_value
        from opt_option_value
        group by option_id
      ) v using (option_id)
      inner join doc_mask m using (mask_id)'
|| case when batchShortName is not null then
'
      inner join
        (
        select
          op.option_id
          , max( b.batch_short_name) as batch_short_name
        from
          opt_option op
          , (
            select
              b.batch_short_name
              , replace(
                  replace( b.batch_short_name, ''%'',''\%'')
                  , ''_'',''\_''
                )
                || ''_%''
                as option_short_name_mask
            from
              sch_batch b
          ) b
        where
          op.option_short_name like b.option_short_name_mask escape ''\''
        group by
          op.option_id
        ) opb
        using ( option_id)'
end
|| '
    )
    where $(condition)
  ');
begin
  -- �������� ���� ���������
  checkRole( operatorId, readOnlyAccessFlag => 1);

  -- ������������ ���������� �������
  dynamicSql.addCondition ( 'option_id = ', optionId is null);
  dynamicSql.addCondition ( 'upper (option_name) like', false, 'option_name');
  dynamicSql.addCondition ( 'upper (option_short_name) like', false, 'option_short_name');
  dynamicSql.addCondition (
    'upper( batch_short_name) =', batchShortName is null, 'batch_short_name'
  );
  dynamicSql.addCondition ( 'is_global =', isGlobal is null);
  dynamicSql.addCondition ( 'mask_id =', maskId is null);
  dynamicSql.addCondition ( 'option_value =', optionValue is null);
  dynamicSql.addCondition ( 'rownum <=', maxRowCount is null, 'maxRowCount');
  dynamicSql.useCondition( 'condition');

  open
    resultSet
  for
    dynamicSql.getSqlText()
  using
      optionId
    , '%' || upper (optionName)      || '%'
    , '%' || upper (optionShortName) || '%'
    , upper (batchShortName)
    , isGlobal
    , maskId
    , optionValue
    , maxRowCount;

  return resultSet;

end findOption;

/* func: getStorageRule
  ���������� �������.
*/
function getStorageRule (maskId integer) return sys_refcursor
is
  resultSet sys_refcursor;
begin
  open resultSet for
    select
      mask_id
    , storage_rule_id
    , mask_oracle
  from doc_mask
  where mask_id = nvl (maskId, mask_id);

  return resultSet;

end getStorageRule;

end pkg_Option;
/
