create or replace package body pkg_OptionMain is
/* package body: pkg_OptionMain::body */



/* group: ��������� */

/* iconst: ListSeparator_Default
  ������, ������������ �� ��������� � �������� ����������� � ������ ��������
  ��������� ���������� ����, � ����� ��� ������ �������� ��������� ���������
  ���� � ���� ����.
*/
ListSeparator_Default constant varchar2(1) := ';';

/* iconst: DateValue_ListFormat
  ������ �������� �������� ���� ���� � ������ ��������.
  ����������� "fx" ������, ����� �������� ������������� �������������� ������
  � �����, �������� "01.10.2011" � ���� "20.10.0001 11:00:00".
  � ����� � ���� ��� ����������� ��������� �������������� ���� ��� �������
  ��� ������������� ����������� ����� " 00:00:00".
*/
DateValue_ListFormat constant varchar2(30) := 'fxyyyy-mm-dd hh24:mi:ss';

/* iconst: NumberValue_ListFormat
  ������ �������� ��������� �������� � ������ ��������.
*/
NumberValue_ListFormat constant varchar2(10) := 'tm9';

/* iconst: Number_ListDecimalChar
  ������ ����������� �����������, ������������ ��� �������� ��������� ��������
  � ������ ��������.
*/
Number_ListDecimalChar constant varchar2(1) := '.';




/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_OptionMain'
);

/* ivar: saveValueHistoryFlag
  ���� ���������� ������������ ������� � ������� <opt_value_history>
  ��� ��������� ������ � ������� <opt_value> ( 1 �� ( �� ���������), 0 ���).
*/
saveValueHistoryFlag integer := null;

/* ivar: currentUsedOperatorId
  ������� ������������� Id ���������, ��� �������� ����� ��������������
  ��������, ��� ������������� � ������������� <v_opt_option_value>.
*/
currentUsedOperatorId integer := null;



/* group: ������� */

/* func: getCurrentUsedOperatorId
  ���������� ������� ������������� Id ���������, ��� �������� �����
  �������������� ��������, ��� ������������� � �������������
  <v_opt_option_value>.
*/
function getCurrentUsedOperatorId
return integer
is
begin
  return currentUsedOperatorId;
end getCurrentUsedOperatorId;



/* group: ���� �������� */

/* func: getObjectTypeId
  ���������� Id ���� �������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��� �������
  objectTypeShortName         - ������� ������������ ���� �������
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ������ ( 1 �� ( �� ���������), 0 ���)

  �������:
  Id ���� ������� ( �� ������� <opt_object_type>) ���� null, ���� ������ ��
  ������� � �������� raiseNotFoundFlag ����� 0.
*/
function getObjectTypeId(
  moduleId integer
  , objectTypeShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer
is

  -- Id ���� �������
  objectTypeId integer;

begin
  select
    min( t.object_type_id)
  into objectTypeId
  from
    opt_object_type t
  where
    t.module_id = moduleId
    and t.object_type_short_name = objectTypeShortName
    and t.deleted = 0
  ;
  if objectTypeId is null and coalesce( raiseNotFoundFlag, 1) != 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '��� ������� �� ������.'
    );
  end if;
  return objectTypeId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ����������� Id ���� ������� ('
        || ' moduleId=' || moduleId
        || ', objectTypeShortName="' || objectTypeShortName || '"'
        || ', raiseNotFoundFlag=' || raiseNotFoundFlag
        || ').'
      )
    , true
  );
end getObjectTypeId;

/* func: createObjectType
  ������� ��� �������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��� �������
  objectTypeShortName         - ������� ������������ ���� �������
  objectTypeName              - ������������ ���� �������
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id ���� �������.
*/
function createObjectType(
  moduleId integer
  , objectTypeShortName varchar2
  , objectTypeName varchar2
  , operatorId integer := null
)
return integer
is

  -- Id ���� �������
  objectTypeId integer;

begin
  insert into
    opt_object_type
  (
    module_id
    , object_type_short_name
    , object_type_name
    , operator_id
  )
  values
  (
    moduleId
    , objectTypeShortName
    , objectTypeName
    , operatorId
  )
  returning
    object_type_id
  into
    objectTypeId
  ;
  return objectTypeId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ���� ������� ('
        || ' moduleId=' || moduleId
        || ', objectTypeShortName="' || objectTypeShortName || '"'
        || ').'
      )
    , true
  );
end createObjectType;

/* func: mergeObjectType
  ������� ��� ��������� ��� �������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��� �������
  objectTypeShortName         - ������� ������������ ���� �������
  objectTypeName              - ������������ ���� �������
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  - ���� �������� ��������� ( 0 ��� ���������, 1 ���� ��������� �������)
*/
function mergeObjectType(
  moduleId integer
  , objectTypeShortName varchar2
  , objectTypeName varchar2
  , operatorId integer := null
)
return integer
is

  -- ���� �������� ���������
  isChanged integer := 0;

begin
  merge into
    opt_object_type d
  using
    (
    select
      moduleId as module_id
      , objectTypeShortName as object_type_short_name
      , objectTypeName as object_type_name
      , 0 as deleted
    from
      dual
    minus
    select
      t.module_id
      , t.object_type_short_name
      , t.object_type_name
      , t.deleted
    from
      opt_object_type t
    ) s
  on (
    d.module_id = s.module_id
    and d.object_type_short_name = s.object_type_short_name
    )
  when not matched then
    insert
    (
      module_id
      , object_type_short_name
      , object_type_name
      , deleted
      , operator_id
    )
    values
    (
      s.module_id
      , s.object_type_short_name
      , s.object_type_name
      , s.deleted
      , operatorId
    )
  when matched then
    update set
      d.object_type_name            = s.object_type_name
      , d.deleted                   = s.deleted
  ;
  isChanged := sql%rowcount;
  return isChanged;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ��� ���������� ���� ������� ('
        || ' moduleId=' || moduleId
        || ',  objectTypeShortName="' || objectTypeShortName || '"'
        || ').'
      )
    , true
  );
end mergeObjectType;

/* proc: deleteObjectType
  ������� ��� �������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��� �������
  objectTypeShortName         - ������� ������������ ���� �������
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  ���������:
  - � ������ ������������� ���� � ���������� ������ ������������� ����������;
  - ��� ���������� ������������� ������ ��������� ���������, ����� ��������
    ���� ����������� ��������;
*/
procedure deleteObjectType(
  moduleId integer
  , objectTypeShortName varchar2
  , operatorId integer := null
)
is

  -- ���� ������������� ( 1 - � ����������� �������, 0 - ������ � ���������
  -- ���������, null - �� ������������)
  usedFlag integer;



  /*
    ��������� ������ �� ���� �������.
  */
  procedure lockObjectType
  is
  begin
    select
      coalesce(
        (
        select
          1 - min( t.deleted) as used_flag
        from
          opt_option t
        where
          t.object_type_id = d.object_type_id
        )
        , (
          select
            0 as used_flag
          from
            opt_option_history t
          where
            t.object_type_id = d.object_type_id
            and rownum <= 1
          )
      )
    into usedFlag
    from
      opt_object_type d
    where
      d.module_id = moduleId
      and d.object_type_short_name = objectTypeShortName
      and d.deleted = 0
    for update of d.deleted nowait
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� ������.'
        )
      , true
    );
  end lockObjectType;



-- deleteObjectType
begin
  lockObjectType();
  if usedFlag is null then
    delete
      opt_object_type d
    where
      d.module_id = moduleId
      and d.object_type_short_name = objectTypeShortName
    ;
  elsif usedFlag = 0 then
    update
      opt_object_type d
    set
      d.deleted = 1
    where
      d.module_id = moduleId
      and d.object_type_short_name = objectTypeShortName
    ;
  else
    raise_application_error(
      pkg_Error.ProcessError
      , '���� ����������� ����������� ���������, ����������� � ��������'
        || ' ���������� ����.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ���� ������� ('
        || ' moduleId=' || moduleId
        || ', objectTypeShortName="' || objectTypeShortName || '"'
        || ').'
      )
    , true
  );
end deleteObjectType;



/* group: ����������� ��������� */

/* func: getDecryptValue
  ���������� �������� ��� ������ �������� � �������������� ����.

  ���������:
  stringValue                 - ������ � ������������� ��������� ���� ��
                                ������� ������������� ��������
  listSeparator               - ������, ������������ � �������� ����������� �
                                ������ ��������
                                ( null ���� ������ �� ������������)

  �������:
  ������ � �������������� ��������� ���� ������� �������������� ��������
  ( � ������������ listSeparator)
*/
function getDecryptValue(
  stringValue varchar2
  , listSeparator varchar2
)
return varchar2
is

  -- ������ � �������������� ��������� ���� ������� �������������� ��������
  outString opt_value.string_value%type;

  -- ������ �������� � ������ ( ������� � 1)
  valueIndex pls_integer := 0;

  -- ������� ������� ������� �������� � ������
  beginPos pls_integer := 1;

  -- ������� �� ��������� �������� �������� � ������
  endPos pls_integer := 1;

  -- ����� ������
  len pls_integer;

begin
  logger.trace( 'getDecryptValue: stringValue="' || stringValue || '"');
  len := coalesce( length( stringValue), 0);
  while endPos <= len loop
    valueIndex := valueIndex + 1;
    endPos :=
      case when listSeparator is not null then
        instr( stringValue , listSeparator, beginPos)
      else
        0
      end
    ;
    if endPos = 0 then
      endPos := len + 1;
    end if;
    outString :=
      outString
      || case when valueIndex > 1 then listSeparator end
      || case when endPos > beginPos then
          pkg_OptionCrypto.decrypt(
            substr( stringValue, beginPos, endPos - beginPos)
          )
        end
    ;
    beginPos := endPos + 1;
  end loop;
  return outString;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ����������� ������ �� ���������.'
      )
    , true
  );
end getDecryptValue;

