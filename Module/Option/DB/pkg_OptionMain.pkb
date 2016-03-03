create or replace package body pkg_OptionMain is
/* package body: pkg_OptionMain::body */



/* group: ��������� */

/* iconst: OldTestOptionName_Suffix
  ����������� �������, � ������� �������� �������� �������� ���������
  ��������� � ���������� ������� opt_option.
*/
OldTestOptionName_Suffix varchar2(10) := ' (����)';

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



/* group: ��������� ���������� �������� */

/* itype: IdListT
  ������ Id �������.
*/
type IdListT is table of integer;

/* itype: OptionSNameListT
  ������ �������� �������� �������.
*/
type OptionSNameListT is table of opt_option.option_short_name%type;

/* iconst: BatchLoader_ModuleName
  ��� ������ BatchLoader.
*/
BatchLoader_ModuleName constant varchar2(50) := 'BatchLoader';

/* iconst: Scheduler_SvnRoot
  ���� � SVN � ��������� �������� ������ Scheduler.
*/
Scheduler_SvnRoot constant varchar2(100) := 'Oracle/Module/Scheduler';

/* iconst: Batch_ObjectTypeShortName
  �������� �������� ���� ������� ��� �������� ������� ������ Scheduler.
*/
Batch_ObjectTypeShortName constant varchar2(30) := 'batch';

/* ivar: isCopyNew2OldChange
  ������� ����������� ���������, �������� � ����� �������, � ����������
  �������.
*/
isCopyNew2OldChange boolean := true;

/* ivar: isCopyOld2NewChange
  ������� ����������� ���������, �������� � ���������� �������, � �����
  �������.
*/
isCopyOld2NewChange boolean := true;

/* ivar: isSkipCheckNew2OldSync
  ������� �������� �������� ���������� ����������� ����� ���������� ����������
  � ����� � ���������� �������� ��� ���������� ��������� <checkNew2OldSync>
  ( �� ��������� �� ����������).
*/
isSkipCheckNew2OldSync boolean := false;

/* ivar: onChangeTableName
  ��� �������, ��� ������� ����������� DML ( OPT_OPTION / OPT_OPTION_VALUE).
*/
onChangeTableName varchar2(30);

/* ivar: onChangeStatementType
  ��� DML, ������������ ��� �������� ( INSERT / UPDATE / DELETE).
*/
onChangeStatementType varchar2(30);

/* ivar: onChangeIdList
  ������ Id ���������� �������.
*/
onChangeIdList IdListT;

/* ivar: onDeleteOptionSNameList
  ������ �������� �������� ���������� ( ���� option_short_name) ��� ���������
  �� <opt_option> �������.
*/
onDeleteOptionSNameList OptionSNameListT;

/* ivar: schedulerExistsInfo
  ���������� �� ������� ������ Scheduler � ����� �����
  ( null ����������, 0 �����������, 1 ������������ ��� ���� module_id,
    2 ������������ � ����� module_id)
*/
schedulerExistsInfo number(1) := null;



/* group: ������� */

procedure checkNew2OldSync;

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
  objectTypeShortName         - �������� �������� ���� �������
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
  objectTypeShortName         - �������� �������� ���� �������
  objectTypeName              - �������� ���� �������
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
  objectTypeShortName         - �������� �������� ���� �������
  objectTypeName              - �������� ���� �������
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
  objectTypeShortName         - �������� �������� ���� �������
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
          opt_option_new t
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

/* func: getOldOptionId
  ��������� id ����� �� ���������� ������� <opt_option> �� ����� ������ �
  ��������� ������������, ������� ������������ ��� ������������ ��������
  option_short_name.
  ������� ������� ������ ����� �������������� � ������ pkg_Option ����������
  ������� getOptionId � ���������� �� ���:
  - ����������� ��������� raiseNotFoundFlag;
  - ����������� ������ �� opt_option ������ v_opt_option, ��� ������������
    �������� ���������� ��� ���������� ����� ��������� ��������;

  ���������:
  moduleName                  - ��� ������
  moduleOptionName            - ��� ����� ���������� � �������� ������
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                �������� ( 1 �� ( �� ���������), 0 ���)
*/
function getOldOptionId(
  moduleName varchar2
  , moduleOptionName varchar2
  , raiseNotFoundFlag integer := null
)
return integer
is

  -- Id �����
  optionId v_opt_option.option_id%type;

  -- �������� ������������ �����
  optionShortName v_opt_option.option_short_name%type
    -- ������� getOptionShortName( moduleName, moduleOptionName) � pkg_Option
    := moduleName || '.' || moduleOptionName
  ;

-- getOldOptionId
begin
  select
    option_id
  into
    optionId
  from
    opt_option
  where
    option_short_name = optionShortName
  ;
  return
    optionId
  ;
exception when others then
  if raiseNotFoundFlag = 0 and sqlcode = pkg_Error.NoDataFound then
    logger.clearErrorStack();
    return null;
  else
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��������� id ����� ('
          || ' moduleName="' || moduleName || '"'
          || ', moduleOptionName="' || moduleOptionName || '"'
          || ', raiseNotFoundFlag=' || raiseNotFoundFlag
          || ')'
        )
      , true
    );
  end if;
end getOldOptionId;

/* proc: getOptionInfoOld
  ���������� Id ������������ ��������� � ���� �������� ��� ��������� ���� ��
  �� �������� �� ���������� �������.

  ���������:
  optionId                    - Id ��������� ( �� ������� <opt_option_new>)
                                ( �������)
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������)
                                ( �������)
  moduleName                  - ��� ������
  moduleOptionName            - ��� ����� ���������� � �������� ������
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  ���������:
  - ���� �������� �� ������ � �������� raiseNotFoundFlag ����� 0, �� �
    ���������� optionId � prodValueFlag ������������ null;
*/
procedure getOptionInfoOld(
  optionId out integer
  , prodValueFlag out integer
  , moduleName varchar2
  , moduleOptionName varchar2
  , raiseNotFoundFlag integer := null
)
is

  -- �������� ������������ �����
  optionShortName v_opt_option.option_short_name%type
    -- ������� getOptionShortName( moduleName, moduleOptionName) � pkg_Option
    := moduleName || '.' || moduleOptionName
  ;

begin
  select
    min( opn.option_id) as option_id
    , min(
        case when opn.test_prod_sensitive_flag = 1 then
          case when
              moduleOptionName like '%_' || OldTestOption_Suffix
            then 0
            else 1
          end
        end
      )
      as prod_value_flag
  into optionId, prodValueFlag
  from
    opt_option_new opn
  where
    opn.old_option_short_name =
      (
      select
        case when
          opt.option_short_name like '%_' || OldTestOption_Suffix
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
        opt.option_short_name = optionShortName
      )
    and opn.deleted = 0
  ;
  if optionId is null and coalesce( raiseNotFoundFlag, 1) != 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '����������� �������� �� ������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ����������� Id ��������� �� ����������� �������� ('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', raiseNotFoundFlag=' || raiseNotFoundFlag
        || ').'
      )
    , true
  );
end getOptionInfoOld;

/* iproc: insertOptionOld( BASE)
  ��������� ������ ��� ������������ ��������� � ���������� ������� <opt_option>.

  ���������:
  rowData                     - ������ ������ ( �������)
  oldOptionShortName          - �������� �������� ��������� � �������
                                opt_option
  storageValueTypeCode        - ��� ���� ��� �������� �������� ���������
  oldOptionName               - �������� ��������� � ������� opt_option
  optionId                    - Id ����������� ������
                                ( �� ��������� ����������� �������������)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - �������� ���������� isCopyOld2NewChange ��� ���������� ��������� ��
    ����������;
*/
procedure insertOptionOld(
  rowData out nocopy opt_option%rowtype
  , oldOptionShortName varchar2
  , storageValueTypeCode varchar2
  , oldOptionName varchar2
  , optionId integer := null
  , operatorId integer
)
is



  /*
    ���������� ����� ������.
  */
  procedure fillData
  is
  begin
    rowData.option_id := optionId;
    rowData.option_short_name := oldOptionShortName;
    rowData.option_name := oldOptionName;
    rowData.is_global := 1;
    rowData.mask_id :=
      case storageValueTypeCode
        when Date_ValueTypeCode    then 4
        when Number_ValueTypeCode  then 1
        when String_ValueTypeCode  then 3
      end
    ;
    rowData.operator_id := operatorId;
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
    ������� ������ � opt_option.
  */
  procedure insertRecord
  is
  begin
    insert into
      opt_option
    values
      rowData
    returning
      option_id
      , date_ins
    into
      rowData.option_id
      , rowData.date_ins
    ;
    logger.trace(
      'insertOptionOld: opt_option inserted: option_id=' || rowData.option_id
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������� ������ � opt_option ('
          || ' option_short_name="' || rowData.option_short_name || '"'
          || ', mask_id=' || rowData.mask_id
          || ').'
        )
      , true
    );
  end insertRecord;



-- insertOptionOld
begin
  fillData();
  insertRecord();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� ������ � ���������� ������� opt_option ('
        || ' oldOptionShortName="' || oldOptionShortName || '"'
        || ', storageValueTypeCode="' || storageValueTypeCode || '"'
        || ').'
      )
    , true
  );
end insertOptionOld;

