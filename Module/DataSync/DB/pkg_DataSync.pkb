create or replace package body pkg_DataSync is
/* package body: pkg_DataSync::body */



/* group: Константы */

/* iconst: List_Separator
  Символ-разделить, используемый в списках.
*/
List_Separator constant varchar2(1) := ':';

/* iconst: MLog_CommentTail
  Хвостовая часть комментария, которая добавляется к комментарию таблицы,
  содержащей материализованный лог, автоматически создаваемому Oracle.
  В тексте комментария используется макрос "$(moduleSvnRoot)", который
  заменяется на путь к корневому каталогу модуля в Subversion ( начиная с
  имени репозитария), указанный в параметре процедуры <createMLog>.
*/
MLog_CommentTail constant varchar2(100) := ' [ SVN Root: $(moduleSvnRoot)]';



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_DataSync'
);



/* group: Функции */

/* iproc: execSql
  Выполняет динамический SQL.

  Параметры:
  sqlText                     - текст SQL для выполнения
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
        'Ошибка при выполнении SQL ( первые 100 символов): "'
        || substr( execSql, 1, 100)
        || '".'
      )
    , true
  );
end execSql;

/* iproc: getLocalFullName
  Возвращает имя владельца и имя объекта по строке с именем объекта.
  Если имя владельца не задано явно, то используется текущий пользователь
  ( под правами которого выполняется пакет).

  Параметры:
  objectOwner                 - строка с именем владельца
                                ( возврат)
  objectName                  - строка с именем объекта
                                ( возврат)
  localObject                 - строка с именем, и возможно схемой, локального
                                объекта
*/
procedure getLocalFullName(
  objectOwner out varchar2
  , objectName out varchar2
  , localObject varchar2
)
is
begin
  if instr( localObject, '@') > 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Объект не является локальным.'
    );
  end if;
  if localObject like '%.%' then
    objectOwner := substr( localObject, 1, instr( localObject, '.') - 1);
    objectName := substr( localObject, instr( localObject, '.') + 1);
  else
    objectOwner := lower( sys_context( 'USERENV', 'CURRENT_USER'));
    objectName := localObject;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при определении полного имени локального объекта ('
        || ' localObject="' || localObject || '"'
        || ').'
      )
    , true
  );
end getLocalFullName;



/* group: Обновление с помощью сравнения */

