begin
  pkg_CommonTest.testNumberToWord(
    sourceNumber => 1
    , expectedString => '���� ����� 00 ������'
  );
  pkg_CommonTest.testNumberToWord(
    sourceNumber => 1000000000
    , expectedString => '���� �������� ������ 00 ������'
  );
end;
/