/* iproc: insertOptionOld
  ��������� ������ ��� ������������ ��������� � ���������� ������� <opt_option>.

  ���������:
  rowData                     - ������ ������ ( �������)
  moduleId                    - Id ������, � �������� ��������� ��������
  objectShortName             - �������� �������� ������� ������
  objectTypeId                - Id ���� �������
  optionShortName             - �������� �������� ���������
                                ( � ������� opt_option_new)
  storageValueTypeCode        - ��� ���� ��� �������� �������� ���������
  optionName                  - �������� ���������
                                ( � ������� opt_option_new)
  testOptionFlag              - ���� ���������� ��������� ���������
                                ( 1 ��, 0 ���)
  optionId                    - Id ����������� ������
                                ( �� ��������� ����������� �������������)
  prodOldOptionShortName      - �������� �������� ������������� ��������� �
                                ������� opt_option
                                ( �� ��������� ����������� �������������)
  operatorId                  - Id ���������
*/
procedure insertOptionOld(
  rowData out nocopy opt_option%rowtype
  , moduleId integer
  , objectShortName varchar2
  , objectTypeId integer
  , optionShortName varchar2
  , storageValueTypeCode varchar2
  , optionName varchar2
  , testOptionFlag integer
  , optionId integer := null
  , prodOldOptionShortName varchar2 := null
  , operatorId integer
)
is

  -- ������ �������� �������� ����������� � ����� �������
  isCopyOld2NewChangeOld boolean := isCopyOld2NewChange;

  -- �������� ����� ����������� ������
  oldOptionShortName opt_option.option_short_name%type;
  oldOptionName opt_option.option_name%type;


  /*
    ���������� ����� ������.
  */
  procedure fillData
  is
  begin
    if prodOldOptionShortName is null then
      select
        md.module_name
        || case when objectShortName is not null then
            '.' || objectShortName
          end
        || '.'
        || optionShortName
        || case when testOptionFlag = 1 then
            OldTestOption_Suffix
          end
      into oldOptionShortName
      from
        v_mod_module md
        left outer join opt_object_type ot
          on ot.object_type_id = objectTypeId
      where
        md.module_id = moduleId
      ;
      oldOptionName :=
        optionName
        || case when testOptionFlag = 1 then
            OldTestOptionName_Suffix
          end
      ;
    else
      oldOptionShortName :=
        prodOldOptionShortName
        || case when testOptionFlag = 1 then
            OldTestOption_Suffix
          end
      ;
    end if;
    oldOptionName :=
      optionName
      || case when testOptionFlag = 1 then
          OldTestOptionName_Suffix
        end
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� ����� ������.'
        )
      , true
    );
  end fillData;



-- insertOptionOld
begin

  -- ��������� �������� ����������� ��������� ����������
  isCopyOld2NewChange := false;

  fillData();
  insertOptionOld(
    rowData                 => rowData
    , oldOptionShortName    => oldOptionShortName
    , storageValueTypeCode  => storageValueTypeCode
    , oldOptionName         => oldOptionName
    , optionId              => optionId
    , operatorId            => operatorId
  );

  isCopyOld2NewChange := isCopyOld2NewChangeOld;
exception when others then
  isCopyOld2NewChange := isCopyOld2NewChangeOld;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� ������ � ���������� ������� opt_option ('
        || ' moduleId=' || moduleId
        || ', objectShortName="' || objectShortName || '"'
        || ', objectTypeId=' || objectTypeId
        || ', optionShortName="' || optionShortName || '"'
        || ', storageValueTypeCode="' || storageValueTypeCode || '"'
        || ').'
      )
    , true
  );
end insertOptionOld;

/* iproc: updateOptionOld
  ��������� ������ ��������� � ������� ���������� ������� <opt_option>.

  ���������:
  optionId                    - Id ��������� ( � ������� opt_option_new)
  testProdSensitiveFlag       - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
                                ( 1 ��, 0 ���)
  storageValueTypeCode        - ��� ���� ��� �������� �������� ���������
  optionName                  - �������� ���������
                                ( � ������� opt_option_new)
  oldMaskId                   - Id ����� ��� �������� ���������
*/
procedure updateOptionOld(
  optionId integer
  , testProdSensitiveFlag integer
  , storageValueTypeCode varchar2
  , optionName varchar2
  , oldMaskId integer
)
is

  -- ������ �������� �������� ����������� � ����� �������
  isCopyOld2NewChangeOld boolean := isCopyOld2NewChange;



  /*
    �������� ������ ���������.
  */
  procedure updateOptionData(
    prodValueFlag integer
  )
  is
  begin
    update
      opt_option d
    set
      d.mask_id = oldMaskId
      , d.option_name =
        optionName
        || case when prodValueFlag = 0 then OldTestOptionName_Suffix end
    where
      d.option_id in
        (
        select distinct
          vlh.old_option_id
        from
          v_opt_value_history vlh
        where
          vlh.old_option_value_del_date is null
          and vlh.deleted = 0
          and vlh.value_id in
            (
            select
              vl.value_id
            from
              opt_value vl
            where
              vl.option_id = optionId
              and vl.deleted = 0
              and (
                vl.prod_value_flag = prodValueFlag
                or prodValueFlag is null
                  and vl.prod_value_flag is null
              )
              and vl.storage_value_type_code = storageValueTypeCode
              -- ����������� ������� �������� ��� ���������� �� / ��������� ��
              -- �������������� ��� ���������� ��������
              and vl.instance_name is null
              and vl.used_operator_id is null
            )
        )
      or nullif( prodValueFlag, 1) is null
        and d.option_id = optionId
    ;
    logger.trace(
      'updateOptionOld: opt_option updated:'
      || ' for new option_id=' || optionId
      || ', prodValueFlag=' || prodValueFlag
      || ': ' || sql%rowcount || ' rows'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� �������� ��������� ('
          || ' prodValueFlag=' || prodValueFlag
          || ').'
        )
      , true
    );
  end updateOptionData;



-- updateOptionOld
begin

  -- ��������� �������� ����������� ��������� ����������
  isCopyOld2NewChange := false;

  updateOptionData( prodValueFlag => nullif( testProdSensitiveFlag, 0));
  if testProdSensitiveFlag = 1 then
    updateOptionData( prodValueFlag => 0);
  end if;

  isCopyOld2NewChange := isCopyOld2NewChangeOld;
exception when others then
  isCopyOld2NewChange := isCopyOld2NewChangeOld;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� ������ ���������'
        || ' � ���������� ������� opt_option ('
        || ' optionId=' || optionId
        || ', testProdSensitiveFlag=' || testProdSensitiveFlag
        || ', storageValueTypeCode="' || storageValueTypeCode || '"'
        || ').'
      )
    , true
  );
end updateOptionOld;

/* iproc: setOldDelDate
  ������������� ���� �������� ������� �� ���������� ������.

  ���������:
  valueId                     - Id ��������
  valueHistoryId              - Id ������������ ������ ( null ���� ����������
                                ����� ��������� � ������� opt_value)
  oldOptionValueDelDate       - ��������������� ���� �������� ��
                                opt_option_value
                                ( �� ��������� �� ������)
  oldOptionDelDate            - ��������������� ���� �������� �� opt_option
                                ( �� ��������� �� ������)

  ���������:
  - � ������ ���������� ������� opt_option ����������� �������� �����
    ������������ ������;
*/
procedure setOldDelDate(
  valueId integer
  , valueHistoryId integer
  , oldOptionValueDelDate date := null
  , oldOptionDelDate date := null
)
is

  -- ������� �������� ����� ���������� ������� ��������
  oldSaveValueHistoryFlag integer := saveValueHistoryFlag;

begin
  if valueHistoryId is not null then
    update
      opt_value_history t
    set
      t.old_option_value_del_date =
          coalesce( oldOptionValueDelDate, t.old_option_value_del_date)
      , t.old_option_del_date =
          coalesce( oldOptionDelDate, t.old_option_del_date)
    where
      t.value_history_id = valueHistoryId
      and t.value_id = valueId
    ;
  else
    saveValueHistoryFlag := 0;
    update
      opt_value t
    set
      t.old_option_value_del_date =
          coalesce( oldOptionValueDelDate, t.old_option_value_del_date)
      , t.old_option_del_date =
          coalesce( oldOptionDelDate, t.old_option_del_date)
    where
      t.value_id = valueId
    ;
    saveValueHistoryFlag := oldSaveValueHistoryFlag;
  end if;
  logger.trace(
    'setOldDelDate:'
    || case when valueHistoryId is not null then
        ' opt_value_history updated:'
        || ' value_history_id=' || valueHistoryId
        || ','
      else
        ' opt_value updated ( without save history):'
      end
    || ' value_id=' || valueId
    || case when oldOptionValueDelDate is not null then
        ', old_option_value_del_date='
        || to_char( oldOptionValueDelDate, 'dd.mm.yyyy hh24:mi:ss')
      end
    || case when oldOptionDelDate is not null then
        ', old_option_del_date='
        || to_char( oldOptionDelDate, 'dd.mm.yyyy hh24:mi:ss')
      end
  );
exception when others then
  saveValueHistoryFlag := oldSaveValueHistoryFlag;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ��� �������� ������� �� ���������� ������ ('
        || ' value_id=' || valueId
        || ', value_history_id=' || valueHistoryId
        || ').'
      )
    , true
  );
end setOldDelDate;

/* iproc: deleteOptionOld( BASE)
  ������� ������ �� ���������� ������� opt_option.

  ���������:
  oldOptionId                 - Id ��������� ������
*/
procedure deleteOptionOld(
  oldOptionId integer
)
is

  -- ������ �������� �������� ����������� � ����� �������
  isCopyOld2NewChangeOld boolean := isCopyOld2NewChange;

-- deleteOptionOld
begin

  -- ��������� �������� ����������� ��������� ����������
  isCopyOld2NewChange := false;

  delete
    opt_option d
  where
    d.option_id = oldOptionId
  ;
  if sql%rowcount = 0 then
    raise_application_error(
      pkg_Error.ProcessError
      , '������ �� �������.'
    );
  end if;
  logger.trace(
    'deleteOptionOld: opt_option deleted: option_id='
    || oldOptionId
  );

  isCopyOld2NewChange := isCopyOld2NewChangeOld;
exception when others then
  isCopyOld2NewChange := isCopyOld2NewChangeOld;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ������ �� opt_option ('
        || ' oldOptionId=' || oldOptionId
        || ').'
      )
    , true
  );
end deleteOptionOld;

