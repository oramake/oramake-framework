create or replace package body pkg_DataSync is
/* package body: pkg_DataSync::body */



/* group: ���� */

/* itype: NameT
  ��� ������� � ��.
*/
subtype NameT is varchar2(128);

/* itype: FullNameT
  ������ ��� ������� (�������� � ��������� ���������) � ��.
*/
subtype FullNameT is varchar2(257);

/* itype: ObjectFullNameT
  ������ ��� ������� (��� ������� � ��������).
*/
type ObjectFullNameT is record (
  -- �������� �������
  owner NameT
  -- ��� �������
  , objectName NameT
);

/* itype: ConfigStringT
  ������ � �����������.
*/
subtype ConfigStringT is varchar2(4000);

/* itype: ConfigItemListT
  ������ �������� �� ������ � �����������.
*/
type ConfigItemListT is table of ConfigStringT;

/* itype: ConfigOptionListT
  ������ �������������� ����� �� ������ � �����������.
*/
type ConfigOptionListT is table of ConfigStringT index by NameT;

/* itype: ColumnInfoT
  ���������� �� �������� ��� ����������.
*/
type ColumnInfoT is record (

  -- ������ �������� ������� � �������
  -- ",<columnName>[,<columnName2>][,<columnName3>]...."
  keyColumn varchar2(1000)

  -- ������ ������� ��� ���������� �� ����������� �������� ������� � �������
  -- ",<columnName>[,<columnName2>][,<columnName3>]...."
  , regularColumn varchar2(10000)

  -- ������� ��� where, ������������ ������ � ������ ������������ ������ �
  -- �������� ������ ( ����� "a") � �������� ������ ( ����� "t"), �����������
  -- � ������ ������������� ���������� ������� ���� LOB ( CLOB ��� BLOB)
  , equalWhereSql varchar2(32500)
);



/* group: ��������� */

/* iconst: List_Separator
  ������-���������, ������������ � �������.
*/
List_Separator constant varchar2(1) := ':';

/* iconst: MLog_CommentTail
  ��������� ����� �����������, ������� ����������� � ����������� �������,
  ���������� ����������������� ���, ������������� ������������ Oracle.
  � ������ ����������� ������������ ������ "$(moduleSvnRoot)", �������
  ���������� �� ���� � ��������� �������� ������ � Subversion ( ������� �
  ����� �����������), ��������� � ��������� ��������� <createMLog>.
*/
MLog_CommentTail constant varchar2(100) := ' [ SVN Root: $(moduleSvnRoot)]';

/* iconst: ExcludeColumnList_OptName
  ��� �������������� ����� "������ �������, ����������� �� ���������� (�����
  �������, ��� ����� ��������)".
*/
ExcludeColumnList_OptName constant NameT := 'excludeColumnList';



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_DataSync'
);



/* group: ������� */

/* iproc: execSql
  ��������� ������������ SQL.

  ���������:
  sqlText                     - ����� SQL ��� ����������
*/
procedure execSql(
  execSql varchar2
)
is
begin
  logger.trace( 'execSql: ' || execSql);
  execute immediate execSql;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� SQL'
        || case when length( execSql) > 500 then
            ' (������ 500 ��������): "'
            || chr(10) || substr( execSql, 1, 500) || '..."'
          else
            ': "' || chr(10) || execSql || chr(10) || '".'
          end
      )
    , true
  );
end execSql;

/* ifunc: getLocalFullName
  ���������� ��� ��������� � ��� ������� �� ������ � ������ �������.
  ���� ��� ��������� �� ������ ����, �� ������������ ������� ������������
  ( ��� ������� �������� ����������� �����).

  ���������:
  localObject                 - ������ � ������, � �������� ������, ����������
                                �������

  �������:
  ��� ��������� � ��� ������� (��� <ObjectFullNameT>)
*/
function getLocalFullName(
  localObject varchar2
)
return ObjectFullNameT
is

  ofn ObjectFullNameT;

begin
  if instr( localObject, '@') > 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������ �� �������� ���������.'
    );
  end if;
  if localObject like '%.%' then
    ofn.owner := substr( localObject, 1, instr( localObject, '.') - 1);
    ofn.objectName := substr( localObject, instr( localObject, '.') + 1);
  else
    ofn.owner := lower( sys_context( 'USERENV', 'CURRENT_USER'));
    ofn.objectName := localObject;
  end if;
  return ofn;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ����������� ������� ����� ���������� ������� ('
        || ' localObject="' || localObject || '"'
        || ').'
      )
    , true
  );
end getLocalFullName;

/* iproc: getColumnInfo
  ���������� ���������� �� �������� ��� ����������.

  ���������:
  colInfo                     - ���������� �� �������� ��� ����������
                                (�������)
  columnTableOwner            - ��� ��������� ������� (�������������) ���
                                ��������� ������ ������� (��� ����� ��������)
  columnTableName             - ��� ������� (�������������) ��� ���������
                                ������ ������� (��� ����� ��������)
  keyTableName                - ��� ��������� ������� ��� ����������� �������
                                ���������� ����� (��� ����� ��������)
                                (�� ��������� columnTableOwner)
  keyTableName                - ��� ������� ��� ����������� �������
                                ���������� ����� (��� ����� ��������)
                                (�� ��������� columnTableName)
  excludeColumnList           - ������ �������, ����������� �� ����������
                                (����� �������, ��� ����� ��������)
                                (�� ��������� �����������)
  fillEqualWhereSqlFlag       - ��������� colInfo.equalWhereSql
                                (1 ��������� ��� ������������� (�� ���������),
                                 0 �� ���������)
  raiseKeyNotFoundFlag        - ����������� ���������� ��� ���������� �������
                                ���������� �����
                                (1 �� (�� ���������), 0 ���)

  �������:
  ���������� �� �������� (��� <ColumnInfoT>).
*/
procedure getColumnInfo(
  colInfo out nocopy ColumnInfoT
  , columnTableOwner varchar2
  , columnTableName varchar2
  , keyTableOwner varchar2 := null
  , keyTableName varchar2 := null
  , excludeColumnList varchar2 := null
  , fillEqualWhereSqlFlag pls_integer := null
  , raiseKeyNotFoundFlag pls_integer := null
)
is

  cursor columnCur is
    select
      lower( tc.column_name) as column_name
      , case when b.column_name is not null then 1 else 0 end
        as key_column_flag
      , case when
            excludeColumnList is not null
            and instr(
                ',' || lower( excludeColumnList) || ','
                , ',' || lower( tc.column_name) || ','
              )
              > 0
          then 1 else 0
        end
        as exclude_flag
      , case when tc.data_type in ( 'CLOB', 'BLOB')  then 1 else 0 end
        as lob_type_flag
      , case when tc.nullable = 'Y' then 1 else 0 end
        as nullable_flag
      , max( case when tc.data_type in ( 'CLOB', 'BLOB') then 1 else 0 end)
        over()
        as exists_lob_column_flag
    from
      all_tab_columns tc
      left outer join
        (
        select
          ic.column_name
          , ic.column_position
        from
          all_constraints cn
          inner join all_ind_columns ic
            on ic.index_owner = cn.owner
              and ic.index_name = cn.index_name
        where
          cn.owner = upper( coalesce( keyTableOwner, columnTableOwner))
          and cn.table_name = upper( coalesce( keyTableName, columnTableName))
          and cn.constraint_type = 'P'
        ) b
        on b.column_name = tc.column_name
    where
      tc.owner = upper( columnTableOwner)
      and tc.table_name = upper( columnTableName)
    order by
      b.column_position nulls last
      , tc.column_id nulls last
      , tc.column_name
  ;

-- getColumnInfo
begin
  for rec in columnCur loop
    if rec.key_column_flag = 1 then
      colInfo.keyColumn := colInfo.keyColumn || ',' || rec.column_name;
      if rec.exclude_flag = 1 then
        raise_application_error(
          pkg_Error.IllegalArgument
          , '���������� ��������� �� ���������� ������� ���������� ����� ('
            || ' column_name="' || rec.column_name || '"'
            || ').'
        );
      end if;
    elsif rec.exclude_flag = 0 then
      colInfo.regularColumn := colInfo.regularColumn || ',' || rec.column_name;
    end if;
    if coalesce( fillEqualWhereSqlFlag, 1) != 0
          and rec.exists_lob_column_flag = 1 and rec.exclude_flag = 0
        then
      colInfo.equalWhereSql :=
        case when colInfo.equalWhereSql is not null then
          colInfo.equalWhereSql || chr(10) || ' and '
        end
        || replace(
            case when rec.nullable_flag = 0 and rec.lob_type_flag = 0 then
              't.$cn = a.$cn'
            else
              '( coalesce( t.$cn, a.$cn) is null'
                || case when rec.lob_type_flag = 1 then
                    ' or dbms_lob.compare( t.$cn, a.$cn) = 0'
                  else
                    ' or t.$cn = a.$cn'
                  end
                || ')'
            end
            , '$cn', rec.column_name
          )
      ;
    end if;
  end loop;
  if colInfo.keyColumn is null and colInfo.regularColumn is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�� ������� ���������� ������ ������� ��� ����������'
        || ' (������� �� ����������, ���������� ���� �����������'
        || ' ������� ������������).'
    );
  end if;
  if coalesce( raiseKeyNotFoundFlag, 1) != 0 and colInfo.keyColumn is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�� ������� ���������� �������� ���������� �����.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� ���������� �� ��������� ��� ���������� ('
        || ' columnTableOwner="' || columnTableOwner || '"'
        || ', columnTableName="' || columnTableName || '"'
        || ', keyTableOwner="' || keyTableOwner || '"'
        || ', keyTableName="' || keyTableName || '"'
        || ').'
      )
    , true
  );
end getColumnInfo;