/* proc: refreshByCompare
  Обновляет данные таблицы с помощью сравнения содержащихся в ней и актуальных
  данных и внесения необходимых изменений командами merge и delete.

  Параметры:
  targetTable                 - таблица для обновления (имя таблицы, возможно
                                с указанием схемы и DB-линка, без учета
                                регистра)
  dataSource                  - источник актуальных данных
  tempTableName               - временная таблица для промежуточного сохранения
                                актуальных данных и использования в командах
                                merge и delete ( имя таблицы, возможно
                                с указанием схемы, без учета регистра)
                                ( по умолчанию в командах merge и delete
                                  используется источник актуальных данных)
  excludeColumnList           - список колонок таблицы, исключаемых из
                                обновления ( с разделителем запятая, без учета
                                регистра)
                                ( по умолчанию пустой, т.е. обновляются все
                                  колонки таблицы)

  Замечания:
  - у таблицы должен быть первичный ключ;
  - в dataSource может быть указано любое выражение, из которого можно
    выполнить выборку с указанием всех колонок, присутствующих в таблице для
    обновления, за исключением указанных в excludeColumnList;
  - во временной таблице должны быть все колонки, присутствующие в таблице для
    обновления, за исключением указанных в excludeColumnList;
  - в случае указания удалённой таблицы в качестве targetTable список колонок
    определяется по dataSource, а первичный ключ по targetTable в БД
    источнике;
*/
procedure refreshByCompare(
  targetTable varchar2
  , dataSource varchar2
  , tempTableName varchar2 := null
  , excludeColumnList varchar2 := null
)
is

  -- Список ключевых колонок в формате
  -- ",<columnName>[,<columnName2>][,<columnName3>]...."
  keyColumn varchar2(1000);

  -- Список колонок для обновления за исключением ключевых колонок в формате
  -- ",<columnName>[,<columnName2>][,<columnName3>]...."
  regularColumn varchar2(10000);

  -- Условия для where, возвращающие истину в случае идентичности данных в
  -- исходной записи ( алиас "a") и конечной записи ( алиас "t"), заполняется
  -- в случае необходимости обновления колонок типа LOB ( CLOB или BLOB)
  equalWhereSql varchar2(32500);

  -- Дата обновления
  refreshDate date;

  -- Число добавленных/изменений записей
  nMerged integer;

  -- Число удаленных записей
  nDeleted integer;



  /*
    Заполняет списки колонок для обновления.
  */
  procedure fillColumn(
    excludeColumn varchar2
  )
  is

    -- Владелец и имя обновляемой таблицы
    tableOwner varchar2(100);
    tableName varchar2(100);

    cursor columnCur is
      select
        lower( tc.column_name) as column_name
        , case when b.column_name is not null then 1 else 0 end
          as key_column_flag
        , case when
              excludeColumn is not null
              and instr( excludeColumn, ',' || lower( tc.column_name) || ',')
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
          from
            all_constraints cn
            inner join all_ind_columns ic
              on ic.index_owner = cn.owner
                and ic.index_name = cn.index_name
          where
            cn.owner = upper( tableOwner)
            and cn.table_name =
              case when
                instr(targetTable, '@') > 0
              then
                substr(upper(targetTable), 1, instr(targetTable, '@') - 1)
              else
                upper(tableName)
              end
            and cn.constraint_type = 'P'
          ) b
          on b.column_name = tc.column_name
      where
        tc.owner = upper( tableOwner)
        and tc.table_name = upper( tableName)
      order by
        tc.column_id
    ;

  -- fillColumn
  begin
    getLocalFullName(
      objectOwner   => tableOwner
      , objectName  => tableName
      , localObject =>
      case when
        instr(targetTable, '@') > 0
      then
        dataSource
      else
        targetTable
      end
    );
    for rec in columnCur loop
      if rec.key_column_flag = 1 then
        keyColumn := keyColumn || ',' || rec.column_name;
        if rec.exclude_flag = 1 then
          raise_application_error(
            pkg_Error.IllegalArgument
            , 'Невозможно исключить из обновления колонку первичного ключа ('
              || ' column_name="' || rec.column_name || '"'
              || ').'
          );
        end if;
      elsif rec.exclude_flag = 0 then
        regularColumn := regularColumn || ',' || rec.column_name;
      end if;
      if rec.exists_lob_column_flag = 1 and rec.exclude_flag = 0 then
        equalWhereSql :=
          case when equalWhereSql is not null then
            equalWhereSql || chr(10) || ' and '
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
    if keyColumn is null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , case when regularColumn is null then
            'Не удалось определить список колонок для обновления'
            || ' ( таблица не существует, недоступна либо принадлежит'
            || ' другому пользователю).'
          else
            'Не удалось определить список ключевых колонок для обновления.'
          end
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при заполнении списков колонок для обновления ('
          || ' tableOwner="' || tableOwner || '"'
          || ', tableName="' || tableName || '"'
          || ').'
        )
      , true
    );
  end fillColumn;



  /*
    Загружает актуальные данные во временную таблицу.
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
        replace( keyColumn || regularColumn, ',', chr(10) || '  , ')
        , 6
      ) || '
)
select
  ' || substr(
        replace( keyColumn || regularColumn, ',', chr(10) || '  , a.')
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
          'Ошибка при загрузке актуальных данных во временную таблицу.'
        )
      , true
    );
  end loadTempTable;



  /*
    Выполняет слияние добавленных/измененных записей в таблицу.
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
        replace( keyColumn || regularColumn, ',', chr(10) || '  , a.')
        , 6
      ) || '
from
  ' || recordSource || ' a'
|| case when equalWhereSql is not null then
'
where
  not exists
    (
    select
      null
    from
      ' || targetTable || ' t
    where
      ' || equalWhereSql || '
    )'
else
'
minus
select
  ' || substr(
        replace( keyColumn || regularColumn, ',', chr(10) || '  , t.')
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
        regexp_replace( keyColumn, ',([^,]+)', chr(10) || '  and d.\1 = s.\1')
        , 8
      ) || '
)
when matched then update set
  ' || substr(
        regexp_replace( regularColumn, ',([^,]+)', chr(10) || '  , d.\1 = s.\1')
        , 6
      ) || '
when not matched then insert
(
  ' || substr(
        replace( keyColumn || regularColumn, ',', chr(10) || '  , ')
        , 6
      ) || '
)
values
(
  ' || substr(
        replace( keyColumn || regularColumn, ',', chr(10) || '  , s.')
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
          'Ошибка при слиянии добавленных/измененных записей ('
          || ' keyColumn="' || keyColumn || '"'
          || ', recordSource="' || recordSource || '"'
          || ').'
        )
      , true
    );
  end mergeChangedRecord;



  /*
    Удаляет лишние записи из таблицы.
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
        replace( keyColumn , ',', chr(10) || '  , d.')
        , 6
      ) || '
)
not in
(
select
  ' || substr(
        replace( keyColumn , ',', chr(10) || '  , a.')
        , 6
      ) || '
from
  ' || recordSource || ' a
where
  ' || substr(
        regexp_replace(
          keyColumn
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
          'Ошибка при удалени лишних записей ('
          || ' keyColumn="' || keyColumn || '"'
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
    'Таблица ' || targetTable || ' обновлена с помощью сравнения данных'
    || ' по источнику "' || dataSource || '"'
    || case when tempTableName is not null then
        ' с использованием временной таблицы "' || tempTableName || '"'
      end
    || ' ('
    || ' дата обновления: ' || to_char( refreshDate, 'dd.mm.yyyy hh24:mi:ss')
    || ', внесено изменений: ' || to_char( nMerged + nDeleted)
    || case when nMerged + nDeleted > 0 then
        ', из них добавлено/изменено записей: ' || nMerged
        || ', удалено записей: ' || nDeleted
      end
    || ').'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при обновлении с помощью сравнения данных ('
        || ' targetTable="' || targetTable || '"'
        || ', dataSource="' || dataSource || '"'
        || ', tempTableName="' || tempTableName || '"'
        || ', excludeColumnList="' || excludeColumnList || '"'
        || ').'
      )
    , true
  );
end refreshByCompare;



/* group: Обновление с использованием первичного ключа */

/* ifunc: substituteColumnList
  Возвращает текст SQL-запроса, подставляя вместо макросов список колонок
  из указанной таблицы ( представления).

  Параметры:
  baseSql                     - базовый текст SQL
  tableName                   - имя таблицы ( представления) для получения
                                списка колонок

  Возврат:
  текст SQL с подстановкой списка колонок вместо макросов

  Подставляемые значения макросов вида $(NAME):
  insertColumnList            - список колонк вида
                                "<column1>[, <column2>[...]]"
  selectColumnList            - список колонк вида
                                "t.<column1>[, t.<column2>[...]]"
*/
function substituteColumnList(
  baseSql varchar2
  , tableName varchar2
)
return varchar2
is

  -- Колонки таблицы
  cursor tableColumnCur is
    select
      tc.column_name
    from
      all_tab_columns tc
    where
      tc.table_name = upper( tableName)
      and (
        tc.owner = sys_context( 'userenv', 'current_user')
        -- Таблица другого пользователя, на которую создан одноименный
        -- личный синоним
        or tc.owner =
          (
          select
            sn.table_owner
          from
            all_synonyms sn
          where
            sn.synonym_name = tc.table_name
            and sn.table_name = tc.table_name
            and sn.owner = sys_context( 'userenv', 'current_user')
          )
      )
    order by
      tc.column_id
  ;

  -- Список колонок таблицы ( через запятую и пробел)
  columnList varchar2(32000);

-- substituteColumnList
begin
  for rec in tableColumnCur loop
    columnList :=
      columnList
      || case when columnList is not null then ', ' end
      || rec.column_name
    ;
  end loop;
  if columnList is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Таблица не найдена.'
    );
  end if;
  return
    replace( replace(
      baseSql
      , '$(insertColumnList)', columnList)
      , '$(selectColumnList)', 't.' || replace( columnList, ', ', ', t.'))
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при формировании текста SQL-запроса ('
        || ' tableName="' || tableName || '"'
        || ').'
      )
    , true
  );