/* func: getOptionId
  ���������� Id ������������ ���������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��������
  objectShortName             - ������� ������������ ������� ������
  objectTypeId                - Id ���� �������
  optionShortName             - ������� ������������ ���������
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  Id ��������� ���� null, ���� �������� �� ������ � �������� raiseNotFoundFlag
  ����� 0.
*/
function getOptionId(
  moduleId integer
  , objectShortName varchar2
  , objectTypeId integer
  , optionShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer
is

  -- Id ���������
  optionId integer;

begin
  if objectShortName is not null and objectTypeId is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�� ������ Id ���� �������.'
    );
  end if;
  select
    min( t.option_id)
  into optionId
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
    and t.deleted = 0
  ;
  if optionId is null and coalesce( raiseNotFoundFlag, 1) != 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '����������� �������� �� ������.'
    );
  end if;
  return optionId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ����������� Id ��������� ('
        || ' moduleId=' || moduleId
        || ', objectShortName="' || objectShortName || '"'
        || ', objectTypeId=' || objectTypeId
        || ', optionShortName="' || optionShortName || '"'
        || ', raiseNotFoundFlag=' || raiseNotFoundFlag
        || ').'
      )
    , true
  );
end getOptionId;

/* proc: lockOption
  ��������� � ���������� ������ ���������.

  ���������:
  rowData                     - ������ ������ ( �������)
  optionId                    - Id ���������

  ���������:
  - � ������, ���� ������ ���� ��������� �������, ������������� ����������;
*/
procedure lockOption(
  rowData out nocopy opt_option%rowtype
  , optionId integer
)
is
begin
  select
    t.*
  into rowData
  from
    opt_option t
  where
    t.option_id = optionId
  for update nowait;

  if rowData.deleted = 1 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������ �� ������� ( ���� ��������� �������).'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� ��������� ('
        || ' optionId=' || optionId
        || ').'
      )
    , true
  );
end lockOption;

/* func: createOption
  ������� ����������� ��������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��������
  optionShortName             - ������� ������������ ���������
  valueTypeCode               - ��� ���� �������� ���������
  optionName                  - ������������ ���������
  objectShortName             - ������� ������������ ������� ������
                                ( �� ��������� �����������)
  objectTypeId                - Id ���� �������
                                ( �� ��������� �����������)
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ���������� ���� ( 1 ��, 0 ��� ( �� ���������))
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ����
                                ( 1 ��, 0 ��� ( �� ���������))
  testProdSensitiveFlag       - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
                                ( 1 ��, 0 ��� ( �� ���������))
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( �� ��������� ������ ��������� �������� �
                                  ������ �������� �������� � �������������
                                  ����, ����� ������ ������)
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  optionId                    - Id ������������ ���������
                                ( �� ��������� ����������� �������������)
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id ���������.
*/
function createOption(
  moduleId integer
  , optionShortName varchar2
  , valueTypeCode varchar2
  , optionName varchar2
  , objectShortName varchar2 := null
  , objectTypeId integer := null
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , optionId integer := null
  , operatorId integer := null
)
return integer
is

  -- ������ � ���� ������
  rec opt_option%rowtype;



  /*
    ��������� ���� ������.
  */
  procedure fillData
  is
  begin
    rec.module_id                 := moduleId;
    rec.option_short_name         := optionShortName;
    rec.value_type_code           := valueTypeCode;
    rec.option_name               := optionName;
    rec.object_short_name         := objectShortName;
    rec.object_type_id            := objectTypeId;
    rec.value_list_flag           := coalesce( valueListFlag, 0);
    rec.encryption_flag           := coalesce( encryptionFlag, 0);
    rec.test_prod_sensitive_flag  := coalesce( testProdSensitiveFlag, 0);
    rec.access_level_code         := coalesce(
      accessLevelCode
      , case when encryptionFlag = 1 then
          Value_AccessLevelCode
        else
          Full_AccessLevelCode
        end
    );
    rec.option_description        := optionDescription;
    rec.option_id                 := optionId;
    rec.operator_id               := operatorId;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� ����� ������.'
        )
      , true
    );
  end fillData;



  /*
    ��������� ������ � ������� opt_option � ���������� ��������� ( true �
    ������ ������, false � ������ ������ ��-�� ��������� ������������).
  */
  function insertRecord
  return boolean
  is
  begin
    insert into
      opt_option
    values
      rec
    returning
      option_id
    into
      rec.option_id
    ;
    logger.trace(
      'createOption: opt_option inserted:'
      || ' option_id=' || rec.option_id
      || ', value_type_code="' || rec.value_type_code || '"'
      || ', value_list_flag=' || rec.value_list_flag
      || ', test_prod_sensitive_flag=' || rec.test_prod_sensitive_flag
    );
    return true;
  exception
    when DUP_VAL_ON_INDEX then
      logger.trace(
        'createOption: insertRecord: DUP_VAL_ON_INDEX error: ' || SQLERRM
      );
      logger.clearErrorStack();
      return false;
    when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ������� ������ � ������� opt_option.'
          )
        , true
      );
  end insertRecord;



  /*
    ��������������� ����� ��������� ������.
  */
  procedure restoreDeleted
  is
  begin
    select
      d.option_id
      , d.deleted
    into rec.option_id, rec.deleted
    from
      opt_option d
    where
      d.module_id = rec.module_id
      and d.option_short_name = rec.option_short_name
      and (
        rec.object_short_name is null
          and d.object_short_name is null
        or d.object_short_name = rec.object_short_name
          and d.object_type_id = rec.object_type_id
      )
    for update nowait;

    if rec.deleted = 0 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '�������� ��� ������ ����� ('
          || ' option_id=' || rec.option_id
          || ').'
      );
    end if;
    update
      opt_option d
    set
      d.value_type_code             = rec.value_type_code
      , d.value_list_flag           = rec.value_list_flag
      , d.encryption_flag           = rec.encryption_flag
      , d.test_prod_sensitive_flag  = rec.test_prod_sensitive_flag
      , d.access_level_code         = rec.access_level_code
      , d.option_name               = rec.option_name
      , d.option_description        = rec.option_description
      , d.deleted                   = 0
      , d.change_operator_id        = rec.operator_id
    where
      d.option_id = rec.option_id
    ;
    logger.trace(
      'createOption: restore deleted: opt_option updated:'
      || ' option_id=' || rec.option_id
      || ', value_type_code="' || rec.value_type_code || '"'
      || ', value_list_flag=' || rec.value_list_flag
      || ', test_prod_sensitive_flag=' || rec.test_prod_sensitive_flag
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������������� ����� ��������� ������.'
        )
      , true
    );
  end restoreDeleted;



-- createOption
begin
  if objectShortName is not null and objectTypeId is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�� ������ Id ���� �������.'
    );
  end if;
  if encryptionFlag = 1 and valueTypeCode != String_ValueTypeCode then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '���������� ����������� ������ ��� �������� ���������� ����.'
    );
  end if;
  fillData();
  if not insertRecord() then
    restoreDeleted();
  end if;
  return rec.option_id;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ��������� ('
        || ' moduleId=' || moduleId
        || ', objectShortName="' || objectShortName || '"'
        || ', objectTypeId=' || objectTypeId
        || ', optionShortName="' || optionShortName || '"'
        || ', optionId=' || optionId
        || ').'
      )
    , true
  );
end createOption;