/* iproc: parseConfigString
  ��������� ������ � �����������.
  ������ � ����������� ������ ���� � �������:

  <item1>[:[<item2>][:...[:[<itemN>]...]]][:[<optionList>]]

  ���

  item1 ... itemN       - ���������
  optionList            - ������ �������������� ����� (� ������������ ������)
                          � ������� "<optName>=<optValue>"

  ���������:
  itemList                    - ������ �������� (maxItemCount ���������,
                                �� ��������� � ���������������� ������
                                ����� �������� NULL)
                                (�������)
  optionList                  - ������ ����� (��� ��������� � optionNameList,
                                �� ��������� � ���������������� ������
                                ����� �������� NULL)
                                (�������)
  cfgString                   - ������ � �����������
  maxItemCount                - ������������ ����� ��������
                                (��� ����� optionList)
  optionNameList              - ���������� ����� �������������� �����

  ���������:
  - ��� ���������� �������� ��������� ����� (��������,
    <ExcludeColumnList_OptName>) ����������� �������������� ��������������;
*/
procedure parseConfigString(
  itemList out nocopy ConfigItemListT
  , optionList out nocopy ConfigOptionListT
  , cfgString varchar2
  , maxItemCount pls_integer
  , optionNameList cmn_string_table_t
)
is

  -- ���������� �������
  Space_Char constant varchar2(10) :=
    ' ' || chr(9) || chr(10) || chr(13)
  ;

  -- ����� ��������� ������ ��� ����� �������� �� ������� �����
  itemCount pls_integer;

  -- ������� �������� �� ������� ����� (�� ������ ���������)
  isOptionList boolean;



  /*
    ������� ���������� ������� � ������ � ������ ������.
  */
  function trimSpace(
    srcStr varchar2
  )
  return varchar2
  is
  begin
    return
      ltrim(
        rtrim(
          srcStr
          , Space_Char
        )
        , Space_Char
      )
    ;
  end trimSpace;



  /*
    ��������� itemList.
  */
  procedure fillItemList
  is

    i pls_integer := 1;

  begin
    itemList := ConfigItemListT();
    itemList.extend( maxItemCount);
    for i in 1 .. itemCount loop
      itemList( i) := trimSpace(
        pkg_Common.getStringByDelimiter( cfgString, List_Separator, i)
      );
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� itemList.'
        )
      , true
    );
  end fillItemList;



  /*
    ��������� optionList ������� � NULL-����������.
  */
  procedure fillOptionList
  is
  begin
    optionList := ConfigOptionListT();
    for i in optionNameList.first .. optionNameList.last loop
      optionList( optionNameList( i)) := null;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� optionList ������� � NULL-����������.'
        )
      , true
    );
  end fillOptionList;



  /*
    ������������� �������� �����.
  */
  procedure setOption(
    optionName varchar2
    , optionValue varchar2
  )
  is
  begin
    if optionList.exists( optionName) then
      optionList( optionName) :=
        case when optionName = ExcludeColumnList_OptName then
          lower( translate( optionValue, '.' || Space_Char, '.'))
        else
          optionValue
        end
      ;
    else
      raise_application_error(
        pkg_Error.IllegalArgument
        , '����������� ��� �����: "' || optionName || '".'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� �������� ����� ('
          || ' optionName="' || optionName || '"'
          || ', optionValue="' || optionValue || '"'
          || ').'
        )
      , true
    );
  end setOption;



  /*
    ������ ������ �����.
  */
  procedure parseOptionString(
    optStr varchar2
  )
  is

    -- ����� ����������� ������
    len pls_integer := length( optStr);

    -- ������� ������� ������� �����
    iBegin pls_integer := 1;

    -- ������� ����������� ����� � ��������
    iSep pls_integer;

    -- ������� ���������� ������� �����
    iLast pls_integer;

    -- ��� ������� �����
    optionName NameT;

  begin
    while iBegin < len loop
      iSep := instr( optStr, '=', iBegin);
      if iSep = 0 then
        raise_application_error(
          pkg_Error.IllegalArgument
          , '�� ������� �������� ����� ('
            || ' optionString="'
              || trimSpace( substr( optStr, iBegin)) || '"'
            || ').'
        );
      end if;

      -- ������� ����������� ��������� �����
      iLast := instr( optStr, '=', iSep + 1);
      if iLast = 0 then
        iLast := len;
      else

        -- ���������� "=" � ���������� �������
        iLast := length( rtrim( substr( optStr, 1, iLast - 1), Space_Char));

        -- ���������� ��� ��������� �����
        while iLast > iSep
              and instr( Space_Char, substr( optStr, iLast, 1)) = 0
            loop
          iLast := iLast - 1;
        end loop;
      end if;

      setOption(
        optionName => trimSpace( substr( optStr, iBegin, iSep - iBegin))
        , optionValue => trimSpace( substr( optStr, iSep + 1, iLast - iSep))
      );

      iBegin := iLast + 1;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������� ������ ����� ('
          || ' optStr="' || optStr || '"'
          || ').'
        )
      , true
    );
  end parseOptionString;



-- parseConfigString
begin
  itemCount := least(
    coalesce( length( cfgString), 0)
      - coalesce( length( replace( cfgString, List_Separator, '')), 0)
      + 1
    , maxItemCount + 1
  );
  isOptionList :=
    itemCount > maxItemCount
    or itemCount > 1
      -- ��������� ������� �������� "="
      and instr(
          cfgString
          , '='
          , instr( cfgString, List_Separator, 1, itemCount - 1)
        ) > 0
  ;
  if isOptionList then
    itemCount := itemCount - 1;
  end if;
  fillItemList();
  fillOptionList();
  if isOptionList then
    parseOptionString(
      substr( cfgString, instr( cfgString, List_Separator, 1, itemCount) + 1)
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������� ������ � ����������� ('
        || ' cfgString="' || cfgString || '"'
        || ', maxItemCount=' || maxItemCount
        || ').'
      )
    , true
  );
end parseConfigString;



/* group: �������� �� ���������� ����� */

/* func: appendData
  �������� ������ � �������(�) � �������� �� �� ���������� �����.

  ���������:
  targetDbLink                - ���� � �� ����������
  tableName                   - ������� ��� ��������
                                (��� ����� ��������, �������� � ��������� �����)
  idTableName                 - ������������ �������� ������� ��� ������
                                �������� ���������� �����
                                (��� ����� ��������, �������� � ��������� �����)
                                (�� ��������� tableName)
  addonTableList              - �������������� ������� ��� ��������
                                (������ ��. ����)
                                (�� ��������� �����������)
  sourceTableName             - ������� (�������������) � ��������� �������
                                (��� ����� ��������, �������� � ��������� �����)
                                (�� ��������� tableName)
  excludeColumnList           - ������ ������� �������, ����������� ��
                                ���������� (� ������������ �������, ��� �����
                                ��������)
                                (�� ��������� ������, �.�. ����������� ���
                                ������� �������)
  toDate                      - ����, �� ������� ���������� ������
                                (date_ins < toDate)
                                (�� ��������� �� ������ ����������� ����)
  maxExecTime                 - ������������ ����� ���������� ������� (�
                                ������, ���� ����� ��������� � �������� ������
                                ��� ���������, ������� ��������� ������
                                � ������� ������������� � ���)
                                (�� ��������� ��� �����������)

  �������:
  - ����� ����������� ������� (��� ����� �������������� ������);

  �������� ������ �������������� ������ (�������� addonTableList) ����������� � �������:

  <addonTableName>[:[<addonSourceTableName>]][:[<optionList>]]

  addonTableName        - �������������� ������� ��� ��������
                          (��� ����� ��������, �������� � ��������� �����)
  addonSourceTableName  - �������� �������������� ������� ��� ��������
                          (��� ����� ��������, �������� � ��������� �����)
                          (�� ��������� addonTableName)
  optionList            - ������ �������������� ����� (� ������������ ������)
                          � ������� "<optName>=<optValue>", ���������� �����
                          ����������� ����;

  ��������� ��������������
  ����� (����������� � <optionList>):

  excludeColumnList     - ������ ������� �������������� �������, �����������
                          �� ���������� (� ������������ �������, ��� �����
                          ��������, ���������� ������� ������������)
                          (�� ��������� � ���������� ��������� ��� �������)

  ������� ��������� (0x09), �������� ������� (0x0D), �������� ������ (0x0A)
  ��������������� ��� ���������� � ������������, ���� ��� ������� �� ��� �����
  ��������� ������.

  ���������:
  - ������� ����������� � ���������� ���������� � ������ commit ����� ��������
    ������������� ����� �������;
*/
function appendData(
  targetDbLink                varchar2
, tableName                   varchar2
, idTableName                 varchar2 := null
, addonTableList              cmn_string_table_t := null
, sourceTableName             varchar2 := null
, excludeColumnList           varchar2 := null
, toDate                      date := null
, maxExecTime                 interval day to second := null
)
return integer
is

  -- ����� �������, �������������� � ����� �����
  Block_RowCount constant integer := 10000;

  -- ����� �������, ����� �������� ������� ����������� commit
  Commit_RowCount constant integer := 100000;

  -- ����� ������������ �������
  nProcessed integer := 0;

  -- ����� ������������ ������� � �������������� ��������
  nAddonProcessed integer := 0;

  -- ������������ Id ����������� �������
  maxProcessedId integer;

  -- ������������ Id ������ ��� ��������
  maxUnloadId integer;

  -- ����� ����������� ��������� (case ������������� ������ ��� ����������
  -- �����������)
  stopProcessDate date :=
    case when maxExecTime is not null then current_date + maxExecTime end
  ;

  -- ������������ ������� ���������� ����� (1-� � ������ ���������� �����)
  idColumnName NameT;

  -- ��� ������� ��� ��������� �������� Id ��� ��������
  idSourceTable FullNameT;

  -- ������� ��� �������� ������ (1-� - ��������, ��������� - ��������������)
  type TableListItemT is record (
    -- ��� ������� (�������� � ��������� ���������)
    tableName FullNameT
    -- ����� SQL ��� �������� ������ � �������
    , unloadSql varchar2(32000)
  );
  type TableListT is table of TableListItemT;
  tableList TableListT := TableListT();



  /*
    ��������� ���������������� ��������.
  */
  procedure initialize is
  begin
    pkg_TaskHandler.initTask(
      moduleName  => Module_Name
    , processName => 'appendData'
    );
  end initialize;



  /*
    ��������� ������� ����� ����������� ������.
  */
  procedure clean is
  begin
    pkg_TaskHandler.cleanTask();
  end clean;



  /*
    �������������� ������ ������ ��� �������� ������.
  */
  procedure prepareTableList
  is

    ci ColumnInfoT;

    tab ObjectFullNameT;
    idTab ObjectFullNameT;

    iAddon integer;

    -- ��������� �������������� �������
    addonItemList ConfigItemListT;
    addonOptionList ConfigOptionListT;



    /*
      ��������� ������� � ������.
    */
    procedure addTable(
      tableName varchar2
      , srcTableName varchar2
    )
    is

      ti TableListItemT;

    begin
      ti.tableName := tableName;
      ti.unloadSql :=
'insert into
  ' || tableName || '@' || targetDbLink || '
(
  ' || substr(
        replace( ci.keyColumn || ci.regularColumn, ',', chr(10) || '  , ')
        , 6
      ) || '
)
select /*+ index( t) */
  ' || substr(
        replace( ci.keyColumn || ci.regularColumn, ',', chr(10) || '  , t.')
        , 6
      ) || '
from
  ' || coalesce( srcTableName, tableName) || ' t
where
  t.' || idColumnName || ' > :beforeStartId
  and t.' || idColumnName || ' <= :maxId
