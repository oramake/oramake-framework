@oms-drop-type dsn_data_sync_source_t

create or replace type dsn_data_sync_source_t
authid current_user
as object
(
/* db object type: dsn_data_sync_source_t
  Функции для работы с объектами исходной схемы, используемыми для обновления
  интерфейсных таблиц ( абстрактный базовый класс).

  Объект работает с правами вызывающего ( authid current_user).

  SVN root: Oracle/Module/DataSync
*/



/* group: Закрытые объявления */



/* group: Переменные */

/* var: moduleSvnRoot
  Путь к корневому каталогу модуля в Subversion ( начиная с имени репозитария).
*/
moduleSvnRoot varchar2(100),

/* var: viewList
  Список представлений, используемых для обновления ( указывается имя
  представления без учета регистра).
*/
viewList cmn_string_table_t,

/* var: mlogList
  Список логов материализованных представлений, используемых для обновления.
  В списке указывается имя базовой таблицы ( без учета регистра), и, если
  нужно, дополнительные опции для создания лога после разделителя двоеточие
  ( пример: "tmp_table:with rowid").
*/
mlogList cmn_string_table_t,



/* group: Функции */



/* group: Защищенные объявления */

/* pproc: initialize
  Инициализирует экземпляр объекта.
  Процедура должна в обязательном порядке вызываться при создании экземпляра
  производного класса.

  Параметры:
  moduleSvnRoot               - путь к корневому каталогу модуля в Subversion
                                ( начиная с имени репозитария, например:
                                "Oracle/Module/ModuleInfo")
  viewList                    - список представлений, используемых для
                                обновления ( указывается имя представления без
                                учета регистра)
  mlogList                    - список логов материализованных представлений
                                ( формат см. <mlogList>)
                                ( по умолчанию отсутствует)

  ( <body::initialize>)
*/
member procedure initialize(
  moduleSvnRoot varchar2
  , viewList cmn_string_table_t
  , mlogList cmn_string_table_t := null
),



/* group: Открытые объявления */

/* pproc: createMLog
  Создает необходимые логи материализованных представлений.

  Параметры:
  forTableName                - создавать лог только для указанной таблицы
                                ( имя таблицы без учета регистра)
                                ( по умолчанию без ограничений)
  recreateFlag                - флаг пересоздания лога, если он существует
                                ( 1 да, 0 нет ( по умолчанию))
  grantPrivsFlag              - флаг выдачи пользователям, имеющим права на
                                исходное представление, в котором используется
                                таблица лога, прав на лог в случае его создания
                                ( 1 да, 0 нет ( по умолчанию))

  ( <body::createMLog>)
*/
member procedure createMLog(
  self in dsn_data_sync_source_t
  , forTableName varchar2 := null
  , recreateFlag integer := null
  , grantPrivsFlag integer := null
),

/* pproc: dropMLog
  Удаляет использовавшиеся логи материализованных представлений.

  Параметры:
  forTableName                - удалять лог только для указанной таблицы
                                ( имя таблицы без учета регистра)
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

  ( <body::dropMLog>)
*/
member procedure dropMLog(
  self in dsn_data_sync_source_t
  , forTableName varchar2 := null
  , forceFlag integer := null
  , continueAfterErrorFlag integer := null
),

/* pproc: grantPrivs
  Выдает права для основного пользователя, под которым будут создаваться
  интерфейсные объекты.

  Параметры:
  userName                    - имя пользователя, которому выдаются права
  forObjectName               - ограничить выдачу прав только указанным
                                представлением либо исходной таблицей
                                и связанным с ней логом
                                ( имя объекта без учета регистра)
                                ( по умолчанию без ограничений)

  ( <body::grantPrivs>)
*/
member procedure grantPrivs(
  self in dsn_data_sync_source_t
  , userName varchar2
  , forObjectName varchar2 := null
)

)
not final
not instantiable
/
