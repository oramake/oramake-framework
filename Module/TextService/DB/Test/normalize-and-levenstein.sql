declare

  etalonString varchar2(1000) :=
    'Бухгалтерия, аудит, финансы / Бухгалтерский учет';

  /*
    Тестирование расстояния.
  */
  procedure checkDistance(
    target varchar2
  )
  is
  begin
    pkg_Common.outputMessage(
      '"' || target || '": '
      ||
      to_char(
        pkg_TextUtilityTest.normalizeAndLevenstein(
          source => etalonString
          , target => target
        )
     )
    );
  end checkDistance;

begin
  pkg_Common.outputMessage( '...');
  pkg_Common.outputMessage( 'Distance to "' || etalonString || '"');
  pkg_Common.outputMessage( '...');
  checkDistance( 'Бухгалтерия / Банки / Финансы / Инвестиции / Аудит / Бухгалтерия / Финансы');
  checkDistance( 'Бухгалтерия / Банки / Финансы / Инвестиции / Банк / Финансовая компания/ Фондовый рынок');
  checkDistance( 'Бухгалтер');
  checkDistance( 'Бухгалтер 1С');
  etalonString := '/Все/Бухгалтерия';
  pkg_Common.outputMessage( '...');
  pkg_Common.outputMessage( 'Distance to "' || etalonString || '"');
  pkg_Common.outputMessage( '...');
  checkDistance( '/Все/Юриспруденция/Юрист');
  checkDistance( '/Все/Департамент автокредитования/Бухгалтер');
end;
/
