create or replace package body pkg_OptionTest is
/* package body: pkg_OptionTest::body */



/* group: ��������� */

/* iconst: Exp_SvnRoot
  ���� � SVN � ����� ������������� ������, ��� ������������� � ������.
*/
Exp_SvnRoot constant varchar2(50) := 'Oracle/Module/Common';

/* iconst: Exp_ModuleName
  ��� ������ ��� ������������� � ������.
*/
Exp_ModuleName constant varchar2(50) :=
  substr( Exp_SvnRoot, instr( Exp_SvnRoot, '/', -1) + 1)
;

/* iconst: None_Date
  ����, ����������� � �������� �������� ��������� �� ���������, �����������
  ���������� ���������� ���� ��������� ��������.
*/
None_Date constant date := DATE '1901-01-01';

/* iconst: None_String
  ������, ����������� � �������� �������� ��������� �� ���������, �����������
  ���������� ���������� ���� ��������� ��������.
*/
None_String constant varchar2(10) := '$(none)';

/* iconst: None_Integer
  �����, ����������� � �������� �������� ��������� �� ���������, �����������
  ���������� ���������� ���� ��������� ��������.
*/
None_Integer constant integer := -9582095482058325832950482954832;



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_OptionMain.Module_Name
  , objectName  => 'pkg_OptionTest'
);

/* ivar: isProduction
  ���� ������ � ������������ ��
*/
isProduction integer := pkg_Common.isProduction();



/* group: ������� */

/* iproc: checkObjectType
  ��������� ������ ���� �������.

  ���������:
  objectTypeShortName             - �������� �������� ���� �������

    ������ ���� ������� ( �� ��������� �� ���������):
  objectTypeId                    - ...
  objectTypeName                  - ...
*/
procedure checkObjectType(
  objectTypeShortName varchar2
  , objectTypeId integer := None_Integer
  , objectTypeName varchar2 := None_String
)
is

  -- Id ������, � �������� ��������� ��� �������
  moduleId integer;

  cursor dataCur is
    select
      t.*
    from
      opt_object_type t
    where
      t.module_id = moduleId
      and t.object_type_short_name = objectTypeShortName
  ;

  rec dataCur%rowtype;

begin
  moduleId := pkg_ModuleInfo.getModuleId(
    svnRoot  => Exp_SvnRoot
  );
  open dataCur;
  fetch dataCur into rec;
  if dataCur%notfound or rec.deleted = 1 then
    pkg_TestUtility.failTest(
      '��� ������� �� ������'
      || case when rec.deleted = 1 then ' ( ��� ��������� ������)' end
    );
  else
    if nullif( None_Integer, objectTypeId) is not null then
      pkg_TestUtility.compareChar(
        actualString        => rec.object_type_id
        , expectedString    => objectTypeId
        , failMessageText   =>
            '�������� ���� object_type_id ���������� �� ����������'
      );
    end if;
    if nullif( None_String, objectTypeName) is not null then
      pkg_TestUtility.compareChar(
        actualString        => rec.object_type_name
        , expectedString    => objectTypeName
        , failMessageText   =>
            '�������� ���� object_type_name ���������� �� ����������'
      );
    end if;
  end if;
  close dataCur;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ���� ������� ('
        || ' objectTypeShortName="' || objectTypeShortName || '"'
        || ').'
      )
    , true
  );
end checkObjectType;

/* iproc: checkOptionValue
  ��������� ������ � �������� ������������ ���������.

  ���������:
  optionShortName             - �������� �������� ���������
  objectShortName             - �������� ��� �������
  objectTypeId                - Id ���� �������
  instanceName                - ��� ���������� �� ��� �������� ��������
                                ��������
                                ( �� ��������� ��������, �� ����������� � ��)
  usedOperatorId              - Id ���������, ��� �������� �����
                                �������������� ��������, ��� �������� ��������
                                ��������
                                ( �� ��������� ��������, �� ����������� �
                                  ���������)

    ������ ��������� ( �� ��������� �� ���������):

  optionId                    - ...
  valueTypeCode               - ...
  valueListFlag               - ...
  encryptionFlag              - ...
  testProdSensitiveFlag       - ...
  accessLevelCode             - ...
  optionName                  - ...
  optionDescription           - ...
  changeNumber                - ...
  changeOperatorId            - ...
  optionDeleted               - ...

    �������� �������� ��� ���� ��� ������������ �� ( �� ��������� �� ���������):

  valueId                     - ...
  listSeparator               - ...
  valueEncryptionFlag         - ...
  dateValue                   - ...
  numberValue                 - ...
  stringValue                 - ...
  valueChangeOperatorId       - ...
  valueDeleted                - ...

    �������� �������� ��� �������� �� ( �� ��������� �� ���������):

  testValueId                 - ...
  testListSeparator           - ...
  testEncryptionFlag          - ...
  testDateValue               - ...
  testNumberValue             - ...
  testStringValue             - ...
  testChangeOperatorId        - ...
  testDeleted                 - ...

    ������������ �������� ( �� ��������� �� ���������):

  usedValueId                 - ...
  usedListSeparator           - ...
  usedEncryptionFlag          - ...
  usedDateValue               - ...
  usedNumberValue             - ...
  usedStringValue             - ...
  usedChangeOperatorId        - ...

  ���������:
  - ��� �������� ���������� ��������� ����� ������� optionId ������ null;
  - ��� �������� ���������� �������� ��������� ����� ������� ���������������
    Id �������� ( valueId, testValueId, usedValueId) ������ null;
  - �� ������� ��������� ��������� ������ �� �����������, ��� ��������
    ����������� �������� ����� ������� � ��������������� ����������
    ( optionDeleted, valueDeleted, testDeleted) �������� 1;
*/
procedure checkOptionValue(
  optionShortName varchar2
  , objectShortName varchar2 := null
  , objectTypeId varchar2 := null
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , optionId integer := None_Integer
  , valueTypeCode varchar2 := None_String
  , valueListFlag integer := None_Integer
  , encryptionFlag integer := None_Integer
  , testProdSensitiveFlag integer := None_Integer
  , accessLevelCode varchar2 := None_String
  , optionName varchar2 := None_String
  , optionDescription varchar2 := None_String
  , changeNumber integer := None_Integer
  , changeOperatorId integer := None_Integer
  , optionDeleted integer := None_Integer
  , valueId integer := None_Integer
  , listSeparator varchar2 := None_String
  , valueEncryptionFlag integer := None_Integer
  , dateValue date := None_Date
  , numberValue number := None_Integer
  , stringValue varchar2 := None_String
  , valueChangeOperatorId integer := None_Integer
  , valueDeleted integer := None_Integer
  , testValueId integer := None_Integer
  , testListSeparator varchar2 := None_String
  , testEncryptionFlag integer := None_Integer
  , testDateValue date := None_Date
  , testNumberValue number := None_Integer
  , testStringValue varchar2 := None_String
  , testChangeOperatorId integer := None_Integer
  , testDeleted integer := None_Integer
  , usedValueId integer := None_Integer
  , usedListSeparator varchar2 := None_String
  , usedEncryptionFlag integer := None_Integer
  , usedDateValue date := None_Date
  , usedNumberValue number := None_Integer
  , usedStringValue varchar2 := None_String
  , usedChangeOperatorId integer := None_Integer
)
is

  -- ������ ���������
  opt opt_option%rowtype;

  -- �������������� ���������� ��� ��������� � ��������������� � ���������
  failInfo varchar2(200) :=
    ' ( optionShortName="' || optionShortName || '"'
    || case when objectShortName is not null then
        ', objectShortName="' || objectShortName || '"'
      end
    || case when objectTypeId is not null then
        ', objectTypeId=' || objectTypeId
      end
    || case when instanceName is not null then
        ', instanceName="' || instanceName || '"'
      end
    || case when usedOperatorId is not null then
        ', usedOperatorId=' || usedOperatorId
      end
    || ')'
  ;



  /*
    �������� ������ ������ ���������.
  */
  procedure getOptionData
  is

    -- Id ������, � �������� ��������� ��������
    moduleId integer;

    cursor optionCur is
      select
        t.*
      from
        opt_option t
      where
        t.module_id = moduleId
        and (
          objectShortName is null
            and t.object_short_name is null
            and t.object_type_id is null
          or objectShortName is not null
            and t.object_short_name = objectShortName
            and t.object_type_id = objectTypeId
        )
        and t.option_short_name = optionShortName
        and (
          nullif( None_Integer, optionDeleted) is not null
          or t.deleted = 0
        )
    ;

  begin
    moduleId := pkg_ModuleInfo.getModuleId(
      svnRoot  => Exp_SvnRoot
    );
    open optionCur;
    fetch optionCur into opt;
    if optionCur%notfound and optionId is not null then
      pkg_TestUtility.failTest(
        '�������� �� ������' || failInfo
      );
    elsif optionCur%found and optionId is null then
      pkg_TestUtility.failTest(
        '�������� ������' || failInfo
      );
    end if;
    close optionCur;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ������ ���������.'
        )
      , true
    );
  end getOptionData;



  /*
    ��������� ������ ���������.
  */
  procedure checkOptionData
  is
  begin
    if nullif( optionId, None_Integer) is not null then
      pkg_TestUtility.compareChar(
        actualString        => opt.option_id
        , expectedString    => optionId
        , failMessageText   =>
            '�������� ���� option_id ���������� �� ����������'
            || failInfo
      );
    end if;
    if nullif( None_Integer, optionDeleted) is not null then
      pkg_TestUtility.compareChar(
        actualString        => opt.deleted
        , expectedString    => optionDeleted
        , failMessageText   =>
            '�������� ���� deleted ( opt_option) ���������� �� ����������'
            || failInfo
      );
    end if;
    if nullif( None_String, valueTypeCode) is not null then
      pkg_TestUtility.compareChar(
        actualString        => opt.value_type_code
        , expectedString    => valueTypeCode
        , failMessageText   =>
            '�������� ���� value_type_code ���������� �� ����������'
            || failInfo
      );
    end if;
    if nullif( None_Integer, valueListFlag) is not null then
      pkg_TestUtility.compareChar(
        actualString        => opt.value_list_flag
        , expectedString    => valueListFlag
        , failMessageText   =>
            '�������� ���� value_list_flag ���������� �� ����������'
            || failInfo
      );
    end if;
    if nullif( None_Integer, encryptionFlag) is not null then
      pkg_TestUtility.compareChar(
        actualString        => opt.encryption_flag
        , expectedString    => encryptionFlag
        , failMessageText   =>
            '�������� ���� encryption_flag ( opt_option) ����������'
            || ' �� ����������'
            || failInfo
      );
    end if;
    if nullif( None_Integer, testProdSensitiveFlag) is not null then
      pkg_TestUtility.compareChar(
        actualString        => opt.test_prod_sensitive_flag
        , expectedString    => testProdSensitiveFlag
        , failMessageText   =>
            '�������� ���� test_prod_sensitive_flag ���������� �� ����������'
            || failInfo
      );
    end if;
    if nullif( None_String, accessLevelCode) is not null then
      pkg_TestUtility.compareChar(
        actualString        => opt.access_level_code
        , expectedString    => accessLevelCode
        , failMessageText   =>
            '�������� ���� access_level_code ���������� �� ����������'
            || failInfo
      );
    end if;
    if nullif( None_String, optionName) is not null then
      pkg_TestUtility.compareChar(
        actualString        => opt.option_name
        , expectedString    => optionName
        , failMessageText   =>
            '�������� ���� option_name ���������� �� ����������'
            || failInfo
      );
    end if;
    if nullif( None_String, optionDescription) is not null then
      pkg_TestUtility.compareChar(
        actualString        => opt.option_description
        , expectedString    => optionDescription
        , failMessageText   =>
            '�������� ���� option_description ���������� �� ����������'
            || failInfo
      );
    end if;
    if nullif( None_Integer, changeNumber) is not null then
      pkg_TestUtility.compareChar(
        actualString        => opt.change_number
        , expectedString    => changeNumber
        , failMessageText   =>
            '�������� ���� change_number ( opt_option) ����������'
            || ' �� ����������'
            || failInfo
      );
    end if;
    if nullif( None_Integer, changeOperatorId) is not null then
      pkg_TestUtility.compareChar(
        actualString        => opt.change_operator_id
        , expectedString    => changeOperatorId
        , failMessageText   =>
            '�������� ���� change_operator_id ( opt_option) ����������'
            || ' �� ����������'
            || failInfo
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� ������ ���������.'
        )
      , true
    );
  end checkOptionData;



  /*
    ��������� �������� �������� ���������.
  */
  procedure checkValue
  is

    cursor valueCur is
      select
        0 as used_value_flag
        , t.value_id
        , t.option_id
        , t.prod_value_flag
        , t.instance_name
        , t.used_operator_id
        , t.value_type_code
        , t.list_separator
        , t.encryption_flag
        , t.date_value
        , t.number_value
        , t.string_value
        , t.deleted
        , t.change_operator_id
      from
        opt_value t
      where
        t.option_id = opt.option_id
        and (
          instanceName is null
            and t.instance_name is null
          or instanceName is not null
            and t.instance_name = upper( instanceName)
        )
        and (
          usedOperatorId is null
            and t.used_operator_id is null
          or usedOperatorId is not null
            and t.used_operator_id = usedOperatorId
        )
        and (
          nullif( t.prod_value_flag, 1) is null
            and nullif( None_Integer, valueDeleted) is not null
          or t.prod_value_flag = 0
            and nullif( None_Integer, testDeleted) is not null
          or t.deleted = 0
        )
      union all
      select
        1 as used_value_flag
        , t.value_id
        , t.option_id
        , t.prod_value_flag
        , t.instance_name
        , t.used_operator_id
        , t.value_type_code
        , t.list_separator
        , t.encryption_flag
        , t.date_value
        , t.number_value
        , t.string_value
        , 0 as deleted
        , t.value_change_operator_id as change_operator_id
      from
        v_opt_option_value t
      where
        t.option_id = opt.option_id
        -- ������ ���� ������ ��������
        and t.value_id is not null
      order by
        used_value_flag
        , prod_value_flag
    ;

    -- ���. ���������� ��� ��������� � �������������� � ��������
    valueFailInfo varchar2(200);

    -- ������� ������� ��������������� �������
    isValueFound boolean := false;
    isTestValueFound boolean := false;
    isUsedValueFound boolean := false;

    -- ��������� ��� ������� ������ �������� ��������� �����
    er opt_value%rowtype;

    -- ������� �������� �������� ���� list_separator
    isCheckListSeparator boolean;

    -- ������� �������� �������� ���� encryption_flag
    isCheckEncryptionFlag boolean;

    -- ������� �������� �������� ���� deleted
    isCheckDeleted boolean;

  -- checkValue
  begin
    for rec in valueCur loop
      if rec.used_value_flag = 1 then
        isUsedValueFound          := true;
        er.value_id               := usedValueId;
        er.list_separator         := nullif( usedListSeparator, None_String);
        er.encryption_flag        := nullif( usedEncryptionFlag, None_Integer);
        er.date_value             := usedDateValue;
        er.number_value           := usedNumberValue;
        er.string_value           := usedStringValue;
        er.deleted                := null;
        er.change_operator_id     := usedChangeOperatorId;
        isCheckListSeparator      :=
          nullif( None_String, usedListSeparator) is not null
        ;
        isCheckEncryptionFlag     :=
          nullif( None_Integer, usedEncryptionFlag) is not null
        ;
        isCheckDeleted            := false;
      elsif rec.prod_value_flag = 0 then
        isTestValueFound          := true;
        er.value_id               := testValueId;
        er.list_separator         := nullif( testListSeparator, None_String);
        er.encryption_flag        := nullif( testEncryptionFlag, None_Integer);
        er.date_value             := testDateValue;
        er.number_value           := testNumberValue;
        er.string_value           := testStringValue;
        er.deleted                := nullif( testDeleted, None_Integer);
        er.change_operator_id     := testChangeOperatorId;
        isCheckListSeparator      :=
          nullif( None_String, testListSeparator) is not null
        ;
        isCheckEncryptionFlag     :=
          nullif( None_Integer, testEncryptionFlag) is not null
        ;
        isCheckDeleted     :=
          nullif( None_Integer, testDeleted) is not null
        ;
      else
        isValueFound              := true;
        er.value_id               := valueId;
        er.list_separator         := nullif( listSeparator, None_String);
        er.encryption_flag        := nullif( valueEncryptionFlag, None_Integer);
        er.date_value             := dateValue;
        er.number_value           := numberValue;
        er.string_value           := stringValue;
        er.deleted                := nullif( valueDeleted, None_Integer);
        er.change_operator_id     := valueChangeOperatorId;
        isCheckListSeparator      :=
          nullif( None_String, listSeparator) is not null
        ;
        isCheckEncryptionFlag     :=
          nullif( None_Integer, valueEncryptionFlag) is not null
        ;
        isCheckDeleted     :=
          nullif( None_Integer, valueDeleted) is not null
        ;
      end if;
      valueFailInfo :=
        substr( failInfo, 1, length( failInfo) - 1)
        || case when rec.used_value_flag = 1 then
            ', used_value_flag=1'
          end
        || ', instance_name="' || rec.instance_name || '"'
        || ', prod_value_flag=' || rec.prod_value_flag
        || ')'
      ;
      if opt.deleted = 0 and rec.deleted = 0 then
        pkg_TestUtility.compareChar(
          actualString        => rec.prod_value_flag
          , expectedString    =>
              case when
                opt.test_prod_sensitive_flag = 0
                  and rec.prod_value_flag is null
                or opt.test_prod_sensitive_flag = 1
                  and rec.prod_value_flag in ( 0, 1)
              then
                -- ����������� ������ ��������, �.�. ���������� ����������
                to_char( rec.prod_value_flag)
              else
                -- �������� �������� ��������, �.�. ���������� ������������
                '[test_prod_sensitive_flag='
                || opt.test_prod_sensitive_flag
                || ']'
              end
          , failMessageText   =>
              '���� ���� �� ��� �������� �� ������������� ������ ���������'
              || valueFailInfo
        );
        pkg_TestUtility.compareChar(
          actualString        => rec.value_type_code
          , expectedString    => opt.value_type_code
          , failMessageText   =>
              '��� ���� �������� ���������� �� ���������� � ���������'
              || valueFailInfo
        );
      end if;
      if nullif( None_Integer, er.value_id) is not null then
        pkg_TestUtility.compareChar(
          actualString        => rec.value_id
          , expectedString    => er.value_id
          , failMessageText   =>
              'Id �������� ���������� �� ����������'
              || valueFailInfo
        );
      end if;
      if isCheckDeleted then
        pkg_TestUtility.compareChar(
          actualString        => rec.deleted
          , expectedString    => er.deleted
          , failMessageText   =>
              '�������� ���� deleted ���������� �� ����������'
              || failInfo
        );
      end if;
      if isCheckListSeparator then
        pkg_TestUtility.compareChar(
          actualString        => rec.list_separator
          , expectedString    => er.list_separator
          , failMessageText   =>
              '�������� ���� list_separator ���������� �� ����������'
              || valueFailInfo
        );
      end if;
      if isCheckEncryptionFlag then
        pkg_TestUtility.compareChar(
          actualString        => rec.encryption_flag
          , expectedString    => er.encryption_flag
          , failMessageText   =>
              '�������� ���� encryption_flag ���������� �� ����������'
              || valueFailInfo
        );
      end if;
      if nullif( None_Date, er.date_value) is not null then
        pkg_TestUtility.compareChar(
          actualString        =>
              to_char( rec.date_value, 'dd.mm.yyyy hh24:mi:ss')
          , expectedString    =>
              to_char( er.date_value, 'dd.mm.yyyy hh24:mi:ss')
          , failMessageText   =>
              '�������� � ���� date_value ���������� �� ����������'
              || valueFailInfo
        );
      end if;
      if nullif( None_Integer, er.number_value) is not null then
        pkg_TestUtility.compareChar(
          actualString        => rec.number_value
          , expectedString    => er.number_value
          , failMessageText   =>
              '�������� � ���� number_value ���������� �� ����������'
              || valueFailInfo
        );
      end if;
      if nullif( None_String, er.string_value) is not null then
        pkg_TestUtility.compareChar(
          actualString        => rec.string_value
          , expectedString    => er.string_value
          , failMessageText   =>
              '�������� � ���� string_value ���������� �� ����������'
              || valueFailInfo
        );
      end if;
      if nullif( None_Integer, er.change_operator_id) is not null then
        pkg_TestUtility.compareChar(
          actualString        => rec.change_operator_id
          , expectedString    => er.change_operator_id
          , failMessageText   =>
              '�������� � ���� change_operator_id ���������� �� ����������'
              || valueFailInfo
        );
      end if;
    end loop;
    if not isValueFound
          and (
            nullif( valueId, None_Integer) is not null
            or nullif( None_Date, dateValue) is not null
            or nullif( None_Integer, numberValue) is not null
            or nullif( None_String, stringValue) is not null
          )
        then
      pkg_TestUtility.failTest(
        '��� ��������� �� ������'
        || case when opt.test_prod_sensitive_flag = 1 then
            ' ������������'
          end
        || ' ��������'
        || failInfo
      );
    elsif isValueFound and valueId is null then
      pkg_TestUtility.failTest(
        '��� ��������� ������'
        || case when opt.test_prod_sensitive_flag = 1 then
            ' ������������'
          end
        || ' ��������'
        || failInfo
      );
    end if;
    if not isTestValueFound
          and (
            nullif( testValueId, None_Integer) is not null
            or nullif( None_Date, testDateValue) is not null
            or nullif( None_Integer, testNumberValue) is not null
            or nullif( None_String, testStringValue) is not null
          )
        then
      pkg_TestUtility.failTest(
        '��� ��������� �� ������ �������� ��������'
        || failInfo
      );
    elsif isTestValueFound and testValueId is null then
      pkg_TestUtility.failTest(
        '��� ��������� ������ �������� ��������'
        || failInfo
      );
    end if;
    if not isUsedValueFound
          and (
            nullif( usedValueId, None_Integer) is not null
            or nullif( None_Date, usedDateValue) is not null
            or nullif( None_Integer, usedNumberValue) is not null
            or nullif( None_String, usedStringValue) is not null
          )
        then
      pkg_TestUtility.failTest(
        '������������ �������� ��������� �� �������'
        || failInfo
      );
    elsif isUsedValueFound and usedValueId is null then
      pkg_TestUtility.failTest(
        '������� ������������ �������� ���������'
        || failInfo
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� �������� ��������.'
        )
      , true
    );
  end checkValue;