'
      ;
      tableList.extend(1);
      tableList( tableList.last()) := ti;
    end addTable;



    /*
      ��������� ������ � ����������� ��� �������������� �������.
    */
    procedure parseAddonTableString(
      cfgString varchar2
    )
    is
    begin
      parseConfigString(
        itemList          => addonItemList
        , optionList      => addonOptionList
        , cfgString       => cfgString
        , maxItemCount    => 2
        , optionNameList  =>
            cmn_string_table_t(
              ExcludeColumnList_OptName
            )
      );
      if addonItemList(1) is null then
        raise_application_error(
          pkg_Error.IllegalArgument
          , '�� ������� ������� ��� ����������.'
        );
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ������� ������ � ����������� �������������� ������� ('
            || 'cfgString="' || cfgString || '"'
            || ').'
          )
        , true
      );
    end parseAddonTableString;



  -- prepareTableList
  begin
    tab := getLocalFullName( coalesce( sourceTableName, tableName));
    idTab := getLocalFullName( coalesce( idTableName, tableName));
    getColumnInfo(
      colInfo                   => ci
      , columnTableOwner        => tab.owner
      , columnTableName         => tab.objectName
      , keyTableOwner           => idTab.owner
      , keyTableName            => idTab.objectName
      , excludeColumnList       => excludeColumnList
      , fillEqualWhereSqlFlag   => 0
    );
    idColumnName :=
      substr( ci.keyColumn, 2, instr( ci.keyColumn || ',', ',', 2) - 2)
    ;
    idSourceTable := coalesce( idTableName, sourceTableName, tableName);
    addTable( tableName, sourceTableName);
    if addonTableList is not null then
      iAddon := addonTableList.first();
      while iAddon is not null loop
        parseAddonTableString( addonTableList( iAddon));
        tab := getLocalFullName( coalesce( addonItemList(2), addonItemList(1)));
        getColumnInfo(
          colInfo                   => ci
          , columnTableOwner        => tab.owner
          , columnTableName         => tab.objectName
          , excludeColumnList       =>
              addonOptionList( ExcludeColumnList_OptName)
          , fillEqualWhereSqlFlag   => 0
          , raiseKeyNotFoundFlag    => 0
        );
        addTable( addonItemList(1), addonItemList(2));
        iAddon := addonTableList.next( iAddon);
      end loop;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� ������ ������ ��� �������� ������.'
        )
      , true
    );
  end prepareTableList;



  /*
    ���������� ������������ Id ����������� �������.
  */
  function getMaxUnloadedId
  return integer
  is

    -- ������������ Id ����������� �������.
    maxId integer;

  begin
    execute immediate
      'select max(t.' || idColumnName || ') from '
      || tableName || '@' || targetDbLink || ' t'
    into
      maxId
    ;
    return maxId;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ����������� ������������� Id ����������� ������� ('
          || ' targetDbLink="' || targetDbLink || '"'
          || ', tableName="' || tableName || '"'
          || ', idColumnName="' || idColumnName || '"'
          || ').'
        )
      , true
    );
  end getMaxUnloadedId;



  /*
    ���������� ������������ Id ������������ �������.
  */
  procedure setMaxProcessedId
  is
  begin
    logger.trace( 'setMaxProcessedId: start...');
    maxProcessedId := coalesce( getMaxUnloadedId(), 0);
    logger.debug(
      'setMaxProcessedId: maxProcessedId=' || maxProcessedId
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ����������� ������������� Id ������������ �������.'
        )
      , true
    );
  end setMaxProcessedId;



  /*
    ��������� ������� � ������� ���� date_ins
  */
  function existsFieldDateIns
  return boolean
  is

    idTab ObjectFullNameT;
    countDateIns integer;

  begin
    idTab := getLocalFullName( idSourceTable);
    select
      count(1)
    into
      countDateIns
    from
      all_tab_columns tc
    where
      tc.owner = upper( idTab.owner)
      and tc.table_name = upper( idTab.objectName)
      and tc.column_name = 'DATE_INS'
    ;
    return
      case countDateIns
        when 0 then false
        else true
      end;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� ������� � ������� ���� date_ins ('
          || 'idSourceTable="' || idSourceTable || '"'
          || ').'
        )
      , true
    );
  end existsFieldDateIns;



  /*
    ���������� ������������ Id ������ ��� ��������.
  */
  procedure setMaxUnloadId
  is

    toUnloadDate date;

    sqlText varchar2(32767);

  begin
    logger.trace( 'setMaxUnloadId: start...');
    -- ��������� ������ � ������� ���� date_ins
    if existsFieldDateIns() then
      toUnloadDate :=
         coalesce( toDate, trunc(sysdate, 'hh24') - 1/24)
      ;
      logger.trace('toUnloadDate=' || to_char(toUnloadDate));
      -- ���� ���� date_ins ������������ � �������, �� ��������� ���������
      -- ������������ Id ������ ��� �������� ������ �� ����
      sqlText :=
      '
        select
          min(a.' || idColumnName || ') - 1 as max_period_id
        from
          (
          select /*+ first_rows */
            t.' || idColumnName || '
          from
            ' || idSourceTable || ' t
          where
            t.date_ins > :toUnloadDate
          order by
            t.date_ins
          ) a
        where
          rownum <= 1000
      ';
      logger.trace(sqlText);
      execute immediate
        sqlText
      into
        maxUnloadId
      using
        toUnloadDate
      ;
    end if;
    if maxUnloadId is null then
      -- ���� �� ������� ��������� ������������ Id ������ ��� ��������
      -- ������ �� �������� ���� date_ins, ����� ������������ �������� �� �������
      sqlText :=
      '
        select
          max(t.' || idColumnName || ') as max_id
        from
          ' || idSourceTable || ' t
      ';
      logger.trace(sqlText);
      execute immediate
        sqlText
      into
        maxUnloadId
      ;
    end if;
    logger.debug('setMaxUnloadId: maxUnloadId=' || maxUnloadId);
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ����������� ������������� Id ������ ��� �������� ('
          || 'idSourceTable="' || idSourceTable || '"'
          || ').'
        )
      , true
    );
  end setMaxUnloadId;



  /*
    ���������� ������������ id ��� ����� �������.

    ���������:
    beforeStartId             - Id ������, ������� � ������� ( �� ������� ��)
                                ����������� ��������
    maxId                     - ������������ Id ������, �� �������
                                (������������) ����������� ��������
    maxRowCount               - ������������ ����� ����������� �������

    �������:
    ������������ Id ����� �������.
  */
  function getBlockMaxId(
    beforeStartId integer
    , maxId integer
    , maxRowCount integer
  )
  return integer
  is

    -- ����� SQL
    getSql varchar2(32000);

    -- ��������� �������
    blockMaxId integer;

  begin
    getSql := '
select
  max(' || idColumnName || ') as block_max_id
from
  (
  select
    b.' || idColumnName || '
  from
    (
    select
      a.' || idColumnName || '
    from
      ' || coalesce( sourceTableName, tableName) || ' a
    where
      a.' || idColumnName || ' > :beforeStartId
      and a.' || idColumnName || ' <= :maxId
    order by
      a.' || idColumnName || '
    ) b
  where
    rownum <= :maxRowCount
  )
';
    logger.trace('getSql="' || getSql || '"');
    execute immediate
      getSql
    into
      blockMaxId
    using
      beforeStartId
      , maxId
      , maxRowCount
    ;
    return blockMaxId;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ����������� ������������� Id ����� ������ ('
          || ' beforeStartId=' || beforeStartId
          || ', maxId=' || maxId
          || ', maxRowCount=' || maxRowCount
          || ').'
        )
      , true
    );
  end getBlockMaxId;



  /*
    ��������� ������ � �������.

    ���������:
    iTable                    - ������ ������� � tableList
    beforeStartId             - Id ������, ������� � ������� (�� ������� ��)
                                ����������� ��������
    maxId                     - ������������ Id ������, �� �������
                                (������������) ����������� ��������

    �������:
    ����� ����������� �������.
  */
  function unloadBlock(
    iTable integer
  , beforeStartId integer
  , maxId integer
  )
  return integer
  is

    -- ����� ����������� �������
    nUnload integer;

  begin
    logger.trace('unloadSql="' || tableList( iTable).unloadSql || '"');
    execute immediate
      tableList( iTable).unloadSql
    using
      beforeStartId
      , maxId
    ;
    nUnload := sql%rowcount;
    logger.trace(
      'unloadBlock: ' || tableList( iTable).tableName
      || ': ��������� �������: ' || nUnload
    );
    return nUnload;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� ������ ('
          || 'tableName="' || tableList( iTable).tableName || '"'
          || ', beforeStartId=' || beforeStartId
          || ', maxId=' || maxId
          || ').'
        )
      , true
    );
  end unloadBlock;



  /*
    ��������� �������� ������.
  */
  procedure unloadData
  is

    pragma autonomous_transaction;

    -- ������� ���������� ��������
    isFinish boolean := false;

    -- ����� ����������� � ������� ���������� �������
    nTransactionUnload integer;

    -- ����� ����������� � ������� ����� �������
    nBlockUnload integer;
    nAddonUnload integer;

    -- ������������ Id ����������� � ���������� ����� �������
    prevMaxId integer := maxProcessedId;

    -- ������������ Id ����������� � ������� ����� �������
    blockMaxId integer;

  -- unloadData
  begin
    while not isFinish loop
      nTransactionUnload := 0;
      while not isFinish
            and nTransactionUnload < Commit_RowCount
          loop
        logger.trace(
          'unloadData: start unload block: prevMaxId=' || prevMaxId
        );
        blockMaxId := getBlockMaxId(
          beforeStartId  => prevMaxId
        , maxId          => maxUnloadId
        , maxRowCount    => Block_RowCount
        );
        nBlockUnload := unloadBlock(
          iTable         => 1
        , beforeStartId  => prevMaxId
        , maxId          => blockMaxId
        );
        if nBlockUnload > 0 then
          blockMaxId := getMaxUnloadedId();
          for iTable in 2 .. tableList.last() loop
            nAddonUnload := unloadBlock(
              iTable        => iTable
            , beforeStartId => prevMaxId
            , maxId         => blockMaxId
            );
            nAddonProcessed := nAddonProcessed + nAddonUnload;
          end loop;
          prevMaxId := blockMaxId;
          nTransactionUnload := nTransactionUnload + nBlockUnload;
          if stopProcessDate is not null then
            if current_date >= stopProcessDate then
              isFinish := true;
              logger.info(
                '�������� ���������� � ����� � ����������� ������ �������.'
              );
            end if;
          end if;
        else
          isFinish := true;
        end if;
      end loop;
      commit;
      nProcessed := nProcessed + nTransactionUnload;
      maxProcessedId := prevMaxId;
      logger.debug(
        'unloadData: commit transaction: nTransactionUnload='
        || nTransactionUnload
        || ', maxProcessedId=' || maxProcessedId
      );
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� ������ ('
          || ' nProcessed=' || nProcessed
          || ', maxProcessedId=' || maxProcessedId
          || ', maxUnloadId=' || maxUnloadId
          || ').'
        )
      , true
    );
  end unloadData;



