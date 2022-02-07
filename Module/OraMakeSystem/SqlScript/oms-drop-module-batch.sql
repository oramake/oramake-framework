-- script: oms-drop-module-batch.sql
-- ������� �������� ������� (�����) �� �������� ������
--
-- ���������:
-- moduleName                  - ��� ������ � ������� ��������� �����
--

define moduleName = &1

prompt Dropping batches by module name &moduleName ...

declare
  -- �������� ������
  moduleName varchar2(100):= '&moduleName';
  -- Id ���������, ������������ ��������
  operatorId constant integer := pkg_Operator.GetCurrentUserId();
begin
  pkg_SchedulerLoad.deleteModuleBatch(
    moduleName   => moduleName
  );
exception
  when others
    then
      dbms_output.put_line( 'Exception: [' || sqlerrm || ']' );

end;
/

undefine moduleName