/* iproc: deleteOptionOld
  ������� ������ �� ���������� ������� opt_option.

  ���������:
  valueId                     - Id �������� ���� ����� ������� ��� ���������
                                � ���� ��������� ������ ����� ��������
  optionId                    - Id ��������� � opt_option_new ���� �����
                                ������� ������ �������� ������ �� ���������
  oldOptionDelDate            - ���� �������� ��� ���������� � ����
                                old_option_del_date
*/
procedure deleteOptionOld(
  valueId integer := null
  , optionId integer := null
  , oldOptionDelDate date
)
is

  cursor dataCur is
    select
      a.old_option_id
      , a.value_id
      , a.value_history_id
    from
      (
      select
        t.old_option_id
        , t.value_id
        , max( t.value_history_id)
          keep ( dense_rank last order by t.change_number)
          as value_history_id
        , max( t.old_option_del_date)
          keep ( dense_rank last order by t.change_number)
          as old_option_del_date
      from
        v_opt_value_history t
      where
        t.value_id in
          (
          select
            vl.value_id
          from
            opt_value vl
          where
            vl.value_id = valueId
            or vl.option_id = optionId
              and vl.instance_name is null
              and vl.used_operator_id is null
              and nullif( vl.prod_value_flag, 1) is null
          )
        and t.deleted = 0
        and t.old_option_id is not null
        and (
          valueId is not null
            and t.old_option_id != t.option_id
          or optionId is not null
            and t.old_option_id = t.option_id
        )
      group by
        t.old_option_id
        , t.value_id
      ) a
    where
      a.old_option_del_date is null
    -- �� ������ ���������� ��������
    union all
    select
      opt.option_id as old_option_id
      , null as value_id
      , null as value_history_id
    from
      opt_option opt
    where
      opt.option_id = optionId
    order by
      1, 2
  ;

  -- ������ �������� �������� ����������� � ����� �������
  isCopyOld2NewChangeOld boolean := isCopyOld2NewChange;

  -- ���� ��������� �������� �������� ������
  isMainDeleted boolean := false;

-- deleteOptionOld
begin

  -- ��������� �������� ����������� ��������� ����������
  isCopyOld2NewChange := false;

  for rec in dataCur loop
    begin
      if optionId is null or not isMainDeleted then
        deleteOptionOld(
          oldOptionId => rec.old_option_id
        );
        if rec.old_option_id = optionId then
          isMainDeleted := true;
        end if;
      end if;
      if rec.value_id is not null then
        setOldDelDate(
          valueId                 => rec.value_id
          , valueHistoryId        => rec.value_history_id
          , oldOptionDelDate      => oldOptionDelDate
        );
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ��������� ������ ('
            || ' option_id=' || rec.old_option_id
            || ', value_history_id=' || rec.value_history_id
            || ', value_id=' || rec.value_id
            || ').'
          )
        , true
      );
    end;
  end loop;

  isCopyOld2NewChange := isCopyOld2NewChangeOld;
exception when others then
  isCopyOld2NewChange := isCopyOld2NewChangeOld;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ������� �� ���������� ������� opt_option ('
        || ' valueId=' || valueId
        || ', optionId=' || optionId
        || ').'
      )
    , true
  );
end deleteOptionOld;

/* func: getOptionId
  ���������� Id ������������ ���������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��������
  objectShortName             - �������� �������� ������� ������
  objectTypeId                - Id ���� �������
  optionShortName             - �������� �������� ���������
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  Id ��������� ( �� ������� <opt_option_new>) ���� null, ���� �������� ��
  ������ � �������� raiseNotFoundFlag ����� 0.
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
    opt_option_new t
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
  rowData out nocopy opt_option_new%rowtype
  , optionId integer
)
is
begin
  select
    t.*
  into rowData
  from
    opt_option_new t
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
  optionShortName             - �������� �������� ���������
  valueTypeCode               - ��� ���� �������� ���������
  optionName                  - �������� ���������
  objectShortName             - �������� �������� ������� ������
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
  oldOptionShortName          - �������� �������� ��������� � �������
                                opt_option
                                ( �� ��������� ����������� �������������)
  oldMaskId                   - Id ����� ��� �������� ���������
                                ( �� ��������� ����������� �������������)
  oldOptionNameTest           - �������� ��������� ��������� � �������
                                opt_option
                                ( �� ��������� �����������)
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id ���������.

  ���������:
  - ���� � ������ ���������� ������� <body::isCopyNew2OldChange>, �� �����
    ����������� ������ � ���������� ������� opt_option � ��� �� ���������
    option_id;
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
  , oldOptionShortName varchar2 := null
  , oldMaskId integer := null
  , oldOptionNameTest varchar2 := null
  , operatorId integer := null
)
return integer
is

  -- ������ � ���� ������
  rec opt_option_new%rowtype;



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
    rec.old_option_short_name     := oldOptionShortName;
    rec.old_mask_id               := oldMaskId;
    rec.old_option_name_test      := oldOptionNameTest;
    rec.operator_id               := operatorId;

    -- ��������� ���� ������������ �������� � old_option_name_test
    rec.old_option_name_test :=
      nullif(
        rec.old_option_name_test
        , rec.option_name || OldTestOptionName_Suffix
      )
    ;
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
    ��������� ������ � ���������� �������.
  */
  procedure insertOld
  is

    oldRec opt_option%rowtype;

  begin
    insertOptionOld(
      rowData                 => oldRec
      , moduleId              => rec.module_id
      , objectShortName       => rec.object_short_name
      , objectTypeId          => rec.object_type_id
      , optionShortName       => rec.option_short_name
      , storageValueTypeCode  =>
          case when rec.value_list_flag = 1 then
            String_ValueTypeCode
          else
            rec.value_type_code
          end
      , optionName            => rec.option_name
      , testOptionFlag        => 0
        -- ������������ ��� �������������� ����� ���������� ���������
      , optionId              => rec.option_id
      , prodOldOptionShortName => rec.old_option_short_name
      , operatorId            => rec.operator_id
    );

    rec.option_id             := oldRec.option_id;
    rec.old_option_short_name := oldRec.option_short_name;
    rec.old_mask_id           := oldRec.mask_id;
    rec.old_option_name_test  := null;
  end insertOld;



  /*
    ��������� ������ � ������� opt_option_new � ���������� ��������� ( true �
    ������ ������, false � ������ ������ ��-�� ��������� ������������).
  */
  function insertRecord
  return boolean
  is
  begin
    insert into
      opt_option_new
    values
      rec
    returning
      option_id
    into
      rec.option_id
    ;
    logger.trace(
      'createOption: opt_option_new inserted:'
      || ' option_id=' || rec.option_id
      || ', value_type_code="' || rec.value_type_code || '"'
      || ', value_list_flag=' || rec.value_list_flag
      || ', test_prod_sensitive_flag=' || rec.test_prod_sensitive_flag
      || ', old_option_short_name="' || rec.old_option_short_name || '"'
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
            '������ ��� ������� ������ � ������� opt_option_new.'
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
      opt_option_new d
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

    if isCopyNew2OldChange then
      insertOld();
    end if;
    update
      opt_option_new d
    set
      d.value_type_code             = rec.value_type_code
      , d.value_list_flag           = rec.value_list_flag
      , d.encryption_flag           = rec.encryption_flag
      , d.test_prod_sensitive_flag  = rec.test_prod_sensitive_flag
      , d.access_level_code         = rec.access_level_code
      , d.option_name               = rec.option_name
      , d.option_description        = rec.option_description
      , d.old_option_short_name     = rec.old_option_short_name
      , d.old_mask_id               = rec.old_mask_id
      , d.old_option_name_test      = rec.old_option_name_test
      , d.deleted                   = 0
      , d.change_operator_id        = rec.operator_id
    where
      d.option_id = rec.option_id
    ;
    logger.trace(
      'createOption: restore deleted: opt_option_new updated:'
      || ' option_id=' || rec.option_id
      || ', value_type_code="' || rec.value_type_code || '"'
      || ', value_list_flag=' || rec.value_list_flag
      || ', test_prod_sensitive_flag=' || rec.test_prod_sensitive_flag
      || ', old_option_short_name="' || rec.old_option_short_name || '"'
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
  if isCopyNew2OldChange then
    rec.option_id := null;
    insertOld();
  end if;
  if not insertRecord() then
    if isCopyNew2OldChange then
      deleteOptionOld( oldOptionId => rec.option_id);
      rec.option_id := null;
    end if;
    restoreDeleted();
  end if;
  if isCopyNew2OldChange then
    checkNew2OldSync();
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
        || ', oldOptionShortName="' || oldOptionShortName || '"'
        || ', old_option_short_name="' || rec.old_option_short_name || '"'
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
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
  optionName                  - �������� ���������
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
  oldOptionNameTest           - �������� ��������� ��������� � �������
                                opt_option
                                ( ������������ ������ ��� ����������
                                  ������������� ���������)
                                ( �� ��������� ������� ��������)
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
  , valueTypeCode varchar2
  , valueListFlag integer
  , encryptionFlag integer
  , testProdSensitiveFlag integer
  , accessLevelCode varchar2
  , optionName varchar2
  , optionDescription varchar2
  , moveProdSensitiveValueFlag integer := null
  , deleteBadValueFlag integer := null
  , oldOptionNameTest varchar2 := null
  , operatorId integer := null
)
is

  -- ������� ������
  rec opt_option_new%rowtype;

  -- Id ����� ��� �������� ���������
  oldMaskId opt_option_new.old_mask_id%type;

  -- �������� ��������� ��������� � ���������� ������� ( ����� ��������)
  newOldOptionNameTest opt_option_new.old_option_name_test%type;



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
                , oldOptionValueId      =>
                    case when not isCopyNew2OldChange then
                      vr.old_option_value_id
                    end
                , oldOptionId           => vr.old_option_id
                , oldOptionValueDelDate =>
                    case when not isCopyNew2OldChange then
                      vr.old_option_value_del_date
                    end
                , oldOptionDelDate      => vr.old_option_del_date
                , ignoreTestProdSensitiveFlag => 1
                , fillIdFromOldFlag     => 0
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

    -- ��������� �������� ��������, �.�. ��� ����� ���� � ������
    -- �������������� ��������� ������ ����� ( ��������, option_name)
    isSkipCheckNew2OldSync := true;

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
    isSkipCheckNew2OldSync := false;
  exception when others then
    isSkipCheckNew2OldSync := false;
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
  if isCopyNew2OldChange and oldOptionNameTest is not null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�������� oldOptionNameTest ������ �������������� ������ ������ ������.'
    );
  end if;
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
  newOldOptionNameTest :=
    case
      when isCopyNew2OldChange then
        null
      else
        nullif(
          coalesce( oldOptionNameTest, rec.old_option_name_test)
          , optionName || OldTestOptionName_Suffix
        )
    end
  ;
  oldMaskId :=
    case when
      rec.value_type_code != valueTypeCode
        or rec.value_list_flag != valueListFlag
    then
      case
          case when valueListFlag = 1 then
            String_ValueTypeCode
          else
            valueTypeCode
          end
        when Date_ValueTypeCode    then 4
        when Number_ValueTypeCode  then 1
        when String_ValueTypeCode  then 3
      end
    else
      rec.old_mask_id
    end
  ;
  update
    opt_option_new d
  set
    d.value_type_code             = valueTypeCode
    , d.value_list_flag           = valueListFlag
    , d.encryption_flag           = encryptionFlag
    , d.test_prod_sensitive_flag  = testProdSensitiveFlag
    , d.access_level_code         = accessLevelCode
    , d.option_name               = optionName
    , d.option_description        = optionDescription
    , d.old_mask_id               = oldMaskId
    , d.old_option_name_test      = newOldOptionNameTest
    , d.change_operator_id        = operatorId
  where
    d.option_id = optionId
  ;
  logger.trace(
    'updateOption: opt_option_new updated: option_id=' || optionId
  );
  if rec.encryption_flag != encryptionFlag then
    changeValueEncryption();
  end if;
  if isCopyNew2OldChange then
    if coalesce(
              nullif( rec.old_mask_id, oldMaskId)
              , nullif( oldMaskId, rec.old_mask_id)
            )
            is not null
          or rec.option_name != optionName
          -- ���������� ����������� �������� ��������� ���������
          or newOldOptionNameTest is null
            and rec.old_option_name_test is not null
        then
      updateOptionOld(
        optionId                => optionId
        , testProdSensitiveFlag => testProdSensitiveFlag
        , storageValueTypeCode  =>
            case when valueListFlag = 1 then
              String_ValueTypeCode
            else
              valueTypeCode
            end
        , optionName            => optionName
        , oldMaskId             => oldMaskId
      );
    end if;
    checkNew2OldSync();
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
  rec opt_option_new%rowtype;

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
    opt_option_new d
  set
    d.deleted = 1
    , d.change_operator_id = operatorId
  where
    d.option_id = optionId
  ;
  logger.trace(
    'deleteOption: opt_option_new set deleted: option_id=' || optionId
  );
  if isCopyNew2OldChange then
    deleteOptionOld(
      optionId            => optionId
      , oldOptionDelDate  => sysdate
    );
    checkNew2OldSync();
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



