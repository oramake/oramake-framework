--trigger: dsz_segment_bi_define
--Триггер, инициализирующий поле segment_id 
create or replace trigger dsz_segment_bi_define
 before insert
 on dsz_segment
 for each row
 when ( new.segment_id is null )
begin
						    --Идентификатор записи
  if :new.segment_id is null then
    :new.segment_id := pkg_DataSize.GetNextSegmentId;
  end if;

end;--trigger;
/