end substituteColumnList;

/* proc: appendData
  Догрузка данных в таблицу(ы) в удалённой БД по первичному ключу.

  Параметры:
  targetDbLink                - линк к БД назначения
  tableName                   - таблица для догрузки
  idTableName                 - наименование исходной таблицы для поиска
                                значений первичного ключа (по-умолчанию
                                tableName)
  addonTableName              - дополнительная таблица для догрузки
  addonSourceTableName        - исходная дополнительная таблица для догрузки
  sourceTableName             - таблица(представление) с исходными данными
                                (по-умолчанию tableName)
  toDate                      - дата, до которой доливаются данные
                                ( date_ins < toDate, по умолчанию до начала
                                  предыдущего часа)
  maxExecTime                 - максимальное время выполнения процедуры ( в
                                случае, если время превышено и остались данные
                                для обработки, процедура завершает работу
                                с выводом предпреждения в лог, по умолчанию
                                без ограничений)

  Возврат:
  - число добавленных записей;

  Замечания:
  - функция выполняется в автономной транзакции и делает commit после выгрузки
    существенного числа записей;
*/
function appendData(
  targetDbLink                varchar2
, tableName                   varchar2
, idTableName                 varchar2 := null
, addonTableName              varchar2 := null
, addonSourceTableName        varchar2 := null
, sourceTableName             varchar2 := null
, toDate                      date := null
, maxExecTime                 interval day to second := null
)
return integer
is
  -- Число обработанных записей
  nProcessed integer := 0;

  -- Максимальный Id выгруженных записей
  maxProcessedId integer;

  -- Максимальный Id записи для выгрузки
  maxUnloadId integer;

  -- Число записей, после выгрузки которых в процедуре <unloadData>
  -- выполняется фиксация автономной транзакции.
  UnloadCheckReq_CommitRowCount constant integer := 100000;

  -- Число записей, обрабатываемых в одном блоке в процедуре
  -- <unloadCheckRequest>.
  UnloadCheckReq_BlockRowCount constant integer := 10000;

  -- Время прекращения обработки (case предотвращает ошибку при отсутствии
  -- ограничения)
  stopProcessDate date :=
    case when maxExecTime is not null then current_date + maxExecTime end
  ;

  -- наиенование id колонки
  idColumnName varchar2(30);


  /*
    Получение наименования исходной таблицы
  */
  function getSourceTable(tableName varchar2)
  return varchar2
  is
  begin
    return
      case when
        tableName = addonTableName
      then
        coalesce(addonSourceTableName, tableName)
      else
        coalesce(sourceTableName, tableName)
      end
    ;
  end getSourceTable;



  /*
    Получение наименования колонки первичного ключа.
  */
  procedure getIdColumn
  is
    idColumnTableName varchar2(30);
  begin
    idColumnTableName :=
      coalesce(idTableName, tableName);
    select
      -- Исключаем копию таблицы
      distinct cols.column_name
    into
      idColumnName
    from
      all_constraints cons
    inner join
      all_cons_columns cols
    on
      cons.constraint_type = 'P'
      and cons.constraint_name = cols.constraint_name
      and cons.owner = cols.owner
      and cols.position = 1
    where
      cols.table_name = upper(idColumnTableName)
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка получения наименования колонки первичного ключа ('
        || 'idColumnTableName="' || idColumnTableName || '"'
        || ')'
        )
      , true
    );
  end getIdColumn;



  /*
    Выполняет подготовительные действия.
  */
  procedure initialize is
  begin
    pkg_TaskHandler.initTask(
      moduleName  => Module_Name
    , processName => 'unloadData'
    );
    getIdColumn();
  end initialize;



  /*
    Выполняет очистку перед завершением работы.
  */
  procedure clean is
  begin
    pkg_TaskHandler.cleanTask();
  end clean;



  /*
    Возвращает максимальный Id выгруженных записей.
  */
  function getMaxUnloadedId
  return integer
  is

    -- Максимальный Id выгруженных записей.
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
          'Ошибка при определении максимального Id выгруженных записей'
          || ' записей ('
          || ' targetDbLink="' || targetDbLink || '"'
          || ', tableName="' || tableName || '"'
          || ', idColumnName="' || idColumnName || '"'
          || ').'
        )
      , true
    );
  end getMaxUnloadedId;



  /*
    Определяет максимальный Id обработанных записей.
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
          'Ошибка при определении максимального Id обработанных записей.'
        )
      , true
    );
  end setMaxProcessedId;

  /*
    Проверяет наличие в таблице поля date_ins
  */
  function existsFieldDateIns
  return boolean
  is
    idColumnTableName varchar2(30);
    countDateIns integer;
  begin
    idColumnTableName :=
      coalesce(idTableName, tableName);
    select
      count(cols.column_name)
    into
      countDateIns
    from
      all_tab_columns cols
    where
      cols.table_name = upper(idColumnTableName)
      and cols.COLUMN_NAME = 'DATE_INS'
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
          'Ошибка при проверке наличия в таблице поля date_ins ('
        || 'idColumnTableName="' || idColumnTableName || '"'
        || ')'
        )
      , true
    );
  end existsFieldDateIns;
 
  /*
    Определяет максимальный Id записи для выгрузки.
  */
  procedure setMaxUnloadId
  is

    toUnloadDate date;

    sqlText varchar2(32767);

  begin
    logger.trace( 'setMaxUnloadId: start...');
    toUnloadDate :=
       coalesce( toDate, trunc(sysdate, 'hh24') - 1/24)
    ;
    logger.trace('toUnloadDate=' || to_char(toUnloadDate));
    -- проверяем налице в таблице поля date_ins
    if existsFieldDateIns then
      -- если поле date_ins присутствует в таблице, то попробуем вычислить 
      -- максимальный Id записи для выгрузки изходя из него
      sqlText :=
      '
        select
          min(a.' || idColumnName || ') - 1 as max_period_id
        from
          (
          select /*+ first_rows */
            t.' || idColumnName || '
          from
            ' || coalesce(idTableName, getSourceTable(tableName)) || ' t
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
      -- если не удалось вычислить максимальный Id записи для выгрузки
      -- исходя из значений поля date_ins, берем максимальное значение из таблицы
      sqlText :=
      '
        select
          max(t.' || idColumnName || ') as max_id
        from
          ' || coalesce(idTableName, getSourceTable(tableName)) || ' t
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
          'Ошибка при определении максимального Id записи для выгрузки.'
        )
      , true
    );
  end setMaxUnloadId;



  /*
    Получает текущий максимальный id для блока записей.

    Параметры:
    beforeStartId             - Id записи, начиная с которой ( не включая ее)
                                выполняется выгрузка
    maxId                     - максимальный Id записи, до которой
                                ( включительно) выполняется выгрузка
    maxRowCount               - максимальное число выгружаемых записей

    Возврат:
    число выгруженных записей.
  */
  function getBlockMaxId(
    beforeStartId integer
    , maxId integer
    , maxRowCount integer
  )
  return integer
  is

    -- Текст SQL
    getSql varchar2(32000);

    -- Результат функции
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
      ' || getSourceTable(tableName) || ' a
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
          'Ошибка при выгрузке данных ('
          || ' beforeStartId=' || beforeStartId
          || ', maxId=' || maxId
          || ', maxRowCount=' || maxRowCount
          || ').'
        )
      , true
    );
  end getBlockMaxId;



  /*
    Выгружает данные в основную таблицу.

    Параметры:
    beforeStartId             - Id записи, начиная с которой ( не включая ее)
                                выполняется выгрузка
    maxId                     - максимальный Id записи, до которой
                                ( включительно) выполняется выгрузка
    maxRowCount               - максимальное число выгружаемых записей

    Возврат:
    число выгруженных записей.
  */
  function unloadBlock(
    tableName varchar2
  , beforeStartId integer
  , maxId integer
  )
  return integer
  is

    -- Число выгруженных записей
    nUnload integer;
    -- Текст SQL для выгрузки данных в главную таблицу
    unloadSql varchar2(32000);

  begin
    if unloadSql is null then
      unloadSql := substituteColumnList( '
insert into
  ' || tableName || '@' || targetDbLink || '
(
  $(insertColumnList)
)
select
  $(selectColumnList)
from
  ' || getSourceTable(tableName) || ' t
where
  t.' || idColumnName || ' > :beforeStartId
  and t.' || idColumnName || ' <= :maxId
'
        , getSourceTable(tableName)
      );
    end if;
    logger.trace('unloadSql="' || unloadSql || '"');
    execute immediate
      unloadSql
    using
      beforeStartId
      , maxId
    ;
    nUnload := sql%rowcount;
    logger.trace( 'unloadBlock: выгружено записей: ' || nUnload);
    return nUnload;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при выгрузке данных ('
          || 'tableName="' || tableName || '"'
          || ', beforeStartId=' || beforeStartId
          || ', maxId=' || maxId
          || ').'
        )
      , true
    );
  end unloadBlock;



  /*
    Выполняет выгрузку данных.
  */
  procedure unloadData
  is

    pragma autonomous_transaction;

    -- Признак завершения выгрузки
    isFinish boolean := false;

    -- Число выгруженных в текущей транзакции записей
    nTransactionUnload integer;

    -- Число выгруженных в текущем блоке записей
    nBlockUnload integer;
    nAddonUnload integer;

    -- Максимальный Id выгруженных в предыдущем блоке записей
    prevMaxId integer := maxProcessedId;

    -- Максимальный Id выгруженных в текущем блоке записей
    blockMaxId integer;

  -- unloadData
  begin
    while not isFinish loop
      nTransactionUnload := 0;
      while not isFinish
            and nTransactionUnload < UnloadCheckReq_CommitRowCount
          loop
        logger.trace(
          'unloadData: start unload block: prevMaxId=' || prevMaxId
        );
        blockMaxId := getBlockMaxId(
          beforeStartId  => prevMaxId
        , maxId          => maxUnloadId
        , maxRowCount    => UnloadCheckReq_BlockRowCount
        );
        nBlockUnload := unloadBlock(
          tableName      => tableName
        , beforeStartId  => prevMaxId
        , maxId          => blockMaxId
        );
        if nBlockUnload > 0 then
          blockMaxId := getMaxUnloadedId();
          if addonTableName is not null then
            nAddonUnload := unloadBlock(
              tableName     => addonTableName
            , beforeStartId => prevMaxId
            , maxId         => blockMaxId
            );
          end if;
          prevMaxId := blockMaxId;
          nTransactionUnload := nTransactionUnload + nBlockUnload;
          if stopProcessDate is not null then
            if current_date >= stopProcessDate then
              isFinish := true;
              logger.info(
                'Выгрузка прекращена в связи с достижением лимита времени.'
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
          'Ошибка при выгрузке данных ('
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
  setMaxProcessedId();
  setMaxUnloadId();
  if maxProcessedId < maxUnloadId then
    unloadData();
  end if;
  clean();
  return nProcessed;
exception when others then
  clean();
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при догрузке данных ('
      || 'targetDbLink="' || targetDbLink || '"'
      || ', tableName="' || tableName || '"'
      || ', sourceTableName="' || sourceTableName|| '"'
      || ', idTableName="' || idTableName || '"'
      || ', addonTableName="' || addonTableName || '"'
      || ', sourceTableName="' || sourceTableName || '"'
      || ', toDate={' || to_char(toDate, 'dd.mm.yyyy hh24:mi:ss') || '}'
      || ', maxExecTime=' || to_char(maxExecTime)
      || ').'
      )
    , true
  );