/* group: �������� ���������� */

/* ifunc: insertOptionValueOld
  ��������� ������ ��� �������� ��������� � ���������� �������
  <opt_option_value>.

  ���������:
  oldOptionId                 - Id ��������� � ������� opt_option
  dateValue                   - �������� ���� ����
  numberValue                 - �������� ��������
  stringValue                 - ��������� ��������
  operatorId                  - Id ���������
  copyOld2NewChange           - ������������� ����������� ��������� � �����
                                �������
                                ( �� ��������� ���)

  �������:
  Id ����������� ������.
*/
function insertOptionValueOld(
  oldOptionId integer
  , dateValue date
  , numberValue number
  , stringValue varchar2
  , operatorId integer
  , copyOld2NewChange boolean := null
)
return integer
is

  -- ������ �������� �������� ����������� � ����� �������
  isCopyOld2NewChangeOld boolean := isCopyOld2NewChange;

  -- Id ��������� ������
  optionValueId integer;

begin

  -- ����������� �������� ����������� ��������� ����������
  isCopyOld2NewChange := coalesce( copyOld2NewChange, false);

  insert into
    opt_option_value
  (
    option_id
    , datetime_value
    , integer_value
    , string_value
    , operator_id
  )
  values
  (
    oldOptionId
    , dateValue
    , numberValue
    , stringValue
    , operatorId
  )
  returning
    option_value_id
  into
    optionValueId
  ;
  logger.trace(
    'insertOptionValueOld: opt_option_value inserted:'
    || ' option_id=' || oldOptionId
    || ', option_value_id=' || optionValueId
  );

  isCopyOld2NewChange := isCopyOld2NewChangeOld;

  return optionValueId;
exception when others then
  isCopyOld2NewChange := isCopyOld2NewChangeOld;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� ������ � ���������� ������� opt_option_value ('
        || ' oldOptionId=' || oldOptionId
        || ').'
      )
    , true
  );
end insertOptionValueOld;

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
        opt_option_new opn
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
        opt_option_new opn
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
      opt_option_new opn
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
  , opt opt_option_new%rowtype
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
  oldOptionValueId            - Id �������� � ������� opt_option_value
                                ( �� ��������� ����������� �������������)
  oldOptionId                 - Id ��������� � ������� opt_option
                                ( �� ��������� ����������� �������������)
  oldOptionValueDelDate       - ���� �������� �������� �� �������
                                opt_option_value
                                ( �� ��������� �����������)
  oldOptionDelDate            - ���� �������� �������� �� �������
                                opt_option
                                ( �� ��������� �����������)
  ignoreTestProdSensitiveFlag - ��� �������� �������� �� ��������� ���
                                ������������ �������� �������� �����
                                test_prod_sensitive_flag ���������
                                ( 1 ��, 0 ��� ( ����������� ���������� ���
                                  �����������))
                                ( �� ��������� 0)
  fillIdFromOldFlag           - ������������ � �������� Id ����������� ������
                                ( value_id) �������� oldOptionValueId ����
                                ��� ������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id �������� ���������.

  ���������:
  - ���� � ������ ���������� ������� <body::isCopyNew2OldChange>, �� �����
    ����������� ������ � ���������� ������� opt_option_value;
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
  , oldOptionValueId integer := null
  , oldOptionId integer := null
  , oldOptionValueDelDate date := null
  , oldOptionDelDate date := null
  , ignoreTestProdSensitiveFlag integer := null
  , fillIdFromOldFlag integer := null
  , operatorId integer := null
)
return integer
is

  -- ������ � ���� ������
  rec opt_value%rowtype;

  -- ������ ���������
  opt opt_option_new%rowtype;



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
    rec.old_option_value_id       := oldOptionValueId;
    rec.old_option_id             := oldOptionId;
    rec.old_option_value_del_date := oldOptionValueDelDate;
    rec.old_option_del_date       := oldOptionDelDate;
    rec.operator_id               := operatorId;

    -- Id ���������, �.�. ������������ ���� ������������������
    if coalesce( fillIdFromOldFlag, 1) = 1 then
      rec.value_id := rec.old_option_value_id;
    end if;
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
    ��������� ������ � ���������� �������.
  */
  procedure insertOld
  is

    -- ������ ��������� ���������
    testOptOldRec opt_option%rowtype;

  begin
    if rec.old_option_id is null then
      if rec.prod_value_flag = 0 then
        insertOptionOld(
          rowData                 => testOptOldRec
          , moduleId              => opt.module_id
          , objectShortName       => opt.object_short_name
          , objectTypeId          => opt.object_type_id
          , optionShortName       => opt.option_short_name
          , storageValueTypeCode  => rec.storage_value_type_code
          , optionName            => opt.option_name
          , testOptionFlag        => 1
          , operatorId            => rec.operator_id
          , prodOldOptionShortName => opt.old_option_short_name
        );
        rec.old_option_id := testOptOldRec.option_id;
      else
        rec.old_option_id := rec.option_id;
      end if;
    end if;
    if rec.old_option_value_id is null then
      rec.old_option_value_id := insertOptionValueOld(
        oldOptionId             => rec.old_option_id
        , dateValue             => rec.date_value
        , numberValue           => rec.number_value
        , stringValue           => rec.string_value
        , operatorId            => rec.operator_id
      );
      rec.value_id := rec.old_option_value_id;
    end if;
  end insertOld;



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
      || ', old_option_value_id=' || rec.old_option_value_id
      || ', old_option_id=' || rec.old_option_id
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
      , d.old_option_value_id       = rec.old_option_value_id
      , d.old_option_id             = rec.old_option_id
      , d.old_option_value_del_date = rec.old_option_value_del_date
      , d.old_option_del_date       = rec.old_option_del_date
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
      || ', old_option_value_id=' || rec.old_option_value_id
      || ', old_option_id=' || rec.old_option_id
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
  if isCopyNew2OldChange
        and rec.instance_name is null
        and rec.used_operator_id is null
      then
    insertOld();
  end if;
  if not insertRecord() then
    restoreDeleted();
  end if;
  if isCopyNew2OldChange then
    checkNew2OldSync();
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
  oldOptionValueId            - Id �������� � ������� opt_option_value
                                ( �� ��������� ����������� �������������)
  oldOptionId                 - Id ��������� � ������� opt_option
                                ( �� ��������� ����������� �������������)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ���� � ������ ���������� ������� <body::isCopyNew2OldChange>, �� �����
    ����������� ������ � ���������� ������� opt_option_value;
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
  , oldOptionValueId integer := null
  , oldOptionId integer := null
  , operatorId integer := null
)
is

  -- ������ � ���� ������
  rec opt_value%rowtype;

  -- ������ ���������
  opt opt_option_new%rowtype;



  /*
    ��������� ���� ������.
  */
  procedure fillData
  is
  begin
    rec.old_option_value_id       :=
      coalesce( oldOptionValueId, rec.old_option_value_id)
    ;
    rec.old_option_id             :=
      coalesce( oldOptionId, rec.old_option_id)
    ;
    rec.change_operator_id        := operatorId;
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
    ��������� ������ � ���������� �������.
  */
  procedure insertOld
  is
  begin
    rec.old_option_value_id := insertOptionValueOld(
      oldOptionId             => rec.old_option_id
      , dateValue             => rec.date_value
      , numberValue           => rec.number_value
      , stringValue           => rec.string_value
      , operatorId            => rec.change_operator_id
    );
  end insertOld;



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
      , d.old_option_value_id     = rec.old_option_value_id
      , d.old_option_id           = rec.old_option_id
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
      || ', old_option_value_id=' || rec.old_option_value_id
      || ', old_option_id=' || rec.old_option_id
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
    , ignoreTestProdSensitiveFlag => 0
  );
  if isCopyNew2OldChange
        and rec.instance_name is null
        and rec.used_operator_id is null
      then
    insertOld();
  end if;
  updateRecord();
  if isCopyNew2OldChange then
    checkNew2OldSync();
  end if;
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
  oldOptionValueId            - Id �������� � ������� opt_option_value
                                ( �� ��������� ����������� �������������)
  oldOptionId                 - Id ��������� � ������� opt_option
                                ( �� ��������� ����������� �������������)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ���� � ������ ���������� ������� <body::isCopyNew2OldChange>, �� �����
    ����������� ������ � ���������� ������� opt_option_value;
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
  , oldOptionValueId integer := null
  , oldOptionId integer := null
  , operatorId integer := null
)
is

  -- ������ ���������
  opt opt_option_new%rowtype;

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
      , oldOptionValueId      => oldOptionValueId
      , oldOptionId           => oldOptionId
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
      , oldOptionValueId      => oldOptionValueId
      , oldOptionId           => oldOptionId
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

  ���������:
  - ���� � ������ ���������� ������� <body::isCopyNew2OldChange>, �� �����
    ��������� ������ �� ���������� ������ opt_option_value � opt_option;