/* proc: updateOption
  �������� ����������� ��������.

  ���������:
  optionId                    - Id ���������
  moduleId                    - Id ������, � �������� ��������� ��������
  objectShortName             - ������� ������������ ������� ������
  objectTypeId                - Id ���� �������
  optionShortName             - ������� ������������ ���������
  valueTypeCode               - ��� ���� �������� ���������
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ���������� ���� ( 1 ��, 0 ���)
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ���� ( 1 ��, 0 ���)
  testProdSensitiveFlag       - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
                                ( 1 ��, 0 ���)
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
  optionName                  - ������������ ���������
  optionDescription           - �������� ���������
  moveProdSensitiveValueFlag  - ��� ��������� �������� �����
                                testProdSensitiveFlag ���������� ������������
                                �������� ��������� ( ����� � ������������ ����
                                ������������ � �����)
                                ( 1 ��, 0 ��� ( ����������� ����������))
                                ( �� ��������� 0)
  deleteBadValueFlag          - ������� ��������, ������� �� �������������
                                ����� ������ ������������ ���������
                                ( 1 ��, 0 ��� ( ����������� ����������))
                                ( �� ��������� 0)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������������� deleteBadValueFlag ��������� � moveProdSensitiveValueFlag
    ������������ �������� �������� �������� � ������ ���������
    ��� ��������� �������� testProdSensitiveFlag ������ � 0
    ( � ��������� ������ ��� ������� �������� �������� ���� �� ���������
      ����������);
*/
procedure updateOption(
  optionId integer
  , moduleId integer
  , objectShortName varchar2
  , objectTypeId integer
  , optionShortName varchar2
  , valueTypeCode varchar2
  , valueListFlag integer
  , encryptionFlag integer
  , testProdSensitiveFlag integer
  , accessLevelCode varchar2
  , optionName varchar2
  , optionDescription varchar2
  , moveProdSensitiveValueFlag integer := null
  , deleteBadValueFlag integer := null
  , operatorId integer := null
)
is

  -- ������� ������
  rec opt_option%rowtype;



  /*
    ��������� ������������ �������� ���������.
  */
  procedure checkValue(
    isSensitiveChanged boolean
  )
  is

    cursor valueCur is
      select
        b.*
      from
        (
        select
          a.*
        from
          (
          select
            vl.*
            , case when
                  vl.value_type_code = valueTypeCode
                  and vl.value_list_flag = valueListFlag
                then 0 else 1
              end
              as is_type_bad
            , case when
                  testProdSensitiveFlag = 0
                    and vl.prod_value_flag is null
                  or testProdSensitiveFlag = 1
                    and vl.prod_value_flag is not null
                then 0 else 1
              end
              as is_test_prod_bad
            , case when
                  vl.date_value is null
                  and vl.number_value is null
                  and vl.string_value is null
                then 0 else 1
              end
              as is_value_exists
          from
            (
            select
              v.*
              , case when v.list_separator is not null then 1 else 0 end
                as value_list_flag
            from
              opt_value v
            where
              v.deleted = 0
            ) vl
          where
            vl.option_id = optionId
          ) a
        ) b
      where
        b.is_type_bad + b.is_test_prod_bad > 0
      order by
        b.value_id
    ;

    -- ������� ������������� ��������
    isBadValue boolean;

    -- ������� ������������� �������� �������� ��� ���������
    -- test_prod_sensitive_flag
    isMoveValue boolean;

    -- Id ��������, ���������� �������� ������������� ��������
    moveValueId integer;

  -- checkValue
  begin
    for vr in valueCur loop
      begin
        isBadValue :=
          vr.is_type_bad + vr.is_test_prod_bad > 0
        ;
        isMoveValue :=
          isSensitiveChanged
          and moveProdSensitiveValueFlag = 1
          and vr.is_test_prod_bad = 1
          and vr.is_type_bad = 0
          and (
            testProdSensitiveFlag = 1 and vr.prod_value_flag is null
            or testProdSensitiveFlag = 0 and vr.prod_value_flag = 1
          )
        ;
        if isBadValue then
          if deleteBadValueFlag = 1 or isMoveValue then
            deleteValue(
              valueId             => vr.value_id
              , operatorId        => operatorId
            );

            -- �������� ����� ��������, ����� �� �������� �����������
            -- ������������
            if isMoveValue then
              moveValueId := createValue(
                optionId                => optionId
                , prodValueFlag         =>
                    case
                      when vr.prod_value_flag is null then 1
                      when vr.prod_value_flag = 1 then null
                      -- ������ � ���������, ������������ ����������
                      else -1
                    end
                , instanceName          => vr.instance_name
                , usedOperatorId        => vr.used_operator_id
                , valueTypeCode         => vr.value_type_code
                , dateValue             => vr.date_value
                , numberValue           => vr.number_value
                , stringValue           =>
                    case when vr.encryption_flag = 1 then
                      getDecryptValue(
                        stringValue     => vr.string_value
                        , listSeparator => vr.list_separator
                      )
                    else
                      vr.string_value
                    end
                , setValueListFlag    =>
                    case when vr.list_separator is not null then 1 else 0 end
                , valueListSeparator    => vr.list_separator
                , ignoreTestProdSensitiveFlag => 1
                , operatorId            => operatorId
              );
            end if;
          else
            raise_application_error(
              pkg_Error.ProcessError
              , case
                  when vr.is_type_bad = 1 then
                    '��� ��������� ����� ���� ������ �������� ������� ���� ('
                    || ' value_type_code="' || vr.value_type_code || '"'
                    || ', value_list_flag=' || vr.value_list_flag
                    || ').'
                  when vr.is_test_prod_bad = 1 then
                    '��� ��������� ����� ���� ������ �������� '
                    || case vr.prod_value_flag
                        when 0 then '��� �������� ��.'
                        when 1 then '��� ������������ ��.'
                        else '��� �������� ���� ��.'
                      end
                  else
                    '������������ �������� ���������.'
                end
            );
          end if;
        end if;
      exception when others then
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , logger.errorStack(
              '������ ��� �������� �������� ('
              || ' value_id=' || vr.value_id
              || ').'
            )
          , true
        );
      end;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� ������������ �������� ('
          || ' valueTypeCode="' || valueTypeCode || '"'
          || ', valueListFlag=' || valueListFlag
          || ', testProdSensitiveFlag=' || testProdSensitiveFlag
          || ').'
        )
      , true
    );
  end checkValue;



  /*
    �������� ��������� ���������� �������� ���������.
  */
  procedure changeValueEncryption
  is

    cursor valueCur is
      select
        vl.*
      from
        opt_value vl
      where
        vl.option_id = optionId
        and vl.deleted = 0
      order by
        vl.value_id
    ;

  begin
    for vr in valueCur loop
      -- ��������� ��������, ��� ���� ����������/������������ ����� ���������
      -- � ������������ � ���������� ��� ���������
      updateValue(
        valueId               => vr.value_id
        , valueTypeCode       => vr.value_type_code
        , dateValue           => vr.date_value
        , numberValue         => vr.number_value
        , stringValue         =>
            case when vr.encryption_flag = 1 then
              getDecryptValue(
                stringValue     => vr.string_value
                , listSeparator => vr.list_separator
              )
            else
              vr.string_value
            end
        , setValueListFlag    =>
            case when vr.list_separator is not null then 1 else 0 end
        , valueListSeparator  => vr.list_separator
        , operatorId          => vr.operator_id
      );
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ���������� �������� ('
          || ' encryptionFlag=' || encryptionFlag
          || ').'
        )
      , true
    );
  end changeValueEncryption;



-- updateOption
begin
  if encryptionFlag = 1 and valueTypeCode != String_ValueTypeCode then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '���������� ����������� ������ ��� �������� ���������� ����.'
    );
  end if;
  lockOption( rec, optionId => optionId);
  if rec.value_type_code != valueTypeCode
        or rec.value_list_flag != valueListFlag
        or rec.test_prod_sensitive_flag != testProdSensitiveFlag
      then
    checkValue(
      isSensitiveChanged =>
        rec.test_prod_sensitive_flag != testProdSensitiveFlag
    );
  end if;
  update
    opt_option d
  set
    d.module_id                   = moduleId
    , d.object_short_name         = objectShortName
    , d.object_type_id            = objectTypeId
    , d.option_short_name         = optionShortName
    , d.value_type_code           = valueTypeCode
    , d.value_list_flag           = valueListFlag
    , d.encryption_flag           = encryptionFlag
    , d.test_prod_sensitive_flag  = testProdSensitiveFlag
    , d.access_level_code         = accessLevelCode
    , d.option_name               = optionName
    , d.option_description        = optionDescription
    , d.change_operator_id        = operatorId
  where
    d.option_id = optionId
  ;
  logger.trace(
    'updateOption: opt_option updated: option_id=' || optionId
  );
  if rec.encryption_flag != encryptionFlag then
    changeValueEncryption();
  end if;
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

/* proc: deleteOption
  ������� ����������� ��������.

  ���������:
  optionId                    - Id ���������
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ��� �������� ��������� ������������� ��������� ����������� � ���� ��������;
*/
procedure deleteOption(
  optionId integer
  , operatorId integer := null
)
is

  cursor valueCur is
    select
      vl.*
    from
      opt_value vl
    where
      vl.option_id = optionId
      and vl.deleted = 0
    order by
      vl.value_id
  ;

  -- ������� ������
  rec opt_option%rowtype;

-- deleteOption
begin
  lockOption( rec, optionId => optionId);
  for vr in valueCur loop
    deleteValue(
      valueId       => vr.value_id
      , operatorId  => operatorId
    );
  end loop;
  update
    opt_option d
  set
    d.deleted = 1
    , d.change_operator_id = operatorId
  where
    d.option_id = optionId
  ;
  logger.trace(
    'deleteOption: opt_option set deleted: option_id=' || optionId
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



/* group: �������� ���������� */

/* ifunc: toNumber
  ������������ ������ � ������ � �����.

  ���������:
  valueString                 - ������ � ������
  decimalChar                 - ���������� �����������, ������������ � ������
                                ( �� ��������� <Number_ListDecimalChar>)

  ���������:
  - ������������ to_number � ��������� ����������� ����������� � �������
    NLS_NUMERIC_CHARACTERS �� ����������, �.�. ���������, ����� ������
    ��������� �� 2-� ���������, ����� �������������� �������� �����������
    ������������;
*/
function toNumber(
  valueString varchar2
  , decimalChar varchar2 := null
)
return number
is

  -- ������������ � ������ ���������� �����������
  oldDecimalChar varchar2(1);

  -- ���������� ����������� ��� to_number ( null ���� ��������� �
  -- ������������)
  newDecimalChar varchar2(1);

-- toNumber
begin

  -- ���������� ������������� ��������� �����������
  oldDecimalChar := coalesce( decimalChar, Number_ListDecimalChar);
  newDecimalChar := nullif(
    substr( to_char( 0.1, 'tm9'), 1, 1)
    , oldDecimalChar
  );

  if newDecimalChar is not null
      and instr( valueString, newDecimalChar) > 0
      then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '� ������ �� �� ���������� ������������ ������, ����������'
        || ' ���������� ������������ � ������ ('
        || ' session decimal char="' || newDecimalChar || '"'
        || ' string decimal char="' || oldDecimalChar || '"'
        || ').'
    );
  end if;

  return
    to_number(
      case when newDecimalChar is null then
        valueString
      else
        replace( valueString, oldDecimalChar, newDecimalChar)
      end
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ����������� ������ � ����� ('
        || ' valueString="' || valueString || '"'
        || ', decimalChar="' || decimalChar || '"'
        || ').'
      )
    , true
  );
end toNumber;

/* ifunc: formatValueString
  ��������� ������������ � ����������� �������� � ���� ������.

  ���������:
  valueTypeCode               - ��� ���� �������� ���������
  valueString                 - �������� ������ �� ���������
  sourceValueFormat           - ������ �������� ���� ���� � �������� ������
                                ( �� ��������� ������������ "yyyy-mm-dd
                                  hh24:mi:ss" � ������������ ���������
                                  �������)
  sourceDecimalChar           - ���������� ����������� ��� ��������� ��������
                                � �������� ������
                                ( �� ��������� ������������ �����)
  encryptionFlag              - ���� ���������� ���������� ��������
                                ( 1 ��, 0 ��� ( �� ���������))
  forbiddenChar               - ����������� ��� ������������� ������
                                ( �� ��������� ��� �����������)

  �������:
  - ����������������� ������ �� ���������.
*/
function formatValueString(
  valueTypeCode varchar2
  , valueString varchar2
  , sourceValueFormat varchar2 := null
  , sourceDecimalChar varchar2 := null
  , encryptionFlag varchar2 := null
  , forbiddenChar varchar2 := null
)
return varchar2
is

  -- ������������ ������ ��� ����
  valueFormat varchar2(100);