-- unloadData
begin
  initialize();
  prepareTableList();
  setMaxProcessedId();
  setMaxUnloadId();
  if maxProcessedId < maxUnloadId then
    unloadData();
  end if;
  clean();
  logger.info(
    '��������� ������� � ' || tableName || ': ' || nProcessed
    || case when tableList.count() > 1 then
        ' (� ����� � '
        || case when tableList.count() = 2 then
            tableList(2).tableName || ': '
          else
            '�������������� �������: '
          end
        || nAddonProcessed || ')'
      end
  );
  return nProcessed;
exception when others then
  clean();
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ������ ('
      || 'targetDbLink="' || targetDbLink || '"'
      || ', tableName="' || tableName || '"'
      || ', sourceTableName="' || sourceTableName|| '"'
      || ', idTableName="' || idTableName || '"'
      || ', addonTableList.count='
        || case when addonTableList is not null then
          to_char( addonTableList.count())
        end
      || ', sourceTableName="' || sourceTableName || '"'
      || ', excludeColumnList="' || excludeColumnList || '"'
      || ', toDate={' || to_char(toDate, 'dd.mm.yyyy hh24:mi:ss') || '}'
      || ', maxExecTime=' || to_char(maxExecTime)
      || ').'
      )
    , true
  );
end appendData;

/* func: appendData( SIMPLE)
  �������� ������ � ������� (� �������� � ���� �������������� �������) �
  �������� �� �� ���������� �����.

  ���������:
  targetDbLink                - ���� � �� ����������
  tableName                   - ������� ��� ��������
  idTableName                 - ������������ �������� ������� ��� ������
                                �������� ���������� ����� (�� ���������
                                tableName)
  addonTableName              - �������������� ������� ��� ��������
                                (�� ��������� �����������)
  addonSourceTableName        - �������� �������������� ������� ��� ��������
                                (�� ��������� addonTableName)
  addonExcludeColumnList      - ������ ������� �������������� �������,
                                ����������� �� ����������
                                (� ������������ �������, ��� ����� ��������,
                                 ���������� ������� ������������)
                                (�� ��������� � ��������� ��� �������)
  sourceTableName             - ������� (�������������) � ��������� �������
                                (�� ��������� tableName)
  excludeColumnList           - ������ ������� �������, ����������� ��
                                ���������� (� ������������ �������, ��� �����
                                ��������)
                                (�� ��������� ������, �.�. ����������� ���
                                ������� �������)
  toDate                      - ����, �� ������� ���������� ������
                                (date_ins < toDate)
                                (�� ��������� �� ������ ����������� ����)
  maxExecTime                 - ������������ ����� ���������� ������� (�
                                ������, ���� ����� ��������� � �������� ������
                                ��� ���������, ������� ��������� ������
                                � ������� ������������� � ���)
                                (�� ��������� ��� �����������)

  �������:
  - ����� ����������� �������;

  ���������:
  - �������� �������� ��� �������� ������� <appendData> (� ����������
    addonTableList);
*/
function appendData(
  targetDbLink                varchar2
, tableName                   varchar2
, idTableName                 varchar2 := null
, addonTableName              varchar2
, addonSourceTableName        varchar2 := null
, addonExcludeColumnList      varchar2 := null
, sourceTableName             varchar2 := null
, excludeColumnList           varchar2 := null
, toDate                      date := null
, maxExecTime                 interval day to second := null
)
return integer
is
begin
  return
    appendData(
      targetDbLink                => targetDbLink
      , tableName                 => tableName
      , idTableName               => idTableName
      , addonTableList            =>
          case when
            addonTableName is not null
            or addonSourceTableName is not null
            or addonExcludeColumnList is not null
          then
            cmn_string_table_t(
              addonTableName
              || case when addonSourceTableName is not null then
                  ':' || addonSourceTableName
                end
              || case when addonExcludeColumnList is not null then
                  ':' || ExcludeColumnList_OptName
                  || '=' || addonExcludeColumnList
                end
            )
          end
      , sourceTableName           => sourceTableName
      , excludeColumnList         => excludeColumnList
      , toDate                    => toDate
      , maxExecTime               => maxExecTime
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ������ ('
      || 'addonTableName="' || addonTableName || '"'
      || ', addonSourceTableName="' || addonSourceTableName || '"'
      || ', addonExcludeColumnList="' || addonExcludeColumnList || '"'
      || ').'
      )
    , true
  );
end appendData;



/* group: ���������� � ������� ��������� */

/* proc: refreshByCompare
  ��������� ������ ������� � ������� ��������� ������������ � ��� � ����������
  ������ � �������� ����������� ��������� ��������� merge � delete.

  ���������:
  targetTable                 - ������� ��� ���������� (��� �������, ��������
                                � ��������� ����� � DB-�����, ��� �����
                                ��������)
  dataSource                  - �������� ���������� ������
  tempTableName               - ��������� ������� ��� �������������� ����������
                                ���������� ������ � ������������� � ��������
                                merge � delete ( ��� �������, ��������
                                � ��������� �����, ��� ����� ��������)
                                ( �� ��������� � �������� merge � delete
                                  ������������ �������� ���������� ������)
  excludeColumnList           - ������ ������� �������, ����������� ��
                                ���������� ( � ������������ �������, ��� �����
                                ��������)
                                ( �� ��������� ������, �.�. ����������� ���
                                  ������� �������)

  ���������:
  - � ������� ������ ���� ��������� ����;
  - � dataSource ����� ���� ������� ����� ���������, �� �������� �����
    ��������� ������� � ��������� ���� �������, �������������� � ������� ���
    ����������, �� ����������� ��������� � excludeColumnList;
  - �� ��������� ������� ������ ���� ��� �������, �������������� � ������� ���
    ����������, �� ����������� ��������� � excludeColumnList;
  - � ������ �������� �������� ������� � �������� targetTable ������ �������
    ������������ �� dataSource, � ��������� ���� �� targetTable � ��
    ���������;
*/
procedure refreshByCompare(
  targetTable varchar2
  , dataSource varchar2
  , tempTableName varchar2 := null
  , excludeColumnList varchar2 := null
)
is

  -- ���������� �� �������� ��� ����������
  ci ColumnInfoT;

  -- ���� ����������
  refreshDate date;

  -- ����� �����������/��������� �������
  nMerged integer;

  -- ����� ��������� �������
  nDeleted integer;



  /*
    ��������� ������ ������� ��� ����������.
  */
  procedure fillColumn(
    excludeColumn varchar2
  )
  is

    -- ������� (�������������) ��� ��������� ������ �������
    colTab ObjectFullNameT;

  begin
    colTab := getLocalFullName(
      localObject =>
        case when
          instr( targetTable, '@') > 0
        then
          dataSource
        else
          targetTable
        end
    );
    getColumnInfo(
      colInfo               => ci
      , columnTableOwner    => colTab.owner
      , columnTableName     => colTab.objectName
      , keyTableName        =>
          case when
            instr( targetTable, '@') > 0
          then
            substr( targetTable, 1, instr( targetTable, '@') - 1)
          end
      , excludeColumnList   => excludeColumnList
    );
  end fillColumn;



  /*
    ��������� ���������� ������ �� ��������� �������.
  */
  procedure loadTempTable
  is
  begin
    execSql( 'delete from ' || tempTableName);
    execSql(
'insert into
  ' || tempTableName || '
(
  ' || substr(
        replace( ci.keyColumn || ci.regularColumn, ',', chr(10) || '  , ')
        , 6
      ) || '
)
select
  ' || substr(
        replace( ci.keyColumn || ci.regularColumn, ',', chr(10) || '  , a.')
        , 6
      ) || '
from
  ' || dataSource || ' a
'
    );
    logger.trace(
      'loaded record into ' || tempTableName || ': ' || sql%rowcount
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� ���������� ������ �� ��������� �������.'
        )
      , true
    );
  end loadTempTable;



  /*
    ��������� ������� �����������/���������� ������� � �������.
  */
  procedure mergeChangedRecord(
    recordSource varchar2
  )
  is
  begin
    execSql(
'merge into
  ' || targetTable || ' d
using
(
select
  ' || substr(
        replace( ci.keyColumn || ci.regularColumn, ',', chr(10) || '  , a.')
        , 6
      ) || '
from
  ' || recordSource || ' a'
|| case when ci.equalWhereSql is not null then
'
where
  not exists
    (
    select
      null
    from
      ' || targetTable || ' t
    where
      ' || ci.equalWhereSql || '
    )'
else
'
minus
select
  ' || substr(
        replace( ci.keyColumn || ci.regularColumn, ',', chr(10) || '  , t.')
        , 6
      ) || '
from
  ' || targetTable || ' t'
end
|| '
) s
on
(
  ' || substr(
        regexp_replace( ci.keyColumn, ',([^,]+)', chr(10) || '  and d.\1 = s.\1')
        , 8
      ) || '
)
when matched then update set
  ' || substr(
        regexp_replace( ci.regularColumn, ',([^,]+)', chr(10) || '  , d.\1 = s.\1')
        , 6
      ) || '
when not matched then insert
(
  ' || substr(
        replace( ci.keyColumn || ci.regularColumn, ',', chr(10) || '  , ')
        , 6
      ) || '
)
values
(
  ' || substr(
        replace( ci.keyColumn || ci.regularColumn, ',', chr(10) || '  , s.')
        , 6
      ) || '
)
'
    );
    nMerged := sql%rowcount;
    logger.trace( 'merged record into ' || targetTable || ': ' || nMerged);
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������� �����������/���������� ������� ('
          || ' keyColumn="' || ci.keyColumn || '"'
          || ', recordSource="' || recordSource || '"'
          || ').'
        )
      , true
    );
  end mergeChangedRecord;



  /*
    ������� ������ ������ �� �������.
  */
  procedure deleteExcessRecord(
    recordSource varchar2
  )
  is
  begin
    execSql(
'delete from
  ' || targetTable || ' d
where
(
  ' || substr(
        replace( ci.keyColumn , ',', chr(10) || '  , d.')
        , 6
      ) || '
)
not in
(
select
  ' || substr(
        replace( ci.keyColumn , ',', chr(10) || '  , a.')
        , 6
      ) || '
from
  ' || recordSource || ' a
where
  ' || substr(
        regexp_replace(
          ci.keyColumn
          , ',([^,]+)'
          , chr(10) || '  and d.\1 is not null'
        )
        , 8
      ) || '
)
'
    );
    nDeleted := sql%rowcount;
    logger.trace( 'deleted record into ' || targetTable || ': ' || nDeleted);
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������� ������ ������� ('
          || ' keyColumn="' || ci.keyColumn || '"'
          || ', recordSource="' || recordSource || '"'
          || ').'
        )
      , true
    );
  end deleteExcessRecord;