*/
procedure deleteValue(
  valueId integer
  , operatorId integer := null
)
is

  -- ������ � ���� ������
  vlr opt_value%rowtype;

  -- ������ ���������
  opt opt_option_new%rowtype;

  -- ���� �������� ���������
  changeDate date := sysdate;



  /*
    ������� ������ �� ���������� ������� opt_option_value.
  */
  procedure deleteOptionValueOld
  is

    cursor dataCur is
      select
        a.*
      from
        (
        select
          t.value_id
          , t.old_option_value_id
          , max( t.value_history_id)
            keep ( dense_rank last order by t.change_number)
            as value_history_id
          , max( t.old_option_value_del_date)
            keep ( dense_rank last order by t.change_number)
            as old_option_value_del_date
        from
          v_opt_value_history t
        where
          t.deleted = 0
          and t.old_option_value_id is not null
          and (
            t.value_id = vlr.value_id
            -- ��������, ��������� � ���������� ��������� ��������� � ���������
            -- moveProdSensitiveValueFlag = 1
            or t.value_id =
              (
              select distinct
                vl.value_id
              from
                opt_value vl
                inner join opt_value_history vh
                  on vh.value_id = vl.value_id
                    and vh.deleted = 0
                    and vh.old_option_value_id is not null
              where
                vl.option_id = vlr.option_id
                and vl.deleted = 1
                and (
                  vlr.prod_value_flag = 1
                    and vl.prod_value_flag is null
                  or vlr.prod_value_flag is null
                    and vl.prod_value_flag = 1
                )
                and exists
                  (
                  select
                    null
                  from
                    v_opt_value_history vh0
                  where
                    vh0.value_id = vlr.value_id
                    and vh0.old_option_value_id = vh.old_option_value_id
                  )
              )
          )
        group by
          t.value_id
          , t.old_option_value_id
        ) a
      where
        a.old_option_value_del_date is null
      order by
        nullif( a.value_id, vlr.value_id) nulls first
        , a.old_option_value_id
    ;

    -- ������ �������� �������� ����������� � ����� �������
    isCopyOld2NewChangeOld boolean := isCopyOld2NewChange;

  -- deleteOptionValueOld
  begin

    -- ��������� �������� ����������� ��������� ����������
    isCopyOld2NewChange := false;

    for rec in dataCur loop
      delete
        opt_option_value d
      where
        d.option_value_id = rec.old_option_value_id
      ;
      if sql%rowcount = 0 then
        if rec.value_id = vlr.value_id then
          raise_application_error(
            pkg_Error.ProcessError
            , '�� ������� ������� ������ � opt_option_value'
              || ' ��-�� �� ���������� ('
              || ' option_value_id=' || rec.old_option_value_id
              || ', value_history_id=' || rec.value_history_id
              || ', value_id=' || rec.value_id
              || ').'
          );
        else
          logger.trace(
            'deleteValue: �� ������� ������� ������ � opt_option_value'
            || ' ��-�� �� ���������� ('
            || ' option_value_id=' || rec.old_option_value_id
            || ', value_history_id=' || rec.value_history_id
            || ', value_id=' || rec.value_id
            || ').'
          );
        end if;
      else
        logger.trace(
          'deleteValue: opt_option_value deleted: option_value_id='
          || rec.old_option_value_id
        );
      end if;
      setOldDelDate(
        valueId                 => rec.value_id
        , valueHistoryId        => rec.value_history_id
        , oldOptionValueDelDate => changeDate
      );
    end loop;

    isCopyOld2NewChange := isCopyOld2NewChangeOld;
  exception when others then
    isCopyOld2NewChange := isCopyOld2NewChangeOld;
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� ������� �� ���������� ������� opt_option_value.'
        )
      , true
    );
  end deleteOptionValueOld;



-- deleteValue
begin
  lockValue( vlr, valueId => valueId);
  lockOption( opt, optionId => vlr.option_id);
  if isCopyNew2OldChange
        and vlr.instance_name is null
        and vlr.used_operator_id is null
      then
    deleteOptionValueOld();
    deleteOptionOld(
      valueId             => vlr.value_id
      , oldOptionDelDate  => changeDate
    );
  end if;
  update
    opt_value d
  set
    d.deleted = 1
    , d.old_option_value_id = null
    , d.old_option_id = null
    , d.old_option_value_del_date = null
    , d.old_option_del_date = null
    , d.change_operator_id = operatorId
  where
    d.value_id = vlr.value_id
  ;
  logger.trace(
    'deleteValue: set deleted: opt_value updated:'
    || ' value_id=' || vlr.value_id
    || ', option_id=' || vlr.option_id
  );
  if isCopyNew2OldChange then
    checkNew2OldSync();
  end if;
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

/* proc: addOptionWithValueOld
  ��������� ����������� �������� �� ��������� � ���������� �������, ���� �� ��
  ��� ������ �����.

  ���������:
  moduleName                  - ��� ������
  moduleOptionName            - ��� ����� ���������� � �������� ������
  valueTypeCode               - ��� ���� �������� ���������
  optionName                  - �������� ���������
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
  operatorId                  - Id ��������� ( �� ��������� �������)
*/
procedure addOptionWithValueOld(
  moduleName varchar2
  , moduleOptionName varchar2
  , valueTypeCode varchar2
  , optionName varchar2
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , operatorId integer := null
)
is

  -- Id ���������
  optionId integer;

  -- ���� ������������� �������� ������ � ������������ ( ���� ��������) ��
  prodValueFlag integer;

  -- ������ ����������� � opt_option ������
  opt opt_option%rowtype;

  -- Id ����������� � opt_option_value ������
  optionValueId integer;

begin
  getOptionInfoOld(
    optionId            => optionId
    , prodValueFlag     => prodValueFlag
    , moduleName        => moduleName
    , moduleOptionName  => moduleOptionName
    , raiseNotFoundFlag => 0
  );
  if optionId is null then
    insertOptionOld(
      rowData                 => opt
      , oldOptionShortName    => moduleName || '.' || moduleOptionName
      , storageValueTypeCode  => valueTypeCode
      , oldOptionName         => optionName
      , operatorId            => operatorId
    );
    optionValueId := insertOptionValueOld(
      oldOptionId             => opt.option_id
      , dateValue             => dateValue
      , numberValue           => numberValue
      , stringValue           => stringValue
      , operatorId            => operatorId
      , copyOld2NewChange     => true
    );
    logger.trace(
      'addOptionWithValueOld: created: "' || opt.option_short_name || '"'
      || ' ( old option_id=' || opt.option_id
      || ', option_value_id=' || optionValueId
      || ')'
    );
  else
    logger.trace(
      'addOptionWithValueOld: exists: "' || opt.option_short_name || '"'
      || ' ( old option_id=' || optionId
      || ')'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� ��������� �� ��������� ����������� ��������� ('
        || ' moduleName="' || moduleName || '"'
        || ', moduleOptionName="' || moduleOptionName || '"'
        || ', valueTypeCode="' || valueTypeCode || '"'
        || ').'
      )
    , true
  );
end addOptionWithValueOld;

/* proc: addOptionWithValue
  ��������� ����������� �������� �� ���������, ���� �� �� ��� ������ �����.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��������
  optionShortName             - �������� �������� ���������
  valueTypeCode               - ��� ���� �������� ���������
  optionName                  - �������� ���������
  objectShortName             - �������� �������� ������� ������
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
  objectShortName             - �������� �������� ������� ������, � ��������
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



/* group: ��������� ���������� �������� */

/* func: getSaveValueHistoryFlag
  ���������� ������� �������� ����� ���������� ������� ��� ���������
  ������� � <opt_value>.
*/
function getSaveValueHistoryFlag
return integer
is
begin
  return coalesce( saveValueHistoryFlag, 1);
end getSaveValueHistoryFlag;

/* func: getCopyOld2NewChangeFlag
  ���������� ������� �������� ����� ����������� ���������, �������� �
  ���������� �������, � ����� �������.
*/
function getCopyOld2NewChangeFlag
return integer
is
begin
  return
    case when isCopyOld2NewChange then 1 else 0 end
  ;
end getCopyOld2NewChangeFlag;

/* iproc: checkNew2OldSync
  ��������� ���������� ����������� ����� ���������� ���������� � ����� �
  ���������� ��������.
*/
procedure checkNew2OldSync
is

  cursor diffCur is
    select
      count( distinct d.option_id) as option_id_cnt
      , count( distinct d.option_value_id) as option_value_id_cnt
      , min( d.option_id) as min_option_id
      , min( d.option_value_id) as min_option_value_id
    from
      v_opt_option_new2old_diff d
  ;

begin
  if not coalesce( isSkipCheckNew2OldSync, false) then
    for rec in diffCur loop
      if rec.option_id_cnt > 0 then
        raise_application_error(
          pkg_Error.ProcessError
          , '������� ����������� ('
            || ' option_id_cnt=' || rec.option_id_cnt
            || ', option_value_id_cnt=' || rec.option_value_id_cnt
            || ', min_option_id=' || rec.min_option_id
            || ', min_option_value_id=' || rec.min_option_value_id
            || ').'
        );
      end if;
    end loop;
    logger.trace( 'checkNew2OldSync: OK');
  else
    logger.trace( 'checkNew2OldSync: skipped');
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ���������� ����������� ����� ������� � �����'
        || ' � ���������� ��������.'
      )
    , true
  );
end checkNew2OldSync;