end appendData;



/* group: Обновление с помощью материализованного представления */

/* iproc: dropMLog
  Удаляет лог материализованного представления.

  Параметры:
  tableName                   - имя базовой таблицы ( без учета регистра)
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
        'Ошибка при удалении лога материализованного представления ('
        || ' tableName="' || tableName || '"'
        || ').'
      )
    , true
  );
end dropMLog;

/* proc: createMLog
  Создает необходимые логи материализованных представлений.

  Параметры:
  mlogList                    - список логов м-представлений в формате
                                <tableName>[:<createOption>], где tableName
                                имя базовой таблицы ( без учета регистра),
                                createOption опции для создания лога
                                ( пример: "tmp_table:with rowid")
  viewList                    - список представлений, используемых для
                                обновления ( указывается имя представления без
                                учета регистра)
                                ( необходимо указывать только в случае
                                  grantPrivsFlag равного 1, чтобы определить
                                  пользователей, которым нужно выдать права,
                                  по умолчанию отсутствует)
  moduleSvnRoot               - путь к корневому каталогу модуля в Subversion
                                ( начиная с имени репозитария, например:
                                "Oracle/Module/ModuleInfo"). Если указан, то
                                в комментарий к таблице, содержащей лог,
                                добавляется строка
                                " [ SVN root: <moduleSvnRoot>]"
                                ( по умолчанию отсутствует)
  forTableName                - создавать лог только для указанной таблицы
                                из списка
                                ( по умолчанию без ограничений)
  recreateFlag                - флаг пересоздания лога, если он существует
                                ( 1 да, 0 нет ( по умолчанию))
  grantPrivsFlag              - флаг выдачи пользователям, имеющим права на
                                исходное представление, в котором используется
                                таблица лога, прав на лог в случае его создания
                                ( 1 да, 0 нет ( по умолчанию))
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

  -- Число успешно обработанных записей списка
  nProcessed pls_integer := 0;



  /*
    Выполняет создание м-лога.
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
          'Ошибка при создании лога.'
        )
      , true
    );
  end processCreate;



  /*
    Обновляет комментарий к таблице лога.
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
          'Ошибка при обновлении комментария к таблице лога.'
        )
      , true
    );
  end updateComment;



  /*
    Выдает права на лог.
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
          'Ошибка при выдаче прав на лог.'
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
            'Ошибка при обработке м-лога ('
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
      , 'Нет удалось определить лог для обработки.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при создании необходимых логов м-представлений ('
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
  Удаляет использовавшиеся логи материализованных представлений.

  Параметры:
  mlogList                    - список логов м-представлений в формате
                                <tableName>[:<createOption>], где tableName
                                имя базовой таблицы ( без учета регистра),
                                createOption опции для создания лога ( не
                                используются)
  moduleSvnRoot               - путь к корневому каталогу модуля в Subversion
                                ( начиная с имени репозитария, например:
                                "Oracle/Module/ModuleInfo"). Если указан, то
                                по комментарию к таблице, содержащей лог,
                                определяется, был ли лог создан в рамках модуля
                                ( по умолчанию отсутствует)
  forTableName                - удалять лог только для указанной таблицы
                                из списка
                                ( по умолчанию без ограничений)
  forceFlag                   - флаг удаления лога даже если он возможно не
                                создавался в рамках модуля
                                ( 1 да, 0 нет ( по умолчанию))
  continueAfterErrorFlag      - продолжать обработку остальных логов в случае
                                ошибки при удалении лога материализованного
                                представления
                                ( 1 да, 0 нет ( по умолчанию))

  Замечания:
  - если лог для удаления отсутствует, то удаление не выполняется и процедура
    завершается без ошибок;
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

  -- Число успешно обработанных записей списка
  nProcessed pls_integer := 0;

  -- Число записей списка, обработанных с ошибками
  nError pls_integer := 0;

  -- В списке есть таблица для обработки
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
          'Ошибка #' || nError || ' при удалении лога м-представления:'
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
      , 'При удалении некоторых логов м-представлений возникли ошибки ('
        || ' nError=' || nError
        || ', nProcessed=' || nProcessed
        || ').'
    );
  elsif forTableName is not null and not isTableFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Нет удалось определить таблицу для обработки.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при удалении использовавшихся логов м-представлений ('
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
  Выдает права для основного пользователя, под которым будут создаваться
  интерфейсные объекты.

  Параметры:
  viewList                    - список представлений, используемых для
                                обновления ( указывается имя представления без
                                учета регистра)
  userName                    - имя пользователя, которому выдаются права
  mlogList                    - список логов м-представлений в формате
                                <tableName>[:<createOption>], где tableName
                                имя базовой таблицы ( без учета регистра),
                                createOption опции для создания лога ( не
                                используются)
                                ( по умолчанию отсутствуют)
  forObjectName               - ограничить выдачу прав только указанным
                                представлением либо исходной таблицей
                                и связанным с ней логом
                                ( имя объекта без учета регистра)
                                ( по умолчанию без ограничений)
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
          -- добавляем значение по умолчанию, чтобы получить ошибку
          -- в случае отсутствия м-лога
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

  -- Число успешно обработанных записей списка
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
      , 'Нет удалось определить объект для выдачи прав.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при выдаче прав для основного пользователя ('
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
  Удаляет материализованное представление с сохранением одноименной таблицы
  с данными.

  Параметры:
  tableName                   - имя таблицы ( м-представления)
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
    'Удалено материализованное представление для таблицы ' || tableName
    || ' ( с сохранением одноименной таблицы).'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при удалении м-представления с сохранением таблицы ('
        || ' tableName="' || tableName || '"'
        || ').'
      )
    , true
  );
end dropMViewPreserveTable;

/* proc: refreshByMView
  Обновляет данные интерфейсной таблицы с помощью fast-обновляемого
  материализованного представления.

  Параметры:
  tableName                   - имя таблицы ( м-представления) текущего
                                пользователя
  sourceView                  - имя представления с исходными данными, возможно
                                с указанием схемы
                                ( без учета регистра, используется в случае
                                  создания м-представления)
                                ( по умолчанию отсутствует)
  excludeColumnList           - список колонок таблицы, исключаемых из
                                обновления ( с разделителем запятая, без учета
                                регистра)
                                ( по умолчанию пустой, т.е. обновляются все
                                  колонки таблицы)
  allowDropMViewList          - список материализованных представлений текущего
                                пользователя, которые могут быть удалены, если
                                они зависят от обновляемой итерфейсной таблицы
                                ( для исключения ошибки "ORA-32334: cannot
                                  create prebuilt materialized view on a table
                                  already referenced by a MV" при создании
                                  материализованного представления)
                                ( без учета регистра, по умолчанию список
                                  пустой и удаление не выполняется)
  createMViewFlag             - создавать материализованное представление для
                                обновления таблицы, если оно отсутствует либо
                                его невозможно использовать для обновления
                                ( 1 да, 0 нет ( по умолчанию), игнорируется в
                                  в случае указания forceCreateMViewFlag равным
                                  1)
  forceCreateMViewFlag        - безусловно создавать ( пересоздавать)
                                материализованное представление для обновления
                                таблицы
                                ( 1 да, 0 нет ( по умолчанию))

  Если параметр createMViewFlag равен 1, то при выполнении процедуры
  материализованное представление будет:
  - создано в случае его отсутствия;
  - пересоздано в случае пересоздания логов исходных таблиц, на которых оно
    основано ( при возникновении ошибки
    "ORA-12034: materialized view log on "..." younger than last refresh"
    во время обновления либо если дата создания локального лога
    ( находящегося в той же БД, что и материализованное представление) больше
    или равна дате создания материализованного представления);

  Если параметр forceCreateMViewFlag равен 1, то при выполнении процедуры
  в любом случае будет создано новое материализованное представление.

  Замечания:
  - при обновлении таблицы выполняется commit;
  - для исключения пропуска изменений в исходных данных перед созданием
    м-представления устанавливается эксклюзивная блокировка на таблицу
    для обновления и на таблицы с исходными данными, от которых зависит
    исходное представление, и выполняется обновление данных таблицы с помощью
    сравнения данных ( см. <refreshByCompare>);
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

  -- Возможность создания м-представления в случае необходимости
  isAllowCreate constant boolean :=
    forceCreateMViewFlag = 1 or createMViewFlag = 1
  ;

  -- Флаг наличия м-представления
  existsMViewFlag integer;

  -- Дата создания м-представления, существовавшего на момент вызова
  -- процедуры ( null если отсутствовало или было пересоздано)
  mviewCreatedDate date;

  -- Владелец и имя исходного представления
  sourceViewOwner varchar2(100);
  sourceViewName varchar2(100);



  /*
    Удаляет зависящие от таблицы м-представления из списка разрешенных для
    удаления.
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
          'Ошибка при удалении зависящих от таблицы м-представлений.'
        )
      , true
    );
  end dropDepsMView;



  /*
    Устанавливает блокировку на таблицы, используемые при сравнении,
    для предотвращения изменения в них данных.
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
          'Ошибка при блокировке таблиц перед сравнением ('
          || ' sourceViewOwner="' || sourceViewOwner || '"'
          || ', sourceViewName="' || sourceViewName || '"'
          || ').'
        )
      , true
    );
  end lockTable;



  /*
    Возвращает текст исходного представления.
  */
  function getSourceViewText(
    sourceViewOwner varchar2
    , sourceViewName varchar2
  )
  return varchar2
  is

    -- Используем максимальную длину для varchar2 ( в представлении поле типа
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
          'Ошибка при получении текста исходного представления ('
          || ' sourceViewOwner="' || sourceViewOwner || '"'
          || ', sourceViewName="' || sourceViewName || '"'
          || ').'
        )
      , true
    );
  end getSourceViewText;



  /*
    Создает м-представление для обновления таблицы.
  */
  procedure createMView
  is
  begin
    if allowDropMViewList is not null then
      dropDepsMView();
    end if;
    lockTable(
      sourceViewOwner   => sourceViewOwner
      , sourceViewName  => sourceViewName
    );
    refreshByCompare(
      targetTable           => tableName
      , dataSource          => sourceViewOwner || '.' || sourceViewName
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
          sourceViewOwner   => sourceViewOwner
          , sourceViewName  => sourceViewName
        )
    );
    logger.info(
      'Создано материализованное представление для обновления таблицы '
      || tableName
      || ' на основе выборки из представления '
      || sourceViewOwner || '.' || sourceViewName
      || '.'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при создании м-представления.'
        )
      , true
    );
  end createMView;



  /*
    Возвращает дату обновления материализованного представления.
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
          'Ошибка при получении даты обновления м-представления.'
        )
      , true
    );
  end getMViewRefreshDate;



  /*
    Проверка даты создания логов, от которых зависит м-представление.
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
        t.owner = upper( sourceViewOwner)
        and t.name = upper( sourceViewName)
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
        , 'Лог для таблицы ' || rec.source_table
          || ' возможно был пересоздан после создания м-представления,'
          || ' из-за чего в м-представлении могут быть некорректные данные ('
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
          'Ошибка при проверке даты создания логов, от которых зависит'
          || ' м-представление.'
        )
      , true
    );
  end checkMLogCreatedDate;



  /*
    Обновляет м-представление методом fast.
  */
  procedure refreshMView
  is

    -- Признак выполнения первой попытки обновления
    isFirstRefresh boolean := true;

    -- Ошибка при проверке даты создания логов
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

        -- Дополнительная проверка по даты создания логов, т.к. в некоторых
        -- случаях по неизвестной причине Oracle не выбрасывает исключение
        -- ORA-12034 несмотря на пересоздание лога после создания
        -- м-представления
        if mviewCreatedDate is not null then
          isCheckMLogDateError := true;
          checkMLogCreatedDate();
          isCheckMLogDateError := false;
        end if;

        logger.info(
          'Таблица ' || tableName || ' обновлена с помощью материализованного'
          || ' представления ('
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
              'Будет выполнено пересоздание материализованного представления'
              || ' в связи с ошибкой при обновлении:'
              || chr(10) || logger.getErrorStack()
            );
          else
            raise_application_error(
              pkg_Error.ErrorStackInfo
              , logger.errorStack(
                  'Ошибка при обновлении ( для решения проблемы нужно разрешить'
                  || ' пересоздание м-представления с помощью параметров'
                  || ' createMViewFlag или forceCreateMViewFlag).'
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
          'Ошибка при обновлении м-представления.'
        )
      , true
    );
  end refreshMView;



