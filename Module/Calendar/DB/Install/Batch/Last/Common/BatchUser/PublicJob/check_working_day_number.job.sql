-- �������� ����������� ������ �������� ��� � ������
-- �������� ����, ��� ������� ���� �������� ������� ����, � ����� � ������,
-- ���� ������ �������� WorkingDayNumber, � ��� ��� N-� �� ����� ( N �����
-- WorkingDayNumber) ������� ���� � ������ ������.
--
-- ������������ ���������:
-- WorkingDayNumber              - ���������� ����� �������� ��� � ������ ������,
--                                 �������� ������� ��������������� ������� ����
--                                 ( �� ��������� ��� �����������, �.�. �����
--                                 ������� ����)
-- IgnoreWorkingDayCheckFlag     - ������������ �������� ( ��������� ������
--                                  �������������)
--
declare

  workingDayNumber integer := pkg_Scheduler.getContextNumber(
    'WorkingDayNumber'
  );

  ignoreWorkingDayCheckFlag number(1) := pkg_Scheduler.getContextNumber(
    'IgnoreWorkingDayCheckFlag'
  );

  -- ����������� ����
  checkDate date := trunc( sysdate);

  -- ��������� ��������
  resultFlag integer;

begin
  if ( ignoreWorkingDayCheckFlag = 1) then
    jobResultMessage := '�������� ���������������';
  else
    resultFlag :=
      case
        when
          pkg_Calendar.isWorkingDay( checkDate) = 1
          and (
            workingDayNumber is null
            or pkg_Calendar.getPeriodWorkingDayAmount(
                trunc( checkDate, 'mm')
                , checkDate
              ) = workingDayNumber
            )
        then 1
        else 0
      end
    ;
    if resultFlag = 0 then
      jobResultId := pkg_Scheduler.False_ResultId;
    end if;
    jobResultMessage :=
      case when resultFlag = 1 then
        '������������� ���������'
      else
        '������������� ���������'
      end
      || ' ('
      || ' ' || to_char( checkDate, 'dd.mm.yyyy')
      || case when resultFlag = 1 then
          ' ��������'
         else
          ' �� ��������'
         end
      || case when workingDayNumber is not null then
          ' ' || workingDayNumber || '-� ������� ���� � ������ ������'
        else
          ' ������� ����'
        end
      || ').';
  end if;
end;
