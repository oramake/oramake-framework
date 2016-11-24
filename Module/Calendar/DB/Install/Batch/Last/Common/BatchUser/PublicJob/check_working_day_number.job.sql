-- ѕроверка пор€дкового номера рабочего дн€ в мес€це
-- ѕроверка того, что текуща€ дата €вл€етс€ рабочим днем, а также в случае,
-- если указан параметр WorkingDayNumber, и что это N-й по счету ( N равно
-- WorkingDayNumber) рабочий день с начала мес€ца.
--
-- »спользуемые параметры:
-- WorkingDayNumber              - пор€дковый номер рабочего дн€ с начала мес€ца,
--                                 которому должена соответствовать текуща€ дата
--                                 ( по умолчанию без ограничений, т.е. любой
--                                 рабочий день)
-- IgnoreWorkingDayCheckFlag     - игнорировать проверку ( результат всегда
--                                  положительный)
--
declare

  workingDayNumber integer := pkg_Scheduler.getContextNumber(
    'WorkingDayNumber'
  );

  ignoreWorkingDayCheckFlag number(1) := pkg_Scheduler.getContextNumber(
    'IgnoreWorkingDayCheckFlag'
  );

  -- ѕровер€ема€ дата
  checkDate date := trunc( sysdate);

  -- –езультат проверки
  resultFlag integer;

begin
  if ( ignoreWorkingDayCheckFlag = 1) then
    jobResultMessage := 'ѕроверка проигнорирована';
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
        'ѕоложительный результат'
      else
        'ќтрицательный результат'
      end
      || ' ('
      || ' ' || to_char( checkDate, 'dd.mm.yyyy')
      || case when resultFlag = 1 then
          ' €вл€етс€'
         else
          ' не €вл€етс€'
         end
      || case when workingDayNumber is not null then
          ' ' || workingDayNumber || '-м рабочим днем с начала мес€ца'
        else
          ' рабочим днем'
        end
      || ').';
  end if;
end;
