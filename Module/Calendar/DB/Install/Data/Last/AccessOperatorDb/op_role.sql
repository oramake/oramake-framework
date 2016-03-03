begin
  merge into op_role d
  using
  (
    select
      'CdrUser' as role_short_name
      , 'ѕользователь модул€ Calendar' as role_name
      , 'Calendar user' as role_name_en
      , 'ƒает права на просмотр данных по справочнику отклонений рабочих/выходных дней' as description
    from op_role
    union all
    select
      'CdrAdministrator' as role_short_name
      , 'јдминистратор модул€ Calendar' as role_name
      , 'Calendar administrator' as role_name_en
      , 'ƒает права на просмотр, редактирование, добавление и удаление данных по справочнику отклонений рабочих/выходных дней ' as description
    from op_role
    minus
    select
      t.role_short_name
      , t.role_name
      , t.role_name_en
      , t.description
    from
      op_role t
  ) s
  on (d.role_short_name = s.role_short_name)
  when not matched then insert
  (
    role_id
    , role_short_name
    , role_name
    , role_name_en
    , description
  )
  values
  (
    op_role_seq.nextval
    , s.role_short_name
    , s.role_name
    , s.role_name_en
    , s.description
  )
  when matched then update set
    d.role_name         = s.role_name
    , d.role_name_en    = s.role_name_en
    , d.description     = nvl (d.description, s.description)
  ;
  commit;
end;
/