-- refreshByMView
begin
  if isAllowCreate and sourceView is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Для возможности создания м-представления следует указать'
        || ' исходное представление.'
    );
  end if;
  getLocalFullName(
    objectOwner   => sourceViewOwner
    , objectName  => sourceViewName
    , localObject => sourceView
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
        , 'Отсутствует материализованное представление для обновления.'
      );
    end if;
  end if;
  refreshMView();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при обновлении с помощью м-представления ('
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



/* group: Обновление списка таблиц */

/* func: getTableConfigString
  Возвращает нормализованную строку с настройками обновления для таблицы.

  Параметры:
  srcString                   - исходная строка
                                ( элемент списка таблиц, используемого в
                                  качестве значения парамета tableList функции
                                  <refresh>)
  sourceSchema                - имя схемы по умолчанию для исходных
                                представлений
                                ( по умолчанию отсутствует)

  Возврат:
  нормализованная строка.

  Формат нормализованной
  строки:

  <tableName>:<refreshMethod>:<sourceView>:<tempTableName>:<excludeColumnList>
*/
function getTableConfigString(
  srcString varchar2
  , sourceSchema varchar2 := null
)
return varchar2
is

  -- Пробельные символы
  Space_Char constant varchar2(10) :=
    ' ' || chr(9) || chr(10) || chr(13)
  ;

  -- Максимальное число элементов списка
  Max_ItemCount pls_integer := 5;

  -- Таблица для обновления ( возможно с указанием схемы)
  tableName varchar2(1000);

  -- Метод обновления
  refreshMethod varchar2(1000);

  -- Имя исходного представления, возможно с указанием схемы
  sourceView varchar2(4000);

  -- Имя временной таблицы, используемой при обновлении методом
  tempTableName varchar2(1000);

  -- Список дополнительных опций
  optionList varchar2(4000);

  -- Список колонок таблицы, исключаемых из обновления
  excludeColumnList varchar2(4000);

  -- Число элементов списка без учета элемента со списком опций
  itemCount pls_integer;

  -- Наличие элемента со списком опций ( он всегда последний)
  isOptionList boolean;



  /*
    Удаляет пробельные символы с начала и хвоста строки.
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
    Возвращает элемент списка.
  */
  function getItem(
    i pls_integer
  )
  return varchar2
  is
  begin
    return
      trimSpace(
        pkg_Common.getStringByDelimiter( srcString, List_Separator, i)
      )
    ;
  end getItem;


  /*
    Устанавливает значение опции.
  */
  procedure setOption(
    optionName varchar2
    , optionValue varchar2
  )
  is
  begin
    case optionName
      when 'excludeColumnList' then
        excludeColumnList :=
          lower( translate( optionValue, '.' || Space_Char, '.'))
        ;
      else
        raise_application_error(
          pkg_Error.IllegalArgument
          , 'Неизвестное имя опции: "' || optionName || '".'
        );
    end case;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при установке значения опции ('
          || ' optionName="' || optionName || '"'
          || ', optionValue="' || optionValue || '"'
          || ').'
        )
      , true
    );
  end setOption;




  /*
    Разбор списка опций.
  */
  procedure parseOptionList(
    optionList varchar2
  )
  is

    -- Длина разбираемой строки
    len pls_integer := length( optionList);

    -- Позиция первого символа опции
    iBegin pls_integer := 1;

    -- Позиция разделителя имени и значения
    iSep pls_integer;

    -- Позиция последнего символа опции
    iLast pls_integer;

  begin
    while iBegin < len loop
      iSep := instr( optionList, '=', iBegin);
      if iSep = 0 then
        raise_application_error(
          pkg_Error.IllegalArgument
          , 'Не указано значение опции ('
            || ' optionString="'
              || trimSpace( substr( optionList, iBegin)) || '"'
            || ').'
        );
      end if;

      -- находим разделитель следующей опции
      iLast := instr( optionList, '=', iSep + 1);
      if iLast = 0 then
        iLast := len;
      else

        -- пропускаем "=" и пробельные символы
        iLast := length( rtrim( substr( optionList, 1, iLast - 1), Space_Char));

        -- пропускаем имя следующей опции
        while iLast > iSep
              and instr( Space_Char, substr( optionList, iLast, 1)) = 0
            loop
          iLast := iLast - 1;
        end loop;
      end if;

      setOption(
        optionName =>
            trimSpace( substr( optionList, iBegin, iSep - iBegin))
        , optionValue =>
            trimSpace( substr( optionList, iSep + 1, iLast - iSep))
      );

      iBegin := iLast + 1;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при разборе списка опций ('
          || ' optionList="' || optionList || '"'
          || ').'
        )
      , true
    );
  end parseOptionList;