-- refreshByCompare
begin
  fillColumn(
    excludeColumn =>
      case when excludeColumnList is not null then
        ',' || lower( excludeColumnList) || ','
      end
  );
  refreshDate := sysdate;
  if tempTableName is not null then
    loadTempTable();
  end if;
  deleteExcessRecord(
    recordSource => coalesce( tempTableName, dataSource)
  );
  mergeChangedRecord(
    recordSource => coalesce( tempTableName, dataSource)
  );
  logger.info(
    '������� ' || targetTable || ' ��������� � ������� ��������� ������'
    || ' �� ��������� "' || dataSource || '"'
    || case when tempTableName is not null then
        ' � �������������� ��������� ������� "' || tempTableName || '"'
      end
    || ' ('
    || ' ���� ����������: ' || to_char( refreshDate, 'dd.mm.yyyy hh24:mi:ss')
    || ', ������� ���������: ' || to_char( nMerged + nDeleted)
    || case when nMerged + nDeleted > 0 then
        ', �� ��� ���������/�������� �������: ' || nMerged
        || ', ������� �������: ' || nDeleted
      end
    || ').'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� � ������� ��������� ������ ('
        || ' targetTable="' || targetTable || '"'
        || ', dataSource="' || dataSource || '"'
        || ', tempTableName="' || tempTableName || '"'
        || ', excludeColumnList="' || excludeColumnList || '"'
        || ').'
      )
    , true
  );
end refreshByCompare;


/* group: ���������� � ������� ������������������ ������������� */

/* iproc: dropMLog
  ������� ��� ������������������ �������������.

  ���������:
  tableName                   - ��� ������� ������� ( ��� ����� ��������)
*/
procedure dropMLog(
  tableName varchar2
)
is
begin
  execSql(
    'drop materialized view log on ' || tableName
  );
  logger.info(
    'droped materialized log on: ' || tableName
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ���� ������������������ ������������� ('
        || ' tableName="' || tableName || '"'
        || ').'
      )
    , true
  );
end dropMLog;

/* proc: createMLog
  ������� ����������� ���� ����������������� �������������.

  ���������:
  mlogList                    - ������ ����� �-������������� � �������
                                <tableName>[:<createOption>], ��� tableName
                                ��� ������� ������� ( ��� ����� ��������),
                                createOption ����� ��� �������� ����
                                ( ������: "tmp_table:with rowid")
  viewList                    - ������ �������������, ������������ ���
                                ���������� ( ����������� ��� ������������� ���
                                ����� ��������)
                                ( ���������� ��������� ������ � ������
                                  grantPrivsFlag ������� 1, ����� ����������
                                  �������������, ������� ����� ������ �����,
                                  �� ��������� �����������)
  moduleSvnRoot               - ���� � ��������� �������� ������ � Subversion
                                ( ������� � ����� �����������, ��������:
                                "Oracle/Module/ModuleInfo"). ���� ������, ��
                                � ����������� � �������, ���������� ���,
                                ����������� ������
                                " [ SVN root: <moduleSvnRoot>]"
                                ( �� ��������� �����������)
  forTableName                - ��������� ��� ������ ��� ��������� �������
                                �� ������
                                ( �� ��������� ��� �����������)
  recreateFlag                - ���� ������������ ����, ���� �� ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  grantPrivsFlag              - ���� ������ �������������, ������� ����� ��
                                �������� �������������, � ������� ������������
                                ������� ����, ���� �� ��� � ������ ��� ��������
                                ( 1 ��, 0 ��� ( �� ���������))
*/
procedure createMLog(
  mlogList cmn_string_table_t
  , viewList cmn_string_table_t := null
  , moduleSvnRoot varchar2 := null
  , forTableName varchar2 := null
  , recreateFlag integer := null
  , grantPrivsFlag integer := null
)
is

  cursor mlogCur is
    select
      b.*
      , (
        select
          1
        from
          user_mview_logs ml
        where
          ml.master = upper( b.table_name)
        )
        as exists_flag
    from
      (
      select
        trim( substr( a.info_string, 1, a.separator_pos - 1)) as table_name
        , trim( substr( a.info_string, a.separator_pos + 1)) as create_option
      from
        (
        select
          t.column_value as info_string
          , instr( t.column_value || List_Separator, List_Separator)
            as separator_pos
        from
          table( mlogList) t
        ) a
      ) b
    where
      nullif( upper( forTableName), upper( b.table_name)) is null
  ;

  -- ����� ������� ������������ ������� ������
  nProcessed pls_integer := 0;



  /*
    ��������� �������� �-����.
  */
  procedure processCreate(
    tableName varchar2
    , createOption varchar2
  )
  is
  begin
    execSql(
      'create materialized view log on ' || tableName
      || case when createOption is not null then
          ' ' || createOption
        end
    );
    logger.info(
      'created materialized log on: ' || tableName
      || case when createOption is not null then
          ' ( ' || createOption || ')'
        end
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� ����.'
        )
      , true
    );
  end processCreate;



  /*
    ��������� ����������� � ������� ����.
  */
  procedure updateComment(
    tableName varchar2
  )
  is

    logTableName varchar2(30);

    tableComment varchar2(4000);

  begin
    select
      ml.log_table as log_table_name
      , tc.comments as table_comment
    into logTableName, tableComment
    from
      user_mview_logs ml
      left outer join user_tab_comments tc
        on tc.table_name = ml.log_table
    where
      ml.master = upper( tableName)
    ;
    execSql(
      'comment on table ' || logTableName
      || ' is ''' || replace( tableComment, '''', '''''')
      || ' [ SVN Root: ' || moduleSvnRoot || ']'''
    );
    logger.debug(
      'updated materialized log table comment: ' || logTableName
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� ����������� � ������� ����.'
        )
      , true
    );
  end updateComment;



  /*
    ������ ����� �� ���.
  */
  procedure grantMLogPrivs(
    tableName varchar2
  )
  is

    cursor grantListCur is
      select distinct
        pr.grantee
        , ml.log_table as log_table_name
      from
        user_dependencies dp
        inner join user_mview_logs ml
          on ml.master = dp.referenced_name
        inner join user_tab_privs pr
          on pr.table_name = dp.name
            and pr.owner = dp.referenced_owner
            and pr.privilege = 'SELECT'
      where
        dp.name in
          (
          select
            upper( t.column_value) as view_name
          from
            table( viewList) t
          )
        and dp.type = 'VIEW'
        and dp.referenced_owner = sys_context( 'USERENV', 'CURRENT_USER')
        and dp.referenced_type = 'TABLE'
        and dp.referenced_name = upper( tableName)
      order by
        1
    ;

  begin
    for rec in grantListCur loop
      execSql(
        'grant select on ' || rec.log_table_name || ' to ' || rec.grantee
      );
      logger.info(
        'granted: select on ' || rec.log_table_name || ' to ' || rec.grantee
      );
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������ ���� �� ���.'
        )
      , true
    );
  end grantMLogPrivs;



-- createMLog
begin
  for rec in mlogCur loop
    begin
      if rec.exists_flag = 1 and recreateFlag = 1 then
        dropMLog( tableName => rec.table_name);
        rec.exists_flag := 0;
      end if;
      if coalesce( rec.exists_flag, 0) = 0 then
        processCreate(
          tableName       => rec.table_name
          , createOption  => rec.create_option
        );
        if moduleSvnRoot is not null then
          updateComment(
            tableName     => rec.table_name
          );
        end if;
        if coalesce( grantPrivsFlag, 1) != 0 and viewList is not null then
          grantMLogPrivs(
            tableName     => rec.table_name
          );
        end if;
      else
        logger.debug( 'materialized log exists on: ' || rec.table_name);
      end if;
      nProcessed := nProcessed + 1;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ��������� �-���� ('
            || ' table_name="' || rec.table_name || '"'
            || ', create_option="' || rec.create_option || '"'
            || ', exists_flag=' || rec.exists_flag
            || ').'
          )
        , true
      );
    end;
  end loop;
  if forTableName is not null and nProcessed = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '��� ������� ���������� ��� ��� ���������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ����������� ����� �-������������� ('
        || ' mlogList.count='
          || case when mlogList is not null then mlogList.count() end
        || ', moduleSvnRoot="' || moduleSvnRoot || '"'
        || ', forTableName="' || forTableName || '"'
        || ', recreateFlag=' || recreateFlag
        || ').'
      )
    , true
  );
end createMLog;

/* proc: dropMLog
  ������� ���������������� ���� ����������������� �������������.

  ���������:
  mlogList                    - ������ ����� �-������������� � �������
                                <tableName>[:<createOption>], ��� tableName
                                ��� ������� ������� ( ��� ����� ��������),
                                createOption ����� ��� �������� ���� ( ��
                                ������������)
  moduleSvnRoot               - ���� � ��������� �������� ������ � Subversion
                                ( ������� � ����� �����������, ��������:
                                "Oracle/Module/ModuleInfo"). ���� ������, ��
                                �� ����������� � �������, ���������� ���,
                                ������������, ��� �� ��� ������ � ������ ������
                                ( �� ��������� �����������)
  forTableName                - ������� ��� ������ ��� ��������� �������
                                �� ������
                                ( �� ��������� ��� �����������)
  forceFlag                   - ���� �������� ���� ���� ���� �� �������� ��
                                ���������� � ������ ������
                                ( 1 ��, 0 ��� ( �� ���������))
  continueAfterErrorFlag      - ���������� ��������� ��������� ����� � ������
                                ������ ��� �������� ���� ������������������
                                �������������
                                ( 1 ��, 0 ��� ( �� ���������))

  ���������:
  - ���� ��� ��� �������� �����������, �� �������� �� ����������� � ���������
    ����������� ��� ������;
*/
procedure dropMLog(
  mlogList cmn_string_table_t
  , moduleSvnRoot varchar2 := null
  , forTableName varchar2 := null
  , forceFlag integer := null
  , continueAfterErrorFlag integer := null
)
is

  cursor mlogCur is
    select
      b.table_name
      , ml.log_table
      , case when moduleSvnRoot is not null then
          coalesce(
            (
            select
              1
            from
              user_tab_comments tc
            where
              tc.table_name = ml.log_table
              and tc.comments like '%'
                || replace( MLog_CommentTail, '$(moduleSvnRoot)', moduleSvnRoot)
            )
            , 0
          )
        end
        as for_module_flag
    from
      (
      select
        trim( substr( a.info_string, 1, a.separator_pos - 1)) as table_name
      from
        (
        select
          t.column_value as info_string
          , instr( t.column_value || List_Separator, List_Separator)
            as separator_pos
        from
          table( mlogList) t
        ) a
      ) b
      left outer join user_mview_logs ml
        on ml.master = upper( b.table_name)
    where
      nullif( upper( forTableName), upper( b.table_name)) is null
  ;

  -- ����� ������� ������������ ������� ������
  nProcessed pls_integer := 0;

  -- ����� ������� ������, ������������ � ��������
  nError pls_integer := 0;

  -- � ������ ���� ������� ��� ���������
  isTableFound boolean := false;