begin
  case valueTypeCode
    when Date_ValueTypeCode then
      valueFormat := coalesce( sourceValueFormat, DateValue_ListFormat);
      return
        to_char(
          to_date(
              valueString
                -- ������������ ����������� �������������� ���� ��� �������
                -- ��� ���������� ���� ���������� �������
                || case when
                    valueFormat = 'fxyyyy-mm-dd hh24:mi:ss'
                    and sourceValueFormat is null
                    and valueString like '____-__-__'
                  then
                    ' 00:00:00'
                  end
              , valueFormat
            )
          , DateValue_ListFormat
        )
      ;
    when Number_ValueTypeCode then
      return
        to_char(
          toNumber(
            valueString   => valueString
            , decimalChar => sourceDecimalChar
          )
          , NumberValue_ListFormat
          , 'NLS_NUMERIC_CHARACTERS = ''' || Number_ListDecimalChar || ' '''
        )
      ;
    when String_ValueTypeCode then
      return
        case when encryptionFlag = 1 then
          pkg_OptionCrypto.encrypt(
            valueString
            , forbiddenChar => forbiddenChar
          )
        else
          valueString
        end
      ;
  end case;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������������� �������� ('
        || ' valueTypeCode="' || valueTypeCode || '"'
        || ', valueString="' || valueString || '"'
        || case when valueFormat is not null then
            ', valueFormat="' || valueFormat || '"'
          end
        || ').'
      )
    , true
  );
end formatValueString;

/* func: formatValueList
  ���������� ������ �������� � ����������� �������.

  ���������:
  valueTypeCode               - ��� ���� �������� ���������
  listSeparator               - ������, ������������ � �������� �����������
                                � ������������ ������
  valueList                   - �������� ������ ��������
  valueListSeparator          - ������, ������������ � �������� �����������
                                � ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  valueListItemFormat         - ������ ��������� � ������ �� ������� ��������
                                ���� ���� ( �� ��������� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������
                                ��������� �������)
  valueListDecimalChar        - ���������� ����������� ��� ������ �� �������
                                �������� ��������
                                ( �� ��������� ������������ �����)
  encryptionFlag              - ���� ���������� ��������� �������� �
                                ������������ ������
                                ( 1 ��, 0 ��� ( �� ���������))

  �������:
  ������ �������� � ����������� �������.
*/
function formatValueList(
  valueTypeCode varchar2
  , listSeparator varchar2
  , valueList varchar2
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , encryptionFlag varchar2 := null
)
return varchar2
is

  -- ����������������� ������
  resultList opt_value.string_value%type;

  -- ������ �������� � ������ ( ������� � 1)
  valueIndex pls_integer := 0;

  -- ������� ������� ������� �������� � ������
  beginPos pls_integer := 1;

  -- ������� �� ��������� �������� �������� � ������
  endPos pls_integer := 1;

  -- ����� ������
  len pls_integer;

begin
  resultList := null;
  len := coalesce( length( valueList), 0);
  while endPos <= len loop
    begin
      valueIndex := valueIndex + 1;
      endPos := instr(
        valueList
        , coalesce( valueListSeparator, ListSeparator_Default)
        , beginPos
      );
      if endPos = 0 then
        endPos := len + 1;
      end if;
      resultList :=
        resultList
        || case when valueIndex > 1 then listSeparator end
        || case when endPos > beginPos then
            formatValueString(
              valueTypeCode       => valueTypeCode
              , valueString       =>
                  substr( valueList, beginPos, endPos - beginPos)
              , sourceValueFormat => valueListItemFormat
              , sourceDecimalChar => valueListDecimalChar
              , encryptionFlag    => encryptionFlag
              , forbiddenChar     => listSeparator
            )
          end
      ;
      beginPos := endPos + 1;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ��������� �������� ������ ('
            || ' valueIndex=' || valueIndex
            || ').'
          )
        , true
      );
    end;
  end loop;
  logger.trace( 'formatValueList: "' || resultList || '"');
  return resultList;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������������� ������ ��������.'
      )
    , true
  );
end formatValueList;

/* iproc: getValueFromList
  ���������� �������� �� ������.

  ���������:
  dateValue                   - �������� ���� ����
                                ( �������)
  numberValue                 - �������� ��������
                                ( �������)
  stringValue                 - ��������� ��������
                                ( �������)
  valueTypeCode               - ��� ���� �������� ���������
  valueList                   - ������ ��������
  listSeparator               - ������, ������������ � �������� ����������� �
                                ������ ��������
  valueIndex                  - ������ �������� � ������ ( ������� � 1)
*/
procedure getValueFromList(
  dateValue out nocopy date
  , numberValue out nocopy number
  , stringValue out nocopy varchar2
  , valueTypeCode varchar2
  , valueList varchar2
  , listSeparator varchar2
  , valueIndex integer
)
is

  -- ������� ������� ������� ��������
  beginPos pls_integer;

  -- ������� ����� ���������� ������� ��������
  endPos pls_integer;



  /*
    ������������� �������� �� ������, �������� ���������� ����.
  */
  procedure setFromString(
    valueString varchar2
  )
  is
  begin
    case valueTypeCode
      when Date_ValueTypeCode then
        dateValue := to_date( valueString, DateValue_ListFormat);
      when Number_ValueTypeCode then
        numberValue := toNumber( valueString);
      when String_ValueTypeCode then
        stringValue := valueString;
    end case;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� �������� �� ������ ('
          || ' valueString="' || valueString || '"'
          || ').'
        )
      , true
    );
  end setFromString;



-- getValueFromList
begin
  if valueIndex = 1 then
    beginPos := 1;
  elsif valueIndex > 1 then
    beginPos := instr( valueList, listSeparator, 1, valueIndex - 1);
    if beginPos > 0 then
      beginPos := beginPos + 1;
    end if;
  else
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������ ������������ ������ ��������.'
    );
  end if;
  if beginPos > 0 then
    endPos := instr( valueList, listSeparator, beginPos);
    if endPos = 0 then
      endPos := length( valueList) + 1;
    end if;
  end if;
  if endPos > beginPos then
    setFromString(
      substr( valueList, beginPos, endPos - beginPos)
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� �������� �� ������.'
      )
    , true
  );
end getValueFromList;

/* func: getValueCount
  ���������� ����� �������� ��������.

  ���������:
  valueTypeCode               - ��� ���� �������� ���������
                                ( null ���� �������� �� ������)
  listSeparator               - ������, ������������ � �������� ����������� �
                                ������ �������� ( null ���� ������ ��
                                ������������)
  stringValue                 - ��������� �������� ��� ������ �� �������
                                ��������

  �������:
  0 ���� �������� ( � �.�. null) �� ������, ����� ������������� ����� ��������
  �������� ( 1 ���� ������ �������� ��� ���������, �� ������������� ������
  ��������, ���� ����� �������� � ������ �������� ���������).
*/
function getValueCount(
  valueTypeCode varchar2
  , listSeparator varchar2
  , stringValue varchar2
)
return integer
is

  -- ����� ��������
  valueCount pls_integer := 0;

begin
  if valueTypeCode is not null then
    if listSeparator is null or stringValue is null then
      valueCount := 1;
    else
      valueCount :=
        length( stringValue)
        - coalesce( length( replace( stringValue, listSeparator, '')), 0)
        + 1
      ;
    end if;
  end if;
  return valueCount;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ����������� ����� �������� ��������.'
      )
    , true
  );
end getValueCount;

