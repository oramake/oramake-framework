-- Поиск файла
-- if  <ProcessFileOrder> is not null and not in [ 'SINGLE_LIST', 'CYCLE_RANDOM', 'CYCLE_MODIFIED' ] then
--   raise_application_error with message ""Неверный параметр ProcessFileOrder: ""    concatenated with parameter value.
--
-- Execute pkg_File.FileList(
--   <SourcePath>
--   , <SourceMask>
--   , case when <ProcessFileOrder> = 'CYCLE_RANDOM' then 1 end
-- );
--
-- if table "tmp_file_list" is not empty then
--   if <ProcessFileOrder> in ( 'CYCLE_RANDOM', 'CYCLE_MODIFIED')  then
--     set <SourceFileName>, <SourceFullFileName> with first file name by
--     modification time.
--   if <ProcessFileOrder> = 'CYCLE_RANDOM' then
--     log "Найден файл: " concatenated with the found file name
--   else
--     log "Найдено файлов: ' concatenated with the found files count
--   set job result to Successful_True
-- else
--   set job result to Successful_False.
declare

  sourcePath varchar2(1024) := pkg_Scheduler.getContextString(
    'SourcePath', riseException => 1
  );

  sourceMask varchar2(1024) := pkg_Scheduler.getContextString(
    'SourceMask'
  );

  processFileOrder varchar2(100) := pkg_Scheduler.getContextString(
    'ProcessFileOrder'
  );

  -- Имя найденного файла
  fileName tmp_file_name.file_name%type;

  -- Число найденных файлов
  nFound integer;

begin

  -- Проверяем корректность параметра
  if processFileOrder is not null
    and processFileOrder not in (
        'SINGLE_LIST'
        , 'CYCLE_RANDOM'
        , 'CYCLE_MODIFIED'
      )
      then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Неверный параметр ProcessFileOrder: ' || processFileOrder
    );
  end if;

  -- Выполняем поиск файлов
  pkg_File.FileList(
    fromPath        => sourcePath
    , fileMask      => sourceMask
    , maxCount      => case when processFileOrder = 'CYCLE_RANDOM' then 1 end
  );

  -- Определяем результат поиска
  select
    min( t.file_name)
      keep ( dense_rank first order by t.last_modification)
      as file_name
    , count(*)
  into fileName, nFound
  from
    tmp_file_name t
  ;

  -- Устанавливаем результат выполнения
  if fileName is not null then
    if processFileOrder in ( 'CYCLE_RANDOM', 'CYCLE_MODIFIED') then
      pkg_Scheduler.setContext(
        'SourceFileName'
        , fileName
      );
      pkg_Scheduler.setContext(
        'SourceFullFileName'
        , pkg_File.GetFilePath(
            parent    => sourcePath
            , child   => fileName
          )
      );
    end if;
    if processFileOrder = 'CYCLE_RANDOM' then
      jobResultMessage := 'Найден файл: ' || fileName;
    else
      jobResultMessage := 'Найдено файлов: ' || to_char( nFound);
    end if;
  else
    jobResultId := pkg_Scheduler.False_ResultId;
    jobResultMessage := 'Файл не найден';
  end if;
end;