/* proc: onOldBeforeStatement
  ���������� �� ��������� �� �������� <opt_option> � <opt_option_value> �����
  ����������� DML.

  ���������:
  tableName                   - ��� ������� ( � ������� ��������)
  statementType               - ��� DML ( INSERT / UPDATE / DELETE)
*/
procedure onOldBeforeStatement(
  tableName varchar2
  , statementType varchar2
)
is
begin
  logger.trace(
    'onOldBeforeStatement: ' || tableName || ': ' || statementType
    || case when not isCopyOld2NewChange then ' - skipped' end
  );
  if coalesce( isCopyOld2NewChange, true) then
    if coalesce( tableName, '-') not in ( 'OPT_OPTION', 'OPT_OPTION_VALUE') then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������� ������������ ��� �������.'
      );
    elsif coalesce( statementType, '-') not in ( 'INSERT', 'UPDATE', 'DELETE')
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������ ������������ ��� DML.'
      );
    elsif tableName = 'OPT_OPTION_VALUE' and statementType = 'UPDATE' then
      raise_application_error(
        pkg_Error.ProcessError
        , '��������� ( update) ������� � ������� opt_option_value ���������.'
      );
    end if;
    onChangeTableName := tableName;
    onChangeStatementType := statementType;
    onChangeIdList := IdListT();
    onDeleteOptionSNameList := OptionSNameListT();
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ � ���������, ���������� ����� ����������� DML ('
        || ' tableName="' || tableName || '"'
        || ', statementType="' || statementType || '"'
        || ').'
      )
    , true
  );
end onOldBeforeStatement;

/* proc: onOldAfterRow
  ���������� �� ��������� �� �������� <opt_option> � <opt_option_value> ���
  ���������� DML ����� ��������� ������ ������.

  ���������:
  tableName                   - ��� ������� ( � ������� ��������)
  statementType               - ��� DML ( INSERT / UPDATE / DELETE)
  newRowId                    - Id ���������� ������ ( ����� ��������)
  oldRowId                    - Id ���������� ������ ( ������ ��������)
  oldOptionShortName          - �������� �������� ����� ( ����������
                                ������ � ������ �������� �� opt_option)

  ���������:
  - � �������� �������� ���������� newRowId � oldRowId ��� ������� opt_option
    ����������� option_id, ��� ������� opt_option_value �����������
    option_value_id;
*/
procedure onOldAfterRow(
  tableName varchar2
  , statementType varchar2
  , newRowId integer
  , oldRowId integer
  , oldOptionShortName varchar2 := null
)
is
begin
  logger.trace(
    'onOldAfterRow: ' || tableName || ': ' || statementType
    || ': ' || newRowId || ' ( ' || oldRowId
    || case when oldOptionShortName is not null then
        ', "' || oldOptionShortName || '"'
      end
    || ')'
    || case when not isCopyOld2NewChange then ' - skipped' end
  );
  if coalesce( isCopyOld2NewChange, true) then
    if tableName = onChangeTableName and statementType = onChangeStatementType
        then
      if newRowId != oldRowId then
        raise_application_error(
          pkg_Error.ProcessError
          , '��������� �������� ���������� ����� ������ ���������.'
        );
      end if;
      onChangeIdList.extend(1);
      onChangeIdList( onChangeIdList.last) := coalesce( newRowId, oldRowId);
      if tableName = 'OPT_OPTION' and  statementType = 'DELETE' then
        onDeleteOptionSNameList.extend(1);
        onDeleteOptionSNameList( onDeleteOptionSNameList.last)
          := oldOptionShortName
        ;
      end if;
    else
      raise_application_error(
        pkg_Error.IllegalArgument
        , '����������� ��� ������� ��� ��� DML ( ���������'
          || ' "' || onChangeTableName || '"'
          || ' � "' || onChangeStatementType || '"'
          || ').'
          || ' ���������� ������� DML ( ��������, merge) �� ��������������.'
      );
    end if;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ � ���������, ���������� ����� ��������� ������ ������ � DML ('
        || ' tableName="' || tableName || '"'
        || ', statementType="' || statementType || '"'
        || ', newRowId=' || newRowId
        || ', oldRowId=' || oldRowId
        || ').'
      )
    , true
  );
end onOldAfterRow;