-- getTableConfigString
begin
  itemCount := least(
    coalesce( length( srcString), 0)
      - coalesce( length( replace( srcString, List_Separator, '')), 0)
      + 1
    , Max_ItemCount
  );
  isOptionList :=
    itemCount = Max_ItemCount
    or itemCount > 1
      -- последний элемент содержит "="
      and instr(
          srcString
          , '='
          , instr( srcString, List_Separator, 1, itemCount - 1)
        ) > 0
  ;
  if isOptionList then
    itemCount := itemCount - 1;
  end if;

  tableName := getItem( 1);
  if tableName is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не указана таблица для обновления.'
    );
  end if;

  if itemCount >= 2 then
    refreshMethod := getItem( 2);
    if refreshMethod not in (
          Compare_RefreshMethodCode
          , CompareTemp_RefreshMethodCode
          , MView_RefreshMethodCode
        )
        then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Указан некорректный метод обновления.'
      );
    end if;
  end if;
  refreshMethod := coalesce( refreshMethod, Compare_RefreshMethodCode);

  if itemCount >= 3 then
    sourceView := getItem( 3);
  end if;
  sourceView := coalesce( sourceView, 'v_' || tableName);
  if sourceSchema is not null
        -- схема не указана ( т.е. нет точки, за исключением точек в имени
        -- линка)
        and instr( sourceView || '@.', '.') > instr( sourceView || '@.', '@')
      then
    sourceView := sourceSchema || '.' || sourceView;
  end if;

  if itemCount >= 4 then
    tempTableName := getItem( 4);
  end if;
  if refreshMethod = CompareTemp_RefreshMethodCode then
    tempTableName := coalesce( tempTableName, tableName || '_tmp');
  elsif tempTableName is not null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Временная таблица используется только для метода'
        || ' обновления "' || CompareTemp_RefreshMethodCode || '".'
    );
  end if;

  if isOptionList then
    parseOptionList(
      substr( srcString, instr( srcString, List_Separator, 1, itemCount) + 1)
    );
  end if;

  return
    tableName
    || ':' || refreshMethod
    || ':' || sourceView
    || ':' || tempTableName
    || ':' || excludeColumnList
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении нормализованной строки с настройками обновления ('
        || ' srcString="' || srcString || '"'
        || ', sourceSchema="' || sourceSchema || '"'
        || ').'
      )
    , true
  );
