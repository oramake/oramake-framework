begin
  pkg_CommonTest.testNumberToWord(
    sourceNumber => 1
    , expectedString => 'один рубль 00 копеек'
  );
  pkg_CommonTest.testNumberToWord(
    sourceNumber => 1000000000
    , expectedString => 'один миллиард рублей 00 копеек'
  );
end;
/
