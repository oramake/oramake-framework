-- script: Test/Example/parse-csv.sql
-- ������ ������� ������ ������� CSV � �������������� ���������.
--
-- ����� �������������:
--
-- (code)
-- ...
--    -- �������� ��� ������� ������
--    ti tpr_csv_iterator_t;
--
-- begin
--    -- ������� �������� ( � ������ ������ ���������� ����� �����)
--    ti := tpr_csv_iterator_t(
--      textData              => textData
--      , headerRecordNumber  => 1
--    );
--
--
--    -- ���� ���������� ��������� ������
--    while ( ti.next()) loop
--      ...
--      dbms_output.put_line(
--        '#' || ti.getRecordNumber()
--        || '|' || ti.getString( 'last_name')
--        ...
--      );
--      ...
--    end loop;
--
--    -- ������� ����� ������������ ������� � �������
--    return ti.getProcessedCount();
-- end;
--
-- (end)
--

declare

  function loadData(
    textData clob
  )
  return integer
  is

    -- �������� ��� ������� ������
    ti tpr_csv_iterator_t;

  begin

    -- ������� �������� ( � ������ ������ ���������� ����� �����)
    ti := tpr_csv_iterator_t(
      textData              => textData
      , headerRecordNumber  => 1
    );

    -- ���� ���������� ��������� ������
    while ( ti.next()) loop

      -- ��������� ������ ������
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

    -- ������� ����� ������������ ������� � �������
    return ti.getProcessedCount();
  end loadData;

begin
  dbms_output.put_line(
    'loaded record: ' || loadData(
'last_name;first_name;middle_name;birth_date;amount;work_place
������;����;��������;01.05.1970;100,35;"��� ""�����"""
������;��������;;30.04.1981;0;"��� ""���,����;���"""
�������;;;;;
'
    )
  );
end;
/