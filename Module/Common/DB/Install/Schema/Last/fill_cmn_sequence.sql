declare
  maxOrderNumber constant integer := 10000;
  nInsert integer;
begin
  insert into
    cmn_sequence sq
  (
    order_number
  )
  select
    s.*
  from
    (
    -- Генерация большого числа записей с помощью иерархического запроса
    select
      s.*
    from
      (
      select
        rownum as order_number
      from
        dual
      connect by
        1=1
      ) s
    where
      rownum <= maxOrderNumber
    ) s
  where
    not exists
      (
      select
        null
      from
        cmn_sequence t
      where
        t.order_number = s.order_number
      )
  ;
  nInsert := SQL%ROWCOUNT;
  if nInsert not in ( 0, maxOrderNumber) then
    raise_application_error(
      -20001
      , 'Некорректное число добавленных в cmn_sequence записей ('
        || ' ' || to_char( nInsert)
        || ').'
    );
  end if;
  dbms_output.put_line( 'cmn_sequence: add record: ' || nInsert);
  commit;
end;
/
