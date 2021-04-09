-- script: Test/example.sql
-- Пример использования итератора для разбора данных формата CSV.
--

declare

  function loadData(
    textData clob
  )
  return integer
  is

    -- Итератор для разбора данных
    ti tpr_csv_iterator_t;

  begin

    -- создаем итератор ( в первой записи содержатся имена полей)
    ti := tpr_csv_iterator_t(
      textData              => textData
      , headerRecordNumber  => 1
    );

    -- цикл построчной обработки данных
    while ( ti.next()) loop

      if ti.getProcessedCount() = 1 then
        dbms_output.put_line(
          'field "last_name" exists: ' || ti.isFieldExists( 'last_name')
        );
        dbms_output.put_line(
          'field "last_name_old" exists: ' || ti.isFieldExists( 'last_name_old')
        );
        dbms_output.put_line(
          'optional field value: '
          || ti.getString( 'mother_last_name', isNotFoundRaised => 0)
        );
      end if;

      -- обработка данных записи
      dbms_output.put_line(
        '#' || ti.getRecordNumber()
        || '|' || ti.getString( 'last_name')
        || '|' || ti.getString( 'first_name')
        || '|' || ti.getString( 'middle_name')
        || '|' || to_char( ti.getDate( 'birth_date', 'dd.mm.yyyy') , 'dd.mm.yyyy hh24:mi:ss')
        || '|' || ti.getNumber( 'amount', ',')
        || '|' || ti.getString( 'work_place')
      );
    end loop;

    -- возврат числа обработанных записей с данными
    return ti.getProcessedCount();
  end loadData;

begin
  dbms_output.put_line(
    'loaded record: ' || loadData(
'last_name;first_name;middle_name;birth_date;amount;work_place
Иванов;Иван;Иванович;01.05.1970;100,35;"ООО ""Проба"""
Петров;Владимир;;30.04.1981;0;"ООО ""Мир,труд;май"""
Сидоров;;;;;
'
    )
  );
end;
/
