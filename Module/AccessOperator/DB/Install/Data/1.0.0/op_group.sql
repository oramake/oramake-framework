-- script: Install/Data/1.0.0/op_group.sql
-- ƒобавление первоначальных групп дл€ работы с модулем.

declare

  nChanged integer;

  groupId integer;

begin
  merge into
    op_group dest
  using
    (
    select
      k.group_id
      , k.group_name
      , k.group_name_en
      , 1 as operator_id
    from
      (
      select
        t.group_id
        , t.group_name
        , t.group_name_en
      from
        (
        select
          -- pkg_Operator.FullAccess_GroupId
          1 as group_id
          , 'ѕолный доступ' as group_name
          , 'Full Access'   as group_name_en
        from
          dual
        ) t
      minus
      select
        opg.group_id
        , opg.group_name
        , opg.group_name_en
      from
        op_group opg
      ) k
    ) src
  on
    ( dest.group_id = src.group_id)
  when not matched then
    insert (
      dest.group_id
      , dest.group_name
      , dest.group_name_en
      , dest.operator_id
      , dest.group_name_rus
      , dest.group_name_eng
    )
    values (
      src.group_id
      , src.group_name
      , src.group_name_en
      , src.operator_id
      , src.group_name
      , src.group_name_en
      )
  when matched then
    update set
      dest.group_name = src.group_name
      , dest.group_name_en = src.group_name_en
      , dest.group_name_rus = src.group_name
      , dest.group_name_eng = src.group_name_en
  ;
  nChanged := sql%rowcount;

  if nChanged > 0 then

    -- »сключаем дублирование по Id при последующем добавлении записи
    -- с использованием последовательности
    groupId := op_group_seq.nextval;
  end if;

  commit;

  dbms_output.put_line(
    'changed: ' || nChanged
  );
end;
/