-- dropMLog
begin
  for rec in mlogCur loop
    begin
      isTableFound := true;
      if rec.log_table is not null then
        if moduleSvnRoot is null or forceFlag = 1 or rec.for_module_flag = 1
            then
          dropMLog( tableName => rec.table_name);
        else
          logger.debug( 'skiped materialized log on: ' || rec.table_name);
        end if;
        nProcessed := nProcessed + 1;
      end if;
    exception when others then
      if continueAfterErrorFlag = 1 then
        nError := nError + 1;
        logger.error(
          '������ #' || nError || ' ��� �������� ���� �-�������������:'
          || chr(10) || logger.getErrorStack()
        );
      else
        raise;
      end if;
    end;
  end loop;
  if nError > 0 then
    raise_application_error(
      pkg_Error.ProcessError
      , '��� �������� ��������� ����� �-������������� �������� ������ ('
        || ' nError=' || nError
        || ', nProcessed=' || nProcessed
        || ').'
    );
  elsif forTableName is not null and not isTableFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '��� ������� ���������� ������� ��� ���������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ���������������� ����� �-������������� ('
        || ' mlogList.count='
          || case when mlogList is not null then mlogList.count() end
        || ', moduleSvnRoot="' || moduleSvnRoot || '"'
        || ', forTableName="' || forTableName || '"'
        || ', forceFlag=' || forceFlag
        || ', continueAfterErrorFlag=' || continueAfterErrorFlag
        || ').'
      )
    , true
  );
end dropMLog;

/* proc: grantPrivs
  ������ ����� ��� ��������� ������������, ��� ������� ����� �����������
  ������������ �������.

  ���������:
  viewList                    - ������ �������������, ������������ ���
                                ���������� ( ����������� ��� ������������� ���
                                ����� ��������)
  userName                    - ��� ������������, �������� �������� �����
  mlogList                    - ������ ����� �-������������� � �������
                                <tableName>[:<createOption>], ��� tableName
                                ��� ������� ������� ( ��� ����� ��������),
                                createOption ����� ��� �������� ���� ( ��
                                ������������)
                                ( �� ��������� �����������)
  forObjectName               - ���������� ������ ���� ������ ���������
                                �������������� ���� �������� ��������
                                � ��������� � ��� �����
                                ( ��� ������� ��� ����� ��������)
                                ( �� ��������� ��� �����������)
*/
procedure grantPrivs(
  viewList cmn_string_table_t
  , userName varchar2
  , mlogList cmn_string_table_t := null
  , forObjectName varchar2 := null
)
is

  cursor objectCur is
    select
      t.column_value as object_name
    from
      table( viewList) t
    where
      nullif( upper( forObjectName), upper( t.column_value)) is null
    union all
    select
      case t.object_type_id
        when 1 then
          b.table_name
        when 2 then
          -- ��������� �������� �� ���������, ����� �������� ������
          -- � ������ ���������� �-����
          coalesce( ml.log_table, upper( 'mlog$_' || b.table_name))
      end
      as object_name
    from
      (
      select
        trim( substr( a.info_string, 1, a.separator_pos - 1)) as table_name
      from
        (
        select
          t.column_value as info_string
          , instr( t.column_value || List_Separator, List_Separator)
            as separator_pos
        from
          table( mlogList) t
        ) a
      ) b
      cross join
        (
        select 1 as object_type_id from dual
        union all select 2 from dual
        ) t
      left outer join user_mview_logs ml
        on ml.master = upper( b.table_name)
    where
      nullif( upper( forObjectName), upper( b.table_name)) is null
  ;

  -- ����� ������� ������������ ������� ������
  nProcessed pls_integer := 0;

-- grantPrivs
begin
  for rec in objectCur loop
    execSql(
      'grant select on ' || rec.object_name || ' to ' || userName
    );
    logger.info(
      'granted: select on ' || rec.object_name || ' to ' || userName
    );
    nProcessed := nProcessed + 1;
  end loop;
  if forObjectName is not null and nProcessed = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '��� ������� ���������� ������ ��� ������ ����.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������ ���� ��� ��������� ������������ ('
        || ' viewList.count='
          || case when viewList is not null then viewList.count() end
        || ', userName="' || userName || '"'
        || ', mlogList.count='
          || case when mlogList is not null then mlogList.count() end
        || ', forObjectName="' || forObjectName || '"'
        || ').'
      )
    , true
  );
end grantPrivs;

/* proc: dropMViewPreserveTable
  ������� ����������������� ������������� � ����������� ����������� �������
  � �������.

  ���������:
  tableName                   - ��� ������� ( �-�������������)
*/
procedure dropMViewPreserveTable(
  tableName varchar2
)
is
begin
  execSql(
    'drop materialized view ' || tableName || ' preserve table'
  );
  logger.info(
    '������� ����������������� ������������� ��� ������� ' || tableName
    || ' ( � ����������� ����������� �������).'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� �-������������� � ����������� ������� ('
        || ' tableName="' || tableName || '"'
        || ').'
      )
    , true
  );
end dropMViewPreserveTable;

