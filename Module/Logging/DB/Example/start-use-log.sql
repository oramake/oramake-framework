-- ��� ��������� � ���� �������
begin
  lg_logger_t.getRootLogger().info('Hellow World');
end;
/



-- ���������� ��� � ��� �� ������
-- ��� ����� ������� ��� � ������ output
select
  vl.*
from 
  v_lg_current_log vl
order by
  vl.date_ins
/