/* proc: onOldAfterStatement
  ���������� �� ��������� �� �������� <opt_option> � <opt_option_value> �����
  ���������� DML.

  ���������:
  tableName                   - ��� ������� ( � ������� ��������)
  statementType               - ��� DML ( INSERT / UPDATE / DELETE)
*/
procedure onOldAfterStatement(
  tableName varchar2
  , statementType varchar2
)
is



  /*
    ��������� ������� � opt_option.
  */
  procedure processOptionInsert(
    optionId integer
  )
  is

    cursor oldOptionCur is
      select
        b.*
        , opn.option_id as new_option_id
        , cast( null as varchar2(100)) as batch_short_name
        , cast( null as integer) as module_id
      from
        (
        select
          a.*
          , case when
                a.option_short_name != a.prod_option_short_name
              then 1 else 0
            end
            as is_test_option
        from
          (
          select
            opt.*
            , case when
                opt.option_short_name like '%_'
                || OldTestOption_Suffix
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
          ) a
        ) b
        left outer join opt_option_new opn
          on opn.old_option_short_name = b.prod_option_short_name
            and opn.deleted = 0
    ;

    oldRec oldOptionCur%rowtype;

    rec opt_option_new%rowtype;



    /*
      ���������� �������� ��� ����� � Id ������, � �������� ���������
      ��������, ���� null, ���� �� �� ������ � ������.
      ������� �������� �� ��������� ������� � ������� � ������� ������������,
      ����� �������� ������ ��� ���������� ������ Scheduler ( �.�. �����������
      �� ���� ���� �� ������).
    */
    procedure getBatchShortName(
      batchShortName out varchar2
      , moduleId out integer
      , optionId integer
    )
    is
    begin
      if schedulerExistsInfo is null then
        select
          coalesce(
            max( case when t.column_name = 'MODULE_ID' then 2 else 1 end)
            , 0
          )
          as scheduler_exists_flag
        into schedulerExistsInfo
        from
          user_tab_columns t
        where
          t.table_name = 'SCH_BATCH'
        ;
      end if;
      if schedulerExistsInfo > 0 then
        execute immediate '
          select
            max( opb.batch_short_name)
            , max( opb.module_id)
          from
            (
            select
              op.option_id
              , max( b.batch_short_name) as batch_short_name
              , to_number( substr(
                  max( rpad( b.batch_short_name, 50) || to_char( b.module_id))
                  , 51
                ))
                as module_id
            from
              opt_option op
              , (
                select
                  b.batch_short_name
                  , ' || case when schedulerExistsInfo = 2 then
                      'b.module_id'
                    else
                      'cast( null as integer) as module_id'
                    end
                  || '
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
          where
            opb.option_id = :optionId
        '
        into
          batchShortName
          , moduleId
        using
          optionId
        ;
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ����������� ����� �����, � �������� ���������'
            || ' �������� ('
            || ' optionId=' || optionId
            || ').'
          )
        , true
      );
    end getBatchShortName;



    /*
      ���������� ��� �������� ���������, ��������������� ���������� ��������
      �����.
    */
    function getValueTypeFromMask(
      maskId integer
    )
    return varchar2
    is
    begin
      return
        case oldRec.mask_id
          when 1 then Number_ValueTypeCode
          when 2 then Number_ValueTypeCode
          when 3 then String_ValueTypeCode
          when 4 then Date_ValueTypeCode
        end
      ;
    end getValueTypeFromMask;



    /*
      ���������� ����� ��� ������ ���������.
    */
    procedure fillRec
    is
    begin
      rec.option_id                 := oldRec.option_id;
      rec.module_id                 :=
        case when oldRec.module_id is not null then
          oldRec.module_id
        else
          pkg_ModuleInfo.getModuleId(
            moduleName =>
              case
                when oldRec.batch_short_name is not null then
                  BatchLoader_ModuleName
                when oldRec.prod_option_short_name like '_%._%' then
                  substr(
                    oldRec.prod_option_short_name
                    , 1
                    , instr( oldRec.prod_option_short_name, '.') - 1
                  )
                when oldRec.prod_option_short_name like '_%:_%' then
                  substr(
                    oldRec.prod_option_short_name
                    , 1
                    , instr( oldRec.prod_option_short_name, ':') - 1
                  )
              end
            , raiseExceptionFlag => 0
          )
        end
      ;
      if rec.module_id is null then
        raise_application_error(
          pkg_Error.IllegalArgument
          , '�� ������� ���������� ��� ������ ��� ��������� ('
            || ' option_short_name="' || oldRec.option_short_name || '"'
            || ', is_test_option=' || oldRec.is_test_option
            || ').'
        );
      end if;
      rec.object_short_name         := oldRec.batch_short_name;
      rec.object_type_id            :=
        case when oldRec.batch_short_name is not null then
          getObjectTypeId(
            moduleId              =>
                pkg_ModuleInfo.getModuleId(
                  svnRoot => Scheduler_SvnRoot
                )
            , objectTypeShortName => Batch_ObjectTypeShortName
          )
        end
      ;
      rec.option_short_name         :=
        case
          when oldRec.batch_short_name is not null then
            substr(
              oldRec.prod_option_short_name
              , length( oldRec.batch_short_name) + 1
            )
          when oldRec.prod_option_short_name like '_%._%' then
            substr(
              oldRec.prod_option_short_name
              , instr( oldRec.prod_option_short_name, '.') + 1
            )
          when oldRec.prod_option_short_name like '_%:_%' then
            substr(
              oldRec.prod_option_short_name
              , instr( oldRec.prod_option_short_name, ':') + 1
            )
          else
            oldRec.prod_option_short_name
        end
      ;
      rec.value_type_code           := getValueTypeFromMask( oldRec.mask_id);
      rec.value_list_flag           := 0;
      rec.encryption_flag           := 0;
      rec.test_prod_sensitive_flag  :=
        case when
            oldRec.is_test_option = 1
            or oldRec.batch_short_name is not null
          then 1
          else 0
        end
      ;
      rec.access_level_code         := null;
      rec.option_name               :=
        case
          when oldRec.is_test_option = 1
                and oldRec.option_name like '% (����)'
              then
            substr( oldRec.option_name, 1, length( oldRec.option_name) - 7)
          when oldRec.is_test_option = 1
                and oldRec.option_name like '% ( ����)'
              then
            substr( oldRec.option_name, 1, length( oldRec.option_name) - 8)
          else
            oldRec.option_name
        end
      ;
      rec.option_description        := null;
      rec.old_option_short_name     := oldRec.prod_option_short_name;
      rec.old_mask_id               := oldRec.mask_id;
      rec.old_option_name_test      :=
        case when oldRec.is_test_option = 1 then
          oldRec.option_name
        end
      ;
      rec.operator_id               := oldRec.operator_id;
    end fillRec;



  -- processOptionInsert
  begin
    open oldOptionCur;
    fetch oldOptionCur into oldRec;
    close oldOptionCur;

    if oldRec.new_option_id is null then
      getBatchShortName(
        batchShortName  => oldRec.batch_short_name
        , moduleId      => oldRec.module_id
        , optionId      => oldRec.option_id
      );
      fillRec();
      rec.option_id := createOption(
        moduleId                => rec.module_id
        , optionShortName       => rec.option_short_name
        , valueTypeCode         => rec.value_type_code
        , optionName            => rec.option_name
        , objectShortName       => rec.object_short_name
        , objectTypeId          => rec.object_type_id
        , valueListFlag         => rec.value_list_flag
        , encryptionFlag        => rec.encryption_flag
        , testProdSensitiveFlag => rec.test_prod_sensitive_flag
        , accessLevelCode       => rec.access_level_code
        , optionDescription     => rec.option_description
        , optionId              => rec.option_id
        , oldOptionShortName    => rec.old_option_short_name
        , oldMaskId             => rec.old_mask_id
        , oldOptionNameTest     => rec.old_option_name_test
        , operatorId            => rec.operator_id
      );
    else
      lockOption(
        rowData     => rec
        , optionId  => oldRec.new_option_id
      );
      if rec.value_type_code != getValueTypeFromMask( oldRec.mask_id)
          or rec.value_list_flag = 1
          then
        raise_application_error(
          pkg_Error.ProcessError
          , '��� ����� ���������� ��������� ���������� �� ���� ������������'
            || ' ��������� ('
            || ' option_id=' || rec.option_id
            || ', value_type_code="' || rec.value_type_code || '"'
            || ', value_list_flag=' || rec.value_list_flag
            || ').'
        );
      elsif
          oldRec.is_test_option = 0
            and rec.option_name != oldRec.option_name
          or oldRec.is_test_option = 1
            and (
              rec.test_prod_sensitive_flag != 1
              or nullif( oldRec.option_name, rec.old_option_name_test)
                  is not null
            )
          then
        updateOption(
          optionId                      => rec.option_id
          , valueTypeCode               => rec.value_type_code
          , valueListFlag               => rec.value_list_flag
          , encryptionFlag              => rec.encryption_flag
          , testProdSensitiveFlag       =>
              case when oldRec.is_test_option = 1 then
                1
              else
                rec.test_prod_sensitive_flag
              end
          , accessLevelCode             => rec.access_level_code
          , optionName                  =>
              case when oldRec.is_test_option = 0 then
                oldRec.option_name
              else
                rec.option_name
              end
          , optionDescription           => rec.option_description
          , moveProdSensitiveValueFlag  => 1
          , deleteBadValueFlag          => 0
          , oldOptionNameTest           =>
              case when oldRec.is_test_option = 1 then
                oldRec.option_name
              else
                rec.old_option_name_test
              end
          , operatorId                  => oldRec.operator_id
        );
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ������� � opt_option ('
          || ' optionId=' || optionId
          || ').'
        )
      , true
    );
  end processOptionInsert;



  /*
    ��������� ��������� � opt_option ( ��������� ������ ��������� ����
    option_name).
  */
  procedure processOptionUpdate(
    oldOptionId integer
  )
  is

    cursor oldOptionCur is
      select
        b.*
        , opn.option_id as new_option_id
      from
        (
        select
          a.*
          , case when
                a.option_short_name != a.prod_option_short_name
              then 1 else 0
            end
            as is_test_option
        from
          (
          select
            opt.*
            , case when
                opt.option_short_name like '%_'
                || OldTestOption_Suffix
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
            opt.option_id = oldOptionId
          ) a
        ) b
        left outer join opt_option_new opn
          on opn.old_option_short_name = b.prod_option_short_name
            and opn.deleted = 0
    ;

    oldRec oldOptionCur%rowtype;

    rec opt_option_new%rowtype;

  -- processOptionUpdate
  begin
    open oldOptionCur;
    fetch oldOptionCur into oldRec;
    close oldOptionCur;
    lockOption(
      rowData     => rec
      , optionId  => oldRec.new_option_id
    );
    updateOption(
      optionId                      => rec.option_id
      , valueTypeCode               => rec.value_type_code
      , valueListFlag               => rec.value_list_flag
      , encryptionFlag              => rec.encryption_flag
      , testProdSensitiveFlag       => rec.test_prod_sensitive_flag
      , accessLevelCode             => rec.access_level_code
      , optionName                  =>
          case when oldRec.is_test_option = 1 then
            rec.option_name
          else
            oldRec.option_name
          end
      , optionDescription           => rec.option_description
      , oldOptionNameTest           =>
          case
            when oldRec.is_test_option = 1 then
              oldRec.option_name
            else
              coalesce(
                rec.old_option_name_test
                -- ��������� ��������� �������� ��-�� �������� ���������
                -- ��������� �������� ����� ( ������� ����������� �� ����
                -- option_name)
                , case when rec.test_prod_sensitive_flag = 1 then
                    rec.option_name || OldTestOptionName_Suffix
                  end
              )
          end
      , operatorId                  => null
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ��������� � opt_option ('
          || ' oldOptionId=' || oldOptionId
          || ').'
        )
      , true
    );
  end processOptionUpdate;



  /*
    ��������� �������� �� opt_option.
  */
  procedure processOptionDelete(
    oldOptionId integer
    , oldOptionShortName varchar2
  )
  is

    -- ��������� ������, ����������� � ��������� �� opt_option ������
    vhr v_opt_value_history%rowtype;



    /*
      ���������� ��������� ������ �� v_opt_value_history, ����������� �
      ��������� ������ � ��������� �� � ���������� vhr.
    */
    procedure getValue
    is

      cursor valueCur is
        select
          a.*
        into vhr
        from
          (
          select
            vlh.*
          from
            v_opt_value_history vlh
          where
            vlh.old_option_id = oldOptionId
          order by
            vlh.value_history_id desc nulls first
            , vlh.change_date desc
            , vlh.value_id desc
          ) a
        where
          rownum <= 1
      ;

    begin
      open valueCur;
      fetch valueCur into vhr;
      close valueCur;

      -- ������ ����� �� ����, ���� ��� ��������� �� ���������� ��������
      if vhr.value_id is not null then
        if vhr.deleted = 1 then
          raise_application_error(
            pkg_Error.ProcessError
            , '������ ���� ������� ('
              || ' value_id=' || vhr.value_id
              || ', change_number=' || vhr.change_number
              || ').'
          );
        elsif vhr.old_option_del_date is not null then
          raise_application_error(
            pkg_Error.ProcessError
            , '������ � opt_option_value ��� ���� ������� ('
              || ' value_id=' || vhr.value_id
              || ', change_number=' || vhr.change_number
              || ', old_option_del_date='
                || to_char( vhr.old_option_del_date, 'dd.mm.yyyy hh24:mi:ss')
              || ').'
          );
        end if;
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ����������� ������ �� v_opt_value_history ('
            || ' oldOptionId=' || oldOptionId
            || ').'
          )
        , true
      );
    end getValue;



    /*
      ���������� Id ��������� �� ����������� ��������� �����
      ( ���������� null, ���� �������� ��� ������).
      ���� ������ checkOptionId, �� ����� ���� ���������� ������ ���������
      ��������.
    */
    function getOptionId(
      checkOptionId integer
    )
    return integer
    is

      -- Id ���������
      optionId integer;

    begin
      select
        case when opn.deleted = 0 then
          opn.option_id
        end
        as option_id
      into optionId
      from
        opt_option_new opn
      where
        opn.old_option_short_name =
          case when
            oldOptionShortName like '%_' || OldTestOption_Suffix
          then
            substr(
              oldOptionShortName, 1, length( oldOptionShortName) - 4
            )
          else
            oldOptionShortName
          end
        and nullif( checkOptionId, opn.option_id) is null
      ;
      return optionId;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ����������� Id ��������� ('
            || ' oldOptionShortName="' || oldOptionShortName || '"'
            || ', checkOptionId=' || checkOptionId
            || ').'
          )
        , true
      );
    end getOptionId;



    /*
      ������� ��������, ���� ����������� � ���� ������� ��� � opt_option.
    */
    procedure deleteNotUsedOption
    is

      -- Id ���������
      optionId integer;

      -- Id ������ � opt_option, ����������� � ���������
      minOldOptionId integer;

    begin
      select
        min( opt.option_id)
      into minOldOptionId
      from
        opt_option opt
      where
        opt.option_short_name in (
          -- � �������� ������ � oldOptionShortName ����� ����, �.�. �
          -- opt_option ��� ������������ �� ����� ����
          oldOptionShortName
          , case when
              oldOptionShortName like '%_' || OldTestOption_Suffix
            then
              substr(
                oldOptionShortName, 1, length( oldOptionShortName) - 4
              )
            else
              oldOptionShortName || OldTestOption_Suffix
            end
        )
        -- ����� ������������ ��������� ������
        and opt.option_id >= 0
      ;
      if minOldOptionId is null then
        optionId := getOptionId(
          checkOptionId => vhr.option_id
        );

        -- �������� ����� ���� ��� ������ � ������ �������� 2-� �������
        -- �� opt_option ( �� ��������� � ������������� ��������)
        -- ����� �������� delete
        if optionId is not null then
          deleteOption(
            optionId        => optionId
            , operatorId    => null
          );
        end if;
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ �������� ��������� �� ������������� �������� ('
            || ' option_id=' || vhr.option_id
            || ').'
          )
        , true
      );
    end deleteNotUsedOption;



  -- processOptionDelete
  begin
    getValue();
    if vhr.value_id is not null then
      vhr.old_option_del_date := sysdate;
      setOldDelDate(
        valueId               => vhr.value_id
        , valueHistoryId      => vhr.value_history_id
        , oldOptionDelDate    => vhr.old_option_del_date
      );
    end if;
    deleteNotUsedOption();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� �������� �� opt_option ('
          || ' oldOptionId=' || oldOptionId
          || ', oldOptionShortName="' || oldOptionShortName || '"'
          || ').'
        )
      , true
    );
  end processOptionDelete;



  /*
    ��������� ������� � opt_option_value.
  */
  procedure processValueInsert(
    optionValueId integer
  )
  is

    cursor oldValueCur is
      select
        b.*
        , opn.option_id as new_option_id
        , case when opn.value_list_flag = 1 then
            String_ValueTypeCode
          else
            opn.value_type_code
          end
          as storage_value_type_code
        , opn.test_prod_sensitive_flag
        , opn.encryption_flag
      from
        (
        select
          a.*
          , case when
                a.option_short_name != a.prod_option_short_name
              then 1 else 0
            end
            as is_test_option
        from
          (
          select
            ov.*
            , opt.option_short_name
            , case when
                opt.option_short_name like '%_'
                || OldTestOption_Suffix
              then
                substr(
                  opt.option_short_name, 1, length( opt.option_short_name) - 4
                )
              else
                opt.option_short_name
              end
              as prod_option_short_name
          from
            opt_option_value ov
            inner join opt_option opt
              on opt.option_id = ov.option_id
          where
            ov.option_value_id = optionValueId
          ) a
        ) b
        left outer join opt_option_new opn
          on opn.old_option_short_name = b.prod_option_short_name
            and opn.deleted = 0
    ;

    oldRec oldValueCur%rowtype;

  -- processValueInsert
  begin
    open oldValueCur;
    fetch oldValueCur into oldRec;
    close oldValueCur;
    if oldRec.encryption_flag = 1 then
      raise_application_error(
        pkg_Error.ProcessError
        , '��� ��������� � ����������� �������� ��������� �������� ��������'
          || ' ������ ����� API ('
          || ' new_option_id=' || oldRec.new_option_id
          || ').'
      );
    end if;
    setValue(
      optionId                => oldRec.new_option_id
      , prodValueFlag         =>
          case when oldRec.test_prod_sensitive_flag = 1 then
            1 - oldRec.is_test_option
          end
      , instanceName          => null
      , usedOperatorId        => null
      , dateValue             => oldRec.datetime_value
      , numberValue           => oldRec.integer_value
      , stringValue           => oldRec.string_value
      , oldOptionValueId      => oldRec.option_value_id
      , oldOptionId           => oldRec.option_id
      , operatorId            => oldRec.operator_id
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ������� � opt_option_value ('
          || ' optionValueId=' || optionValueId
          || ').'
        )
      , true
    );
  end processValueInsert;



  /*
    ��������� �������� �� opt_option_value.
  */
  procedure processValueDelete(
    optionValueId integer
  )
  is

    -- ��������� ������, ����������� � ��������� �� opt_option_value ������
    vhr v_opt_value_history%rowtype;

    -- ������� ��������
    cv opt_value%rowtype;

    -- ������� �������� �������� opt_option_value
    cov opt_option_value%rowtype;



    /*
      ���������� ��������� ������ �� v_opt_value_history, ����������� �
      ��������� ������ � ��������� �� � ���������� vhr.
    */
    procedure getValue
    is
    begin
      select
        a.*
      into vhr
      from
        (
        select
          vlh.*
        from
          v_opt_value_history vlh
        where
          vlh.old_option_value_id = optionValueId
        order by
          vlh.value_history_id desc nulls first
        ) a
      where
        rownum <= 1
      ;
      if vhr.deleted = 1 then
        raise_application_error(
          pkg_Error.ProcessError
          , '������ ���� ������� ('
            || ' value_id=' || vhr.value_id
            || ', change_number=' || vhr.change_number
            || ').'
        );
      elsif vhr.old_option_value_del_date is not null then
        raise_application_error(
          pkg_Error.ProcessError
          , '������ � opt_option_value ��� ���� ������� ('
            || ' value_id=' || vhr.value_id
            || ', change_number=' || vhr.change_number
            || ', old_option_value_del_date='
              || to_char(
                  vhr.old_option_value_del_date, 'dd.mm.yyyy hh24:mi:ss'
                )
            || ').'
        );
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ����������� ������ �� v_opt_value_history ('
            || ' optionValueId=' || optionValueId
            || ').'
          )
        , true
      );
    end getValue;



    /*
      ���������� ������� �������� �������� ������� opt_value �
      ��������� ��� � ���������� cv.
    */
    procedure getCurrentValue(
      valueId integer
    )
    is
    begin
      select
        vl.*
      into cv
      from
        opt_value vl
      where
        vl.value_id = valueId
      ;
      if cv.deleted = 1 then
        cv := null;
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ����������� �������� �������� �� opt_value ('
            || ' valueId=' || valueId
            || ').'
          )
        , true
      );
    end getCurrentValue;



    /*
      ���������� ������� �������� �������� ������� opt_option_value �
      ��������� ��� � ���������� cov.
    */
    procedure getCurrentOldValue(
      valueId integer
      , storageValueTypeCode varchar2
    )
    is

      cursor dataCur is
        select
          a.*
        from
          (
          select
            ov.*
          from
            opt_option_value ov
            inner join opt_option opt
              on opt.option_id = ov.option_id
          where
            ov.option_value_id in
              (
              select
                vlh.old_option_value_id
              from
                v_opt_value_history vlh
              where
                vlh.value_id = valueId
                and vlh.old_option_value_id is not null
                and vlh.old_option_value_del_date is null
              )
            and case opt.mask_id
                when 1 then Number_ValueTypeCode
                when 2 then Number_ValueTypeCode
                when 3 then String_ValueTypeCode
                when 4 then Date_ValueTypeCode
              end
              = storageValueTypeCode
          order by
            ov.date_ins desc
          ) a
        where
          rownum <= 1
      ;

    begin
      open dataCur;
      fetch dataCur into cov;
      close dataCur;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ����������� �������� �������� �� opt_option_value ('
            || ' valueId=' || valueId
            || ').'
          )
        , true
      );
    end getCurrentOldValue;



  -- processValueDelete
  begin
    getValue();
    getCurrentValue( valueId => vhr.value_id);
    getCurrentOldValue(
      valueId                 => vhr.value_id
      , storageValueTypeCode  => vhr.storage_value_type_code
    );

    vhr.old_option_value_del_date := sysdate;
    setOldDelDate(
      valueId                 => vhr.value_id
      , valueHistoryId        => vhr.value_history_id
      , oldOptionValueDelDate => vhr.old_option_value_del_date
    );
    if nullif( cov.option_value_id, cv.old_option_value_id) is not null then
      updateValue(
        valueId                 => cv.value_id
        , valueTypeCode         => cv.value_type_code
        , dateValue             =>
            case when
              cv.storage_value_type_code = Date_ValueTypeCode
            then
              cov.datetime_value
            end
        , numberValue           =>
            case when
              cv.storage_value_type_code = Number_ValueTypeCode
            then
              cov.integer_value
            end
        , stringValue           =>
            case when
              cv.storage_value_type_code = String_ValueTypeCode
            then
              cov.string_value
            end
        , valueListSeparator    => cv.list_separator
        , oldOptionValueId      => cov.option_value_id
        , oldOptionId           => cov.option_id
        , operatorId            => null
      );
    elsif cov.option_value_id is null
          and cv.old_option_value_id is not null
        then
      deleteValue(
        valueId   => cv.value_id
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� �������� �� opt_option_value ('
          || ' optionValueId=' || optionValueId
          || ').'
        )
      , true
    );
  end processValueDelete;



  /*
    ��������� ���������, ��������� � ���������� �������.
  */
  procedure processChange
  is

    -- ������ �������� �������� ���������
    i pls_integer;

  begin
    i := onChangeIdList.first();
    while i is not null loop
      if onChangeIdList( i) < 0 then
        logger.trace(
          'processChange: ignore temporary changes: id=' || onChangeIdList( i)
        );
      else
        case
          when tableName = 'OPT_OPTION' and statementType = 'INSERT' then
            processOptionInsert( optionId => onChangeIdList( i));
          when tableName = 'OPT_OPTION' and statementType = 'UPDATE' then
            processOptionUpdate( oldOptionId => onChangeIdList( i));
          when tableName = 'OPT_OPTION' and statementType = 'DELETE' then
            processOptionDelete(
              oldOptionId           => onChangeIdList( i)
              , oldOptionShortName  => onDeleteOptionSNameList( i)
            );
          when tableName = 'OPT_OPTION_VALUE' and statementType = 'INSERT' then
            processValueInsert( optionValueId => onChangeIdList( i));
          when tableName = 'OPT_OPTION_VALUE' and statementType = 'DELETE' then
            processValueDelete( optionValueId => onChangeIdList( i));
          else
            raise_application_error(
              pkg_Error.ProcessError
              , '��������� ��������� �� ��������������.'
            );
        end case;
      end if;
      i := onChangeIdList.next( i);
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ���������.'
        )
      , true
    );
  end processChange;



