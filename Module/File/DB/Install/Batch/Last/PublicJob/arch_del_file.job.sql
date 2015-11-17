-- Архивирование и удаление файла
-- Перемещает файл в каталог с указанным именем.
--
-- Параметры:
-- SourceFullFileName            - полный путь к исходному файлу
-- ArchivePath                   - путь для архивирования
-- ArchiveFileName               - имя файла для архивирования
--                                 ( по умолчанию формируется по шаблону
--                                  to_char( sysdate, 'YYYYMMDD_HH24MiSS') +
--                                  '_ARCH_' + SourceFileName
--                                 )
-- SourceFileName                - имя исходного файла
--                                 ( требуется только если не задан
--                                 ArchiveFileName)
--
declare

  -- Полный путь к исходному файлу
  sourceFile varchar2(1024) :=
    pkg_Scheduler.getContextString(
      'SourceFullFileName'
      , riseException => 1
    )
  ;

  -- Путь для архивирования
  archPath varchar2(1024) :=
    pkg_Scheduler.getContextString(
      'ArchivePath'
      , riseException => 1
    )
  ;

  -- Имя файла для архивирования
  archFileName varchar2(1024) :=
    pkg_Scheduler.getContextString( 'ArchiveFileName')
  ;

begin
  if archFileName is null then
    archFileName :=
      to_char( sysdate, 'YYYYMMDD_HH24MiSS')
      || '_ARCH_'
      || pkg_Scheduler.getContextString(
          'SourceFileName'
          , riseException => 1
        )
    ;
  end if;
  archPath := pkg_File.getFilePath( archPath, archFileName);
  pkg_File.fileMove(
    fromPath    => sourceFile
    , toPath    => archPath
    , overwrite => 0
  );
  jobResultMessage := 'Файл скопирован в "' || archPath || '" и удален.';
end;
