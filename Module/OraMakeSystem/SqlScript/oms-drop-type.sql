--script: oms-drop-type.sql
--Удаляет SQL-тип принудительным ( "force") образом, при этом зависящие от
--удаляемого типа объекты становятся инвалидными.
--
--Параметры:
--typeName                    - имя SQL-типа
--
--Замечания:
--  - прикладной скрипт, предназначен для вызова из пользовательских скриптов;
--  - скрипт используется для удаления типа перед пересозданием, чтобы не было
--    ошибки из-за наличия зависимостей;
--  - ошибка, возникающая из-за отсутствия удаляемого типа, игнорируется;
--  - в скрипте включается использование макропеременных SQL*Plus командой
--    "set define on"; если это мешает, то после вызова скрипта нужно выполнить
--    команду "set define off";
--

set define on

define typeName = "&1"



declare

  typeName varchar2(30) := '&typeName';
  
begin
  dbms_output.put_line( 'drop type: ' || typeName);
  execute immediate 'drop type ' || typeName || ' force';
exception when others then
                                        --ORA-04043: object * does not exist
  if SQLCODE = -04043 then
    null;
  else
    raise;
  end if;
end;
/



undefine typeName