/* proc: getValue
  ���������� �������� ���������.

  ���������:
  rowData                     - ������ �������� ( �������)
  optionId                    - Id ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������
                                ( �� ���������))
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  usedOperatorId              - Id ���������, ��� �������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  usedValueFlag               - ���� �������� ������������� � ������� ��
                                ��������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueTypeCode               - ��� ���� �������� ���������
                                ( ����������� ���������� ���� ���������� ��
                                  ����������, �� ��������� �� �����������)
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ( 1 ��, 0 ���)
                                ( ����������� ���������� ���� ���������� ��
                                  ����������, �� ��������� �� �����������)
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, �� ��������� null)
  decryptValueFlag            - ���� �������� ��������������� �������� �
                                ������, ���� ��� �������� � ������������� ����
                                ( 1 �� ( �� ���������), 0 ���)
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                �������� ( 1 �� ( �� ���������), 0 ���)

  ���������:
  - � ������, ���� ��� ��� ���� ������������� ������ ��� �������� ����������
    �� ��� �� ������ ��� ���������, �� �������� ������������;
  - � ������, ���� ������������ �������� ( ��� usedValueFlag = 1) �� ������� �
    ������� raiseNotFoundFlag ������ 0, �� � ������ rowData ����
    prod_value_flag � instance_name ����������� ����������, ����������������
    ������� ��, � ��������� ����� ������������ null;
  - � ������, ���� �������� ������������ ��������� �� ������ ( � �.�. �
    ������, ���� ������ �������� � valueIndex ��������� ����� �������� �
    ������ ���� ������ 1 ���� ������ �� ������������) � �������� ���������
    ������� raiseNotFoundFlag ����� 0, ������������ null;
  - � ������, ���� ������������ ������ �������� � ������ valueIndex, �� ����
    string_value ��������� ������ �������� � �������� � ��������� ��������
    ����������� � ���� �� ����� date_value, number_value ��� string_value
    �������� ���� ��������;
*/
procedure getValue(
  rowData out nocopy opt_value%rowtype
  , optionId integer
  , prodValueFlag integer := null
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , usedValueFlag integer := null
  , valueTypeCode varchar2 := null
  , valueListFlag integer := null
  , valueIndex integer := null
  , decryptValueFlag integer := null
  , raiseNotFoundFlag integer := null
)
is



  /*
    �������� ������ ������������� ��������.
  */
  procedure getUsedValue
  is

    -- ��������� ������� ��
    usedProdValueFlag opt_value.prod_value_flag%type
      := pkg_Common.isProduction()
    ;

    usedInstanceName opt_value.instance_name%type
      := upper( pkg_Common.getInstanceName())
    ;

  begin
    if prodValueFlag is not null or instanceName is not null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '��� ��������� ������������� �������� ����������� �� ���� ��'
          || ' � ����� ���������� ������������.'
      );
    end if;
    select
      a.*
    into rowData
    from
      (
      select
        vl.*
      from
        opt_option opn
        left outer join opt_value vl
          on vl.option_id = opn.option_id
            and vl.deleted = 0
            and vl.value_type_code = opn.value_type_code
            and case when vl.list_separator is not null then 1 else 0 end
              = opn.value_list_flag
            and nullif( vl.prod_value_flag, usedProdValueFlag) is null
            and nullif( vl.instance_name, usedInstanceName) is null
            and nullif( vl.used_operator_id, usedOperatorId) is null
      where
        opn.option_id = optionId
        and opn.deleted = 0
        -- ������������ ������ � ������, ���� �������� ������ ���� �������
        and ( raiseNotFoundFlag = 0 or vl.value_id is not null)
      order by
        vl.used_operator_id nulls last
        , vl.instance_name nulls last
        , vl.prod_value_flag nulls last
      ) a
    where
      rownum <= 1
    ;

    if rowData.value_id is null then

      -- ���������� ��������� ������� ��, ������� ����� ����������� � ������
      -- ��������� ��������
      select
        case when opn.test_prod_sensitive_flag = 1 then
            usedProdValueFlag
          end
          as prod_value_flag
      into rowData.prod_value_flag
      from
        opt_option opn
      where
        opn.option_id = optionId
        and opn.deleted = 0
      ;
      rowData.instance_name := usedInstanceName;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� �������� ��������.'
        )
      , true
    );
  end getUsedValue;



  /*
    �������� ������ ���������� ��������.
  */
  procedure getThisValue
  is
  begin
    select
      vl.*
    into rowData
    from
      opt_option opn
      left outer join opt_value vl
        on vl.option_id = opn.option_id
          and vl.deleted = 0
          and vl.value_type_code = opn.value_type_code
          and case when vl.list_separator is not null then 1 else 0 end
            = opn.value_list_flag
          and (
            vl.prod_value_flag = prodValueFlag
            or prodValueFlag is null
              and vl.prod_value_flag is null
          )
          and (
            vl.instance_name = upper( instanceName)
            or instanceName is null
              and vl.instance_name is null
          )
          and (
            vl.used_operator_id = usedOperatorId
            or usedOperatorId is null
              and vl.used_operator_id is null
          )
    where
      opn.option_id = optionId
      and opn.deleted = 0
      -- ������������ ������ � ������, ���� �������� ������ ���� �������
      and ( raiseNotFoundFlag = 0 or vl.value_id is not null)
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ���������� ��������.'
        )
      , true
    );
  end getThisValue;



  /*
    ������������� ������ �������� � ��������� ��������.
  */
  procedure setValueByIndex
  is

    -- ����� �������� ��������
    valueCount integer;

    -- ������ �� ������� ��������
    valueList opt_value.string_value%type;

  begin
    if valueIndex < 1 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������ ������������ ������ ��������.'
      );
    end if;
    valueCount := getValueCount(
      valueTypeCode   => rowData.value_type_code
      , listSeparator => rowData.list_separator
      , stringValue   => rowData.string_value
    );
    if coalesce( raiseNotFoundFlag, 1) != 0 and valueIndex > valueCount then
      raise_application_error(
        pkg_Error.IllegalArgument
        , case when rowData.list_separator is null then
            '������ ������������ ������ ��������'
            || ' ( �������� �� ���������� ������ ��������).'
          else
            '������ ������ ��������, ����������� ����� �������� � ������.'
          end
      );
    end if;
    if valueIndex > valueCount then
      rowData.date_value := null;
      rowData.number_value := null;
      rowData.string_value := null;
    elsif rowData.list_separator is not null
        and rowData.string_value is not null
        then
      valueList := rowData.string_value;
      getValueFromList(
        dateValue       => rowData.date_value
        , numberValue   => rowData.number_value
        , stringValue   => rowData.string_value
        , valueTypeCode => rowData.value_type_code
        , valueList     => valueList
        , listSeparator => rowData.list_separator
        , valueIndex    => valueIndex
      );
    end if;
  end setValueByIndex;



-- getValue
begin
  if usedValueFlag = 1 then
    getUsedValue();
  else
    getThisValue();
  end if;
  if rowData.value_id is not null then
    if rowData.value_type_code != valueTypeCode then
      raise_application_error(
        pkg_Error.ProcessError
        , '��� �������� ���������� �� ���������� ('
          || ' value_id=' || rowData.value_id
          || ', value_type_code="' || rowData.value_type_code || '"'
          || ').'
      );
    end if;
    if valueListFlag = 1 and rowData.list_separator is null
        or valueListFlag = 0 and rowData.list_separator is not null
        then
      raise_application_error(
        pkg_Error.ProcessError
        , '������������� ������ �������� ���������� �� ���������� ('
          || ' value_id=' || rowData.value_id
          || ', list_separator="' || rowData.list_separator || '"'
          || ').'
      );
    end if;
    if valueIndex is not null then
      setValueByIndex();
    end if;
    if rowData.encryption_flag = 1 and coalesce( decryptValueFlag, 1) != 0 then
      rowData.string_value := getDecryptValue(
        stringValue     => rowData.string_value
        , listSeparator => rowData.list_separator
      );
      rowData.encryption_flag := 0;
    end if;
  end if;
  logger.trace(
    'getValue:'
    || ' optionId=' || optionId
    || ': value_id=' || rowData.value_id
    || ' ( prodValueFlag=' || prodValueFlag
    || ', instanceName="' || instanceName || '"'
    || ', usedOperatorId=' || usedOperatorId
    || ', usedValueFlag=' || usedValueFlag
    || ', valueIndex=' || valueIndex
    || ')'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� �������� ��������� ('
        || ' optionId=' || optionId
        || ', prodValueFlag=' || prodValueFlag
        || ', instanceName="' || instanceName || '"'
        || ', usedOperatorId=' || usedOperatorId
        || ', usedValueFlag=' || usedValueFlag
        || ', valueTypeCode="' || valueTypeCode || '"'
        || ', valueListFlag=' || valueListFlag
        || ', valueIndex=' || valueIndex
        || ', raiseNotFoundFlag=' || raiseNotFoundFlag
        || ').'
      )
    , true
  );
end getValue;

/* proc: lockValue
  ��������� � ���������� ������ �������� ���������.

  ���������:
  rowData                     - ������ ������ ( �������)
  valueId                     - Id �������� ���������

  ���������:
  - � ������, ���� ������ ���� ��������� �������, ������������� ����������;
*/
procedure lockValue(
  rowData out nocopy opt_value%rowtype
  , valueId integer
)
is
begin
  select
    t.*
  into rowData
  from
    opt_value t
  where
    t.value_id = valueId
  for update nowait;

  if rowData.deleted = 1 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������ �� ������� ( ���� ��������� �������).'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� �������� ��������� ('
        || ' valueId=' || valueId
        || ').'
      )
    , true
  );
end lockValue;

