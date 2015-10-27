-- Перемещение файлов в каталог назначения
-- Перемещает файлы, соответствующие маске, из исходного каталога в каталог
-- назначения.
--
-- Параметры:
--
-- SourcePath                 - путь к исходному каталогу
-- DestPath                   - путь к каталогу назначения
-- FileMask                   - SQL-маска имени файла (без учета регистра,
--                              для экранирования спецсимволов '%' и '_' можно
--                              использовать '\')
--
-- Замечания:
-- - в случае наличия в каталоге назначения файла с именем, совпадающем с именем
--   перемещаемого файла, файл в каталоге назначения будет перезаписан;
declare

  sourcePath varchar2(1024) := pkg_Scheduler.getContextString(
    'SourcePath', riseException => 1
  );

  destPath varchar2(1024) := pkg_Scheduler.getContextString(
    'DestPath', riseException => 1
  );

  fileMask varchar2(1024) := pkg_Scheduler.getContextString(
    'FileMask'
  );

  cursor curFile is
    select
      t.file_name
    from
      tmp_file_name t
    order by
      t.last_modification
      , t.file_name
  ;

  -- Число обработанных файлов
  nProcessed integer := 0;

  -- Обрабатываемый файл
  filePath varchar(1024);

begin
  pkg_File.fileList( sourcePath);
  for rec in curFile loop
    filePath := pkg_File.getFilePath(
      parent    => sourcePath
      , child   => rec.file_name
    );
    pkg_File.fileMove(
      fromPath      => filePath
      , toPath      => destPath
      , overwrite   => 1
    );
    nProcessed := nProcessed + 1;
    pkg_Scheduler.writeLog(
      messageTypeCode     => pkg_Scheduler.Info_MessageTypeCode
      , messageText       =>
        'Перемещен файл: ' || rec.file_name
    );
  end loop;
  jobResultMessage := 'Перемещено файлов: ' || to_char( nProcessed);
end;