/* proc: refreshByMView
  ��������� ������ ������������ ������� � ������� fast-������������
  ������������������ �������������.

  ���������:
  tableName                   - ��� ������� ( �-�������������) ��������
                                ������������
  sourceView                  - ��� ������������� � ��������� �������, ��������
                                � ��������� �����
                                ( ��� ����� ��������, ������������ � ������
                                  �������� �-�������������)
                                ( �� ��������� �����������)
  excludeColumnList           - ������ ������� �������, ����������� ��
                                ���������� ( � ������������ �������, ��� �����
                                ��������)
                                ( �� ��������� ������, �.�. ����������� ���
                                  ������� �������)
  allowDropMViewList          - ������ ����������������� ������������� ��������
                                ������������, ������� ����� ���� �������, ����
                                ��� ������� �� ����������� ����������� �������
                                ( ��� ���������� ������ "ORA-32334: cannot
                                  create prebuilt materialized view on a table
                                  already referenced by a MV" ��� ��������
                                  ������������������ �������������)
                                ( ��� ����� ��������, �� ��������� ������
                                  ������ � �������� �� �����������)
  createMViewFlag             - ��������� ����������������� ������������� ���
                                ���������� �������, ���� ��� ����������� ����
                                ��� ���������� ������������ ��� ����������
                                ( 1 ��, 0 ��� ( �� ���������), ������������ �
                                  � ������ �������� forceCreateMViewFlag ������
                                  1)
  forceCreateMViewFlag        - ���������� ��������� ( �������������)
                                ����������������� ������������� ��� ����������
                                �������
                                ( 1 ��, 0 ��� ( �� ���������))

  ���� �������� createMViewFlag ����� 1, �� ��� ���������� ���������
  ����������������� ������������� �����:
  - ������� � ������ ��� ����������;
  - ����������� � ������ ������������ ����� �������� ������, �� ������� ���
    �������� ( ��� ������������� ������
    "ORA-12034: materialized view log on "..." younger than last refresh"
    �� ����� ���������� ���� ���� ���� �������� ���������� ����
    ( ������������ � ��� �� ��, ��� � ����������������� �������������) ������
    ��� ����� ���� �������� ������������������ �������������);

  ���� �������� forceCreateMViewFlag ����� 1, �� ��� ���������� ���������
  � ����� ������ ����� ������� ����� ����������������� �������������.

  ���������:
  - ��� ���������� ������� ����������� commit;
  - ��� ���������� �������� ��������� � �������� ������ ����� ���������
    �-������������� ��������������� ������������ ���������� �� �������
    ��� ���������� � �� ������� � ��������� �������, �� ������� �������
    �������� �������������, � ����������� ���������� ������ ������� � �������
    ��������� ������ ( ��. <refreshByCompare>);
*/
procedure refreshByMView(
  tableName varchar2
  , sourceView varchar2 := null
  , excludeColumnList varchar2 := null
  , allowDropMViewList cmn_string_table_t := null
  , createMViewFlag integer := null
  , forceCreateMViewFlag integer := null
)
is

  -- ����������� �������� �-������������� � ������ �������������
  isAllowCreate constant boolean :=
    forceCreateMViewFlag = 1 or createMViewFlag = 1
  ;

  -- ���� ������� �-�������������
  existsMViewFlag integer;

  -- ���� �������� �-�������������, ��������������� �� ������ ������
  -- ��������� ( null ���� ������������� ��� ���� �����������)
  mviewCreatedDate date;

  -- �������� � ��� ��������� �������������
  srcView ObjectFullNameT;



  /*
    ������� ��������� �� ������� �-������������� �� ������ ����������� ���
    ��������.
  */
  procedure dropDepsMView
  is

    cursor dropMViewCur is
      select
        lower( dp.name) as mview_name
      from
        user_dependencies dp
      where
        dp.name in
          (
          select
            upper( t.column_value) as mview_name
          from
            table( allowDropMViewList) t
          )
        and dp.type = 'MATERIALIZED VIEW'
        and dp.referenced_owner = sys_context( 'USERENV', 'CURRENT_USER')
        and dp.referenced_type = 'TABLE'
        and dp.referenced_name = upper( tableName)
        and dp.referenced_link_name is null
        and dp.name != dp.referenced_name
      order by
        1
    ;

  begin
    for rec in dropMViewCur loop
      dropMViewPreserveTable( tableName => rec.mview_name);
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� ��������� �� ������� �-�������������.'
        )
      , true
    );
  end dropDepsMView;



  /*
    ������������� ���������� �� �������, ������������ ��� ���������,
    ��� �������������� ��������� � ��� ������.
  */
  procedure lockTable(
    sourceViewOwner varchar2
    , sourceViewName varchar2
  )
  is

    cursor lockTableCur is
      select
        cast( tableName as varchar2(300)) as target_table
      from
        dual
      union all
      select
        *
      from
        (
        select
          lower(
              t.referenced_owner
              || '.' || t.referenced_name
              || case when t.referenced_link_name is not null then
                  '@' || t.referenced_link_name
                end
            )
            as target_table
        from
          all_dependencies t
        where
          t.owner = upper( sourceViewOwner)
          and t.name = upper( sourceViewName)
          and t.referenced_type = 'TABLE'
        order by
          t.referenced_link_name
          , t.referenced_owner
          , t.referenced_name
        )
    ;

  begin
    for rec in lockTableCur loop
      execSql(
        'lock table ' || rec.target_table
        || ' in exclusive mode wait 3'
      );
      logger.debug(
        'locked table: ' || rec.target_table
      );
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� ������ ����� ���������� ('
          || ' sourceViewOwner="' || sourceViewOwner || '"'
          || ', sourceViewName="' || sourceViewName || '"'
          || ').'
        )
      , true
    );
  end lockTable;



  /*
    ���������� ����� ��������� �������������.
  */
  function getSourceViewText(
    sourceViewOwner varchar2
    , sourceViewName varchar2
  )
  return varchar2
  is

    -- ���������� ������������ ����� ��� varchar2 ( � ������������� ���� ����
    -- LONG)
    viewText varchar2(32567);

  begin
    select
      t.text
    into viewText
    from
      all_views t
    where
      t.owner = upper( sourceViewOwner)
      and t.view_name = upper( sourceViewName)
    ;
    return viewText;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ������ ��������� ������������� ('
          || ' sourceViewOwner="' || sourceViewOwner || '"'
          || ', sourceViewName="' || sourceViewName || '"'
          || ').'
        )
      , true
    );
  end getSourceViewText;



  /*
    ������� �-������������� ��� ���������� �������.
  */
  procedure createMView
  is
  begin
    if allowDropMViewList is not null then
      dropDepsMView();
    end if;
    lockTable(
      sourceViewOwner   => srcView.owner
      , sourceViewName  => srcView.objectName
    );
    refreshByCompare(
      targetTable           => tableName
      , dataSource          => srcView.owner || '.' || srcView.objectName
      , excludeColumnList   => excludeColumnList
    );
    execSql(
'create materialized view
  ' || tableName || '
on prebuilt table with reduced precision
refresh fast on demand
as
'
      || getSourceViewText(
          sourceViewOwner   => srcView.owner
          , sourceViewName  => srcView.objectName
        )
    );
    logger.info(
      '������� ����������������� ������������� ��� ���������� ������� '
      || tableName
      || ' �� ������ ������� �� ������������� '
      || srcView.owner || '.' || srcView.objectName
      || '.'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� �-�������������.'
        )
      , true
    );
  end createMView;



  /*
    ���������� ���� ���������� ������������������ �������������.
  */
  function getMViewRefreshDate
  return date
  is

    lastRefreshDate date;

  begin
    select
      t.last_refresh_date
    into lastRefreshDate
    from
      user_mviews t
    where
      t.mview_name = upper( tableName)
    ;
    return lastRefreshDate;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ���� ���������� �-�������������.'
        )
      , true
    );
  end getMViewRefreshDate;



  /*
    �������� ���� �������� �����, �� ������� ������� �-�������������.
  */
  procedure checkMLogCreatedDate
  is

    cursor dataCur is
      select
        lower(
            t.referenced_owner
            || '.' || t.referenced_name
          )
          as source_table
        , ml.log_table
        , mlo.created as mlog_created_date
      from
        all_dependencies t
        inner join all_mview_logs ml
          on ml.log_owner = t.referenced_owner
            and ml.master = t.referenced_name
            and t.referenced_link_name is null
        inner join all_objects mlo
          on mlo.owner = ml.log_owner
            and mlo.object_name = ml.log_table
            and mlo.object_type = 'TABLE'
      where
        t.owner = upper( srcView.owner)
        and t.name = upper( srcView.objectName)
        and t.referenced_type = 'TABLE'
        and mlo.created >= mviewCreatedDate
      order by
        1
    ;

  -- checkMLogCreatedDate
  begin
    for rec in dataCur loop
      raise_application_error(
        pkg_Error.ProcessError
        , '��� ��� ������� ' || rec.source_table
          || ' �������� ��� ���������� ����� �������� �-�������������,'
          || ' ��-�� ���� � �-������������� ����� ���� ������������ ������ ('
          || ' mviewCreatedDate='
            || to_char( mviewCreatedDate, 'dd.mm.yyyy hh24:mi:ss')
          || ', mlog_created_date='
            || to_char( rec.mlog_created_date, 'dd.mm.yyyy hh24:mi:ss')
          || ').'
      );
    end loop;
    logger.trace( 'checkMLogCreatedDate: OK');
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� �������� ���� �������� �����, �� ������� �������'
          || ' �-�������������.'
        )
      , true
    );
  end checkMLogCreatedDate;



  /*
    ��������� �-������������� ������� fast.
  */
  procedure refreshMView
  is

    -- ������� ���������� ������ ������� ����������
    isFirstRefresh boolean := true;

    -- ������ ��� �������� ���� �������� �����
    isCheckMLogDateError boolean;

  begin
    loop
      begin
        if not isFirstRefresh then
          dropMViewPreserveTable( tableName => tableName);
          mviewCreatedDate := null;
          createMView();
        end if;
        dbms_mview.refresh( tableName, 'f');

        -- �������������� �������� �� ���� �������� �����, �.�. � ���������
        -- ������� �� ����������� ������� Oracle �� ����������� ����������
        -- ORA-12034 �������� �� ������������ ���� ����� ��������
        -- �-�������������
        if mviewCreatedDate is not null then
          isCheckMLogDateError := true;
          checkMLogCreatedDate();
          isCheckMLogDateError := false;
        end if;

        logger.info(
          '������� ' || tableName || ' ��������� � ������� ������������������'
          || ' ������������� ('
          || ' last_refresh_date: '
            || to_char( getMViewRefreshDate(), 'dd.mm.yyyy hh24:mi:ss')
          || ').'
        );
        exit;
      exception when others then
        if isFirstRefresh and ( sqlcode = -12034 or isCheckMLogDateError) then
          if isAllowCreate then
            isFirstRefresh := false;
            logger.info(
              '����� ��������� ������������ ������������������ �������������'
              || ' � ����� � ������� ��� ����������:'
              || chr(10) || logger.getErrorStack()
            );
          else
            raise_application_error(
              pkg_Error.ErrorStackInfo
              , logger.errorStack(
                  '������ ��� ���������� ( ��� ������� �������� ����� ���������'
                  || ' ������������ �-������������� � ������� ����������'
                  || ' createMViewFlag ��� forceCreateMViewFlag).'
                )
              , true
            );
          end if;
        else
          raise;
        end if;
      end;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� �-�������������.'
        )
      , true
    );
  end refreshMView;



-- refreshByMView
begin
  if isAllowCreate and sourceView is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '��� ����������� �������� �-������������� ������� �������'
        || ' �������� �������������.'
    );
  end if;
  srcView := getLocalFullName(
    localObject => sourceView
  );
  select
    count(*)
    , max( ob.created)
  into existsMViewFlag, mviewCreatedDate
  from
    user_objects ob
  where
    ob.object_name = upper( tableName)
    and ob.object_type = 'MATERIALIZED VIEW'
  ;
  if existsMViewFlag = 1 and forceCreateMViewFlag = 1 then
    dropMViewPreserveTable( tableName => tableName);
    existsMViewFlag := 0;
    mviewCreatedDate := null;
  end if;
  if existsMViewFlag = 0 then
    if isAllowCreate then
      createMView();
    else
      raise_application_error(
        pkg_Error.ProcessError
        , '����������� ����������������� ������������� ��� ����������.'
      );
    end if;
  end if;
  refreshMView();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� � ������� �-������������� ('
        || ' tableName="' || tableName || '"'
        || ', sourceView="' || sourceView || '"'
        || ', excludeColumnList="' || excludeColumnList || '"'
        || ', allowDropMViewList.count='
          || case when allowDropMViewList is not null then
              allowDropMViewList.count()
            end
        || ', createMViewFlag=' || createMViewFlag
        || ', forceCreateMViewFlag=' || forceCreateMViewFlag
        || ').'
      )
    , true
  );
end refreshByMView;



/* group: ���������� ������ ������ */

/* func: getTableConfigString
  ���������� ��������������� ������ � ����������� ���������� ��� �������.

  ���������:
  srcString                   - �������� ������
                                ( ������� ������ ������, ������������� �
                                  �������� �������� �������� tableList �������
                                  <refresh>)
  sourceSchema                - ��� ����� �� ��������� ��� ��������
                                �������������
                                ( �� ��������� �����������)

  �������:
  ��������������� ������.

  ������ ���������������
  ������:

  <tableName>:<refreshMethod>:<sourceView>:<tempTableName>:<excludeColumnList>
*/
function getTableConfigString(
  srcString varchar2
  , sourceSchema varchar2 := null
)
return varchar2
is

  -- ��������� ������� ������ � �����������
  itemList ConfigItemListT;
  optionList ConfigOptionListT;

  -- ������� ��� ���������� ( �������� � ��������� �����)
  tableName varchar2(1000);

  -- ����� ����������
  refreshMethod varchar2(1000);

  -- ��� ��������� �������������, �������� � ��������� �����
  sourceView varchar2(4000);

  -- ��� ��������� �������, ������������ ��� ���������� �������
  tempTableName varchar2(1000);

begin
  parseConfigString(
    itemList          => itemList
    , optionList      => optionList
    , cfgString       => srcString
    , maxItemCount    => 4
    , optionNameList  =>
        cmn_string_table_t(
          ExcludeColumnList_OptName
        )
  );

  tableName := itemList( 1);
  if tableName is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�� ������� ������� ��� ����������.'
    );
  end if;

  refreshMethod := itemList( 2);
  if refreshMethod not in (
        Compare_RefreshMethodCode
        , CompareTemp_RefreshMethodCode
        , MView_RefreshMethodCode
      )
      then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������ ������������ ����� ����������.'
    );
  end if;
  refreshMethod := coalesce( refreshMethod, Compare_RefreshMethodCode);

  sourceView := coalesce( itemList( 3), 'v_' || tableName);
  if sourceSchema is not null
        -- ����� �� ������� ( �.�. ��� �����, �� ����������� ����� � �����
        -- �����)
        and instr( sourceView || '@.', '.') > instr( sourceView || '@.', '@')
      then
    sourceView := sourceSchema || '.' || sourceView;
  end if;

  tempTableName := itemList( 4);
  if refreshMethod = CompareTemp_RefreshMethodCode then
    tempTableName := coalesce( tempTableName, tableName || '_tmp');
  elsif tempTableName is not null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '��������� ������� ������������ ������ ��� ������'
        || ' ���������� "' || CompareTemp_RefreshMethodCode || '".'
    );
  end if;

  return
    tableName
    || ':' || refreshMethod
    || ':' || sourceView
    || ':' || tempTableName
    || ':' || optionList( ExcludeColumnList_OptName)
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ��������������� ������ � ����������� ���������� ('
        || ' srcString="' || srcString || '"'
        || ', sourceSchema="' || sourceSchema || '"'
        || ').'
      )
    , true
  );
end getTableConfigString;