/* iproc: fillValueData
  ��������� ���� � ������� �������� � ��������� �������� ������������.

  ���������:
  valueId                     - Id ��������
  valueTypeCode               - ��� ���� �������� ���������
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� �������� ��� ������ �� �������
                                ��������
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
  setValueListFlag            - ���������� �������� �������� ������ �� �������
                                ��������, ���������� � ��������� stringValue
                                ( 1 ��, 0 ��� ( �� ���������))
  valueListSeparator          - ������, ������������ � �������� �����������
                                � ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  valueListItemFormat         - ������ ��������� � ������ �� ������� ��������
                                ���� ���� ( �� ��������� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������
                                ��������� �������)
  valueListDecimalChar        - ���������� ����������� ��� ������ �� �������
                                �������� ��������
                                ( �� ��������� ������������ �����)
  ignoreTestProdSensitiveFlag - ��� �������� �������� �� ��������� ���
                                ������������ �������� �������� �����
                                test_prod_sensitive_flag ���������
                                ( 1 ��, 0 ��� ( ����������� ���������� ���
                                  �����������))
                                ( �� ��������� 0)
*/
procedure fillValueData(
  vlr in out nocopy opt_value%rowtype
  , opt opt_option%rowtype
  , valueTypeCode varchar2
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , setValueListFlag integer := null
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , ignoreTestProdSensitiveFlag integer := null
)
is



  /*
    ��������� ������������ � ������������� ����������.
  */
  procedure checkArgs
  is
  begin
    if dateValue is not null
        and (
          valueTypeCode != Date_ValueTypeCode
          or setValueListFlag = 1
        )
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������� �������������� �������� ��������� dateValue ('
          || ' dateValue=' || to_char( dateValue, 'dd.mm.yyyy hh24:mi:ss')
          || ').'
      );
    end if;
    if numberValue is not null
        and (
          valueTypeCode != Number_ValueTypeCode
          or setValueListFlag = 1
        )
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������� �������������� �������� ��������� numberValue ('
          || ' numberValue=' || numberValue
          || ').'
      );
    end if;
    if stringValue is not null
        and (
          valueTypeCode != String_ValueTypeCode
          and coalesce( setValueListFlag, 0) != 1
        )
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������� �������������� �������� ��������� stringValue ('
          || ' stringValue="' || stringValue || '"'
          || ').'
      );
    end if;
    if opt.value_list_flag = 0
        and (
          nullif( valueIndex, 1) is not null
          or setValueListFlag = 1
          or valueListSeparator is not null
          or valueListItemFormat is not null
          or valueListDecimalChar is not null
        )
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������������ ��������, �.�. �������� �� ���������� ������ �������� ('
          || ' valueIndex=' || valueIndex
          || ', setValueListFlag=' || setValueListFlag
          || ', valueListSeparator="' || valueListSeparator || '"'
          || ', valueListItemFormat="' || valueListItemFormat || '"'
          || ', valueListDecimalChar="' || valueListDecimalChar || '"'
          || ').'
      );
    end if;
    if valueIndex < -1 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������ ������������ ������ �������� ('
          || ' valueIndex=' || valueIndex
          || ').'
      );
    end if;
    if setValueListFlag = 1 and valueIndex is not null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������ �������� ����� ���� ����������� ������ ��� ���������'
          || ' ����� �������� ('
          || ' valueIndex=' || valueIndex
          || ').'
      );
    end if;
    if valueListItemFormat is not null
        and valueTypeCode != Date_ValueTypeCode
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������� �������������� �������� ��������� valueListItemFormat ('
          || ' valueListItemFormat="' || valueListItemFormat || '"'
          || ').'
      );
    end if;
    if valueListDecimalChar is not null
        and valueTypeCode != Number_ValueTypeCode
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������� �������������� �������� ��������� valueListDecimalChar ('
          || ' valueListDecimalChar="' || valueListDecimalChar || '"'
          || ').'
      );
    end if;
  end checkArgs;



  /*
    ���������� �������� �������� � ���� ������.
  */
  function getValueString
  return varchar2
  is
  begin
    case opt.value_type_code
      when Date_ValueTypeCode then
        return
          to_char( dateValue, DateValue_ListFormat)
        ;
      when Number_ValueTypeCode then
        return
          to_char(
            numberValue
            , NumberValue_ListFormat
            , 'NLS_NUMERIC_CHARACTERS = ''' || Number_ListDecimalChar || ' '''
          )
        ;
      when String_ValueTypeCode then
        if instr( stringValue, vlr.list_separator) > 0 then
          raise_application_error(
            pkg_Error.IllegalArgument
            , '������ �� ��������� �������� ������ ��������'
              || ' ������-����������� ('
              || ' list_separator="' || vlr.list_separator || '"'
              || ').'
          );
        end if;
        return
          case when opt.encryption_flag = 1 then
            pkg_OptionCrypto.encrypt(
              stringValue
              , forbiddenChar => vlr.list_separator
            )
          else
            stringValue
          end
        ;
    end case;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� �������� �������� � ���� ������.'
        )
      , true
    );
  end getValueString;



  /*
    �������� ������� ������ ��������.
  */
  procedure setValueListItem
  is

    -- �������� �������� � ���� ������
    valueString opt_value.string_value%type;

    -- ������� ������� ������� ��������
    beginPos pls_integer;

    -- ������� ����� ���������� ������� ��������
    endPos pls_integer;

  -- setValueListItem
  begin
    valueString := getValueString();
    if valueIndex = 0 then
      vlr.string_value := valueString || vlr.list_separator || vlr.string_value;
    elsif valueIndex = -1 then
      vlr.string_value := vlr.string_value || vlr.list_separator || valueString;
    else
      if valueIndex = 1 then
        beginPos := 1;
      elsif valueIndex > 1 then
        beginPos :=
          instr( vlr.string_value, vlr.list_separator, 1, valueIndex - 1)
        ;
        if beginPos > 0 then
          beginPos := beginPos + 1;
        else
          vlr.string_value :=
            vlr.string_value
            || rpad(
                vlr.list_separator
                , valueIndex
                  - getValueCount(
                      valueTypeCode   => vlr.value_type_code
                      , listSeparator => vlr.list_separator
                      , stringValue   => vlr.string_value
                    )
                , vlr.list_separator
              )
          ;
          beginPos := length( vlr.string_value) + 1;
        end if;
      else
        raise_application_error(
          pkg_Error.IllegalArgument
          , '������ ������������ ������ ��������.'
        );
      end if;
      endPos := instr( vlr.string_value, vlr.list_separator, beginPos);
      if endPos = 0 then
        endPos := length( vlr.string_value) + 1;
      end if;
      vlr.string_value :=
        substr( vlr.string_value, 1, beginPos - 1)
        || valueString
        || substr( vlr.string_value, endPos)
      ;
    end if;
    logger.trace(
      'setValueListItem:'
      || ' valueIndex=' || valueIndex
      || ', valueString="' || valueString || '"'
      || ', string_value="' || vlr.string_value || '"'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� �������� ������ �������� ('
          || ' valueString="' || valueString || '"'
          || ').'
        )
      , true
    );
  end setValueListItem;



  /*
    ��������� ���� ������.
  */
  procedure fillData
  is
  begin
    vlr.value_type_code           := valueTypeCode;
    vlr.list_separator            :=
      case
        when opt.value_list_flag = 1 then
          coalesce(
            case when
                    opt.value_type_code = String_ValueTypeCode
                    and (
                      valueIndex is null
                      or vlr.list_separator is null
                      or vlr.string_value is null
                    )
                  then
                coalesce( valueListSeparator, ListSeparator_Default)
              end
            , vlr.list_separator
            , ListSeparator_Default
          )
      end
    ;
    vlr.encryption_flag           := opt.encryption_flag;
    vlr.storage_value_type_code   :=
      case when opt.value_list_flag = 1 then
        String_ValueTypeCode
      else
        valueTypeCode
      end
    ;
    if opt.value_list_flag = 0 then
      vlr.date_value   := dateValue;
      vlr.number_value := numberValue;
      vlr.string_value :=
        case when opt.encryption_flag = 1 then
          pkg_OptionCrypto.encrypt( stringValue)
        else
          stringValue
        end
      ;
      logger.trace(
        'set single value:'
        || ' date_value=' || to_char( vlr.date_value, 'dd.mm.yyyy hh24:mi:ss')
        || ', number_value=' || vlr.number_value
        || ', string_value="' || vlr.string_value || '"'
      );
    else
      vlr.date_value   := null;
      vlr.number_value := null;
      if valueIndex is null then
        if setValueListFlag = 1 then
          if opt.value_type_code != String_ValueTypeCode
                or vlr.encryption_flag = 1
              then
            vlr.string_value := formatValueList(
              valueTypeCode           => opt.value_type_code
              , listSeparator         => vlr.list_separator
              , valueList             => stringValue
              , valueListSeparator    => valueListSeparator
              , valueListItemFormat   => valueListItemFormat
              , valueListDecimalChar  => valueListDecimalChar
              , encryptionFlag        => opt.encryption_flag
            );
          else
            vlr.string_value := stringValue;
            logger.trace( 'set string list: "' || vlr.string_value || '"');
          end if;
        else
          vlr.string_value := getValueString();
          logger.trace( 'set string list(1): "' || vlr.string_value || '"');
        end if;
      else
        setValueListItem();
      end if;
    end if;
  end fillData;



  /*
    ��������� ���������� ����� ��������.
  */
  procedure checkData
  is
  begin
    if coalesce(
          vlr.value_type_code != opt.value_type_code
          , true
        )
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '��� �������� ���������� �� ���������� ��� ��������� ('
          || ' value_type_code="' || opt.value_type_code || '"'
          || ').'
      );
    elsif coalesce( ignoreTestProdSensitiveFlag, 0) != 1
        and (
          opt.test_prod_sensitive_flag = 0 and vlr.prod_value_flag is not null
          or opt.test_prod_sensitive_flag = 1 and vlr.prod_value_flag is null
        )
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '�������� ��������� ������ ���� ������'
          || case when opt.test_prod_sensitive_flag = 0 then
              ' ��� ��������'
            else
              ' � ���������'
            end
          || ' ���� �� ( �������� ��� ������������).'
      );
    elsif vlr.list_separator is not null and opt.value_list_flag = 0 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������ ������-����������� ������ ��� ���������, �� �������������'
          || ' ������ ��������.'
      );
    elsif vlr.list_separator is null and opt.value_list_flag = 1 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '�� ������ ������-����������� ������ ��� ���������, �������������'
          || ' ������ ��������.'
      );
    elsif vlr.list_separator != ListSeparator_Default
          and opt.value_type_code != String_ValueTypeCode
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '����������� ������-����������� ����� ���� ����� ������ ��� ������'
          || ' ��������� ��������.'
      );
    end if;
  end checkData;



-- fillValueData
begin
  checkArgs();
  fillData();
  checkData();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� ����� � ������� �������� ('
        || ' valueTypeCode="' || valueTypeCode || '"'
        || ', valueIndex=' || valueIndex
        || ', setValueListFlag=' || setValueListFlag
        || ').'
      )
    , true
  );
end fillValueData;

