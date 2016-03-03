-- �������� ����������� ������ �������� ��� � ������
-- �������� ����, ��� ������� ���� �������� ������� ����, � ����� � ������, ����
-- ������ �������� WorkingDayNumber, � ��� ��� N-� �� ����� ( N �����
-- WorkingDayNumber) ������� ���� � ������ ������.
--
-- ������������ ���������:
-- WorkingDayNumber              - ���������� ����� �������� ��� � ������ ������,
--                                 �������� ������� ��������������� ������� ����
--                                 ( �� ��������� ��� �����������, �.�. �����
--                                 ������� ����)
-- CalendarDbLink                - ���������� ��������; �� ������������;
-- IgnoreWorkingDayCheckFlag     - ������������ �������� ( ��������� ������ �������������)
declare

  workingDayNumber integer := pkg_Scheduler.getContextInteger(
    'WorkingDayNumber'
  );

  calendarDbLink varchar2(128) := pkg_Scheduler.getContextString(
    'CalendarDbLink'
  );

  ignoreWorkingDayCheckFlag number(1,0) := pkg_Scheduler.getContextInteger(
    'IgnoreWorkingDayCheckFlag'
  );

  -- ����������� ����
  checkDate date := trunc( sysdate);

  -- ��������� ��������
  resultFlag integer;

begin
  if calendarDbLink is not null then
    pkg_Scheduler.writeLog(
      messageTypeCode => pkg_Scheduler.Info_MessageTypeCode
      , messageText => '���������� �������� CalendarDbLink ��������������'
    );
  end if;
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