/* proc: refresh
  ��������� ������ � ������������ ��������.

  ���������:
  tableList                   - ������ ������ ��� ���������� ( ������ ��. ����)
  sourceSchema                - ��� ����� �� ��������� ��� ��������
                                �������������
                                ( �� ��������� �����������)
  forTableName                - ���������� ������ ��������� �������
                                ( ��� ������� ��� ����� ��������)
                                ( �� ��������� ��� �����������)
  createMViewFlag             - ��������� ����������������� ������������� ���
                                ���������� �������, ���� ��� ����������� ����
                                ��� ���������� ������������ ��� ����������, �
                                ��� ������� ������ ����� ���������� � �������
                                �-�������������
                                ( 1 ��, 0 ��� ( �� ���������), ������������ �
                                  � ������ �������� forceCreateMViewFlag ������
                                  1)
  forceCreateMViewFlag        - ���������� ��������� ( �������������)
                                ����������������� ������������� ��� ����������
                                �������, ���� ��� ������� ������ �����
                                ���������� � ������� �-�������������
                                ( 1 ��, 0 ��� ( �� ���������))
  continueAfterErrorFlag      - ���������� ��������� ��������� ������ � ������
                                ������ ��� ����������
                                ( 1 ��, 0 ��� ( �� ���������))

  �������� ������ ������ ��� ���������� ( �������� tableList) ����������� � �������:

  <tableName>[:[<refreshMethod>][:[<sourceView>][:[<tempTableName>]]]][:[<optionList>]]

  tableName             - ��� ������� ��� ���������� ( ��� ����� ��������)
                          ( � ������ ���������� � ������� ������������������
                          ������������� ������� ������ ������������ ��������
                          ������������, ����� ����� ������ �������
                          ����� ������� �����)
  refreshMethod         - ����� ���������� ( "d" ���������� ������ ( ��
                          ���������), "m" � ������� ������������������
                          �������������, "t" ���������� � ��������������
                          ��������� �������)
  sourceView            - ��� ��������� �������������, �������� � ���������
                          ����� ( ��� ����� ��������, �� ��������� �������� ��
                          ������ ����� ������� ��� ���������� �����������
                          �������� "v_", � �������� ����� �� ���������
                          ������������ �������� ��������� sourceSchema)
  tempTableName         - ��� ��������� ������� ( ��� ����� ��������),
                          ������������ ��� ���������� ������� "t" ( ��
                          ��������� �������� �� ������ ����� ������� ���
                          ���������� ����������� ��������� "_tmp")
  optionList            - ������ �������������� ����� ( � ������������ ������)
                          � ������� "<optName>=<optValue>", ���������� �����
                          ����������� ����;

  ��������� ��������������
  ����� ( ����������� � <optionList>):

  excludeColumnList     - ������ ������� �������, ����������� �� ����������
                          ( � ������������ �������, ��� ����� ��������,
                           ���������� ������� ������������) ( �� ���������
                          � ���������� ��������� ��� �������)

  ������� ��������� ( 0x09), �������� ������� ( 0x0D), �������� ������ ( 0x0A)
  ��������������� ��� ���������� � ������������, ���� ��� ������� �� ��� �����
  ��������� ������.

  ���������:
  - ����� ���������� ������ ������� ����������� commit;
*/
procedure refresh(
  tableList cmn_string_table_t
  , sourceSchema varchar2 := null
  , forTableName varchar2 := null
  , createMViewFlag integer := null
  , forceCreateMViewFlag integer := null
  , continueAfterErrorFlag integer := null
)
is

  cursor tableCur is
    select
      b.*
      , pkg_Common.split( b.allow_drop_mview_list_str, ',')
        as allow_drop_mview_list
    from
      (
      select
        d.*
        , case when d.refresh_method = MView_RefreshMethodCode then
            listagg( d.table_name, ',')
            within group( order by d.list_order)
            over( partition by d.refresh_method)
          end
          as allow_drop_mview_list_str
      from
        (
        select
          rownum as list_order
          , trim( pkg_Common.getStringByDelimiter(
              f.config_string, List_Separator, 1
            ))
            as table_name
          , trim( pkg_Common.getStringByDelimiter(
              f.config_string, List_Separator, 2
            ))
            as refresh_method
          , trim( pkg_Common.getStringByDelimiter(
              f.config_string, List_Separator, 3
            ))
            as source_view
          , trim( pkg_Common.getStringByDelimiter(
              f.config_string, List_Separator, 4
            ))
            as temp_table_name
          , trim( pkg_Common.getStringByDelimiter(
              f.config_string, List_Separator, 5
            ))
            as exclude_column_list
        from
          (
          select
            pkg_DataSync.getTableConfigString(
              t.column_value
              , sourceSchema
            )
            as config_string
          from
            table( tableList) t
          ) f
        ) d
      ) b
    where
      nullif( upper( forTableName), upper( b.table_name)) is null
    order by
      b.list_order
  ;

  -- ����� ������� ������������ ������� ������
  nProcessed pls_integer := 0;

  -- ����� ������� ������, ������������ � ��������
  nError pls_integer := 0;

-- refresh
begin
  for rec in tableCur loop
    begin
      case
        when rec.refresh_method in (
                Compare_RefreshMethodCode
                , CompareTemp_RefreshMethodCode
              )
            then
          refreshByCompare(
            targetTable             => rec.table_name
            , dataSource            => rec.source_view
            , tempTableName         => rec.temp_table_name
            , excludeColumnList     => rec.exclude_column_list
          );
          commit;
        when rec.refresh_method = MView_RefreshMethodCode then
          refreshByMView(
            tableName               => rec.table_name
            , sourceView            => rec.source_view
            , excludeColumnList     => rec.exclude_column_list
            , allowDropMViewList    => rec.allow_drop_mview_list
            , createMViewFlag       => coalesce( createMViewFlag, 0)
            , forceCreateMViewFlag  => coalesce( forceCreateMViewFlag, 0)
          );
      end case;
      nProcessed := nProcessed + 1;
    exception when others then
      if continueAfterErrorFlag = 1 then
        rollback;
        nError := nError + 1;
        logger.error(
          '������ #' || nError || ' ��� ���������� ������ ('
          || ' table_name="' || rec.table_name || '"'
          || ', refresh_method="' || rec.refresh_method || '"'
          || '):'
          || chr(10) || logger.getErrorStack()
        );
      else
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , logger.errorStack(
              '������ ��� ��������� �������� ������ ������ ('
              || ' table_name="' || rec.table_name || '"'
              || ', refresh_method="' || rec.refresh_method || '"'
              || ').'
            )
          , true
        );
      end if;
    end;
  end loop;
  if nError > 0 then
    raise_application_error(
      pkg_Error.ProcessError
      , '��� ���������� ��������� ������ �������� ������ ('
        || ' nError=' || nError
        || ', nProcessed=' || nProcessed
        || ').'
    );
  elsif forTableName is not null and nProcessed = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '��� ������� ���������� ������� ��� ����������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� ������ � ������������ �������� ('
        || ' tableList.count='
          || case when tableList is not null then tableList.count() end
        || ', sourceSchema="' || sourceSchema || '"'
        || ', forTableName="' || forTableName || '"'
        || ', createMViewFlag=' || createMViewFlag
        || ', forceCreateMViewFlag=' || forceCreateMViewFlag
        || ', continueAfterErrorFlag=' || continueAfterErrorFlag
        || ').'
      )
    , true
  );
end refresh;

/* proc: dropRefreshMView
  ������� ����������������� �������������, ��������� ��� ����������
  ������������ ������.
  �������� ����������� ������ � ������, ���� � ������ ������ ��� �������
  ������ ����� ���������� � ������� ������������������ �������������
  (  ������� ��� �������� �-������������� �����������).

  ���������:
  tableList                   - ������ ������ ��� ���������� ( ������ ��. �
                                �������� ��������� <refresh>)
  forTableName                - ��������� ������ ��������� �������
                                ( ��� ������� ��� ����� ��������)
                                ( �� ��������� ��� �����������)
  ignoreNotExistsFlag         - ������������ ���������� ������������������
                                ������������� ��� ��������
                                ( 1 ������������, 0 ����������� ������
                                  ( �� ���������))
  continueAfterErrorFlag      - ���������� ��������� ��������� ������ � ������
                                ������ ��� �������� ������������������
                                �������������
                                ( 1 ��, 0 ��� ( �� ���������))
*/
procedure dropRefreshMView(
  tableList cmn_string_table_t
  , forTableName varchar2 := null
  , ignoreNotExistsFlag integer := null
  , continueAfterErrorFlag integer := null
)
is

  cursor tableCur is
    select
      b.*
      , (
        select
          count(*)
        from
          user_objects ob
        where
          ob.object_name = upper( b.table_name)
          and ob.object_type = 'MATERIALIZED VIEW'
        )
        as exists_mview_flag
    from
      (
      select
        rownum as list_order
        , trim( pkg_Common.getStringByDelimiter(
            f.config_string, List_Separator, 1
          ))
          as table_name
        , trim( pkg_Common.getStringByDelimiter(
            f.config_string, List_Separator, 2
          ))
          as refresh_method
      from
        (
        select
          pkg_DataSync.getTableConfigString(
            t.column_value
          )
          as config_string
        from
          table( tableList) t
        ) f
      ) b
    where
      b.refresh_method = MView_RefreshMethodCode
      and nullif( upper( forTableName), upper( b.table_name)) is null
  ;

  -- ����� ������� ������������ ������� ������
  nProcessed pls_integer := 0;

  -- ����� ������� ������, ������������ � ��������
  nError pls_integer := 0;

  -- � ������ ���� ������� ��� ���������
  isTableFound boolean := false;

-- dropRefreshMView
begin
  for rec in tableCur loop
    begin
      isTableFound := true;
      if coalesce( ignoreNotExistsFlag, 0) != 1 or rec.exists_mview_flag = 1
          then
        dropMViewPreserveTable(
          tableName   => rec.table_name
        );
        nProcessed := nProcessed + 1;
      end if;
    exception when others then
      if continueAfterErrorFlag = 1 then
        nError := nError + 1;
        logger.error(
          '������ #' || nError || ' ��� �������� �-�������������:'
          || chr(10) || logger.getErrorStack()
        );
      else
        raise;
      end if;
    end;
  end loop;
  if nError > 0 then
    raise_application_error(
      pkg_Error.ProcessError
      , '��� �������� ��������� �-������������� �������� ������ ('
        || ' nError=' || nError
        || ', nProcessed=' || nProcessed
        || ').'
    );
  elsif forTableName is not null and not isTableFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '��� ������� ���������� ������� ��� ���������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� �-�������������, ��������� ��� ���������� ������ ('
        || ' tableList.count='
          || case when tableList is not null then tableList.count() end
        || ', forTableName="' || forTableName || '"'
        || ', ignoreNotExistsFlag=' || ignoreNotExistsFlag
        || ', continueAfterErrorFlag=' || continueAfterErrorFlag
        || ').'
      )
    , true
  );
end dropRefreshMView;

end pkg_DataSync;
/