/* func: createValue
  ������� �������� ���������.

  ���������:
  optionId                    - Id ���������
  valueTypeCode               - ��� ���� �������� ���������
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
  stringValue                 - ��������� �������� ��� ������ �� �������
                                ��������
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
  setValueListFlag            - ���������� �������� �������� ������ �� �������
                                ��������, ���������� � ��������� stringValue
                                ( 1 ��, 0 ��� ( �� ���������))
  valueListSeparator          - ������, ������������ � �������� �����������
                                � ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  valueListItemFormat         - ������ ��������� � ������ �� ������� ��������
                                ���� ���� ( �� ��������� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������
                                ��������� �������)
  valueListDecimalChar        - ���������� ����������� ��� ������ �� �������
                                �������� ��������
                                ( �� ��������� ������������ �����)
  ignoreTestProdSensitiveFlag - ��� �������� �������� �� ��������� ���
                                ������������ �������� �������� �����
                                test_prod_sensitive_flag ���������
                                ( 1 ��, 0 ��� ( ����������� ���������� ���
                                  �����������))
                                ( �� ��������� 0)
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id �������� ���������.
*/
function createValue(
  optionId integer
  , valueTypeCode varchar2
  , prodValueFlag integer := null
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , setValueListFlag integer := null
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , ignoreTestProdSensitiveFlag integer := null
  , operatorId integer := null
)
return integer
is

  -- ������ � ���� ������
  rec opt_value%rowtype;

  -- ������ ���������
  opt opt_option%rowtype;



  /*
    ��������� ���� ������.
  */
  procedure fillData
  is
  begin
    rec.option_id                 := optionId;
    rec.prod_value_flag           := prodValueFlag;
    rec.instance_name             := upper( instanceName);
    rec.used_operator_id          := usedOperatorId;
    rec.operator_id               := operatorId;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� ����� ������.'
        )
      , true
    );
  end fillData;



  /*
    ��������� ������ � ������� opt_value � ���������� ��������� ( true �
    ������ ������, false � ������ ������ ��-�� ��������� ������������).
  */
  function insertRecord
  return boolean
  is
  begin
    insert into
      opt_value
    values
      rec
    returning
      value_id
    into
      rec.value_id
    ;
    logger.trace(
      'createValue: opt_value inserted:'
      || ' value_id=' || rec.value_id
      || ', option_id=' || rec.option_id
      || ', prod_value_flag=' || rec.prod_value_flag
      || ', instance_name="' || rec.instance_name || '"'
      || ', used_operator_id=' || rec.used_operator_id
      || ', value_type_code="' || rec.value_type_code || '"'
      || ', list_separator="' || rec.list_separator || '"'
    );
    return true;
  exception
    when DUP_VAL_ON_INDEX then
      logger.trace(
        'createValue: insertRecord: DUP_VAL_ON_INDEX error: ' || SQLERRM
      );
      logger.clearErrorStack();
      return false;
    when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ������� ������ � ������� opt_value.'
          )
        , true
      );
  end insertRecord;



  /*
    ��������������� ����� ��������� ������.
  */
  procedure restoreDeleted
  is
  begin
    select
      d.value_id
      , d.deleted
    into rec.value_id, rec.deleted
    from
      opt_value d
    where
      d.option_id = rec.option_id
      and (
        rec.prod_value_flag is null
          and d.prod_value_flag is null
        or d.prod_value_flag = rec.prod_value_flag
      )
      and (
        rec.instance_name is null
          and d.instance_name is null
        or d.instance_name = rec.instance_name
      )
      and (
        rec.used_operator_id is null
          and d.used_operator_id is null
        or d.used_operator_id = rec.used_operator_id
      )
    for update nowait;

    if rec.deleted = 0 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '�������� ���� ������� ����� ('
          || ' value_id=' || rec.value_id
          || ').'
      );
    end if;

    update
      opt_value d
    set
      d.value_type_code             = rec.value_type_code
      , d.list_separator            = rec.list_separator
      , d.encryption_flag           = rec.encryption_flag
      , d.storage_value_type_code   = rec.storage_value_type_code
      , d.date_value                = rec.date_value
      , d.number_value              = rec.number_value
      , d.string_value              = rec.string_value
      , d.deleted                   = 0
      , d.change_operator_id        = rec.operator_id
    where
      d.value_id = rec.value_id
    ;
    logger.trace(
      'createValue: restore deleted: opt_value updated:'
      || ' value_id=' || rec.value_id
      || ', option_id=' || rec.option_id
      || ', prod_value_flag=' || rec.prod_value_flag
      || ', instance_name="' || rec.instance_name || '"'
      || ', used_operator_id=' || rec.used_operator_id
      || ', value_type_code="' || rec.value_type_code || '"'
      || ', list_separator="' || rec.list_separator || '"'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������������� ����� ��������� ������.'
        )
      , true
    );
  end restoreDeleted;



-- createValue
begin
  lockOption( opt, optionId => optionId);
  fillData();
  fillValueData(
    vlr                           => rec
    , opt                         => opt
    , valueTypeCode               => valueTypeCode
    , dateValue                   => dateValue
    , numberValue                 => numberValue
    , stringValue                 => stringValue
    , valueIndex                  => valueIndex
    , setValueListFlag            => setValueListFlag
    , valueListSeparator          => valueListSeparator
    , valueListItemFormat         => valueListItemFormat
    , valueListDecimalChar        => valueListDecimalChar
    , ignoreTestProdSensitiveFlag => ignoreTestProdSensitiveFlag
  );
  if not insertRecord() then
    restoreDeleted();
  end if;
  return rec.value_id;
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
  valueTypeCode               - ��� ���� �������� ���������
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� �������� ��� ������ �� �������
                                ��������
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
  setValueListFlag            - ���������� �������� �������� ������ �� �������
                                ��������, ���������� � ��������� stringValue
                                ( 1 ��, 0 ��� ( �� ���������))
  valueListSeparator          - ������, ������������ � �������� �����������
                                � ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  valueListItemFormat         - ������ ��������� � ������ �� ������� ��������
                                ���� ���� ( �� ��������� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������
                                ��������� �������)
  valueListDecimalChar        - ���������� ����������� ��� ������ �� �������
                                �������� ��������
                                ( �� ��������� ������������ �����)
  operatorId                  - Id ��������� ( �� ��������� �������)
*/
procedure updateValue(
  valueId integer
  , valueTypeCode varchar2
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , setValueListFlag integer := null
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , operatorId integer := null
)
is

  -- ������ � ���� ������
  rec opt_value%rowtype;

  -- ������ ���������
  opt opt_option%rowtype;



  /*
    �������� ������ � ������� opt_value.
  */
  procedure updateRecord
  is
  begin
    update
      opt_value d
    set
      d.value_type_code           = rec.value_type_code
      , d.list_separator          = rec.list_separator
      , d.encryption_flag         = rec.encryption_flag
      , d.storage_value_type_code = rec.storage_value_type_code
      , d.date_value              = rec.date_value
      , d.number_value            = rec.number_value
      , d.string_value            = rec.string_value
      , d.change_operator_id      = rec.change_operator_id
    where
      d.value_id = rec.value_id
    ;
    logger.trace(
      'updateValue: opt_value updated:'
      || ' value_id=' || rec.value_id
      || ', option_id=' || rec.option_id
      || ', valueTypeCode="' || rec.value_type_code || '"'
      || ', list_separator="' || rec.list_separator || '"'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ������ � ������� opt_value.'
        )
      , true
    );
  end updateRecord;



-- updateValue
begin
  lockValue( rec, valueId => valueId);
  lockOption( opt, optionId => rec.option_id);
  rec.change_operator_id        := operatorId;
  fillValueData(
    vlr                           => rec
    , opt                         => opt
    , valueTypeCode               => valueTypeCode
    , dateValue                   => dateValue
    , numberValue                 => numberValue
    , stringValue                 => stringValue
    , valueIndex                  => valueIndex
    , setValueListFlag            => setValueListFlag
    , valueListSeparator          => valueListSeparator
    , valueListItemFormat         => valueListItemFormat
    , valueListDecimalChar        => valueListDecimalChar
    , ignoreTestProdSensitiveFlag => 0
  );
  updateRecord();
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

/* proc: setValue
  ������������� �������� ���������.

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
  valueTypeCode               - ��� ���� �������� ���������
                                ( �� ��������� ������������ �� ������ ���������)
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� �������� ��� ������ �� �������
                                ��������
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
  setValueListFlag            - ���������� �������� �������� ������ �� �������
                                ��������, ���������� � ��������� stringValue
                                ( 1 ��, 0 ��� ( �� ���������))
  valueListSeparator          - ������, ������������ � �������� �����������
                                ��������� � ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  valueListItemFormat         - ������ ��������� � ������ �� ������� ��������
                                ���� ���� ( �� ��������� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������
                                ��������� �������)
  valueListDecimalChar        - ���������� ����������� ��� ������ �� �������
                                �������� ��������
                                ( �� ��������� ������������ �����)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ��� ��������� �������� � ����������� �� ��� ������� ������������ ����
    ������� <createValue> ���� ��������� <updateValue>;
*/
procedure setValue(
  optionId integer
  , prodValueFlag integer
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , valueTypeCode varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , setValueListFlag integer := null
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , operatorId integer := null
)
is

  -- ������ ���������
  opt opt_option%rowtype;

  -- Id �������� ���������
  valueId integer;

-- setValue
begin
  lockOption( opt, optionId => optionId);
  select
    min( d.value_id)
  into valueId
  from
    opt_value d
  where
    d.option_id = optionId
    and (
      prodValueFlag is null
        and d.prod_value_flag is null
      or d.prod_value_flag = prodValueFlag
    )
    and (
      instanceName is null
        and d.instance_name is null
      or d.instance_name = instanceName
    )
    and (
      usedOperatorId is null
        and d.used_operator_id is null
      or d.used_operator_id = usedOperatorId
    )
    -- �������������� �������� �������� � createValue
    and d.deleted = 0
  ;
  if valueId is null then
    valueId := createValue(
      optionId                => optionId
      , prodValueFlag         => prodValueFlag
      , instanceName          => instanceName
      , usedOperatorId        => usedOperatorId
      , valueTypeCode         => coalesce( valueTypeCode, opt.value_type_code)
      , dateValue             => dateValue
      , numberValue           => numberValue
      , stringValue           => stringValue
      , valueIndex            => valueIndex
      , setValueListFlag      => setValueListFlag
      , valueListSeparator    => valueListSeparator
      , valueListItemFormat   => valueListItemFormat
      , valueListDecimalChar  => valueListDecimalChar
      , operatorId            => operatorId
    );
  else
    updateValue(
      valueId                 => valueId
      , valueTypeCode         => coalesce( valueTypeCode, opt.value_type_code)
      , dateValue             => dateValue
      , numberValue           => numberValue
      , stringValue           => stringValue
      , valueIndex            => valueIndex
      , setValueListFlag      => setValueListFlag
      , valueListSeparator    => valueListSeparator
      , valueListItemFormat   => valueListItemFormat
      , valueListDecimalChar  => valueListDecimalChar
      , operatorId            => operatorId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� �������� ��������� ('
        || ' optionId=' || optionId
        || ', prodValueFlag=' || prodValueFlag
        || ', instanceName="' || instanceName || '"'
        || ', usedOperatorId=' || usedOperatorId
        || ', valueTypeCode="' || valueTypeCode || '"'
        || ').'
      )
    , true
  );
end setValue;

/* proc: deleteValue
  ������� �������� ���������.

  ���������:
  valueId                     - Id �������� ���������
  operatorId                  - Id ��������� ( �� ��������� �������)
*/
procedure deleteValue(
  valueId integer
  , operatorId integer := null
)
is

  -- ������ � ���� ������
  vlr opt_value%rowtype;

  -- ������ ���������
  opt opt_option%rowtype;

  -- ���� �������� ���������
  changeDate date := sysdate;

