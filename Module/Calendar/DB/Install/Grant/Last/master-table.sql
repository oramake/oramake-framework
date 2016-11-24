-- script: Install/Grant/Last/master-table.sql
-- ¬ыдает пользователю права на таблицу, необходимые дл€ создани€
-- материализованного представлени€ на ее основе.
--
-- ѕараметры:
-- tableName                  - им€ таблицы ( формат schema.tableName, если
--                              схема не указана, то используетс€ текуща€)
--
-- ћакропеременные:
-- toUserName                 - им€ пользовател€, которому выдаютс€ права
--
-- «амечани€:
--  - при наличии у таблицы материализованного лога, пользователю также
--    выдают€ права на его использование ( дл€ создани€ fast-refresh
--    представлений)
--

define tableName = "&1"



prompt grant: &tableName ...

grant select on &tableName to &toUserName
/



declare

  tableName varchar2(100) := '&tableName';

  -- ¬ыдача прав на мат. логи дл€ создани€ fast refresh м-представлений
  cursor curLogTable is
    select
      t.log_owner || '.' || t.log_table as log_name
      , t.master
    from
      all_mview_logs t
    where
      t.log_owner = upper(
          case when tableName like '%.%' then
            substr( tableName, 1, instr( tableName, '.') - 1)
          else
            sys_context( 'USERENV', 'CURRENT_SCHEMA')
          end
        )
      and t.master = upper(
          case when tableName like '%.%' then
            substr( tableName, instr( tableName, '.') + 1)
          else
            tableName
          end
        )
  ;

begin
  for rec in curLogTable loop
    dbms_output.put_line(
      'grant: ' || lower( rec.log_name) || ' ...'
    );
    execute immediate
      'grant select on ' || rec.log_name || ' to ' || '&toUserName'
    ;
  end loop;
end;
/



undefine tableName
