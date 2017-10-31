--script: OmsInternal/finish-install-file.sql
--Сохраняет информацию о завершении установки файла в БД.
--Для сохранения информации вызывается процедура FinishInstallFile пакета
--pkg_ModuleInstall ( модуль Oracle/Module/ModuleInfo).
--
--Скрипт вызывается автоматически при загрузке файла через <oms-load> с помощью
--SQL*Plus в случае необходимости сохранения информации об установке файлов
--( см. <OMS_SAVE_FILE_INSTALL_INFO>).
--
--Замечания:
--  - внутренний скрипт, используется внутри OMS;
--  - ошибка, возникающая из-за недоступности пакета pkg_ModuleInstall,
--    игнорируется;
--

set feedback off

begin
  execute immediate '
begin
  pkg_ModuleInstall.FinishInstallFile;
end;
'
  ;
exception when others then
  raise_application_error(
    -20001
    , 'OMS: Ошибка при сохранении информации о завершении установки файла в БД'
      || ' ( скрипт OmsInternal/finish-install-file.sql).'
    , true
  );
end;
/

set feedback on