begin
  lockValue( vlr, valueId => valueId);
  lockOption( opt, optionId => vlr.option_id);
  update
    opt_value d
  set
    d.deleted = 1
    , d.change_operator_id = operatorId
  where
    d.value_id = vlr.value_id
  ;
  logger.trace(
    'deleteValue: set deleted: opt_value updated:'
    || ' value_id=' || vlr.value_id
    || ', option_id=' || vlr.option_id
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



/* group: �������������� ������� */

/* proc: addOptionWithValue
  ��������� ����������� �������� �� ���������, ���� �� �� ��� ������ �����.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��������
  optionShortName             - ������� ������������ ���������
  valueTypeCode               - ��� ���� �������� ���������
  optionName                  - ������������ ���������
  objectShortName             - ������� ������������ ������� ������
                                ( �� ��������� �����������)
  objectTypeId                - Id ���� �������
                                ( �� ��������� �����������)
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ���������� ���� ( 1 ��, 0 ��� ( �� ���������))
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ����
                                ( 1 ��, 0 ��� ( �� ���������))
  testProdSensitiveFlag       - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
                                ( 1 ��, 0 ��� ( �� ���������))
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( �� ��������� ������ ��������� �������� �
                                  ������ �������� �������� � �������������
                                  ����, ����� ������ ������)
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  usedOperatorId              - Id ���������, ��� �������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  dateValue                   - �������� ���� ���� ��� ���� ���� ���
                                ������������ ��
                                ( �� ��������� �����������)
  testDateValue               - �������� ���� ���� ��� �������� ��
                                ( �� ��������� �����������)
  numberValue                 - �������� �������� ��� ���� ���� ���
                                ������������ ��
                                ( �� ��������� �����������)
  testNumberValue             - �������� �������� ��� �������� ��
                                ( �� ��������� �����������)
  stringValue                 - ��������� �������� ��� ������ �� �������
                                �������� ��� ���� ���� ��� ������������ ��
                                ( �� ��������� �����������)
  testStringValue             - ��������� �������� ��� ������ �� �������
                                �������� ��� �������� ��
                                ( �� ��������� �����������)
  setValueListFlag            - ���������� �������� �������� ������ �� �������
                                ��������, ���������� � ��������� stringValue
                                ( 1 ��, 0 ��� ( �� ���������))
  valueListSeparator          - ������, ������������ � �������� �����������
                                ��������� ������� ��������, ��������� �
                                ���������� stringValue � testStringValue
                                ( �� ��������� ������������ ";")
  valueListItemFormat         - ������ ��������� � ������ �� ������� ��������
                                ���� ���� ( �� ��������� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������
                                ��������� �������)
  valueListDecimalChar        - ���������� ����������� ��� ������� ��������
                                ��������, ��������� � ���������� stringValue �
                                testStringValue
                                ( �� ��������� ������������ �����)
  changeValueFlag             - ���������� �������� ���������, ���� �� ���
                                ������ �����
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)
*/
procedure addOptionWithValue(
  moduleId integer
  , optionShortName varchar2
  , valueTypeCode varchar2
  , optionName varchar2
  , objectShortName varchar2 := null
  , objectTypeId integer := null
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , dateValue date := null
  , testDateValue date := null
  , numberValue number := null
  , testNumberValue number := null
  , stringValue varchar2 := null
  , testStringValue varchar2 := null
  , setValueListFlag integer := null
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
)
is

  -- Id ���������
  optionId integer;

  -- ������� �������� ���������
  isCreateOption boolean;

begin
  optionId := getOptionId(
    moduleId              => moduleId
    , objectShortName     => objectShortName
    , objectTypeId        => objectTypeId
    , optionShortName     => optionShortName
    , raiseNotFoundFlag   => 0
  );
  isCreateOption := optionId is null;
  if isCreateOption then
    optionId := createOption(
      moduleId                => moduleId
      , optionShortName       => optionShortName
      , valueTypeCode         => valueTypeCode
      , optionName            => optionName
      , objectShortName       => objectShortName
      , objectTypeId          => objectTypeId
      , valueListFlag         => valueListFlag
      , encryptionFlag        => encryptionFlag
      , testProdSensitiveFlag => testProdSensitiveFlag
      , accessLevelCode       => accessLevelCode
      , optionDescription     => optionDescription
      , operatorId            => operatorId
    );
  end if;
  if isCreateOption or changeValueFlag = 1 then
    setValue(
      optionId                => optionId
      , prodValueFlag         => case when testProdSensitiveFlag = 1 then 1 end
      , instanceName          => instanceName
      , usedOperatorId        => usedOperatorId
      , dateValue             => dateValue
      , numberValue           => numberValue
      , stringValue           => stringValue
      , setValueListFlag      => setValueListFlag
      , valueListSeparator    => valueListSeparator
      , valueListItemFormat   => valueListItemFormat
      , valueListDecimalChar  => valueListDecimalChar
      , operatorId            => operatorId
    );
    if testProdSensitiveFlag = 1 then
      setValue(
        optionId                => optionId
        , prodValueFlag         => 0
        , instanceName          => instanceName
        , usedOperatorId        => usedOperatorId
        , dateValue             => testDateValue
        , numberValue           => testNumberValue
        , stringValue           => testStringValue
        , setValueListFlag      => setValueListFlag
        , valueListSeparator    => valueListSeparator
        , valueListItemFormat   => valueListItemFormat
        , valueListDecimalChar  => valueListDecimalChar
        , operatorId            => operatorId
      );
    end if;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� ��������� �� ��������� ('
        || ' moduleId=' || moduleId
        || ', objectShortName="' || objectShortName || '"'
        || ', objectTypeId=' || objectTypeId
        || ', optionShortName="' || optionShortName || '"'
        || ', testProdSensitiveFlag=' || testProdSensitiveFlag
        || ', changeValueFlag=' || changeValueFlag
        || ').'
      )
    , true
  );
end addOptionWithValue;

/* proc: getOptionValue
  ���������� ������� ���������� � �������� ������������� ����������.

  ���������:
  rowTable                    - ������� � �������
                                ( ��� <opt_option_value_table_t>)
                                ( �������)
  moduleId                    - Id ������, � �������� ��������� ���������
  objectShortName             - ������� ������������ ������� ������, � ��������
                                ��������� ��������� ( �� ��������� �����������
                                �� ����� ������)
  objectTypeId                - Id ���� �������
                                ( null ��� ���������� ������� ( �� ���������))
  usedOperatorId              - Id ���������, ��� �������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))

  ���������:
  - ��������� ��������� �������� ������ �� ������������� <v_opt_option_value>
    � ��������� ���������� usedOperatorId;
*/
procedure getOptionValue(
  rowTable out nocopy opt_option_value_table_t
  , moduleId integer
  , objectShortName varchar2 := null
  , objectTypeId integer := null
  , usedOperatorId integer := null
)
is

  cursor dataCur is
    select
      t.*
    from
      v_opt_option_value t
    where
      t.module_id = moduleId
      and (
        objectShortName is null
          and t.object_short_name is null
        or t.object_short_name = objectShortName
          and t.object_type_id = objectTypeId
      )
    order by
      t.option_short_name
  ;

-- getOptionValue
begin
  rowTable := opt_option_value_table_t();
  currentUsedOperatorId := usedOperatorId;
  for rec in dataCur loop
    begin
      rowTable.extend(1);
      rowTable( rowTable.last()) :=
        opt_option_value_t(
          option_id                         => rec.option_id
          , value_id                        => rec.value_id
          , module_name                     => rec.module_name
          , object_short_name               => rec.object_short_name
          , object_type_short_name          => rec.object_type_short_name
          , option_short_name               => rec.option_short_name
          , value_type_code                 => rec.value_type_code
          , date_value                      => rec.date_value
          , number_value                    => rec.number_value
          , string_value                    =>
              case when
                rec.encryption_flag = 1 and rec.string_value is not null
              then
                getDecryptValue(
                  stringValue     => rec.string_value
                  , listSeparator => rec.list_separator
                )
              else
                rec.string_value
              end
          , encrypted_string_value          =>
              case when rec.encryption_flag = 1 then
                rec.string_value
              end
          , list_separator                  => rec.list_separator
          , value_list_flag                 => rec.value_list_flag
          , encryption_flag                 => rec.encryption_flag
          , test_prod_sensitive_flag        => rec.test_prod_sensitive_flag
          , access_level_code               => rec.access_level_code
          , option_name                     => rec.option_name
          , option_description              => rec.option_description
          , prod_value_flag                 => rec.prod_value_flag
          , instance_name                   => rec.instance_name
          , used_operator_id                => rec.used_operator_id
          , module_id                       => rec.module_id
          , module_svn_root                 => rec.module_svn_root
          , object_type_id                  => rec.object_type_id
          , object_type_name                => rec.object_type_name
          , object_type_module_id           => rec.object_type_module_id
          , object_type_module_name         => rec.object_type_module_name
          , object_type_module_svn_root     => rec.object_type_module_svn_root
          , option_change_number            => rec.option_change_number
          , option_change_date              => rec.option_change_date
          , option_change_operator_id       => rec.option_change_operator_id
          , option_date_ins                 => rec.option_date_ins
          , option_operator_id              => rec.option_operator_id
          , value_change_number             => rec.value_change_number
          , value_change_date               => rec.value_change_date
          , value_change_operator_id        => rec.value_change_operator_id
          , value_date_ins                  => rec.value_date_ins
          , value_operator_id               => rec.value_operator_id
        )
      ;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ��������� ������ ('
            || ' option_id=' || rec.option_id
            || ', value_id=' || rec.value_id
            || ').'
          )
        , true
      );
    end;
  end loop;

  currentUsedOperatorId := null;
exception when others then
  currentUsedOperatorId := null;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ������� ���������� � �������� ���������� ('
        || ' moduleId=' || moduleId
        || ', objectShortName="' || objectShortName || '"'
        || ', objectTypeId=' || objectTypeId
        || ', usedOperatorId=' || usedOperatorId
        || ').'
      )
    , true
  );
end getOptionValue;

end pkg_OptionMain;
/