-- onOldAfterStatement
begin
  logger.trace(
    'onOldAfterStatement: ' || tableName || ': ' || statementType
    || case when not isCopyOld2NewChange then ' - skipped' end
  );
  if coalesce( isCopyOld2NewChange, true) then
    isCopyOld2NewChange := true;
    if tableName = onChangeTableName and statementType = onChangeStatementType
        then

      -- ���������, � ����� �������� ����������� ��������� �� ����� ������
      -- � ����������
      begin
        isCopyNew2OldChange := false;
        processChange();
        isCopyNew2OldChange := true;
      exception when others then
        isCopyNew2OldChange := true;
        raise;
      end;

      checkNew2OldSync();
      onChangeTableName := null;
      onChangeStatementType := null;
      onChangeIdList := null;
    else
      raise_application_error(
        pkg_Error.IllegalArgument
        , '����������� ��� ������� ��� ��� DML ( ���������'
          || ' "' || onChangeTableName || '"'
          || ' � "' || onChangeStatementType || '"'
          || ').'
          || ' ���������� ������� DML ( ��������, merge) �� ��������������.'
      );
    end if;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ � ���������, ���������� ����� ���������� DML ('
        || ' tableName="' || tableName || '"'
        || ', statementType="' || statementType || '"'
        || ').'
      )
    , true
  );
end onOldAfterStatement;

end pkg_OptionMain;
/