-- checkOptionValue
begin
  getOptionData();
  checkOptionData();
  checkValue();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ������ � �������� �������� ��������� ('
        || ' optionShortName="' || optionShortName || '"'
        || ').'
      )
    , true
  );
end checkOptionValue;

/* proc: testOptionList
  ���� ������ � ����������� � ������� ���� <opt_option_list_t>.

  ���������:
  saveDataFlag                - �������� �������� ������ � �������� ���
                                �������� ���������� �����
                                ( 1 ��, 0 ��� ( �� ���������))
*/
procedure testOptionList(
  saveDataFlag integer := null
)
is



  /*
    ������������ ������� ��� ��������� ���� ���� � ��������������� �������.
  */
  procedure testDateOption
  is

    -- ����� ������
    opt opt_option_list_t := opt_option_list_t(
      moduleName => Exp_ModuleName
    );

    -- ������� ������������ ��������
    usedValue opt_value.date_value%type;

    -- ���� �������� ���������
    changeFlag integer;

  -- testDateOption
  begin
    pkg_TestUtility.beginTest( 'testOptionList: date option');

    pkg_TestUtility.compareChar(
      actualString        => opt.getModuleId()
      , expectedString    =>
          pkg_ModuleInfo.getModuleId(
            moduleName            => Exp_ModuleName
            , raiseExceptionFlag  => 1
          )
      , failMessageText   => '������������ �������� getModuleId'
    );

    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getOptionId(
            optionShortName     => 'DueDate'
            , raiseNotFoundFlag => 0
          )
      , expectedString    => null
      , failMessageText   => '��������� Id ��������������� ��������� DueDate'
    );

    -- ��������� �������� ��� ���������� ���������
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getDate(
            'DueDate_000'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getDate: ������������ ��������� ��� ���������� ���������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getDate(
            'DueDate_001'
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getDate( USED): ������������ ��������� ��� ���������� ���������'
    );

    -- �������� � ������������ � �������� ���������
    opt.addDate(
      optionShortName         => 'DueDate'
      , optionName            => '��������� ����'
      , optionDescription     =>
          '��������� ���� � �������� � ������������ ���������'
      , prodDateValue         =>
          to_date( '05.07.2012 13:01:09', 'dd.mm.yyyy hh24:mi:ss')
      , testDateValue         =>
          to_date( '03.04.2012 12:00:09', 'dd.mm.yyyy hh24:mi:ss')
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Date_ValueTypeCode
      , optionShortName       => 'DueDate'
      , optionName            => '��������� ����'
      , optionDescription     =>
          '��������� ���� � �������� � ������������ ���������'
      , testProdSensitiveFlag => 1
      , accessLevelCode       => 'FULL'
      , dateValue             =>
          to_date( '05.07.2012 13:01:09', 'dd.mm.yyyy hh24:mi:ss')
      , testDateValue         =>
          to_date( '03.04.2012 12:00:09', 'dd.mm.yyyy hh24:mi:ss')
      -- ��������� ������������ ��������������� �������
      , optionId              =>
          opt.getOptionId(
            optionShortName     => 'DueDate'
            , raiseNotFoundFlag => 0
          )
      , valueId               =>
          opt.getValueId(
            optionShortName     => 'DueDate'
            , prodValueFlag     => 1
            , raiseNotFoundFlag => 0
          )
      , testValueId           =>
          opt.getValueId(
            optionShortName     => 'DueDate'
            , prodValueFlag     => 0
            , raiseNotFoundFlag => 0
          )
      , usedValueId           =>
          opt.getValueId(
            optionShortName     => 'DueDate'
            , raiseNotFoundFlag => 0
          )
    );

    -- ���������� � ���������� ��������, ���� �������� ����������
    opt.addDate(
      optionShortName         => 'DueDate'
      , optionName            => '��������� ���� (1)'
      , optionDescription     =>
          '��������� ���� � �������� � ������������ ��������� (1)'
      , prodDateValue         =>
          to_date( '05.07.2012 13:01:03', 'dd.mm.yyyy hh24:mi:ss')
      , testDateValue         =>
          to_date( '03.04.2012 12:00:00', 'dd.mm.yyyy hh24:mi:ss')
      , changeValueFlag       => 1
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Date_ValueTypeCode
      , optionShortName       => 'DueDate'
      , optionName            => '��������� ����'
      , optionDescription     =>
          '��������� ���� � �������� � ������������ ���������'
      , dateValue             =>
          to_date( '05.07.2012 13:01:03', 'dd.mm.yyyy hh24:mi:ss')
      , testDateValue         =>
          to_date( '03.04.2012 12:00:00', 'dd.mm.yyyy hh24:mi:ss')
    );

    -- �������� �� ������ ����������, �.�. ��� ����������
    opt.addDate(
      optionShortName         => 'DueDate'
      , optionName            => '��������� ���� (2)'
      , optionDescription     =>
          '��������� ���� � �������� � ������������ ��������� (2)'
      , prodDateValue         =>
          to_date( '05.07.2000 13:01:03', 'dd.mm.yyyy hh24:mi:ss')
      , testDateValue         =>
          to_date( '03.04.2000 12:00:00', 'dd.mm.yyyy hh24:mi:ss')
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Date_ValueTypeCode
      , optionShortName       => 'DueDate'
      , optionName            => '��������� ����'
      , optionDescription     =>
          '��������� ���� � �������� � ������������ ���������'
      , dateValue             =>
          to_date( '05.07.2012 13:01:03', 'dd.mm.yyyy hh24:mi:ss')
      , testDateValue         =>
          to_date( '03.04.2012 12:00:00', 'dd.mm.yyyy hh24:mi:ss')
    );

    -- ��������� getDate
   pkg_TestUtility.compareChar(
      actualString        =>
          to_char(
            opt.getDate(
              optionShortName     => 'DueDate'
              , prodValueFlag     => 1
              , raiseNotFoundFlag => 0
            )
            , 'dd.mm.yyyy hh24:mi:ss'
          )
      , expectedString    => '05.07.2012 13:01:03'
      , failMessageText   => '����������� �������� getDate( prod)'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          to_char(
            opt.getDate(
              optionShortName     => 'DueDate'
              , prodValueFlag     => 0
              , raiseNotFoundFlag => 0
            )
            , 'dd.mm.yyyy hh24:mi:ss'
          )
      , expectedString    => '03.04.2012 12:00:00'
      , failMessageText   => '����������� �������� getDate( test)'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          to_char(
            opt.getDate(
              optionShortName     => 'DueDate'
              , raiseNotFoundFlag => 0
            )
            , 'dd.mm.yyyy hh24:mi:ss'
          )
      , expectedString    =>
          case isProduction
            when 1 then '05.07.2012 13:01:03'
            when 0 then '03.04.2012 12:00:00'
          end
      , failMessageText   => '����������� �������� getDate( used)'
    );

    -- ��������� setDate
    opt.setDate(
      optionShortName     => 'DueDate'
      , prodValueFlag     => 1
      , dateValue         =>
          to_date( '10.07.2012 01:00:00', 'dd.mm.yyyy hh24:mi:ss')
    );
    checkOptionValue(
      optionShortName         => 'DueDate'
      , dateValue             =>
          to_date( '10.07.2012 01:00:00', 'dd.mm.yyyy hh24:mi:ss')
      , testDateValue         =>
          to_date( '03.04.2012 12:00:00', 'dd.mm.yyyy hh24:mi:ss')
    );
    opt.setDate(
      optionShortName     => 'DueDate'
      , prodValueFlag     => 0
      , dateValue         =>
          to_date( '11.04.2012 03:00:00', 'dd.mm.yyyy hh24:mi:ss')
    );
    checkOptionValue(
      optionShortName         => 'DueDate'
      , dateValue             =>
          to_date( '10.07.2012 01:00:00', 'dd.mm.yyyy hh24:mi:ss')
      , testDateValue         =>
          to_date( '11.04.2012 03:00:00', 'dd.mm.yyyy hh24:mi:ss')
    );

    -- ��������� setDate � instanceName
    usedValue := opt.getDate( 'DueDate');
    opt.setDate(
      optionShortName     => 'DueDate'
      , prodValueFlag     => 0
      , instanceName      => 'none'
      , dateValue         =>
          to_date( '12.04.2012 03:00:00', 'dd.mm.yyyy hh24:mi:ss')
    );
    checkOptionValue(
      optionShortName         => 'DueDate'
      , dateValue             =>
          to_date( '10.07.2012 01:00:00', 'dd.mm.yyyy hh24:mi:ss')
      , testDateValue         =>
          to_date( '11.04.2012 03:00:00', 'dd.mm.yyyy hh24:mi:ss')
      , usedDateValue         => usedValue
    );
    checkOptionValue(
      optionShortName         => 'DueDate'
      , instanceName          => 'none'
      , testDateValue         =>
          to_date( '12.04.2012 03:00:00', 'dd.mm.yyyy hh24:mi:ss')
    );

    opt.setDate(
      optionShortName     => 'DueDate'
      , prodValueFlag     => isProduction
      , instanceName      => pkg_Common.getInstanceName()
      , dateValue         =>
          to_date( '13.04.2012 04:00:00', 'dd.mm.yyyy hh24:mi:ss')
    );
    checkOptionValue(
      optionShortName         => 'DueDate'
      , usedDateValue         =>
          to_date( '13.04.2012 04:00:00', 'dd.mm.yyyy hh24:mi:ss')
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          to_char(
            opt.getDate( 'DueDate', raiseNotFoundFlag => 0)
            , 'dd.mm.yyyy hh24:mi:ss'
          )
      , expectedString    => '13.04.2012 04:00:00'
      , failMessageText   =>
          '�� ������� ������ ���� ��� ������������� ���� � ��������� ��'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          to_char(
            opt.getDate(
              'DueDate'
              , prodValueFlag     => isProduction
              , instanceName      => pkg_Common.getInstanceName()
              , raiseNotFoundFlag => 0
            )
            , 'dd.mm.yyyy hh24:mi:ss'
          )
      , expectedString    => '13.04.2012 04:00:00'
      , failMessageText   =>
          '����������� ��������� �������� � getDate ����� ��������� ��������'
    );
    opt.deleteValue( 'DueDate');
    checkOptionValue(
      optionShortName         => 'DueDate'
      , usedDateValue         => usedValue
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          to_char(
            opt.getDate( 'DueDate', raiseNotFoundFlag => 0)
            , 'dd.mm.yyyy hh24:mi:ss'
          )
      , expectedString    => to_char( usedValue, 'dd.mm.yyyy hh24:mi:ss')
      , failMessageText   =>
          '����������� ������������ �������� � getDate ����� �������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          to_char(
            opt.getDate(
              'DueDate'
              , prodValueFlag     => isProduction
              , instanceName      => pkg_Common.getInstanceName()
              , raiseNotFoundFlag => 0
            )
            , 'dd.mm.yyyy hh24:mi:ss'
          )
      , expectedString    => ''
      , failMessageText   =>
          '����������� ��������� �������� � getDate ����� �������� ��������'
    );

    -- ��������� setDate( USED)
    opt.setDate(
      optionShortName     => 'DueDate'
      , dateValue         =>
          to_date( '15.08.2012 00:00:00', 'dd.mm.yyyy hh24:mi:ss')
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          to_char(
            opt.getDate( 'DueDate', raiseNotFoundFlag => 0)
            , 'dd.mm.yyyy hh24:mi:ss'
          )
      , expectedString    => '15.08.2012 00:00:00'
      , failMessageText   =>
          '�� ������� ������ ������������ ���� � ������� setDate( USED)'
    );

    -- ��������� setDate( TEST_PROD)
    opt.setDate(
      optionShortName     => 'DueDate'
      , prodDateValue         =>
          to_date( '20.10.2014 00:00:00', 'dd.mm.yyyy hh24:mi:ss')
      , testDateValue         =>
          to_date( '25.11.2013 00:00:01', 'dd.mm.yyyy hh24:mi:ss')
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          to_char(
            opt.getDate( 'DueDate', prodValueFlag => 1, raiseNotFoundFlag => 0)
            , 'dd.mm.yyyy hh24:mi:ss'
          )
      , expectedString    => '20.10.2014 00:00:00'
      , failMessageText   =>
          '�� ������� ������ ������������ ���� � ������� setDate( TEST_PROD)'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          to_char(
            opt.getDate( 'DueDate', prodValueFlag => 0, raiseNotFoundFlag => 0)
            , 'dd.mm.yyyy hh24:mi:ss'
          )
      , expectedString    => '25.11.2013 00:00:01'
      , failMessageText   =>
          '�� ������� ������ �������� ���� � ������� setDate( TEST_PROD)'
    );

    -- ��������� setValue
    changeFlag := opt.setValue(
      optionShortName       => 'DueDate'
      , prodValueFlag       => 0
      , dateValue           =>
          to_date( '25.11.2013 00:00:01', 'dd.mm.yyyy hh24:mi:ss')
      , skipIfNoChangeFlag  => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 0
      , failMessageText   =>
          'setValue( DATE): ������������ �������� ��� ���������� ���������'
    );
    changeFlag := opt.setValue(
      optionShortName       => 'DueDate'
      , prodValueFlag       => 0
      , dateValue           =>
          to_date( '25.11.2013 00:00:02', 'dd.mm.yyyy hh24:mi:ss')
      , skipIfNoChangeFlag  => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'setValue( DATE): ������������ �������� ��� ������� ���������'
    );
    checkOptionValue(
      optionShortName         => 'DueDate'
      , testDateValue         =>
          to_date( '25.11.2013 00:00:02', 'dd.mm.yyyy hh24:mi:ss')
    );
    changeFlag := opt.setValue(
      optionShortName       => 'DueDate'
      , prodValueFlag       => 0
      , dateValue           =>
          to_date( '25.11.2013 00:00:02', 'dd.mm.yyyy hh24:mi:ss')
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'setValue( DATE): ������������ �������� ��� ���������'
    );
    checkOptionValue(
      optionShortName         => 'DueDate'
      , testDateValue         =>
          to_date( '25.11.2013 00:00:02', 'dd.mm.yyyy hh24:mi:ss')
    );
    opt.setValue(
      optionShortName       => 'DueDate'
      , prodValueFlag       => 0
      , dateValue           =>
          to_date( '25.11.2013 00:00:02', 'dd.mm.yyyy hh24:mi:ss')
      , skipIfNoChangeFlag  => 1
    );

    -- ��������� �������� ��� ���������� �������� ���������
    opt.deleteValue( 'DueDate');
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getDate(
            'DueDate'
            , prodValueFlag       => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getDate:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getDate(
            'DueDate'
          )
      , expectedString    => null
      , failMessageText   =>
          'getDate( USED):'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getDate(
            'DueDate'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getDate: raise=0:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getDate(
            'DueDate'
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getDate( USED): raise=0:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getDate(
            'DueDate'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getDate: raise=1:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getDate(
            'DueDate'
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getDate( USED): raise=1:'
          || ' ������������ ��������� ��� ���������� ��������'
    );

    -- �������� ��� ��������� �������� ( �� ��������� null)
    opt.addDate(
      optionShortName         => 'ForceLoadDate'
      , optionName            =>
          '���� �������������� ��������'
      , optionDescription     =>
          '���� �������������� �������� ( ��� ��������� ��������)'
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Date_ValueTypeCode
      , optionShortName       => 'ForceLoadDate'
      , optionName            =>
          '���� �������������� ��������'
      , optionDescription     =>
          '���� �������������� �������� ( ��� ��������� ��������)'
      , testProdSensitiveFlag => 0
      , dateValue             => null
      -- ��������� ������������ ��������������� �������
      , optionId              =>
          opt.getOptionId(
            optionShortName     => 'ForceLoadDate'
            , raiseNotFoundFlag => 0
          )
      , valueId               =>
          opt.getValueId(
            optionShortName     => 'ForceLoadDate'
            , prodValueFlag     => null
            , raiseNotFoundFlag => 0
          )
      , usedValueId           =>
          opt.getValueId(
            optionShortName     => 'ForceLoadDate'
            , raiseNotFoundFlag => 0
          )
    );

    -- ��������� updateDateValue
    opt_option_list_t.updateDateValue(
      valueId                 =>
          opt.getValueId(
            optionShortName     => 'ForceLoadDate'
            , prodValueFlag     => null
            , raiseNotFoundFlag => 0
          )
      , dateValue             =>
          to_date( '29.10.2014 00:00:05', 'dd.mm.yyyy hh24:mi:ss')
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Date_ValueTypeCode
      , optionShortName       => 'ForceLoadDate'
      , dateValue             =>
          to_date( '29.10.2014 00:00:05', 'dd.mm.yyyy hh24:mi:ss')
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ��������� ���� ����.'
        )
      , true
    );
  end testDateOption;



  /*
    ������������ ������� ��� ��������� ��������� ���� � ��������������� �������.
  */
  procedure testNumberOption
  is

    -- ����� ������
    opt opt_option_list_t := opt_option_list_t(
      moduleName => Exp_ModuleName
    );

    -- ������� ������������ ��������
    usedValue opt_value.number_value%type;

    -- ���� �������� ���������
    changeFlag integer;

  -- testNumberOption
  begin
    pkg_TestUtility.beginTest( 'testOptionList: number option');

    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getOptionId(
            optionShortName     => 'TimeoutSecond'
            , raiseNotFoundFlag => 0
          )
      , expectedString    => null
      , failMessageText   =>
          '��������� Id ��������������� ��������� TimeoutSecond'
    );

    -- ��������� �������� ��� ���������� ���������
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutSecond_000'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getNumber: ������������ ��������� ��� ���������� ���������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutSecond_001'
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getNumber( USED): ������������ ��������� ��� ���������� ���������'
    );

    -- �������� � ������������ � �������� ���������
    opt.addNumber(
      optionShortName         => 'TimeoutSecond'
      , optionName            => '�������� ��������'
      , optionDescription     =>
          '�������� �������� � �������� � ������������ ���������'
      , prodNumberValue       => 3.59
      , testNumberValue       => 7.19
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Number_ValueTypeCode
      , optionShortName       => 'TimeoutSecond'
      , optionName            => '�������� ��������'
      , optionDescription     =>
          '�������� �������� � �������� � ������������ ���������'
      , testProdSensitiveFlag => 1
      , accessLevelCode       => 'FULL'
      , numberValue           => 3.59
      , testNumberValue       => 7.19
      -- ��������� ������������ ��������������� �������
      , optionId              =>
          opt.getOptionId(
            optionShortName     => 'TimeoutSecond'
            , raiseNotFoundFlag => 0
          )
      , valueId               =>
          opt.getValueId(
            optionShortName     => 'TimeoutSecond'
            , prodValueFlag     => 1
            , raiseNotFoundFlag => 0
          )
      , testValueId           =>
          opt.getValueId(
            optionShortName     => 'TimeoutSecond'
            , prodValueFlag     => 0
            , raiseNotFoundFlag => 0
          )
      , usedValueId           =>
          opt.getValueId(
            optionShortName     => 'TimeoutSecond'
            , raiseNotFoundFlag => 0
          )
    );

    -- ���������� � ���������� ��������, ���� �������� ����������
    opt.addNumber(
      optionShortName         => 'TimeoutSecond'
      , optionName            => '�������� �������� (1)'
      , optionDescription     =>
          '�������� �������� � �������� � ������������ ��������� (1)'
      , prodNumberValue       => 3.5
      , testNumberValue       => 7.1
      , changeValueFlag       => 1
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Number_ValueTypeCode
      , optionShortName       => 'TimeoutSecond'
      , optionName            => '�������� ��������'
      , optionDescription     =>
          '�������� �������� � �������� � ������������ ���������'
      , numberValue             => 3.5
      , testNumberValue         => 7.1
    );

    -- �������� �� ������ ����������, �.�. ��� ����������
    opt.addNumber(
      optionShortName         => 'TimeoutSecond'
      , optionName            => '�������� �������� (2)'
      , optionDescription     =>
          '�������� �������� � �������� � ������������ ��������� (2)'
      , prodNumberValue       => 3.9
      , testNumberValue       => 7.9
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Number_ValueTypeCode
      , optionShortName       => 'TimeoutSecond'
      , optionName            => '�������� ��������'
      , optionDescription     =>
          '�������� �������� � �������� � ������������ ���������'
      , numberValue             => 3.5
      , testNumberValue         => 7.1
    );

    -- ��������� getNumber
   pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            optionShortName     => 'TimeoutSecond'
            , prodValueFlag     => 1
            , raiseNotFoundFlag => 0
          )
      , expectedString    => 3.5
      , failMessageText   => '����������� �������� getNumber( prod)'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            optionShortName     => 'TimeoutSecond'
            , prodValueFlag     => 0
            , raiseNotFoundFlag => 0
          )
      , expectedString    => 7.1
      , failMessageText   => '����������� �������� getNumber( test)'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            optionShortName     => 'TimeoutSecond'
            , raiseNotFoundFlag => 0
          )
      , expectedString    =>
          case isProduction
            when 1 then 3.5
            when 0 then 7.1
          end
      , failMessageText   => '����������� �������� getNumber( used)'
    );

    -- ��������� setNumber
    opt.setNumber(
      optionShortName     => 'TimeoutSecond'
      , prodValueFlag     => 1
      , numberValue       => 3.8
    );
    checkOptionValue(
      optionShortName     => 'TimeoutSecond'
      , numberValue       => 3.8
      , testNumberValue   => 7.1
    );
    opt.setNumber(
      optionShortName     => 'TimeoutSecond'
      , prodValueFlag     => 0
      , numberValue       => 7.8
    );
    checkOptionValue(
      optionShortName     => 'TimeoutSecond'
      , numberValue       => 3.8
      , testNumberValue   => 7.8
    );

    -- ��������� setNumber � instanceName
    usedValue := opt.getNumber( 'TimeoutSecond');
    opt.setNumber(
      optionShortName     => 'TimeoutSecond'
      , prodValueFlag     => 0
      , instanceName      => 'none'
      , numberValue       => 8.5
    );
    checkOptionValue(
      optionShortName     => 'TimeoutSecond'
      , numberValue       => 3.8
      , testNumberValue   => 7.8
      , usedNumberValue   => usedValue
    );
    checkOptionValue(
      optionShortName     => 'TimeoutSecond'
      , instanceName      => 'none'
      , testNumberValue   => 8.5
    );

    opt.setNumber(
      optionShortName     => 'TimeoutSecond'
      , prodValueFlag     => isProduction
      , instanceName      => pkg_Common.getInstanceName()
      , numberValue         => 3.4
    );
    checkOptionValue(
      optionShortName     => 'TimeoutSecond'
      , usedNumberValue   => 3.4
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber( 'TimeoutSecond', raiseNotFoundFlag => 0)
      , expectedString    => 3.4
      , failMessageText   =>
          '�� ������� ������ ����� ��� ������������� ���� � ��������� ��'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutSecond'
            , prodValueFlag     => isProduction
            , instanceName      => pkg_Common.getInstanceName()
            , raiseNotFoundFlag => 0
          )
      , expectedString    => 3.4
      , failMessageText   =>
          '����������� ��������� �������� � getNumber ����� ��������� ��������'
    );
    opt.deleteValue( 'TimeoutSecond');
    checkOptionValue(
      optionShortName     => 'TimeoutSecond'
      , usedNumberValue   => usedValue
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber( 'TimeoutSecond', raiseNotFoundFlag => 0)
      , expectedString    => usedValue
      , failMessageText   =>
          '����������� ������������ �������� � getNumber ����� ��������'
          || ' ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutSecond'
            , prodValueFlag     => isProduction
            , instanceName      => pkg_Common.getInstanceName()
            , raiseNotFoundFlag => 0
          )
      , expectedString    => ''
      , failMessageText   =>
          '����������� ��������� �������� � getNumber ����� �������� ��������'
    );

    -- ��������� setNumber( USED)
    opt.setNumber(
      optionShortName     => 'TimeoutSecond'
      , numberValue       => 9.3
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber( 'TimeoutSecond', raiseNotFoundFlag => 0)
      , expectedString    => 9.3
      , failMessageText   =>
          '�� ������� ������ ������������ ����� � ������� setNumber( USED)'
    );

    -- ��������� setNumber( TEST_PROD)
    opt.setNumber(
      optionShortName     => 'TimeoutSecond'
      , prodNumberValue         => 2.3
      , testNumberValue         => 4.3
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutSecond'
            , prodValueFlag => 1
            , raiseNotFoundFlag => 0
          )
      , expectedString    => 2.3
      , failMessageText   =>
          '�� ������� ������ ������������ ����� � ������� setNumber( TEST_PROD)'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutSecond'
            , prodValueFlag => 0
            , raiseNotFoundFlag => 0
          )
      , expectedString    => 4.3
      , failMessageText   =>
          '�� ������� ������ �������� ����� � ������� setNumber( TEST_PROD)'
    );

    -- ��������� setValue
    changeFlag := opt.setValue(
      optionShortName       => 'TimeoutSecond'
      , prodValueFlag       => 0
      , numberValue         => 4.3
      , skipIfNoChangeFlag  => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 0
      , failMessageText   =>
          'setValue( NUMBER): ������������ �������� ��� ���������� ���������'
    );
    changeFlag := opt.setValue(
      optionShortName       => 'TimeoutSecond'
      , prodValueFlag       => 0
      , numberValue         => 4.31
      , skipIfNoChangeFlag  => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'setValue( NUMBER): ������������ �������� ��� ������� ���������'
    );
    checkOptionValue(
      optionShortName         => 'TimeoutSecond'
      , testNumberValue       => 4.31
    );
    changeFlag := opt.setValue(
      optionShortName       => 'TimeoutSecond'
      , prodValueFlag       => 0
      , numberValue         => 4.31
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'setValue( NUMBER): ������������ �������� ��� ���������'
    );
    checkOptionValue(
      optionShortName         => 'TimeoutSecond'
      , testNumberValue       => 4.31
    );

    opt.setValue(
      optionShortName       => 'TimeoutSecond'
      , prodValueFlag       => 0
      , numberValue         => 4.33
      , skipIfNoChangeFlag  => 1
    );
    checkOptionValue(
      optionShortName         => 'TimeoutSecond'
      , testNumberValue       => 4.33
    );

    -- ��������� �������� ��� ���������� �������� ���������
    opt.deleteValue( 'TimeoutSecond');
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutSecond'
            , prodValueFlag       => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getNumber:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutSecond'
          )
      , expectedString    => null
      , failMessageText   =>
          'getNumber( USED):'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutSecond'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getNumber: raise=0:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutSecond'
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getNumber( USED): raise=0:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutSecond'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getNumber: raise=1:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutSecond'
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getNumber( USED): raise=1:'
          || ' ������������ ��������� ��� ���������� ��������'
    );

    -- �������� ��� ��������� �������� ( �� ��������� null)
    opt.addNumber(
      optionShortName         => 'SaveDayCount'
      , optionName            =>
          '���� �������� ( � ����)'
      , optionDescription     =>
          '���� �������� ( � ����) ( ��� ��������� ��������)'
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Number_ValueTypeCode
      , optionShortName       => 'SaveDayCount'
      , optionName            =>
          '���� �������� ( � ����)'
      , optionDescription     =>
          '���� �������� ( � ����) ( ��� ��������� ��������)'
      , testProdSensitiveFlag => 0
      , numberValue           => null
      -- ��������� ������������ ��������������� �������
      , optionId              =>
          opt.getOptionId(
            optionShortName     => 'SaveDayCount'
            , raiseNotFoundFlag => 0
          )
      , valueId               =>
          opt.getValueId(
            optionShortName     => 'SaveDayCount'
            , prodValueFlag     => null
            , raiseNotFoundFlag => 0
          )
      , usedValueId           =>
          opt.getValueId(
            optionShortName     => 'SaveDayCount'
            , raiseNotFoundFlag => 0
          )
    );

    -- ��������� updateNumberValue
    opt_option_list_t.updateNumberValue(
      valueId                 =>
          opt.getValueId(
            optionShortName     => 'SaveDayCount'
            , prodValueFlag     => null
            , raiseNotFoundFlag => 0
          )
      , numberValue             => 453985.88888888
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Number_ValueTypeCode
      , optionShortName       => 'SaveDayCount'
      , numberValue           => 453985.88888888
    );

    opt_option_list_t.updateNumberValue(
      valueId                 =>
          opt.getValueId(
            optionShortName     => 'SaveDayCount'
            , prodValueFlag     => null
            , raiseNotFoundFlag => 0
          )
      , numberValue             => 45398511.1111111
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Number_ValueTypeCode
      , optionShortName       => 'SaveDayCount'
      , numberValue           => 45398511.1111111
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ��������� ��������� ����.'
        )
      , true
    );
  end testNumberOption;



  /*
    ������������ ������� ��� ��������� ���������� ���� � ���������������
    �������.
  */
  procedure testStringOption
  is

    -- ����� ������
    opt opt_option_list_t := opt_option_list_t(
      moduleName => Exp_ModuleName
    );

    -- ������� ������������ ��������
    usedValue opt_value.string_value%type;

    -- ���� �������� ���������
    changeFlag integer;

  -- testStringOption
  begin
    pkg_TestUtility.beginTest( 'testOptionList: string option');

    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getOptionId(
            optionShortName     => 'InfoString'
            , raiseNotFoundFlag => 0
          )
      , expectedString    => null
      , failMessageText   =>
          '��������� Id ��������������� ��������� InfoString'
    );

    -- ��������� �������� ��� ���������� ���������
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'InfoString_000'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getString: ������������ ��������� ��� ���������� ���������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'InfoString_001'
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getString( USED): ������������ ��������� ��� ���������� ���������'
    );

    -- �������� � ������������ � �������� ���������
    opt.addString(
      optionShortName         => 'InfoString'
      , optionName            => '�������������� ������'
      , optionDescription     =>
          '�������������� ������ � �������� � ������������ ���������'
      , prodStringValue       => 'Production info (0)'
      , testStringValue       => 'Test info (0)'
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.String_ValueTypeCode
      , optionShortName       => 'InfoString'
      , optionName            => '�������������� ������'
      , optionDescription     =>
          '�������������� ������ � �������� � ������������ ���������'
      , testProdSensitiveFlag => 1
      , accessLevelCode       => 'FULL'
      , stringValue           => 'Production info (0)'
      , testStringValue       => 'Test info (0)'
      -- ��������� ������������ ��������������� �������
      , optionId              =>
          opt.getOptionId(
            optionShortName     => 'InfoString'
            , raiseNotFoundFlag => 0
          )
      , valueId               =>
          opt.getValueId(
            optionShortName     => 'InfoString'
            , prodValueFlag     => 1
            , raiseNotFoundFlag => 0
          )
      , testValueId           =>
          opt.getValueId(
            optionShortName     => 'InfoString'
            , prodValueFlag     => 0
            , raiseNotFoundFlag => 0
          )
      , usedValueId           =>
          opt.getValueId(
            optionShortName     => 'InfoString'
            , raiseNotFoundFlag => 0
          )
    );

    -- �������������� ( ����� ��������)
    opt.deleteOption(
      optionShortName         => 'InfoString'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getOptionId( 'InfoString' , raiseNotFoundFlag => 0)
      , expectedString    => null
      , failMessageText   => '��������� Id ���������� ��������� InfoString'
    );
    opt.addString(
      optionShortName         => 'InfoString'
      , optionName            => '�������������� ������'
      , optionDescription     =>
          '�������������� ������ � �������� � ������������ ���������'
      , prodStringValue       => 'Production info (0)'
      , testStringValue       => 'Test info (0)'
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.String_ValueTypeCode
      , optionShortName       => 'InfoString'
      , optionName            => '�������������� ������'
      , optionDescription     =>
          '�������������� ������ � �������� � ������������ ���������'
      , stringValue             => 'Production info (0)'
      , testStringValue         => 'Test info (0)'
    );

    -- ���������� � ���������� ��������, ���� �������� ����������
    opt.addString(
      optionShortName         => 'InfoString'
      , optionName            => '�������������� ������ (1)'
      , optionDescription     =>
          '�������������� ������ � �������� � ������������ ��������� (1)'
      , prodStringValue       => 'Production info (1)'
      , testStringValue       => 'Test info (1)'
      , changeValueFlag       => 1
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.String_ValueTypeCode
      , optionShortName       => 'InfoString'
      , optionName            => '�������������� ������'
      , optionDescription     =>
          '�������������� ������ � �������� � ������������ ���������'
      , stringValue             => 'Production info (1)'
      , testStringValue         => 'Test info (1)'
    );

    -- �������� �� ������ ����������, �.�. ��� ����������
    opt.addString(
      optionShortName         => 'InfoString'
      , optionName            => '�������������� ������ (2)'
      , optionDescription     =>
          '�������������� ������ � �������� � ������������ ��������� (2)'
      , prodStringValue       => 'Production info (2)'
      , testStringValue       => 'Test info (2)'
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.String_ValueTypeCode
      , optionShortName       => 'InfoString'
      , optionName            => '�������������� ������'
      , optionDescription     =>
          '�������������� ������ � �������� � ������������ ���������'
      , stringValue             => 'Production info (1)'
      , testStringValue         => 'Test info (1)'
    );

    -- ��������� getString
   pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            optionShortName     => 'InfoString'
            , prodValueFlag     => 1
            , raiseNotFoundFlag => 0
          )
      , expectedString    => 'Production info (1)'
      , failMessageText   => '����������� �������� getString( prod)'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            optionShortName     => 'InfoString'
            , prodValueFlag     => 0
            , raiseNotFoundFlag => 0
          )
      , expectedString    => 'Test info (1)'
      , failMessageText   => '����������� �������� getString( test)'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            optionShortName     => 'InfoString'
            , raiseNotFoundFlag => 0
          )
      , expectedString    =>
          case isProduction
            when 1 then 'Production info (1)'
            when 0 then 'Test info (1)'
          end
      , failMessageText   => '����������� �������� getString( used)'
    );

    -- ��������� setString
    opt.setString(
      optionShortName     => 'InfoString'
      , prodValueFlag     => 1
      , stringValue       => 'Production info (3)'
    );
    checkOptionValue(
      optionShortName     => 'InfoString'
      , stringValue       => 'Production info (3)'
      , testStringValue   => 'Test info (1)'
    );
    opt.setString(
      optionShortName     => 'InfoString'
      , prodValueFlag     => 0
      , stringValue       => 'Test info (3)'
    );
    checkOptionValue(
      optionShortName     => 'InfoString'
      , stringValue       => 'Production info (3)'
      , testStringValue   => 'Test info (3)'
    );

    -- ��������� setString � instanceName
    usedValue := opt.getString( 'InfoString');
    opt.setString(
      optionShortName     => 'InfoString'
      , prodValueFlag     => 0
      , instanceName      => 'none'
      , stringValue       => 'Test info (4)'
    );
    checkOptionValue(
      optionShortName     => 'InfoString'
      , stringValue       => 'Production info (3)'
      , testStringValue   => 'Test info (3)'
      , usedStringValue   => usedValue
    );
    checkOptionValue(
      optionShortName     => 'InfoString'
      , instanceName      => 'none'
      , testStringValue   => 'Test info (4)'
    );

    opt.setString(
      optionShortName     => 'InfoString'
      , prodValueFlag     => isProduction
      , instanceName      => pkg_Common.getInstanceName()
      , stringValue         => 'Usage info (4)'
    );
    checkOptionValue(
      optionShortName     => 'InfoString'
      , usedStringValue   => 'Usage info (4)'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString( 'InfoString', raiseNotFoundFlag => 0)
      , expectedString    => 'Usage info (4)'
      , failMessageText   =>
          '�� ������� ������ ������ ��� ������������� ���� � ��������� ��'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'InfoString'
            , prodValueFlag     => isProduction
            , instanceName      => pkg_Common.getInstanceName()
            , raiseNotFoundFlag => 0
          )
      , expectedString    => 'Usage info (4)'
      , failMessageText   =>
          '����������� ��������� �������� � getString ����� ��������� ��������'
    );
    opt.deleteValue( 'InfoString');
    checkOptionValue(
      optionShortName     => 'InfoString'
      , usedStringValue   => usedValue
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString( 'InfoString', raiseNotFoundFlag => 0)
      , expectedString    => usedValue
      , failMessageText   =>
          '����������� ������������ �������� � getString ����� ��������'
          || ' ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'InfoString'
            , prodValueFlag     => isProduction
            , instanceName      => pkg_Common.getInstanceName()
            , raiseNotFoundFlag => 0
          )
      , expectedString    => ''
      , failMessageText   =>
          '����������� ��������� �������� � getString ����� �������� ��������'
    );

    -- ��������� setString( USED)
    opt.setString(
      optionShortName     => 'InfoString'
      , stringValue       => 'Usage info (5)'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString( 'InfoString', raiseNotFoundFlag => 0)
      , expectedString    => 'Usage info (5)'
      , failMessageText   =>
          '�� ������� ������ ������������ ������ � ������� setString( USED)'
    );

    -- ��������� setString( TEST_PROD)
    opt.setString(
      optionShortName     => 'InfoString'
      , prodStringValue   => 'Production info (6)'
      , testStringValue   => 'Test info (6)'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'InfoString'
            , prodValueFlag => 1
            , raiseNotFoundFlag => 0
          )
      , expectedString    => 'Production info (6)'
      , failMessageText   =>
          '�� ������� ������ ���������. ������ � ������� setString( TEST_PROD)'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'InfoString'
            , prodValueFlag => 0
            , raiseNotFoundFlag => 0
          )
      , expectedString    => 'Test info (6)'
      , failMessageText   =>
          '�� ������� ������ �������� ������ � ������� setString( TEST_PROD)'
    );

    -- ��������� setValue
    changeFlag := opt.setValue(
      optionShortName       => 'InfoString'
      , prodValueFlag       => 0
      , stringValue         => 'Test info (6)'
      , skipIfNoChangeFlag  => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 0
      , failMessageText   =>
          'setValue( STRING): ������������ �������� ��� ���������� ���������'
    );
    changeFlag := opt.setValue(
      optionShortName       => 'InfoString'
      , prodValueFlag       => 0
      , stringValue         => 'Test info (7)'
      , skipIfNoChangeFlag  => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'setValue( STRING): ������������ �������� ��� ������� ���������'
    );
    checkOptionValue(
      optionShortName         => 'InfoString'
      , testStringValue       => 'Test info (7)'
    );
    changeFlag := opt.setValue(
      optionShortName       => 'InfoString'
      , prodValueFlag       => 0
      , stringValue         => 'Test info (7)'
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'setValue( STRING): ������������ �������� ��� ���������'
    );
    checkOptionValue(
      optionShortName         => 'InfoString'
      , testStringValue       => 'Test info (7)'
    );
    opt.setValue(
      optionShortName       => 'InfoString'
      , prodValueFlag       => 0
      , stringValue         => 'Test info (7)'
    );

    -- ��������� �������� ��� ���������� �������� ���������
    opt.deleteValue( 'InfoString');
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'InfoString'
            , prodValueFlag       => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getString:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'InfoString'
          )
      , expectedString    => null
      , failMessageText   =>
          'getString( USED):'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'InfoString'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getString: raise=0:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'InfoString'
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getString( USED): raise=0:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'InfoString'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getString: raise=1:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'InfoString'
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getString( USED): raise=1:'
          || ' ������������ ��������� ��� ���������� ��������'
    );

    -- �������� ��� ��������� �������� ( �� ��������� null)
    opt.addString(
      optionShortName         => 'SourceDbLink'
      , optionName            =>
          '���� � �������� ��'
      , optionDescription     =>
          '���� � �������� �� ( ��� ��������� ��������)'
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.String_ValueTypeCode
      , optionShortName       => 'SourceDbLink'
      , optionName            =>
          '���� � �������� ��'
      , optionDescription     =>
          '���� � �������� �� ( ��� ��������� ��������)'
      , testProdSensitiveFlag => 0
      , stringValue           => null
      -- ��������� ������������ ��������������� �������
      , optionId              =>
          opt.getOptionId(
            optionShortName     => 'SourceDbLink'
            , raiseNotFoundFlag => 0
          )
      , valueId               =>
          opt.getValueId(
            optionShortName     => 'SourceDbLink'
            , prodValueFlag     => null
            , raiseNotFoundFlag => 0
          )
      , usedValueId           =>
          opt.getValueId(
            optionShortName     => 'SourceDbLink'
            , raiseNotFoundFlag => 0
          )
    );

    -- ��������� updateStringValue
    opt_option_list_t.updateStringValue(
      valueId                 =>
          opt.getValueId(
            optionShortName     => 'SourceDbLink'
            , prodValueFlag     => null
            , raiseNotFoundFlag => 0
          )
      , stringValue             => 'NewLink1'
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.String_ValueTypeCode
      , optionShortName       => 'SourceDbLink'
      , stringValue           => 'NewLink1'
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ��������� ���������� ����.'
        )
      , true
    );
  end testStringOption;



  /*
    ������������ ������� ��� ������������� � SQL
  */
  procedure testSqlFunction
  is

    -- ����� ������
    opt opt_option_list_t := opt_option_list_t(
      moduleName => Exp_ModuleName
    );

    nOption integer;

  -- testSqlFunction
  begin
    pkg_TestUtility.beginTest( 'testOptionList: SQL function');

    opt.addDate(
      optionShortName         => 'SqlDate'
      , optionName            => '�������� ��� ����� SQL'
      , prodDateValue         => null
      , testDateValue         => DATE '2000-09-01'
    );
    opt.addNumber(
      optionShortName         => 'SqlNumber'
      , optionName            => '�������� ��� ����� SQL'
      , prodNumberValue       => 10.1
      , testNumberValue       => 11.1
    );
    opt.addString(
      optionShortName         => 'SqlString'
      , optionName            => '�������� ��� ����� SQL'
      , prodStringValue       => 'str1'
      , testStringValue       => 'str2'
    );

    select
      count(*)
    into nOption
    from
      v_opt_option_value t
    where
      t.module_name = Exp_ModuleName
      and t.object_short_name is null
    ;
    pkg_TestUtility.compareRowCount(
      tableName               =>
        'table( opt_option_list_t( ''' || Exp_ModuleName || ''')'
        || '.getOptionValue())'
      , expectedRowCount      => nOption
      , failMessageText       =>
          'getOptionValue: ����������� ����� ������� � �������'
    );
    pkg_TestUtility.compareRowCount(
      tableName               =>
'(
select
  t.option_id
  , t.value_id
from
  table( opt_option_list_t( ''' || Exp_ModuleName || ''').getOptionValue()) t
intersect
select
  t.option_id
  , t.value_id
from
  v_opt_option_value t
where
  t.module_name = ''' || Exp_ModuleName || '''
  and t.object_short_name is null
)'
      , expectedRowCount      => nOption
      , failMessageText       =>
          'getOptionValue: ������ � ��������� ������� �����������'
    );

    pkg_TestUtility.compareRowCount(
      tableName               =>
        'table( opt_option_list_t( ''' || Exp_ModuleName || ''')'
        || '.getValue(''SqlDate''))'
      , expectedRowCount      => 2
      , failMessageText       =>
          'getValue: ����������� ����� ������� � �������'
    );
    pkg_TestUtility.compareRowCount(
      tableName               =>
'(
select
  t.option_id
  , t.value_id
from
  table(
    opt_option_list_t( ''' || Exp_ModuleName || ''').getValue(''SqlDate'')
  ) t
intersect
select
  t.option_id
  , t.value_id
from
  v_opt_value t
where
  t.option_id = ' || opt.getOptionid( 'SqlDate') || '
)'
      , expectedRowCount      => 2
      , failMessageText       =>
          'getValue: ������ � ��������� ������� �����������'
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ������� ��� SQL.'
        )
      , true
    );
  end testSqlFunction;



  /*
    ������������ ��������� ������ ���������.
  */
  procedure testChangeOptionData
  is

    -- ����� ������
    opt opt_option_list_t := opt_option_list_t(
      moduleName => Exp_ModuleName
    );

    changeFlag integer;

  -- testChangeOptionData
  begin
    pkg_TestUtility.beginTest( 'testOptionList: change option data');

    -- �������������� ������� ��� ���������� ���������
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueId(
            'FlexibleData_000'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueId: ������������ ��������� ��� ���������� ���������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueId(
            'FlexibleData_001'
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueId( USED): ������������ ��������� ��� ���������� ���������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount(
            'FlexibleData_002'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => 0
      , failMessageText   =>
          'getValueCount: ������������ ��������� ��� ���������� ���������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount(
            'FlexibleData_003'
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => 0
      , failMessageText   =>
          'getValueCount( USED):'
          || ' ������������ ��������� ��� ���������� ���������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator(
            'FlexibleData_004'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueListSeparator:'
          || ' ������������ ��������� ��� ���������� ���������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator(
            'FlexibleData_005'
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueListSeparator( USED):'
          || ' ������������ ��������� ��� ���������� ���������'
    );

    pkg_TestUtility.compareChar(
      actualString        => opt.existsOption( 'FlexibleData')
      , expectedString    => 0
      , failMessageText   =>
          'existsOption: ������������ ��������� ��� ���������� ���������'
    );

    opt.createOption(
      optionShortName         => 'FlexibleData'
      , optionName            => '������ �����'
      , valueTypeCode         => opt_option_list_t.getDateValueTypeCode()
      , testProdSensitiveFlag => 1
    );
    checkOptionValue(
      optionShortName         => 'FlexibleData'
      , valueTypeCode         => pkg_OptionMain.Date_ValueTypeCode
      , valueListFlag         => 0
      , testProdSensitiveFlag => 1
      , accessLevelCode       => pkg_OptionMain.Full_AccessLevelCode
      , optionName            => '������ �����'
      , optionDescription     => null
      , usedValueId           => null
    );

    pkg_TestUtility.compareChar(
      actualString        => opt.existsOption( 'FlexibleData')
      , expectedString    => 1
      , failMessageText   =>
          'existsOption: ������������ ��������� ��� ������� ���������'
    );

    opt.setDate(
      optionShortName         => 'FlexibleData'
      , prodDateValue         => null
      , testDateValue         => DATE '2000-01-01'
    );
    opt.updateOption(
      optionShortName         => 'FlexibleData'
      , valueTypeCode         => pkg_OptionMain.Date_ValueTypeCode
      , testProdSensitiveFlag => 1
      , accessLevelCode       => pkg_OptionMain.Read_AccessLevelCode
      , optionName            => '������ ����� (2)'
      , optionDescription     => '���� ��������� ������ ���������'
    );
    checkOptionValue(
      optionShortName         => 'FlexibleData'
      , valueTypeCode         => pkg_OptionMain.Date_ValueTypeCode
      , valueListFlag         => 0
      , testProdSensitiveFlag => 1
      , accessLevelCode       => pkg_OptionMain.Read_AccessLevelCode
      , optionName            => '������ ����� (2)'
      , optionDescription     => '���� ��������� ������ ���������'
      , changeNumber          => 2
      , dateValue             => null
      , testDateValue         => DATE '2000-01-01'
    );

    -- ������ �� ������ ���������� ( �� ��������� ����� ������������ ������)
    changeFlag := opt.updateOption(
      optionShortName         => 'FlexibleData'
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'updateOption: ������������ ��������� � ������ ���������'
    );
    checkOptionValue(
      optionShortName         => 'FlexibleData'
      , valueTypeCode         => pkg_OptionMain.Date_ValueTypeCode
      , valueListFlag         => 0
      , testProdSensitiveFlag => 1
      , accessLevelCode       => pkg_OptionMain.Read_AccessLevelCode
      , optionName            => '������ ����� (2)'
      , optionDescription     => '���� ��������� ������ ���������'
      , changeNumber          => 3
      , dateValue             => null
      , testDateValue         => DATE '2000-01-01'
    );

    -- ... �� �� ��� ����� �������� ���������
    changeFlag := opt.updateOption(
      optionShortName         => 'FlexibleData'
      , skipIfNoChangeFlag    => 0
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'updateOption: ������������ ��������� � ������ ���������'
    );
    checkOptionValue(
      optionShortName         => 'FlexibleData'
      , changeNumber          => 4
    );

    -- ������������� ��-�� ���������� ����������� ���������
    changeFlag := opt.updateOption(
      optionShortName         => 'FlexibleData'
      , skipIfNoChangeFlag    => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 0
      , failMessageText   =>
          'updateOption: ������������ ��������� ��� ���������� ������'
    );
    checkOptionValue(
      optionShortName         => 'FlexibleData'
      , changeNumber          => 4
    );

    changeFlag := opt.updateOption(
      optionShortName         => 'FlexibleData'
      , valueTypeCode         => pkg_OptionMain.Date_ValueTypeCode
      , testProdSensitiveFlag => 1
      , accessLevelCode       => pkg_OptionMain.Read_AccessLevelCode
      , optionName            => '������ ����� (2)'
      , optionDescription     => '���� ��������� ������ ���������'
      , skipIfNoChangeFlag    => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 0
      , failMessageText   =>
          'updateOption: ������������ ��������� ��� ���������� ���������'
    );
    checkOptionValue(
      optionShortName         => 'FlexibleData'
      , changeNumber          => 4
    );

    -- ��������� �� ����������� ����������
    changeFlag := opt.updateOption(
      optionShortName         => 'FlexibleData'
      , optionDescription     => '���� ��������� ������ ��������� (2)'
      , skipIfNoChangeFlag    => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'updateOption: ������������ ��������� ��� ���������'
    );
    checkOptionValue(
      optionShortName         => 'FlexibleData'
      , optionDescription     => '���� ��������� ������ ��������� (2)'
    );

    changeFlag := opt.updateOption(
      optionShortName         => 'FlexibleData'
      , forceOptionDescriptionFlag => 1
      , skipIfNoChangeFlag    => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'updateOption: ������������ ��������� ��� ��������� �� null'
    );
    checkOptionValue(
      optionShortName         => 'FlexibleData'
      , optionDescription     => null
    );

    changeFlag := opt.updateOption(
      optionShortName         => 'FlexibleData'
      , optionDescription     => '���� ��������� ������ ���������'
      , skipIfNoChangeFlag    => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'updateOption: ������������ ��������� ��� ��������� ����� null'
    );
    checkOptionValue(
      optionShortName         => 'FlexibleData'
      , optionDescription     => '���� ��������� ������ ���������'
    );

    -- ��������� ����
    opt.updateOption(
      optionShortName         => 'FlexibleData'
      , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
      , optionName            => '������ ����� - ������ (3)'
      , deleteBadValueFlag    => 1
    );

    opt.setString(
      optionShortName   => 'FlexibleData'
      , stringValue     => 'Usage string'
    );

    checkOptionValue(
      optionShortName         => 'FlexibleData'
      , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
      , valueListFlag         => 0
      , testProdSensitiveFlag => 1
      , accessLevelCode       => pkg_OptionMain.Read_AccessLevelCode
      , optionName            => '������ ����� - ������ (3)'
      , optionDescription     => '���� ��������� ������ ���������'
    );

    opt.updateOption(
      optionShortName         => 'FlexibleData'
      , valueTypeCode         => pkg_OptionMain.Date_ValueTypeCode
      , optionName            => '������ ����� - ���� (4)'
      , deleteBadValueFlag    => 1
    );
    opt.setDate(
      optionShortName         => 'FlexibleData'
      , prodDateValue         => DATE '2015-01-01'
      , testDateValue         => DATE '2013-05-05'
    );

    -- ������ test_prod_sensitive_flag: � 1 �� 0 ( � ������������ ��������)
    opt.updateOption(
      optionShortName               => 'FlexibleData'
      , testProdSensitiveFlag       => 0
      , moveProdSensitiveValueFlag  => 1
      , deleteBadValueFlag          => 1
    );
    checkOptionValue(
      optionShortName         => 'FlexibleData'
      , testProdSensitiveFlag => 0
      , dateValue             => DATE '2015-01-01'
    );

    -- ������ test_prod_sensitive_flag: � 0 �� 1 ( � ������������ ��������)
    opt.updateOption(
      optionShortName               => 'FlexibleData'
      , testProdSensitiveFlag       => 1
      , moveProdSensitiveValueFlag  => 1
      , deleteBadValueFlag          => 1
    );
    opt.setDate(
      optionShortName         => 'FlexibleData'
      , prodValueFlag         => 0
      , dateValue             => DATE '2013-05-15'
    );
    checkOptionValue(
      optionShortName         => 'FlexibleData'
      , testProdSensitiveFlag => 1
      , dateValue             => DATE '2015-01-01'
      , testDateValue         => DATE '2013-05-15'
    );

    -- �������� �������� �� Id
    opt_option_list_t.deleteValue(
      valueId => opt.getValueId( 'FlexibleData', prodValueFlag => 0)
    );
    checkOptionValue(
      optionShortName         => 'FlexibleData'
      , testProdSensitiveFlag => 1
      , dateValue             => DATE '2015-01-01'
      , testDeleted           => 1
    );

    -- �������������� ������� ��� ���������� �������� ���������
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueId(
            'FlexibleData'
            , prodValueFlag       => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueId: ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueId(
            'FlexibleData'
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueId( USED): ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount(
            'FlexibleData'
            , prodValueFlag       => 0
          )
      , expectedString    => 0
      , failMessageText   =>
          'getValueCount: ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount(
            'FlexibleData'
          )
      , expectedString    => 0
      , failMessageText   =>
          'getValueCount( USED): ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator(
            'FlexibleData'
            , prodValueFlag       => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueListSeparator:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator(
            'FlexibleData'
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueListSeparator( USED):'
          || ' ������������ ��������� ��� ���������� ��������'
    );

    -- ... ��� �������� raiseNotFoundFlag => 0
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueId(
            'FlexibleData'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueId: raise=0:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueId(
            'FlexibleData'
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueId( USED): raise=0:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount(
            'FlexibleData'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => 0
      , failMessageText   =>
          'getValueCount: raise=0:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount(
            'FlexibleData'
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => 0
      , failMessageText   =>
          'getValueCount( USED): raise=0:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator(
            'FlexibleData'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueListSeparator: raise=0:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator(
            'FlexibleData'
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueListSeparator( USED): raise=0:'
          || ' ������������ ��������� ��� ���������� ��������'
    );

    -- ... ��� �������� raiseNotFoundFlag => 1
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueId(
            'FlexibleData'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueId: raise=1:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueId(
            'FlexibleData'
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueId( USED): raise=1:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount(
            'FlexibleData'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => 0
      , failMessageText   =>
          'getValueCount: raise=1:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount(
            'FlexibleData'
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => 0
      , failMessageText   =>
          'getValueCount( USED): raise=1:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator(
            'FlexibleData'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueListSeparator: raise=1:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator(
            'FlexibleData'
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueListSeparator( USED): raise=1:'
          || ' ������������ ��������� ��� ���������� ��������'
    );

    -- ������� ��������
    opt.deleteOption(
      optionShortName               => 'FlexibleData'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getOptionId( 'FlexibleData' , raiseNotFoundFlag => 0)
      , expectedString    => null
      , failMessageText   => '��������� Id ���������� ��������� FlexibleData'
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ��������� ������ ���������.'
        )
      , true
    );
  end testChangeOptionData;



  /*
    ������������ ��������� �� ������� �������� ���� ����.
  */
  procedure testDateList
  is

    -- ����� ������
    opt opt_option_list_t := opt_option_list_t(
      moduleName => Exp_ModuleName
    );

    -- ���� �������� ���������
    changeFlag integer;

  -- testDateList
  begin
    pkg_TestUtility.beginTest( 'testOptionList: date list');

    -- ��������� ������ ��� ���������� ���������
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList(
            'CheckDateList_000'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueList: ������������ ��������� ��� ���������� ���������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList(
            'CheckDateList_001'
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueList( USED): ������������ ��������� ��� ���������� ���������'
    );

    -- addDateList: �������� � ������������ � �������� ���������
    opt.addDateList(
      optionShortName         => 'CheckDateList'
      , optionName            => '����������� ����'
      , optionDescription     =>
          '����������� ���� ( � �������� � ������������ ���������)'
      , prodValueList         => '01.12.2009 18:45:09,,05.01.2019'
      , testValueList         => '10.01.2019'
      , listSeparator         => ','
      , valueFormat           => 'dd.mm.yyyy hh24:mi:ss'
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Date_ValueTypeCode
      , optionShortName       => 'CheckDateList'
      , optionName            => '����������� ����'
      , optionDescription     =>
          '����������� ���� ( � �������� � ������������ ���������)'
      , testProdSensitiveFlag => 1
      , listSeparator         => ';'
      , stringValue           => '2009-12-01 18:45:09;;2019-01-05 00:00:00'
      , testListSeparator     => ';'
      , testStringValue       => '2019-01-10 00:00:00'
    );

    -- ���������� � ���������� ��������, ���� �������� ����������
    opt.addDateList(
      optionShortName         => 'CheckDateList'
      , optionName            => '����������� ���� (1)'
      , optionDescription     =>
          '����������� ���� ( � �������� � ������������ ���������) (1)'
      , prodValueList         => '01.12.2009 18:45:03,,05.01.2010'
      , testValueList         => '10.01.2013'
      , listSeparator         => ','
      , valueFormat           => 'dd.mm.yyyy hh24:mi:ss'
      , changeValueFlag       => 1
    );
    checkOptionValue(
      optionShortName         => 'CheckDateList'
      , optionName            => '����������� ����'
      , optionDescription     =>
          '����������� ���� ( � �������� � ������������ ���������)'
      , listSeparator         => ';'
      , stringValue           => '2009-12-01 18:45:03;;2010-01-05 00:00:00'
      , testListSeparator     => ';'
      , testStringValue       => '2013-01-10 00:00:00'
    );

    -- �������� �� ������ ����������, �.�. ��� ����������
    opt.addDateList(
      optionShortName         => 'CheckDateList'
      , optionName            => '����������� ���� (2)'
      , optionDescription     =>
          '����������� ���� ( � �������� � ������������ ���������) (2)'
      , prodValueList         => '03.12.2009 18:45:03,,03.01.2010'
      , testValueList         => '13.01.2013'
      , listSeparator         => ','
      , valueFormat           => 'dd.mm.yyyy hh24:mi:ss'
    );
    checkOptionValue(
      optionShortName         => 'CheckDateList'
      , optionName            => '����������� ����'
      , optionDescription     =>
          '����������� ���� ( � �������� � ������������ ���������)'
      , listSeparator         => ';'
      , stringValue           => '2009-12-01 18:45:03;;2010-01-05 00:00:00'
      , testListSeparator     => ';'
      , testStringValue       => '2013-01-10 00:00:00'
    );

    -- getValueCount
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount( 'CheckDateList', prodValueFlag => 1)
      , expectedString    => '3'
      , failMessageText   =>
          '����������� ����� ����. �������� ���� ���� � getValueCount'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount( 'CheckDateList', prodValueFlag => 0)
      , expectedString    => '1'
      , failMessageText   =>
          '����������� ����� �������� �������� ���� ���� � getValueCount'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount( 'CheckDateList')
      , expectedString    => case when isProduction = 1 then '3' else '1' end
      , failMessageText   =>
          '����������� ����� ������������ �������� ���� ���� � getValueCount'
    );

    -- getDate
    pkg_TestUtility.compareChar(
      actualString        =>
          to_char(
            opt.getDate( 'CheckDateList', prodValueFlag => 1)
            , 'yyyy-mm-dd hh24:mi:ss'
          )
      , expectedString    => '2009-12-01 18:45:03'
      , failMessageText   =>
          '����������� ����. �������� � getDate'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          to_char(
            opt.getDate( 'CheckDateList', prodValueFlag => 1, valueIndex => 2)
            , 'yyyy-mm-dd hh24:mi:ss'
          )
      , expectedString    => ''
      , failMessageText   =>
          '����������� ����. �������� #2 � getDate'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          to_char(
            opt.getDate( 'CheckDateList', prodValueFlag => 1, valueIndex => 3)
            , 'yyyy-mm-dd hh24:mi:ss'
          )
      , expectedString    => '2010-01-05 00:00:00'
      , failMessageText   =>
          '����������� ����. �������� #3 � getDate'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          to_char(
            opt.getDate( 'CheckDateList', prodValueFlag => 0)
            , 'yyyy-mm-dd hh24:mi:ss'
          )
      , expectedString    => '2013-01-10 00:00:00'
      , failMessageText   =>
          '����������� �������� �������� � getDate'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          to_char(
            opt.getDate( 'CheckDateList', valueIndex => 1)
            , 'yyyy-mm-dd hh24:mi:ss'
          )
      , expectedString    =>
          case when isProduction = 1
            then '2009-12-01 18:45:03'
            else '2013-01-10 00:00:00'
          end
      , failMessageText   =>
          '����������� ������������ �������� � getDate'
    );

    -- ��������� �������� ��� �������� ��������������� �������
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getDate(
            'CheckDateList'
            , prodValueFlag       => 0
            , valueIndex          => 888
          )
      , expectedString    => null
      , failMessageText   =>
          'getDate:'
          || ' ������������ ��������� ��� �������������� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getDate(
            'CheckDateList'
            , valueIndex          => 888
          )
      , expectedString    => null
      , failMessageText   =>
          'getDate( USED):'
          || ' ������������ ��������� ��� �������������� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getDate(
            'CheckDateList'
            , prodValueFlag       => 0
            , valueIndex          => 888
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getDate: raise=0:'
          || ' ������������ ��������� ��� �������������� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getDate(
            'CheckDateList'
            , valueIndex          => 888
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getDate( USED): raise=0:'
          || ' ������������ ��������� ��� �������������� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getDate(
            'CheckDateList'
            , prodValueFlag       => 0
            , valueIndex          => 888
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getDate: raise=1:'
          || ' ������������ ��������� ��� �������������� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getDate(
            'CheckDateList'
            , valueIndex          => 888
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getDate( USED): raise=1:'
          || ' ������������ ��������� ��� �������������� �������'
    );

    -- setDate
    opt.setDate(
      optionShortName         => 'CheckDateList'
      , prodValueFlag         => 1
      , dateValue             =>
          to_date( '2010-03-01 12:00:00', 'yyyy-mm-dd hh24:mi:ss')
      , valueIndex            => 2
    );
    checkOptionValue(
      optionShortName         => 'CheckDateList'
      , stringValue           =>
          '2009-12-01 18:45:03;2010-03-01 12:00:00;2010-01-05 00:00:00'
      , testStringValue       =>
          '2013-01-10 00:00:00'
    );
    opt.setDate(
      optionShortName         => 'CheckDateList'
      , prodDateValue         => null
      , testDateValue         => null
      , valueIndex            => 5
    );
    checkOptionValue(
      optionShortName         => 'CheckDateList'
      , stringValue           =>
          '2009-12-01 18:45:03;2010-03-01 12:00:00;2010-01-05 00:00:00;;'
      , testStringValue       =>
          '2013-01-10 00:00:00;;;;'
    );
    opt.setDate(
      optionShortName         => 'CheckDateList'
      , prodDateValue         =>
          to_date( '2008-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss')
      , testDateValue         =>
          to_date( '2013-01-01 12:00:00', 'yyyy-mm-dd hh24:mi:ss')
      , valueIndex            => 0
    );
    checkOptionValue(
      optionShortName         => 'CheckDateList'
      , stringValue           =>
          '2008-01-01 00:00:00;2009-12-01 18:45:03;2010-03-01 12:00:00;2010-01-05 00:00:00;;'
      , testStringValue       =>
          '2013-01-01 12:00:00;2013-01-10 00:00:00;;;;'
    );
    opt.setDate(
      optionShortName         => 'CheckDateList'
      , dateValue         =>
          to_date( '2014-12-01 12:00:00', 'yyyy-mm-dd hh24:mi:ss')
      , valueIndex            => -1
    );
    checkOptionValue(
      optionShortName         => 'CheckDateList'
      , stringValue           =>
          '2008-01-01 00:00:00;2009-12-01 18:45:03;2010-03-01 12:00:00;2010-01-05 00:00:00;;'
          || case when isProduction = 1 then ';2014-12-01 12:00:00' end
      , testStringValue       =>
          '2013-01-01 12:00:00;2013-01-10 00:00:00;;;;'
          || case when isProduction = 0 then ';2014-12-01 12:00:00' end
    );

    -- setDate - ���� ������
    opt.setDate(
      optionShortName         => 'CheckDateList'
      , prodDateValue         =>
          to_date( '2008-01-01 00:10:00', 'yyyy-mm-dd hh24:mi:ss')
      , testDateValue         =>
          to_date( '2013-01-01 12:10:00', 'yyyy-mm-dd hh24:mi:ss')
      , valueIndex            => null
    );
    checkOptionValue(
      optionShortName         => 'CheckDateList'
      , stringValue           => '2008-01-01 00:10:00'
      , testStringValue       => '2013-01-01 12:10:00'
    );
    opt.setDate(
      optionShortName         => 'CheckDateList'
      , dateValue         =>
          to_date( '2014-12-01 12:10:00', 'yyyy-mm-dd hh24:mi:ss')
      , valueIndex            => null
    );
    checkOptionValue(
      optionShortName         => 'CheckDateList'
      , stringValue           =>
          case when isProduction = 1
            then '2014-12-01 12:10:00'
            else '2008-01-01 00:10:00'
          end
      , testStringValue       =>
          case when isProduction = 0
            then '2014-12-01 12:10:00'
            else '2013-01-01 12:10:00'
          end
    );

    -- ��������� setValue
    changeFlag := opt.setValue(
      optionShortName       => 'CheckDateList'
      , prodValueFlag       => 0
      , stringValue         => '2014-04-07,2014-04-07 18:59:08'
      , setValueListFlag    => 1
      , listSeparator       => ','
      , valueFormat         => 'yyyy-mm-dd hh24:mi:ss'
      , skipIfNoChangeFlag  => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'setValue( DATE_LIST): ������������ �������� ��� ������� ���������'
    );
    checkOptionValue(
      optionShortName         => 'CheckDateList'
      , testStringValue       => '2014-04-07 00:00:00;2014-04-07 18:59:08'
      , testListSeparator     => ';'
    );
    changeFlag := opt.setValue(
      optionShortName       => 'CheckDateList'
      , prodValueFlag       => 0
      , stringValue         => '07.04.14,07.04.14 18:59:08'
      , setValueListFlag    => 1
      , listSeparator       => ','
      , valueFormat         => 'dd.mm.yy hh24:mi:ss'
      , skipIfNoChangeFlag  => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 0
      , failMessageText   =>
          'setValue( DATE_LIST): ������������ �������� ��� ���������� ���������'
    );

    changeFlag := opt.setValue(
      optionShortName       => 'CheckDateList'
      , prodValueFlag       => 0
      , stringValue         => '07.04.14;07.04.14 18:59:08'
      , setValueListFlag    => 1
      , valueFormat         => 'dd.mm.yy hh24:mi:ss'
      , skipIfNoChangeFlag  => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 0
      , failMessageText   =>
          'setValue( DATE_LIST): ������������ �������� ��� ��������� �����������'
    );
    checkOptionValue(
      optionShortName         => 'CheckDateList'
      , testStringValue       => '2014-04-07 00:00:00;2014-04-07 18:59:08'
      , testListSeparator     => ';'
    );

    changeFlag := opt.setValue(
      optionShortName       => 'CheckDateList'
      , prodValueFlag       => 0
      , stringValue         => '07.04.14;07.04.14 18:59:08'
      , valueFormat         => 'dd.mm.yyyy hh24:mi:ss'
      , setValueListFlag    => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'setValue( DATE_LIST): ������������ �������� ��� ���������'
    );

    -- setValueList
    opt.setValueList(
      optionShortName         => 'CheckDateList'
      , prodValueList         => '2013-03-01 18:00:01;2013-04-01'
      , testValueList         => '2012-03-01'
    );
    checkOptionValue(
      optionShortName         => 'CheckDateList'
      , stringValue           => '2013-03-01 18:00:01;2013-04-01 00:00:00'
      , testStringValue       => '2012-03-01 00:00:00'
    );
    opt.setValueList(
      optionShortName         => 'CheckDateList'
      , prodValueFlag         => 1
      , valueList             => '21.09.2011'
      , valueFormat           => 'dd.mm.yyyy'
    );
    checkOptionValue(
      optionShortName         => 'CheckDateList'
      , stringValue           => '2011-09-21 00:00:00'
      , testStringValue       => '2012-03-01 00:00:00'
    );
    opt.setValueList(
      optionShortName         => 'CheckDateList'
      , valueList             => '21.09.2003,18.07.2004'
      , listSeparator         => ','
      , valueFormat           => 'dd.mm.yyyy'
    );
    checkOptionValue(
      optionShortName         => 'CheckDateList'
      , usedStringValue       => '2003-09-21 00:00:00;2004-07-18 00:00:00'
    );

    -- getValueList
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList( 'CheckDateList', prodValueFlag => 1)
      , expectedString    => '2011-09-21 00:00:00'
      , failMessageText   =>
          '����������� ����. �������� � getValueList'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList( 'CheckDateList', prodValueFlag => 0)
      , expectedString    => '2003-09-21 00:00:00;2004-07-18 00:00:00'
      , failMessageText   =>
          '����������� �������� �������� � getValueList'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList( 'CheckDateList')
      , expectedString    =>
          case isProduction
            when 1 then '2011-09-21 00:00:00'
            when 0 then '2003-09-21 00:00:00;2004-07-18 00:00:00'
          end
      , failMessageText   =>
          '����������� ������������ �������� � getValueList'
    );

    -- getValueListSeparator
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator( 'CheckDateList', prodValueFlag => 1)
      , expectedString    => ';'
      , failMessageText   =>
          '����������� ����. �������� � getValueListSeparator'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator( 'CheckDateList', prodValueFlag => 0)
      , expectedString    => ';'
      , failMessageText   =>
          '����������� �������� �������� � getValueListSeparator'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator( 'CheckDateList')
      , expectedString    => ';'
      , failMessageText   =>
          '����������� ������������ �������� � getValueListSeparator'
    );

    -- ��������� ������ ��� ���������� �������� ���������
    opt.deleteValue( 'CheckDateList');
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList(
            'CheckDateList'
            , prodValueFlag       => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueList:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList(
            'CheckDateList'
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueList( USED):'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList(
            'CheckDateList'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueList: raise=0:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList(
            'CheckDateList'
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueList( USED): raise=0:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList(
            'CheckDateList'
            , prodValueFlag       => 0
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueList: raise=1:'
          || ' ������������ ��������� ��� ���������� ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList(
            'CheckDateList'
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getValueList( USED): raise=1:'
          || ' ������������ ��������� ��� ���������� ��������'
    );

    -- addDateList: �������� � ����� ���������
    opt.addDateList(
      optionShortName         => 'SendDateList'
      , optionName            => '���� ��������'
      , optionDescription     => '���� �������� ( � ����� ���������)'
      , valueList             => '01.03.2010 01:00:00,,05.03.2010'
      , listSeparator         => ','
      , valueFormat           => 'dd.mm.yyyy hh24:mi:ss'
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Date_ValueTypeCode
      , optionShortName       => 'SendDateList'
      , optionName            => '���� ��������'
      , optionDescription     => '���� �������� ( � ����� ���������)'
      , testProdSensitiveFlag => 0
      , listSeparator         => ';'
      , stringValue           => '2010-03-01 01:00:00;;2010-03-05 00:00:00'
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ������ �������� ���� ����.'
        )
      , true
    );
  end testDateList;



  /*
    ������������ ��������� �� ������� �������� ��������.
  */
  procedure testNumberList
  is

    -- ����� ������
    opt opt_option_list_t := opt_option_list_t(
      moduleName => Exp_ModuleName
    );

    -- ���� �������� ���������
    changeFlag integer;

  -- testNumberList
  begin
    pkg_TestUtility.beginTest( 'testOptionList: number list');

    -- addNumberList: �������� � ������������ � �������� ���������
    opt.addNumberList(
      optionShortName         => 'TimeoutList'
      , optionName            => '��������'
      , optionDescription     =>
          '�������� ( � �������� � ������������ ���������)'
      , prodValueList         => '1.31,,31'
      , testValueList         => '1.81'
      , listSeparator         => ','
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Number_ValueTypeCode
      , optionShortName       => 'TimeoutList'
      , optionName            => '��������'
      , optionDescription     =>
          '�������� ( � �������� � ������������ ���������)'
      , testProdSensitiveFlag => 1
      , listSeparator         => ';'
      , stringValue           => '1.31;;31'
      , testListSeparator     => ';'
      , testStringValue       => '1.81'
    );

    -- ���������� � ���������� ��������, ���� �������� ����������
    opt.addNumberList(
      optionShortName         => 'TimeoutList'
      , optionName            => '�������� (1)'
      , optionDescription     =>
          '�������� ( � �������� � ������������ ���������) (1)'
      , prodValueList         => '1.3,,3'
      , testValueList         => '1.8'
      , listSeparator         => ','
      , changeValueFlag       => 1
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Number_ValueTypeCode
      , optionShortName       => 'TimeoutList'
      , optionName            => '��������'
      , optionDescription     =>
          '�������� ( � �������� � ������������ ���������)'
      , listSeparator         => ';'
      , stringValue           => '1.3;;3'
      , testListSeparator     => ';'
      , testStringValue       => '1.8'
    );

    -- �������� �� ������ ����������, �.�. ��� ����������
    opt.addNumberList(
      optionShortName         => 'TimeoutList'
      , optionName            => '�������� (2)'
      , optionDescription     =>
          '�������� ( � �������� � ������������ ���������) (2)'
      , prodValueList         => '1.39,,39'
      , testValueList         => '1.89'
      , listSeparator         => ','
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Number_ValueTypeCode
      , optionShortName       => 'TimeoutList'
      , optionName            => '��������'
      , optionDescription     =>
          '�������� ( � �������� � ������������ ���������)'
      , listSeparator         => ';'
      , stringValue           => '1.3;;3'
      , testListSeparator     => ';'
      , testStringValue       => '1.8'
    );

    -- getValueCount
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount( 'TimeoutList', prodValueFlag => 1)
      , expectedString    => '3'
      , failMessageText   =>
          '����������� ����� ����. �������� �������� � getValueCount'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount( 'TimeoutList', prodValueFlag => 0)
      , expectedString    => '1'
      , failMessageText   =>
          '����������� ����� �������� �������� �������� � getValueCount'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount( 'TimeoutList')
      , expectedString    => case when isProduction = 1 then '3' else '1' end
      , failMessageText   =>
          '����������� ����� ������������ �������� �������� � getValueCount'
    );

    -- getNumber
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber( 'TimeoutList', prodValueFlag => 1)
      , expectedString    => 1.3
      , failMessageText   =>
          '����������� ����. �������� � getNumber'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber( 'TimeoutList', prodValueFlag => 1, valueIndex => 2)
      , expectedString    => ''
      , failMessageText   =>
          '����������� ����. �������� #2 � getNumber'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber( 'TimeoutList', prodValueFlag => 1, valueIndex => 3)
      , expectedString    => 3
      , failMessageText   =>
          '����������� ����. �������� #3 � getNumber'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber( 'TimeoutList', prodValueFlag => 0)
      , expectedString    => 1.8
      , failMessageText   =>
          '����������� �������� �������� � getNumber'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber( 'TimeoutList', valueIndex => 1)
      , expectedString    =>
          case when isProduction = 1
            then 1.3
            else 1.8
          end
      , failMessageText   =>
          '����������� ������������ �������� � getNumber'
    );

    -- ��������� �������� ��� �������� ��������������� �������
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutList'
            , prodValueFlag       => 0
            , valueIndex          => 888
          )
      , expectedString    => null
      , failMessageText   =>
          'getNumber:'
          || ' ������������ ��������� ��� �������������� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutList'
            , valueIndex          => 888
          )
      , expectedString    => null
      , failMessageText   =>
          'getNumber( USED):'
          || ' ������������ ��������� ��� �������������� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutList'
            , prodValueFlag       => 0
            , valueIndex          => 888
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getNumber: raise=0:'
          || ' ������������ ��������� ��� �������������� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutList'
            , valueIndex          => 888
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getNumber( USED): raise=0:'
          || ' ������������ ��������� ��� �������������� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutList'
            , prodValueFlag       => 0
            , valueIndex          => 888
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getNumber: raise=1:'
          || ' ������������ ��������� ��� �������������� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getNumber(
            'TimeoutList'
            , valueIndex          => 888
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getNumber( USED): raise=1:'
          || ' ������������ ��������� ��� �������������� �������'
    );

    -- setNumber
    opt.setNumber(
      optionShortName         => 'TimeoutList'
      , prodValueFlag         => 1
      , numberValue           => 4.9
      , valueIndex            => 2
    );
    checkOptionValue(
      optionShortName         => 'TimeoutList'
      , stringValue           =>
          '1.3;4.9;3'
      , testStringValue       =>
          '1.8'
    );
    opt.setNumber(
      optionShortName         => 'TimeoutList'
      , prodNumberValue       => null
      , testNumberValue       => null
      , valueIndex            => 5
    );
    checkOptionValue(
      optionShortName         => 'TimeoutList'
      , stringValue           =>
          '1.3;4.9;3;;'
      , testStringValue       =>
          '1.8;;;;'
    );
    opt.setNumber(
      optionShortName         => 'TimeoutList'
      , prodNumberValue       => 3.5
      , testNumberValue       => 3.3
      , valueIndex            => 0
    );
    checkOptionValue(
      optionShortName         => 'TimeoutList'
      , stringValue           =>
          '3.5;1.3;4.9;3;;'
      , testStringValue       =>
          '3.3;1.8;;;;'
    );
    opt.setNumber(
      optionShortName         => 'TimeoutList'
      , numberValue           => 5.8
      , valueIndex            => -1
    );
    checkOptionValue(
      optionShortName         => 'TimeoutList'
      , stringValue           =>
          '3.5;1.3;4.9;3;;'
          || case when isProduction = 1 then ';5.8' end
      , testStringValue       =>
          '3.3;1.8;;;;'
          || case when isProduction = 0 then ';5.8' end
    );

    -- setNumber - ���� ������
    opt.setNumber(
      optionShortName         => 'TimeoutList'
      , prodNumberValue       => 3.9
      , testNumberValue       => 3.8
      , valueIndex            => null
    );
    checkOptionValue(
      optionShortName         => 'TimeoutList'
      , stringValue           => '3.9'
      , testStringValue       => '3.8'
    );
    opt.setNumber(
      optionShortName         => 'TimeoutList'
      , numberValue           => 3.1
      , valueIndex            => null
    );
    checkOptionValue(
      optionShortName         => 'TimeoutList'
      , stringValue           =>
          case when isProduction = 1
            then '3.1'
            else '3.9'
          end
      , testStringValue       =>
          case when isProduction = 0
            then '3.1'
            else '3.8'
          end
    );

    -- ��������� setValue
    changeFlag := opt.setValue(
      optionShortName       => 'TimeoutList'
      , prodValueFlag       => 0
      , stringValue         => '4.89,0.930'
      , setValueListFlag    => 1
      , listSeparator       => ','
      , skipIfNoChangeFlag  => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'setValue( NUM_LIST): ������������ �������� ��� ������� ���������'
    );
    checkOptionValue(
      optionShortName         => 'TimeoutList'
      , testStringValue       => '4.89;.93'
      , testListSeparator     => ';'
    );
    changeFlag := opt.setValue(
      optionShortName       => 'TimeoutList'
      , prodValueFlag       => 0
      , stringValue         => '4.89,.93'
      , setValueListFlag    => 1
      , listSeparator       => ','
      , skipIfNoChangeFlag  => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 0
      , failMessageText   =>
          'setValue( NUM_LIST): ������������ �������� ��� ���������� ���������'
    );

    changeFlag := opt.setValue(
      optionShortName       => 'TimeoutList'
      , prodValueFlag       => 0
      , stringValue         => '4.89;0.93'
      , setValueListFlag    => 1
      , skipIfNoChangeFlag  => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 0
      , failMessageText   =>
          'setValue( NUM_LIST): ������������ �������� ��� ��������� �����������'
    );
    checkOptionValue(
      optionShortName         => 'TimeoutList'
      , testStringValue       => '4.89;.93'
      , testListSeparator     => ';'
    );

    changeFlag := opt.setValue(
      optionShortName       => 'TimeoutList'
      , prodValueFlag       => 0
      , stringValue         => '4.89;.93'
      , setValueListFlag    => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'setValue( NUM_LIST): ������������ �������� ��� ���������'
    );

    -- setValueList
    opt.setValueList(
      optionShortName         => 'TimeoutList'
      , valueList             => '31,21'
      , listSeparator         => ','
    );
    checkOptionValue(
      optionShortName         => 'TimeoutList'
      , usedStringValue       => '31;21'
    );
    opt.setValueList(
      optionShortName         => 'TimeoutList'
      , prodValueList         => '38,5 80'
      , testValueList         => '2012'
      , listSeparator         => ' '
      , decimalChar           => ','
    );
    checkOptionValue(
      optionShortName         => 'TimeoutList'
      , stringValue           => '38.5;80'
      , testStringValue       => '2012'
    );
    opt.setValueList(
      optionShortName         => 'TimeoutList'
      , prodValueFlag         => 1
      , valueList             => '25745452954832'
    );
    checkOptionValue(
      optionShortName         => 'TimeoutList'
      , stringValue           => '25745452954832'
      , testStringValue       => '2012'
    );
    opt.setValueList(
      optionShortName         => 'TimeoutList'
      , prodValueFlag         => 0
      , valueList             => '118,5 0,39'
      , listSeparator         => ' '
      , decimalChar           => ','
    );
    checkOptionValue(
      optionShortName         => 'TimeoutList'
      , stringValue           => '25745452954832'
      , testStringValue       => '118.5;.39'
    );

    -- getValueList
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList( 'TimeoutList', prodValueFlag => 1)
      , expectedString    => '25745452954832'
      , failMessageText   =>
          '����������� ����. �������� � getValueList'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList( 'TimeoutList', prodValueFlag => 0)
      , expectedString    => '118.5;.39'
      , failMessageText   =>
          '����������� �������� �������� � getValueList'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList( 'TimeoutList')
      , expectedString    =>
          case isProduction
            when 1 then '25745452954832'
            when 0 then '118.5;.39'
          end
      , failMessageText   =>
          '����������� ������������ �������� � getValueList'
    );

    -- getValueListSeparator
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator( 'TimeoutList', prodValueFlag => 1)
      , expectedString    => ';'
      , failMessageText   =>
          '����������� ����. �������� � getValueListSeparator'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator( 'TimeoutList', prodValueFlag => 0)
      , expectedString    => ';'
      , failMessageText   =>
          '����������� �������� �������� � getValueListSeparator'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator( 'TimeoutList')
      , expectedString    => ';'
      , failMessageText   =>
          '����������� ������������ �������� � getValueListSeparator'
    );

    -- addNumberList: �������� � ����� ���������
    opt.addNumberList(
      optionShortName         => 'PriorityList'
      , optionName            => '������ �����������'
      , optionDescription     => '������ ����������� ( � ����� ���������)'
      , valueList             => '10 8 19'
      , listSeparator         => ' '
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.Number_ValueTypeCode
      , optionShortName       => 'PriorityList'
      , optionName            => '������ �����������'
      , optionDescription     => '������ ����������� ( � ����� ���������)'
      , testProdSensitiveFlag => 0
      , listSeparator         => ';'
      , stringValue           => '10;8;19'
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ������ �������� ��������.'
        )
      , true
    );
  end testNumberList;



  /*
    ������������ ��������� �� ������� ��������� ��������.
  */
  procedure testStringList
  is

    -- ����� ������
    opt opt_option_list_t := opt_option_list_t(
      moduleName => Exp_ModuleName
    );

    -- ���� �������� ���������
    changeFlag integer;

  -- testStringList
  begin
    pkg_TestUtility.beginTest( 'testOptionList: string list');

    -- addStringList: �������� � ������������ � �������� ���������
    opt.addStringList(
      optionShortName         => 'BatchList'
      , optionName            => '������ ������'
      , optionDescription     =>
          '������ ������ ( � �������� � ������������ ���������)'
      , prodValueList         => 'ClearOld1,,RestartTask1'
      , testValueList         => 'TestBatch1'
      , listSeparator         => ','
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.String_ValueTypeCode
      , optionShortName       => 'BatchList'
      , optionName            => '������ ������'
      , optionDescription     =>
          '������ ������ ( � �������� � ������������ ���������)'
      , testProdSensitiveFlag => 1
      , listSeparator         => ','
      , stringValue           => 'ClearOld1,,RestartTask1'
      , testListSeparator     => ','
      , testStringValue       => 'TestBatch1'
    );

    -- ���������� � ���������� ��������, ���� �������� ����������
    opt.addStringList(
      optionShortName         => 'BatchList'
      , optionName            => '������ ������ (1)'
      , optionDescription     =>
          '������ ������ ( � �������� � ������������ ���������) (1)'
      , prodValueList         => 'ClearOld,,RestartTask'
      , testValueList         => 'TestBatch'
      , listSeparator         => ','
      , changeValueFlag       => 1
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , optionName            => '������ ������'
      , optionDescription     =>
          '������ ������ ( � �������� � ������������ ���������)'
      , listSeparator         => ','
      , stringValue           => 'ClearOld,,RestartTask'
      , testListSeparator     => ','
      , testStringValue       => 'TestBatch'
    );

    -- �������� �� ������ ����������, �.�. ��� ����������
    opt.addStringList(
      optionShortName         => 'BatchList'
      , optionName            => '������ ������ (2)'
      , optionDescription     =>
          '������ ������ ( � �������� � ������������ ���������) (2)'
      , prodValueList         => 'ClearOld2,,RestartTask2'
      , testValueList         => 'TestBatch2'
      , listSeparator         => ','
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , optionName            => '������ ������'
      , optionDescription     =>
          '������ ������ ( � �������� � ������������ ���������)'
      , listSeparator         => ','
      , stringValue           => 'ClearOld,,RestartTask'
      , testListSeparator     => ','
      , testStringValue       => 'TestBatch'
    );

    -- getValueCount
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount( 'BatchList', prodValueFlag => 1)
      , expectedString    => 3
      , failMessageText   =>
          '����������� ����� ����. ��������� �������� � getValueCount'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount( 'BatchList', prodValueFlag => 0)
      , expectedString    => '1'
      , failMessageText   =>
          '����������� ����� �������� ��������� �������� � getValueCount'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueCount( 'BatchList')
      , expectedString    => case when isProduction = 1 then 3 else 1 end
      , failMessageText   =>
          '����������� ����� ������������ ��������� �������� � getValueCount'
    );

    -- getString
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString( 'BatchList', prodValueFlag => 1)
      , expectedString    => 'ClearOld'
      , failMessageText   =>
          '����������� ����. �������� � getString'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString( 'BatchList', prodValueFlag => 1, valueIndex => 2)
      , expectedString    => ''
      , failMessageText   =>
          '����������� ����. �������� #2 � getString'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString( 'BatchList', prodValueFlag => 1, valueIndex => 3)
      , expectedString    => 'RestartTask'
      , failMessageText   =>
          '����������� ����. �������� #3 � getString'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString( 'BatchList', prodValueFlag => 0)
      , expectedString    => 'TestBatch'
      , failMessageText   =>
          '����������� �������� �������� � getString'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString( 'BatchList', valueIndex => 1)
      , expectedString    =>
          case when isProduction = 1
            then 'ClearOld'
            else 'TestBatch'
          end
      , failMessageText   =>
          '����������� ������������ �������� � getString'
    );

    -- ��������� �������� ��� �������� ��������������� �������
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'BatchList'
            , prodValueFlag       => 0
            , valueIndex          => 888
          )
      , expectedString    => null
      , failMessageText   =>
          'getString:'
          || ' ������������ ��������� ��� �������������� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'BatchList'
            , valueIndex          => 888
          )
      , expectedString    => null
      , failMessageText   =>
          'getString( USED):'
          || ' ������������ ��������� ��� �������������� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'BatchList'
            , prodValueFlag       => 0
            , valueIndex          => 888
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getString: raise=0:'
          || ' ������������ ��������� ��� �������������� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'BatchList'
            , valueIndex          => 888
            , raiseNotFoundFlag   => 0
          )
      , expectedString    => null
      , failMessageText   =>
          'getString( USED): raise=0:'
          || ' ������������ ��������� ��� �������������� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'BatchList'
            , prodValueFlag       => 0
            , valueIndex          => 888
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getString: raise=1:'
          || ' ������������ ��������� ��� �������������� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getString(
            'BatchList'
            , valueIndex          => 888
            , raiseNotFoundFlag   => 1
          )
      , expectedString    => null
      , failMessageText   =>
          'getString( USED): raise=1:'
          || ' ������������ ��������� ��� �������������� �������'
    );

    -- setString
    opt.setString(
      optionShortName         => 'BatchList'
      , prodValueFlag         => 1
      , stringValue           => 'CopyData'
      , valueIndex            => 2
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , stringValue           =>
          'ClearOld,CopyData,RestartTask'
      , testStringValue       =>
          'TestBatch'
    );
    opt.setString(
      optionShortName         => 'BatchList'
      , prodStringValue       => null
      , testStringValue       => null
      , valueIndex            => 5
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , stringValue           =>
          'ClearOld,CopyData,RestartTask,,'
      , testStringValue       =>
          'TestBatch,,,,'
    );
    opt.setString(
      optionShortName         => 'BatchList'
      , prodStringValue       => 'CheckData'
      , testStringValue       => 'CheckTest'
      , valueIndex            => 0
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , stringValue           =>
          'CheckData,ClearOld,CopyData,RestartTask,,'
      , testStringValue       =>
          'CheckTest,TestBatch,,,,'
    );
    opt.setString(
      optionShortName         => 'BatchList'
      , stringValue           => 'LoadCustomer'
      , valueIndex            => -1
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , stringValue           =>
          'CheckData,ClearOld,CopyData,RestartTask,,'
          || case when isProduction = 1 then ',LoadCustomer' end
      , testStringValue       =>
          'CheckTest,TestBatch,,,,'
          || case when isProduction = 0 then ',LoadCustomer' end
    );

    -- setString - ���� ������
    opt.setString(
      optionShortName         => 'BatchList'
      , prodStringValue       => 'LoadClient'
      , testStringValue       => 'LoadContract'
      , valueIndex            => null
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , stringValue           => 'LoadClient'
      , testStringValue       => 'LoadContract'
    );
    opt.setString(
      optionShortName         => 'BatchList'
      , stringValue           => 'LoadCard'
      , valueIndex            => null
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , stringValue           =>
          case when isProduction = 1
            then 'LoadCard'
            else 'LoadClient'
          end
      , testStringValue       =>
          case when isProduction = 0
            then 'LoadCard'
            else 'LoadContract'
          end
    );

    -- ��������� setValue
    changeFlag := opt.setValue(
      optionShortName       => 'BatchList'
      , prodValueFlag       => 0
      , stringValue         => 'LoadData1,LoadData2'
      , setValueListFlag    => 1
      , listSeparator       => ','
      , skipIfNoChangeFlag  => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'setValue( STR_LIST): ������������ �������� ��� ������� ���������'
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , testStringValue       => 'LoadData1,LoadData2'
      , testListSeparator     => ','
    );
    changeFlag := opt.setValue(
      optionShortName       => 'BatchList'
      , prodValueFlag       => 0
      , stringValue         => 'LoadData1,LoadData2'
      , setValueListFlag    => 1
      , listSeparator       => ','
      , skipIfNoChangeFlag  => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 0
      , failMessageText   =>
          'setValue( STR_LIST): ������������ �������� ��� ���������� ���������'
    );

    changeFlag := opt.setValue(
      optionShortName       => 'BatchList'
      , prodValueFlag       => 0
      , stringValue         => 'LoadData1;LoadData2'
      , setValueListFlag    => 1
      , skipIfNoChangeFlag  => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'setValue( STR_LIST): ������������ �������� ��� ��������� �����������'
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , testStringValue       => 'LoadData1;LoadData2'
      , testListSeparator     => ';'
    );

    changeFlag := opt.setValue(
      optionShortName       => 'BatchList'
      , prodValueFlag       => 0
      , stringValue         => 'LoadData1;LoadData2'
      , setValueListFlag    => 1
    );
    pkg_TestUtility.compareChar(
      actualString        => changeFlag
      , expectedString    => 1
      , failMessageText   =>
          'setValue( STR_LIST): ������������ �������� ��� ���������'
    );

    -- setValueList
    opt.setValueList(
      optionShortName         => 'BatchList'
      , valueList             => 'SendData,GetData'
      , listSeparator         => ','
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , usedStringValue       => 'SendData,GetData'
    );
    opt.setValueList(
      optionShortName         => 'BatchList'
      , prodValueList         => 'LoadHandler SendHandler'
      , testValueList         => 'CheckHandler'
      , listSeparator         => ' '
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , stringValue           => 'LoadHandler SendHandler'
      , testStringValue       => 'CheckHandler'
    );
    opt.setValueList(
      optionShortName         => 'BatchList'
      , prodValueFlag         => 1
      , valueList             => 'SendMail'
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , stringValue           => 'SendMail'
      , testStringValue       => 'CheckHandler'
    );
    opt.setValueList(
      optionShortName         => 'BatchList'
      , prodValueFlag         => 0
      , valueList             => 'TestBatch RestartBatch'
      , listSeparator         => ' '
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , stringValue           => 'SendMail'
      , testStringValue       => 'TestBatch RestartBatch'
    );

    -- getValueList
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList( 'BatchList', prodValueFlag => 1)
      , expectedString    => 'SendMail'
      , failMessageText   =>
          '����������� ����. �������� � getValueList'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList( 'BatchList', prodValueFlag => 0)
      , expectedString    => 'TestBatch RestartBatch'
      , failMessageText   =>
          '����������� �������� �������� � getValueList'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueList( 'BatchList')
      , expectedString    =>
          case isProduction
            when 1 then 'SendMail'
            when 0 then 'TestBatch RestartBatch'
          end
      , failMessageText   =>
          '����������� ������������ �������� � getValueList'
    );

    -- getValueListSeparator
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator( 'BatchList', prodValueFlag => 1)
      , expectedString    => ';'
      , failMessageText   =>
          '����������� ����. �������� � getValueListSeparator'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator( 'BatchList', prodValueFlag => 0)
      , expectedString    => ' '
      , failMessageText   =>
          '����������� �������� �������� � getValueListSeparator'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getValueListSeparator( 'BatchList')
      , expectedString    =>
          case isProduction
            when 1 then ';'
            when 0 then ' '
          end
      , failMessageText   =>
          '����������� ������������ �������� � getValueListSeparator'
    );

    -- updateOption c moveProdSensitiveValueFlag
    opt.setValueList(
      optionShortName         => 'BatchList'
      , prodValueList         => 'ProdBatch,ProdBatch9'
      , testValueList         => 'TestBatch,TestBatch9'
      , listSeparator         => ','
    );
    opt.updateOption(
      optionShortName               => 'BatchList'
      , testProdSensitiveFlag       => 0
      , moveProdSensitiveValueFlag  => 1
      , deleteBadValueFlag          => 1
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , testProdSensitiveFlag => 0
      , stringValue           => 'ProdBatch,ProdBatch9'
      , listSeparator         => ','
    );
    opt.updateOption(
      optionShortName               => 'BatchList'
      , testProdSensitiveFlag       => 1
      , moveProdSensitiveValueFlag  => 1
    );
    checkOptionValue(
      optionShortName         => 'BatchList'
      , testProdSensitiveFlag => 1
      , stringValue           => 'ProdBatch,ProdBatch9'
      , listSeparator         => ','
    );

    -- addStringList: �������� � ����� ���������
    opt.addStringList(
      optionShortName         => 'FieldList'
      , optionName            => '������ �����'
      , optionDescription     => '������ ����� ( � ����� ���������)'
      , valueList             => 'varName,varPosition,varValue'
      , listSeparator         => ','
    );
    checkOptionValue(
      valueTypeCode           => pkg_OptionMain.String_ValueTypeCode
      , optionShortName       => 'FieldList'
      , optionName            => '������ �����'
      , optionDescription     => '������ ����� ( � ����� ���������)'
      , testProdSensitiveFlag => 0
      , listSeparator         => ','
      , stringValue           => 'varName,varPosition,varValue'
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ������ ��������� ��������.'
        )
      , true
    );
  end testStringList;



  /*
    ������������ ���������� �������
  */
  procedure testObjectOption
  is

    -- ����� ������
    opt opt_option_list_t := opt_option_list_t(
      moduleName => Exp_ModuleName
    );

    -- ��������� ��������
    ob1 opt_option_list_t;
    ob2 opt_option_list_t;
    ob3 opt_option_list_t;

    nChanged integer;

    nOption integer;

  -- testObjectOption
  begin
    pkg_TestUtility.beginTest( 'testOptionList: option for object');

    pkg_TestUtility.compareChar(
      actualString        => opt.getObjectShortName()
      , expectedString    => null
      , failMessageText   =>
          '������������ ��������� getObjectShortName()'
    );
    pkg_TestUtility.compareChar(
      actualString        => opt.getObjectTypeId()
      , expectedString    => null
      , failMessageText   =>
          '������������ ��������� getObjectTypeId()'
    );

    -- ������� ��� �������
    nChanged := opt.mergeObjectType(
      objectTypeShortName => 'smtpServer'
      , objectTypeName    => 'SMTP-������'
    );
    pkg_TestUtility.compareChar(
      actualString        => nChanged
      , expectedString    => 1
      , failMessageText   =>
          '������������ ��������� mergeObjectType ��� ���������� ����'
    );
    checkObjectType(
      objectTypeShortName => 'smtpServer'
      , objectTypeId      => opt.getObjectTypeId( 'smtpServer')
      , objectTypeName    => 'SMTP-������'
    );

    -- ��������� ��� �������
    nChanged := opt.mergeObjectType(
      objectTypeShortName => 'smtpServer'
      , objectTypeName    => 'SMTP-������ ( �������� �����)'
    );
    pkg_TestUtility.compareChar(
      actualString        => nChanged
      , expectedString    => 1
      , failMessageText   =>
          '������������ ��������� mergeObjectType ��� ��������� ����'
    );
    checkObjectType(
      objectTypeShortName => 'smtpServer'
      , objectTypeName    => 'SMTP-������ ( �������� �����)'
    );
    nChanged := opt.mergeObjectType(
      objectTypeShortName => 'smtpServer'
      , objectTypeName    => 'SMTP-������ ( �������� �����)'
    );
    pkg_TestUtility.compareChar(
      actualString        => nChanged
      , expectedString    => 0
      , failMessageText   =>
          '������������ ��������� mergeObjectType ��� ���������� ���������'
    );

    ob1 := opt_option_list_t(
      moduleName            => Exp_ModuleName
      , objectShortName     => 'Internal'
      , objectTypeShortName => 'smtpServer'
    );
    pkg_TestUtility.compareChar(
      actualString        => ob1.getObjectShortName()
      , expectedString    => 'Internal'
      , failMessageText   =>
          '������������ ��������� getObjectShortName() ��� 1-�� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        => ob1.getObjectTypeId()
      , expectedString    => opt.getObjectTypeId( 'smtpServer')
      , failMessageText   =>
          '������������ ��������� getObjectTypeId() ��� 1-�� �������'
    );

    ob2 := opt_option_list_t(
      moduleName            => Exp_ModuleName
      , objectShortName     => 'Reserve'
      , objectTypeShortName => 'smtpServer'
    );

    opt.addString(
      optionShortName         => 'ServerName'
      , optionName            => '�������� ������ ( �����)'
      , stringValue           => 'default.company.ru'
    );
    opt.addString(
      optionShortName         => 'UsedServer'
      , optionName            => '������������ � �� ������'
      , stringValue           => 'Internal'
    );

    ob1.addString(
      optionShortName         => 'ServerName'
      , optionName            => '�������� ������ ( ����������)'
      , stringValue           => 'internal.company.ru'
    );
    checkOptionValue(
      optionShortName         => 'ServerName'
      , objectShortName       => 'Internal'
      , objectTypeId          => ob1.getObjectTypeId()
      , optionName            => '�������� ������ ( ����������)'
      , stringValue           => 'internal.company.ru'
    );
    ob1.addString(
      optionShortName         => 'AddressMask'
      , optionName            => '����� ��� ������� ( ���������� ������)'
      , stringValue           => '*.company.ru'
    );
    ob1.addString(
      optionShortName         => 'InternalData'
      , optionName            => '������ ( ���������� ������)'
      , stringValue           => '1,2'
    );

    ob2.addString(
      optionShortName         => 'ServerName'
      , optionName            => '�������� ������ ( ���������)'
      , stringValue           => 'reserve.company.ru'
    );
    checkOptionValue(
      optionShortName         => 'ServerName'
      , objectShortName       => 'Reserve'
      , objectTypeId          => ob2.getObjectTypeId()
      , optionName            => '�������� ������ ( ���������)'
      , stringValue           => 'reserve.company.ru'
    );
    ob2.addString(
      optionShortName         => 'AddressMask'
      , optionName            => '����� ��� ������� ( ��������� ������)'
      , stringValue           => '*'
    );

    pkg_TestUtility.compareChar(
      actualString        => opt.getString( 'ServerName')
      , expectedString    => 'default.company.ru'
      , failMessageText   => '������������ �������� �� ������ ������'
    );
    pkg_TestUtility.compareChar(
      actualString        => opt.getString( 'UsedServer')
      , expectedString    => 'Internal'
      , failMessageText   => '������������ �������� �� ������ ������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getOptionId( 'AddressMask', raiseNotFoundFlag => 0)
      , expectedString    => ''
      , failMessageText   =>
          '�������� ������� ���������� ����� �� ������ ������'
    );

    pkg_TestUtility.compareChar(
      actualString        => ob1.getString( 'ServerName')
      , expectedString    => 'internal.company.ru'
      , failMessageText   => '������������ �������� ��� 1-�� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        => ob1.getString( 'AddressMask')
      , expectedString    => '*.company.ru'
      , failMessageText   => '������������ �������� ��� 1-�� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        => ob1.getString( 'InternalData')
      , expectedString    => '1,2'
      , failMessageText   => '������������ �������� ��� 1-�� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          ob1.getOptionId( 'UsedServer', raiseNotFoundFlag => 0)
      , expectedString    => ''
      , failMessageText   =>
          '�������� ������ ���������� ����� �� ������ 1-�� �������'
    );

    pkg_TestUtility.compareChar(
      actualString        => ob2.getString( 'ServerName')
      , expectedString    => 'reserve.company.ru'
      , failMessageText   => '������������ �������� ��� 2-�� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        => ob2.getString( 'AddressMask')
      , expectedString    => '*'
      , failMessageText   => '������������ �������� ��� 2-�� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          ob2.getOptionId( 'UsedServer', raiseNotFoundFlag => 0)
      , expectedString    => ''
      , failMessageText   =>
          '�������� ������ ���������� ����� �� ������ 2-�� �������'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          ob2.getOptionId( 'InternalData', raiseNotFoundFlag => 0)
      , expectedString    => ''
      , failMessageText   =>
          '�������� 1-�� ������� ���������� ����� �� ������ 2-�� �������'
    );


    select
      count(*)
    into nOption
    from
      table( ob1.getOptionValue())
    ;
    pkg_TestUtility.compareChar(
      actualString        => nOption
      , expectedString    => 3
      , failMessageText   =>
          'ob1.getOptionValue(): ����������� ����� ������� � �������'
    );
    select
      count(*)
    into nOption
    from
      table( ob2.getOptionValue())
    ;
    pkg_TestUtility.compareChar(
      actualString        => nOption
      , expectedString    => 2
      , failMessageText   =>
          'ob2.getOptionValue(): ����������� ����� ������� � �������'
    );

    -- �������� ���� ����������
    ob2.deleteAll();
    select
      count(*)
    into nOption
    from
      table( ob2.getOptionValue())
    ;
    pkg_TestUtility.compareChar(
      actualString        => nOption
      , expectedString    => 0
      , failMessageText   =>
          'ob2.deleteAll(): �� ��� ��������� �������'
    );
    select
      count(*)
    into nOption
    from
      table( ob1.getOptionValue())
    ;
    pkg_TestUtility.compareChar(
      actualString        => nOption
      , expectedString    => 3
      , failMessageText   =>
          'ob2.deleteAll(): ������� ��������� ������� �������'
    );

    -- ������� � ������� ��� ������� ( ��� ����������)
    nChanged := opt.mergeObjectType(
      objectTypeShortName => 'smtpServer_del'
      , objectTypeName    => 'SMTP-������ ( �������� �����)'
    );
    opt.deleteObjectType(
      objectTypeShortName => 'smtpServer_del'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getObjectTypeId( 'smtpServer_del', raiseNotFoundFlag => 0)
      , expectedString    => ''
      , failMessageText   =>
          '��������� Id ����� ��������� ���������� ���� �������'
    );

    -- ������� � ������� ��� ������� ( � ��������� ��������� ����������)
    nChanged := opt.mergeObjectType(
      objectTypeShortName => 'smtpServer_tmp'
      , objectTypeName    => 'SMTP-������ ( �������� �����)'
    );
    ob3 := opt_option_list_t(
      moduleName            => Exp_ModuleName
      , objectShortName     => 'Tmp'
      , objectTypeShortName => 'smtpServer_tmp'
    );
    ob3.addString(
      optionShortName       => 'ServerName'
      , optionName          => '��� �������'
    );
    ob3.deleteOption(
      optionShortName       => 'ServerName'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          ob3.getOptionId( 'ServerName', raiseNotFoundFlag => 0)
      , expectedString    => ''
      , failMessageText   =>
          '��������� Id ����� ��������� ���������� ��������� 3-�� �������'
    );
    opt.deleteObjectType(
      objectTypeShortName => 'smtpServer_tmp'
    );
    pkg_TestUtility.compareChar(
      actualString        =>
          opt.getObjectTypeId( 'smtpServer_tmp', raiseNotFoundFlag => 0)
      , expectedString    => ''
      , failMessageText   =>
          '��������� Id ����� ��������� ���������� ���� �������'
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ���������� �������.'
        )
      , true
    );
  end testObjectOption;



  /*
    ������������ ���������� PL/SQL �������
  */
  procedure testPlsqlObjectOption
  is

    -- ����� PL/SQL �������
    opt opt_plsql_object_option_t;

    plsqlObjectTypeId integer;

  -- testPlsqlObjectOption
  begin
    pkg_TestUtility.beginTest(
      'testOptionList: option for PL/SQL object'
    );

    plsqlObjectTypeId :=
      opt_option_list_t( pkg_OptionMain.Module_SvnRoot)
        .getObjectTypeId( pkg_OptionMain.PlsqlObject_ObjTypeSName)
    ;

    opt := opt_plsql_object_option_t(
      moduleName            => Exp_ModuleName
      , objectName          => 'pkg_TestPackage'
    );
    pkg_TestUtility.compareChar(
      actualString        => opt.getObjectTypeId()
      , expectedString    => plsqlObjectTypeId
      , failMessageText   =>
          '������������ ��������� getObjectTypeId()'
    );

    opt.addString(
      optionShortName         => 'DefaultServerName'
      , optionName            => '�������� ������ ( �� ���������)'
      , stringValue           => 'default.company.ru'
    );
    checkOptionValue(
      optionShortName         => 'DefaultServerName'
      , objectShortName       => 'pkg_TestPackage'
      , objectTypeId          => plsqlObjectTypeId
      , optionName            => '�������� ������ ( �� ���������)'
      , stringValue           => 'default.company.ru'
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ���������� PL/SQL �������.'
        )
      , true
    );
  end testPlsqlObjectOption;



  /*
    ������������ ������� �������� ��� ��������� ���������.
  */
  procedure testOperatorValue
  is

    -- ����� ������
    opt opt_option_list_t := opt_option_list_t(
      moduleName => Exp_ModuleName
    );

    -- ��������� ��� ����������
    op1 opt_option_list_t;
    op2 opt_option_list_t;
    op3 opt_option_list_t;

    nChanged integer;

    nOption integer;

  -- testOperatorValue
  begin
    pkg_TestUtility.beginTest( 'testOptionList: value for operator');

    pkg_TestUtility.compareChar(
      actualString        => opt.getUsedOperatorId()
      , expectedString    => null
      , failMessageText   =>
          '������������ ��������� getUsedOperatorId()'
    );

    op1 := opt_option_list_t(
      moduleName            => Exp_ModuleName
      , usedOperatorId      => 5
    );
    pkg_TestUtility.compareChar(
      actualString        => op1.getUsedOperatorId()
      , expectedString    => 5
      , failMessageText   =>
          '������������ ��������� getUsedOperatorId()'
    );

    op2 := opt_option_list_t(
      moduleName            => Exp_ModuleName
      , usedOperatorId      => 1
    );

    opt.addString(
      optionShortName         => 'NotifyEmail'
      , optionName            => '�������� ����� ��� �����������'
      , stringValue           => 'alert@company.ru'
    );

    pkg_TestUtility.compareChar(
      actualString        => op1.getString( 'NotifyEmail')
      , expectedString    => 'alert@company.ru'
      , failMessageText   => 'op1.getString: ������������ ��������'
    );
    op1.setString( 'NotifyEmail', 'user1@company.ru');
    checkOptionValue(
      optionShortName         => 'NotifyEmail'
      , usedOperatorId        => 5
      , valueId               => op1.getValueId( 'NotifyEmail')
      , stringValue           => 'user1@company.ru'
    );
    pkg_TestUtility.compareChar(
      actualString        => op1.getString( 'NotifyEmail')
      , expectedString    => 'user1@company.ru'
      , failMessageText   => 'op1.getString: ������������ ��������'
    );
    select
      count(*)
    into nOption
    from
      table( op1.getOptionValue()) t
    where
      t.option_short_name = 'NotifyEmail'
      and t.used_operator_id = 5
      and t.string_value = 'user1@company.ru'
    ;
    pkg_TestUtility.compareChar(
      actualString        => nOption
      , expectedString    => 1
      , failMessageText   => 'op1.getOptionValue: ������������ ������'
    );
    op1.addString(
      optionShortName         => 'UsedDB'
      , optionName            => '������������ ��'
      , stringValue           => 'User1-DB'
    );
    pkg_TestUtility.compareChar(
      actualString        => op1.getString( 'UsedDB')
      , expectedString    => 'User1-DB'
      , failMessageText   => 'op1.getString: ������������ ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        => opt.getString( 'UsedDB')
      , expectedString    => ''
      , failMessageText   => 'opt.getString: ������������ ��������'
    );

    pkg_TestUtility.compareChar(
      actualString        => op2.getString( 'NotifyEmail')
      , expectedString    => 'alert@company.ru'
      , failMessageText   => 'op2.getString: ������������ ��������'
    );
    op2.setString( 'NotifyEmail', 'user2@company.ru');
    pkg_TestUtility.compareChar(
      actualString        => op2.getString( 'NotifyEmail')
      , expectedString    => 'user2@company.ru'
      , failMessageText   => 'op2.getString: ������������ ��������'
    );
    pkg_TestUtility.compareChar(
      actualString        => op1.getString( 'NotifyEmail')
      , expectedString    => 'user1@company.ru'
      , failMessageText   => 'op1.getString(2): ������������ ��������'
    );
    op2.addString(
      optionShortName         => 'UsedDB'
      , optionName            => '������������ ��'
      , stringValue           => 'User2-DB'
    );
    pkg_TestUtility.compareChar(
      actualString        => op2.getString( 'UsedDB')
      , expectedString    => ''
      , failMessageText   => 'op2.getString: ������������ ��������'
    );
    op2.setString( 'UsedDB', 'User2-DB');
    pkg_TestUtility.compareChar(
      actualString        => op2.getString( 'UsedDB')
      , expectedString    => 'User2-DB'
      , failMessageText   => 'op2.getString: ������������ ��������'
    );
    op2.deleteValue( 'UsedDB');
    pkg_TestUtility.compareChar(
      actualString        => op2.getString( 'UsedDB')
      , expectedString    => ''
      , failMessageText   => 'op2.getString: after del: ������������ ��������'
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ �������� ��� ���������.'
        )
      , true
    );
  end testOperatorValue;



  /*
    ������������ ���������� ��������.
  */
  procedure testEncryption
  is

    -- ����� ������
    opt opt_option_list_t := opt_option_list_t(
      moduleName => Exp_ModuleName
    );



    /*
      ���������, ��� �������� ��������� � ������������� ����.
    */
    procedure checkEncription(
      optionShortName varchar2
      , prodValueFlag integer
      , decryptedValue varchar2
      , valueList varchar2 := null
      , valueIndex integer := null
    )
    is

      valueId integer;

      vl opt_value%rowtype;

      failInfo varchar2(200) :=
        ' ( "' || optionShortName || '"'
        || case when prodValueFlag is not null then
            ', prodValueFlag=' || prodValueFlag
          end
        || case when valueIndex is not null then
            ', valueIndex=' || valueIndex
          end
        || ')'
      ;

      stringValue opt_value.string_value%type;
      encryptedValue opt_value.string_value%type;

    begin
      valueId := opt.getValueId(
        optionShortName
        , prodValueFlag => prodValueFlag
      );

      select
        t.*
      into vl
      from
        opt_value t
      where
        t.value_id = valueId
      ;
      pkg_TestUtility.compareChar(
        actualString        =>
            opt.getString(
              optionShortName
              , prodValueFlag => prodValueFlag
              , valueIndex    => valueIndex
            )
        , expectedString    => decryptedValue
        , failMessageText   =>
            '����������� ��������� �������� getString' || failInfo
      );
      if nullif( prodValueFlag, isProduction) is null then
        pkg_TestUtility.compareChar(
          actualString        =>
              opt.getString(
                optionShortName
                , valueIndex    => valueIndex
              )
          , expectedString    => decryptedValue
          , failMessageText   =>
              '����������� ������������ �������� getString' || failInfo
        );
        select
          t.string_value
          , t.encrypted_string_value
        into
          stringValue
          , encryptedValue
        from
          table( opt.getOptionValue()) t
        where
          t.value_id = valueId
        ;
        pkg_TestUtility.compareChar(
          actualString        => stringValue
          , expectedString    => coalesce( valueList, decryptedValue)
          , failMessageText   =>
              'getOptionValue: ����������� �������� string_value' || failInfo
        );
        pkg_TestUtility.compareChar(
          actualString        => encryptedValue
          , expectedString    => vl.string_value
          , failMessageText   =>
              'getOptionValue: ����������� �������� encrypted_string_value'
              || failInfo
        );
      end if;
      if valueList is not null then
        pkg_TestUtility.compareChar(
          actualString        =>
              opt.getValueList(
                optionShortName
                , prodValueFlag => prodValueFlag
              )
          , expectedString    => valueList
          , failMessageText   => '����������� �������� getValueList' || failInfo
        );
      end if;
      pkg_TestUtility.compareChar(
        actualString        =>
            case when
              vl.string_value = coalesce( valueList, decryptedValue)
            then
              vl.string_value
            else
              '*(encripted "' || coalesce( valueList, decryptedValue)
              || '")*'
            end
        , expectedString    =>
              '*(encripted "' || coalesce( valueList, decryptedValue)
              || '")*'
        , failMessageText   => '��������� ��������������� ��������' || failInfo
      );

      -- �������� getValue
      select
        t.string_value
        , t.encrypted_string_value
      into
        stringValue
        , encryptedValue
      from
        table( opt.getValue( optionShortName)) t
      where
        t.value_id = valueId
      ;
      pkg_TestUtility.compareChar(
        actualString        => stringValue
        , expectedString    => coalesce( valueList, decryptedValue)
        , failMessageText   =>
            'getValue: ����������� �������� string_value' || failInfo
      );
      pkg_TestUtility.compareChar(
        actualString        => encryptedValue
        , expectedString    => vl.string_value
        , failMessageText   =>
            'getValue: ����������� �������� encrypted_string_value'
            || failInfo
      );
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� �������� �������������� �������� ('
            || ' optionShortName="' || optionShortName || '"'
            || ', prodValueFlag=' || prodValueFlag
            || ', valueList="' || valueList || '"'
            || ', valueIndex=' || valueIndex
            || ').'
          )
        , true
      );
    end checkEncription;



  -- testEncryption
  begin
    pkg_TestUtility.beginTest( 'testOptionList: encryption');

    if pkg_OptionCrypto.isCryptoAvailable() = 1 then

      -- ��������� �������� � ����������� ��������
      opt.addString(
        optionShortName         => 'Password'
        , optionName            => '������ ��� �����������'
        , encryptionFlag        => 1
        , prodStringValue       => 'prodpwd'
        , testStringValue       => 'testpwd'
      );
      checkOptionValue(
        optionShortName         => 'Password'
        , encryptionFlag        => 1
        , valueEncryptionFlag   => 1
        , testEncryptionFlag    => 1
        , accessLevelCode       => 'VALUE'
      );
      checkEncription( 'Password', 1, 'prodpwd');
      checkEncription( 'Password', 0, 'testpwd');

      -- �������� ��������
      opt.setString(
        optionShortName         => 'Password'
        , prodStringValue       => 'prodpwd2'
        , testStringValue       => 'testpwd2'
      );
      checkEncription( 'Password', 1, 'prodpwd2');
      checkEncription( 'Password', 0, 'testpwd2');

      -- ������� ���������� ��������
      opt.updateOption(
        optionShortName         => 'Password'
        , encryptionFlag        => 0
      );
      checkOptionValue(
        optionShortName         => 'Password'
        , encryptionFlag        => 0
        , valueEncryptionFlag   => 0
        , testEncryptionFlag    => 0
        , accessLevelCode       => 'FULL'
        , stringValue           => 'prodpwd2'
        , testStringValue       => 'testpwd2'
      );

      -- �������� ���������� ��������
      opt.setString(
        optionShortName         => 'Password'
        , prodStringValue       => 'prodpwd3'
        , testStringValue       => 'testpwd3'
      );
      opt.updateOption(
        optionShortName         => 'Password'
        , encryptionFlag        => 1
      );
      checkOptionValue(
        optionShortName         => 'Password'
        , encryptionFlag        => 1
        , accessLevelCode       => 'VALUE'
      );
      checkEncription( 'Password', 1, 'prodpwd3');
      checkEncription( 'Password', 0, 'testpwd3');

      -- ������/��������� ���������� � ������������� ���������� ������������
      -- � ����� �������
      opt.updateOption(
        optionShortName         => 'Password'
        , optionName            => '������ ��� ����������� ( ��� ����������)'
        , encryptionFlag        => 0
        , accessLevelCode       => 'VALUE'
      );
      checkOptionValue(
        optionShortName         => 'Password'
        , optionName            => '������ ��� ����������� ( ��� ����������)'
        , encryptionFlag        => 0
        , valueEncryptionFlag   => 0
        , testEncryptionFlag    => 0
        , accessLevelCode       => 'VALUE'
        , stringValue           => 'prodpwd3'
        , testStringValue       => 'testpwd3'
      );
      opt.updateOption(
        optionShortName         => 'Password'
        , optionName            => '������ ��� �����������'
        , encryptionFlag        => 1
        , accessLevelCode       => 'READ'
      );
      checkOptionValue(
        optionShortName         => 'Password'
        , optionName            => '������ ��� �����������'
        , encryptionFlag        => 1
        , valueEncryptionFlag   => 1
        , testEncryptionFlag    => 1
        , accessLevelCode       => 'READ'
      );
      checkEncription( 'Password', 1, 'prodpwd3');
      checkEncription( 'Password', 0, 'testpwd3');

      -- ��������� ������������� �������� ��������
      opt.updateOption(
        optionShortName         => 'Password'
        , testProdSensitiveFlag => 0
        , moveProdSensitiveValueFlag => 1
        , deleteBadValueFlag    => 1
      );
      checkEncription( 'Password', null, 'prodpwd3');

      -- ��������� �������� �� ������� ����������� ��������
      opt.addStringList(
        optionShortName         => 'PasswordList'
        , optionName            => '������ ��� �����������'
        , encryptionFlag        => 1
        , valueList             => 'pwd1;pwd2;pwd3'
      );
      checkOptionValue(
        optionShortName         => 'PasswordList'
        , encryptionFlag        => 1
        , valueEncryptionFlag   => 1
        , accessLevelCode       => 'VALUE'
      );
      checkEncription( 'PasswordList', null, 'pwd1', 'pwd1;pwd2;pwd3');
      checkEncription( 'PasswordList', null, 'pwd2', 'pwd1;pwd2;pwd3', 2);
      checkEncription( 'PasswordList', null, 'pwd3', 'pwd1;pwd2;pwd3', 3);

      -- ��������� �������� � ������
      opt.setString(
        optionShortName         => 'PasswordList'
        , valueIndex            => 2
        , stringValue           => 'pwdNew'
      );
      checkEncription( 'PasswordList', null, 'pwdNew', 'pwd1;pwdNew;pwd3', 2);
      opt.setValueList(
        optionShortName         => 'PasswordList'
        , valueList             => 'new1,,,new9'
        , listSeparator         => ','
      );
      checkEncription( 'PasswordList', null, 'new9', 'new1,,,new9', 4);

      -- ������� ���������� ��������
      opt.updateOption(
        optionShortName         => 'PasswordList'
        , encryptionFlag        => 0
      );
      checkOptionValue(
        optionShortName         => 'PasswordList'
        , encryptionFlag        => 0
        , valueEncryptionFlag   => 0
        , testEncryptionFlag    => 0
        , accessLevelCode       => 'FULL'
        , stringValue           => 'new1,,,new9'
      );

      -- ��������������� ���������� ��������
      opt.updateOption(
        optionShortName         => 'PasswordList'
        , encryptionFlag        => 1
      );
      checkOptionValue(
        optionShortName         => 'PasswordList'
        , encryptionFlag        => 1
        , accessLevelCode       => 'VALUE'
      );
      checkEncription( 'PasswordList', null, 'new1', 'new1,,,new9', 1);

    else
      pkg_TestUtility.failTest(
        'dbms_crypto not available'
      );
    end if;

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ���������� ��������.'
        )
      , true
    );
  end testEncryption;



-- testOptionList
begin
  testDateOption();
  testNumberOption();
  testStringOption();

  testChangeOptionData();

  testDateList();
  testNumberList();
  testStringList();

  testObjectOption();
  testPlsqlObjectOption();

  testOperatorValue();

  testSqlFunction();

  testEncryption();

  if coalesce( saveDataFlag, 0) != 1 then
    rollback;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������ � ����������� � ������� ���� opt_option_list_t.'
      )
    , true
  );
end testOptionList;

/* proc: testWebApi
  ���� API ��� web-����������.

  ���������:
  saveDataFlag                - �������� �������� ������ � �������� ���
                                �������� ���������� �����
                                ( 1 ��, 0 ��� ( �� ���������))
*/
procedure testWebApi(
  saveDataFlag integer := null
)
is

  -- ������� ��������
  currentOperatorId integer;

  -- Id ���������, ����������� ��� ��������� ������
  adminOperatorId integer := pkg_AccessOperatorTest.getTestOperatorId(
    'OptionAdmin'
    , cmn_string_table_t(
        pkg_OptionMain.Admin_RoleSName
      )
  );

  -- Id ���������, ����������� ��� ��������� ������
  showOperatorId integer := pkg_AccessOperatorTest.getTestOperatorId(
    'OptionShow'
    , cmn_string_table_t(
        pkg_OptionMain.Show_RoleSName
      )
  );

  -- Id ��������� ��� ���� �� ������
  guestOperatorId integer := pkg_AccessOperatorTest.getTestOperatorId(
    'Guest'
    , cmn_string_table_t()
  );

  -- Id ������ ��� ������������
  moduleId integer := pkg_ModuleInfo.getModuleId( moduleName => Exp_ModuleName);



  /*
    �������� ������ ������� ��� ����������� ����������.
  */
  procedure testOptionApi
  is

    optionId integer;

    guestOptionId integer;

    rc sys_refcursor;

  begin
    pkg_TestUtility.beginTest( 'testWebApi: option API');

    -- �������� ���������
    optionId := pkg_Option.createOption(
      moduleId                => moduleId
      , objectShortName       => null
      , objectTypeId          => null
      , optionShortName       => 'MainServerName'
      , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
      , valueListFlag         => null
      , encryptionFlag        => null
      , testProdSensitiveFlag => 0
      , optionName            => '��� ��������� �������'
      , optionDescription     => '��� ��������� ������� ( ����� ��������)'
      , dateValue             => null
      , numberValue           => null
      , stringValue           => 'UsedServer'
      , stringListSeparator   => null
      , operatorId            => adminOperatorId
    );
    checkOptionValue(
      optionShortName         => 'MainServerName'
      , optionId              => optionId
      , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
      , valueListFlag         => 0
      , encryptionFlag        => 0
      , testProdSensitiveFlag => 0
      , optionName            => '��� ��������� �������'
      , optionDescription     => '��� ��������� ������� ( ����� ��������)'
      , changeOperatorId      => adminOperatorId
      , usedStringValue       => 'UsedServer'
      , usedChangeOperatorId  => adminOperatorId
    );

    -- ... ��� �������� ����
    guestOptionId := pkg_Option.createOption(
      moduleId                => moduleId
      , optionShortName       => 'guestMainServerName'
      , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
      , testProdSensitiveFlag => 0
      , optionName            => '��� ��������� �������'
      , checkRoleFlag         => 0
      , operatorId            => guestOperatorId
    );

    -- ��������� �������� ������ ��������
    pkg_Option.setOptionValue(
      optionId                => optionId
      , dateValue             => null
      , numberValue           => null
      , stringValue           => 'UsedServer2'
      , valueIndex            => null
      , operatorId            => adminOperatorId
    );
    checkOptionValue(
      optionShortName         => 'MainServerName'
      , usedStringValue       => 'UsedServer2'
      , usedChangeOperatorId  => adminOperatorId
    );

    -- ... ��� �������� ����
    pkg_Option.setOptionValue(
      optionId                => guestOptionId
      , dateValue             => null
      , numberValue           => null
      , stringValue           => 'UsedServer2'
      , checkRoleFlag         => 0
      , operatorId            => guestOperatorId
    );
    pkg_Option.updateOption(
      optionId                => guestOptionId
      , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
      , valueListFlag         => 0
      , encryptionFlag        => 0
      , testProdSensitiveFlag => 0
      , optionName            => '��� ��������� ������� (2)'
      , optionDescription     => ''
      , checkRoleFlag         => 0
      , operatorId            => guestOperatorId
    );

    -- ��� ��������� testProdSensitiveFlag ����� �������� ���������
    pkg_Option.updateOption(
      optionId                => optionId
      , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
      , valueListFlag         => 0
      , encryptionFlag        => 0
      , testProdSensitiveFlag => 1
      , optionName            => '��� ��������� ������� (2)'
      , optionDescription     => '��� ��������� ������� ( ����-���� ��������)'
      , operatorId            => adminOperatorId
    );
    checkOptionValue(
      optionShortName         => 'MainServerName'
      , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
      , valueListFlag         => 0
      , encryptionFlag        => 0
      , testProdSensitiveFlag => 1
      , optionName            => '��� ��������� ������� (2)'
      , optionDescription     => '��� ��������� ������� ( ����-���� ��������)'
      , changeOperatorId      => adminOperatorId
      , usedValueId           => null
    );

    pkg_Option.setOptionValue(
      optionId                => optionId
      , dateValue             => null
      , numberValue           => null
      , stringValue           => 'NewServer'
      , valueIndex            => null
      , operatorId            => adminOperatorId
    );
    checkOptionValue(
      optionShortName         => 'MainServerName'
      , usedStringValue       => 'NewServer'
      , usedChangeOperatorId  => adminOperatorId
    );

    -- ��� ��������� testProdSensitiveFlag ����-���� �������� ���������
    pkg_Option.updateOption(
      optionId                => optionId
      , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
      , valueListFlag         => 0
      , encryptionFlag        => 0
      , testProdSensitiveFlag => 0
      , optionName            => '��� ��������� ������� (3)'
      , optionDescription     => ''
      , operatorId            => adminOperatorId
    );
    checkOptionValue(
      optionShortName         => 'MainServerName'
      , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
      , valueListFlag         => 0
      , encryptionFlag        => 0
      , testProdSensitiveFlag => 0
      , optionName            => '��� ��������� ������� (3)'
      , optionDescription     => ''
      , changeOperatorId      => adminOperatorId
      , usedValueId           => null
    );

    -- ��������� �������� �������� ��� ���������� ������������ ��������
    pkg_Option.setOptionValue(
      optionId                => optionId
      , dateValue             => null
      , numberValue           => null
      , stringValue           => 'NewServer2'
      , valueIndex            => null
      , operatorId            => adminOperatorId
    );
    checkOptionValue(
      optionShortName         => 'MainServerName'
      , usedStringValue       => 'NewServer2'
      , usedChangeOperatorId  => adminOperatorId
    );

    -- ����� ���������
    rc := pkg_Option.findOption(
      optionId                => optionId
      , moduleId              => moduleId
      , objectShortName       => null
      , objectTypeId          => null
      , optionShortName       => 'MainServerName'
      , optionName            => '��� ��������� ������� (3)'
      , optionDescription     => ''
      , stringValue           => 'NewServer2'
      , maxRowCount           => 5
      , operatorId            => showOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 1
      , failMessageText       =>
          'findOption: ����������� ����� ������� � ������� ('
          || ' option_short_name="MainServerName"'
          || ')'
    );

    -- ... ��� �������� ����
    rc := pkg_Option.findOption(
      optionId                => guestOptionId
      , moduleId              => moduleId
      , maxRowCount           => 5
      , checkRoleFlag         => 0
      , operatorId            => guestOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 1
      , failMessageText       =>
          'findOption: ����������� ����� ������� � ������� ('
          || ' option_short_name="guestMainServerName"'
          || ')'
    );

    -- �������� ���������
    pkg_Option.deleteOption(
      optionId                => optionId
      , operatorId            => adminOperatorId
    );
    checkOptionValue(
      optionShortName         => 'MainServerName'
      , optionDeleted         => 1
      , changeOperatorId      => adminOperatorId
      , valueDeleted          => 1
      , valueChangeOperatorId => adminOperatorId
    );

    -- ... ��� �������� ����
    pkg_Option.deleteOption(
      optionId                => guestOptionId
      , checkRoleFlag         => 0
      , operatorId            => guestOperatorId
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ������� ��� ����������� ����������.'
        )
      , true
    );
  end testOptionApi;



  /*
    �������� ������ ������� ��� �������� ����������.
  */
  procedure testValueApi
  is

    optionId integer;
    valueId integer;
    guestValueId integer;
    operatorValueId integer;

    rc sys_refcursor;

  begin
    pkg_TestUtility.beginTest( 'testWebApi: value API');

    -- �������� ���������
    optionId := pkg_Option.createOption(
      moduleId                => moduleId
      , objectShortName       => null
      , objectTypeId          => null
      , optionShortName       => 'MainUser'
      , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
      , valueListFlag         => null
      , encryptionFlag        => null
      , testProdSensitiveFlag => 1
      , optionName            => '�������� ������������'
      , optionDescription     => '�������� ������������ ( ����/����. ��������)'
      , dateValue             => null
      , numberValue           => null
      , stringValue           => 'User'
      , stringListSeparator   => null
      , operatorId            => adminOperatorId
    );

    -- ���� ������ ���� �������� ( � ����������� �� ���� ��)
    if isProduction = 1 then
      checkOptionValue(
        optionShortName         => 'MainUser'
        , stringValue           => 'User'
        , valueChangeOperatorId => adminOperatorId
        , testValueId           => null
        , usedStringValue       => 'User'
        , usedChangeOperatorId  => adminOperatorId
      );
    else
      checkOptionValue(
        optionShortName         => 'MainUser'
        , testStringValue       => 'User'
        , testChangeOperatorId  => adminOperatorId
        , valueId               => null
        , usedStringValue       => 'User'
        , usedChangeOperatorId  => adminOperatorId
      );
    end if;

    -- ��������� ������ �������� ������� ����
    valueId := pkg_Option.createValue(
      optionId                  => optionId
      , prodValueFlag           => 1 - isProduction
      , instanceName            => null
      , dateValue               => null
      , numberValue             => null
      , stringValue             => 'User2'
      , stringListSeparator     => null
      , operatorId              => adminOperatorId
    );
    checkOptionValue(
      optionShortName           => 'MainUser'
      , stringValue             =>
          case when isProduction = 1 then 'User' else 'User2' end
      , valueChangeOperatorId   => adminOperatorId
      , testStringValue         =>
          case when isProduction = 0 then 'User' else 'User2' end
      , testChangeOperatorId    => adminOperatorId
      , usedStringValue         => 'User'
      , usedChangeOperatorId    => adminOperatorId
    );

    -- ... ��� �������� ����
    guestValueId := pkg_Option.createValue(
      optionId                  => optionId
      , prodValueFlag           => 1 - isProduction
      , instanceName            => 'Guest'
      , stringValue             => 'User2'
      , checkRoleFlag           => 0
      , operatorId              => guestOperatorId
    );

    -- ��������� �������� ��� ���������
    operatorValueId := pkg_Option.createValue(
      optionId                  => optionId
      , prodValueFlag           => 0
      , instanceName            => null
      , usedOperatorId          => 5
      , dateValue               => null
      , numberValue             => null
      , stringValue             => 'User5'
      , stringListSeparator     => null
      , operatorId              => adminOperatorId
    );
    checkOptionValue(
      optionShortName           => 'MainUser'
      , usedOperatorId          => 5
      , testValueId             => operatorValueId
      , testStringValue         => 'User5'
      , testChangeOperatorId    => adminOperatorId
    );

    -- ��������� ��������
    pkg_Option.updateValue(
      valueId                   => valueId
      , dateValue               => null
      , numberValue             => null
      , stringValue             => 'User3'
      , valueIndex              => null
      , operatorId              => adminOperatorId
    );
    checkOptionValue(
      optionShortName           => 'MainUser'
      , stringValue             =>
          case when isProduction = 1 then 'User' else 'User3' end
      , valueChangeOperatorId   => adminOperatorId
      , testStringValue         =>
          case when isProduction = 0 then 'User' else 'User3' end
      , testChangeOperatorId    => adminOperatorId
      , usedStringValue         => 'User'
      , usedChangeOperatorId    => adminOperatorId
    );

    -- ... ��� �������� ����
    pkg_Option.updateValue(
      valueId                   => guestValueId
      , stringValue             => 'User3'
      , checkRoleFlag           => 0
      , operatorId              => guestOperatorId
    );

    -- ����� ��������
    rc := pkg_Option.findValue(
      valueId                 => null
      , optionId              => optionId
      , maxRowCount           => 2
      , operatorId            => showOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 2
      , failMessageText       =>
          'findValue: ����������� ����� ������� � �������'
    );

    -- ... ��� �������� ����
    rc := pkg_Option.findValue(
      valueId                 => guestValueId
      , optionId              => optionId
      , maxRowCount           => 5
      , checkRoleFlag         => 0
      , operatorId            => guestOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 1
      , failMessageText       =>
          'findValue: ����������� ����� ������� � �������'
    );

    -- �������� ��������
    pkg_Option.deleteValue(
      valueId                 => valueId
      , operatorId            => adminOperatorId
    );
    if isProduction = 1 then
      checkOptionValue(
        optionShortName         => 'MainUser'
        , stringValue           => 'User'
        , valueChangeOperatorId => adminOperatorId
        , testValueId           => valueId
        , testDeleted           => 1
        , usedStringValue       => 'User'
        , usedChangeOperatorId  => adminOperatorId
      );
    else
      checkOptionValue(
        optionShortName         => 'MainUser'
        , testStringValue       => 'User'
        , testChangeOperatorId  => adminOperatorId
        , valueId               => valueId
        , valueDeleted          => 1
        , usedStringValue       => 'User'
        , usedChangeOperatorId  => adminOperatorId
      );
    end if;

    -- ... ��� �������� ����
    pkg_Option.deleteValue(
      valueId                   => guestValueId
      , checkRoleFlag           => 0
      , operatorId              => guestOperatorId
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ������� ��� �������� ����������.'
        )
      , true
    );
  end testValueApi;


-- testWebApi
begin

  -- ������� �������� ���������, ����� ����������� ������ �����
  -- web-���������
  currentOperatorId := pkg_Operator.getCurrentUserId();
  pkg_Operator.logoff();

  testOptionApi();
  testValueApi();

  -- ��������������� ����������� ���������
  pkg_Operator.setCurrentUserId( currentOperatorId);

  if coalesce( saveDataFlag, 0) != 1 then
    rollback;
  end if;
exception when others then
  pkg_Operator.setCurrentUserId( currentOperatorId);
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������������ API ��� web-����������.'
      )
    , true
  );
end testWebApi;

end pkg_OptionTest;
/