end getTableConfigString;

/* proc: refresh
  Обновляет данные в интерфейсных таблицах.

  Параметры:
  tableList                   - список таблиц для обновления ( формат см. ниже)
  sourceSchema                - имя схемы по умолчанию для исходных
                                представлений
                                ( по умолчанию отсутствует)
  forTableName                - обновление только указанной таблицы
                                ( имя таблицы без учета регистра)
                                ( по умолчанию без ограничений)
  createMViewFlag             - создавать материализованное представление для
                                обновления таблицы, если оно отсутствует либо
                                его невозможно использовать для обновления, и
                                для таблицы указан метод обновления с помощью
                                м-представления
                                ( 1 да, 0 нет ( по умолчанию), игнорируется в
                                  в случае указания forceCreateMViewFlag равным
                                  1)
  forceCreateMViewFlag        - безусловно создавать ( пересоздавать)
                                материализованное представление для обновления
                                таблицы, если для таблицы указан метод
                                обновления с помощью м-представления
                                ( 1 да, 0 нет ( по умолчанию))
  continueAfterErrorFlag      - продолжать обработку остальных таблиц в случае
                                ошибки при обновлении
                                ( 1 да, 0 нет ( по умолчанию))

  Элементы списка таблиц для обновления ( параметр tableList) указываются в формате:

  <tableName>[:[<refreshMethod>][:[<sourceView>][:[<tempTableName>]]]][:[<optionList>]]

  tableName             - имя таблицы для обновления ( без учета регистра)
                          ( в случае обновления с помощью материализованного
                          представления таблица должна принадлежать текущему
                          пользователю, иначе перед именем таблицы
                          можно указать схему)
  refreshMethod         - метод обновления ( "d" сравнением данных ( по
                          умолчанию), "m" с помощью материализованного
                          представления, "t" сравнением с использованием
                          временной таблицы)
  sourceView            - имя исходного представления, возможно с указанием
                          схемы ( без учета регистра, по умолчанию строится на
                          основе имени таблицы для обновления добавлением
                          префикса "v_", в качестве схемы по умолчанию
                          используется значение параметра sourceSchema)
  tempTableName         - имя временной таблицы ( без учета регистра),
                          используемой при обновлении методом "t" ( по
                          умолчанию строится на основе имени таблицы для
                          обновления добавлением окончания "_tmp")
  optionList            - список дополнительных опций ( с разделителем пробел)
                          в формате "<optName>=<optValue>", допустимые опции
                          перечислены ниже;

  Возможные дополнительные
  опции ( указываемые в <optionList>):

  excludeColumnList     - список колонок таблицы, исключаемых из обновления
                          ( с разделителем запятая, без учета регистра,
                           пробельные символы игнорируются) ( по умолчанию
                          в обновлении участвуют все колонки)

  Символы табуляции ( 0x09), возврата каретки ( 0x0D), перевода строки ( 0x0A)
  рассматриваются как пробельные и игнорируются, если они указаны до или после
  элементов списка.

  Замечания:
  - после обновления каждой таблицы выполняется commit;
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

  -- Число успешно обработанных записей списка
  nProcessed pls_integer := 0;

  -- Число записей списка, обработанных с ошибками
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
          'Ошибка #' || nError || ' при обновлении таблиц ('
          || ' table_name="' || rec.table_name || '"'
          || ', refresh_method="' || rec.refresh_method || '"'
          || '):'
          || chr(10) || logger.getErrorStack()
        );
      else
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , logger.errorStack(
              'Ошибка при обработке элемента списка таблиц ('
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
      , 'При обновлении некоторых таблиц возникли ошибки ('
        || ' nError=' || nError
        || ', nProcessed=' || nProcessed
        || ').'
    );
  elsif forTableName is not null and nProcessed = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Нет удалось определить таблицу для обновления.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при обновлении данных в интерфейсных таблицах ('
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
  Удаляет материализованные представления, созданные для обновления
  интерфейсных таблиц.
  Удаление выполняется только в случае, если в списке таблиц для таблицы
  указан метод обновления с помощью материализованного представления
  (  таблица при удалении м-представления сохраняется).

  Параметры:
  tableList                   - список таблиц для обновления ( формат см. в
                                описании процедуры <refresh>)
  forTableName                - обработка только указанной таблицы
                                ( имя таблицы без учета регистра)
                                ( по умолчанию без ограничений)
  ignoreNotExistsFlag         - игнорировать отсутствие материализованного
                                представления для удаления
                                ( 1 игнорировать, 0 выбрасывать ошибку
                                  ( по умолчанию))
  continueAfterErrorFlag      - продолжать обработку остальных таблиц в случае
                                ошибки при удалении материализованного
                                представления
                                ( 1 да, 0 нет ( по умолчанию))
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

  -- Число успешно обработанных записей списка
  nProcessed pls_integer := 0;

  -- Число записей списка, обработанных с ошибками
  nError pls_integer := 0;

  -- В списке есть таблица для обработки
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
          'Ошибка #' || nError || ' при удалении м-представлений:'
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
      , 'При удалении некоторых м-представлений возникли ошибки ('
        || ' nError=' || nError
        || ', nProcessed=' || nProcessed
        || ').'
    );
  elsif forTableName is not null and not isTableFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Нет удалось определить таблицу для обработки.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при удалении м-представлений, созданных для обновления таблиц ('
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
