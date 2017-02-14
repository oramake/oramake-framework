create or replace package body pkg_TextUtilityTest is
/* package body: pkg_TextUtilityTest::body */

/* group: ���������� */

/* ivar: logger
   ������ ��� ������������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
    moduleName  => pkg_TextUtility.Module_Name
  , packageName => 'pkg_TextUtilityTest'
  );



/* group: ������� */



/* group: Unit-����� ������� */

/* proc: testLevenshteinDistance
   ��������� �������� ���������� ���������� �������������� (��������� �����������).

*/
procedure testLevenshteinDistance
is

  /*
    ������������ ����������.
  */
  procedure checkDistance(
    target varchar2
    , expectedDistance integer
  )
  is
  begin
    pkg_TestUtility.compareChar(
      actualString =>
         pkg_TextUtility.levenshteinDistance(
           source => '�����������, �����, ������� / ������������� ����'
           , target => target
         )
      , expectedString => to_char( expectedDistance)
      , failMessageText => '�������� ����������'
    );
  end checkDistance;

begin
  pkg_TestUtility.beginTest( '�������� ���������� ���������� ��������������' );
  checkDistance( '����������� / ����� / ������� / ���������� / ����� / ����������� / �������', 40);
  checkDistance( '����������� / ����� / ������� / ���������� / ���� / ���������� ��������/ �������� �����', 57);
  checkDistance( '���������', 39);
  checkDistance( '��������� 1�', 38);
  checkDistance( '��������� �� �������', 31);
  checkDistance( '������ �������������', 39);
  pkg_TestUtility.endTest();
end testLevenshteinDistance;

/* proc: testNormalizeWordList
  �������� ������ ������� ������������ ������ �����.

  ���������:
  sourceString                - �������� ������
  expectedString              - ��������� ������
  addonDelimiterList         - ������ ������������ ( ��-��������� ������ ������)
*/
procedure testNormalizeWordList(
  sourceString varchar2
  , expectedString varchar2
  , addonDelimiterList varchar2 := null
)
is
-- testNormalizeWordList
begin
  pkg_TestUtility.beginTest(
    'testNormalizeWordList ( "' || substr( sourceString, 1, 10) || '...")'
  );
  pkg_TestUtility.compareChar(
    expectedString => expectedString
    , actualString => pkg_TextUtility.normalizeWordList(
        sourceString => sourceString
        , addonDelimiterList => addonDelimiterList
      )
    , failMessageText => 'strings do not match'
  );
  pkg_TestUtility.endTest();
end testNormalizeWordList;

/* func: normalizeAndLevenstein
  ���������� ������� ����������� ��� ���������������� �������� ����.

  ���������:
  source                      - �������� ������
  target                      - ������, ������� ���������� ��������

  ���������:
  - ������������ ������������� ����������� "/-,";
*/
function normalizeAndLevenstein(
  source varchar2
  , target varchar2
)
return integer
is
  addonDelimiterList varchar2(10) := '/-,';
-- normalizeAndLevenstein
begin
  return
    pkg_TextUtility.levenshteinDistance(
      source =>
        pkg_TextUtility.normalizeWordList(
          sourceString => source
          , addonDelimiterList => addonDelimiterList
        )
      , target =>
        pkg_TextUtility.normalizeWordList(
          sourceString => target
          , addonDelimiterList => addonDelimiterList
        )
    );
end normalizeAndLevenstein;

/* func: wordListCloseness
  ���������� �������� ����� �������� ���� ( ��� ������ �������� �������,
  ��� ������ �������� - �������� �� 0 �� 1).

  ���������:
  wordList1                   - ����� ���� 1
  wordList2                   - ����� ���� 2
  addonDelimiterList          - ������ �������������� ������������ (
                                ��-��������� ������ ������)

  ����������:
  - ������� ����������� �������� ������ � ��������� �� �� �����, ����� �����
    ���������� ������ ���� ���� �������� ����������� � ������ ���������� ����
    � ������ � � ������ ���������� ����� � ������ ( ����� ������� � �����
    ����� ����� ������� ���);
*/
function wordListCloseness(
  wordList1 varchar2
  , wordList2 varchar2
  , addonDelimiterList varchar2 := null
)
return number
is

  -- ��������� ��� ������������ �����
  subtype MaxVarchar2 is varchar2(32767);

  -- ��������� ������ ����
  type WordColT is table of MaxVarchar2;
  wordCol1 WordColT := WordColT();
  wordCol2 WordColT := WordColT();

  -- ���������� ����� �������
  wordDistance number;
  -- �������� ����� ��������
  closeness number := 0;

  -- ��������� ������������������� �����
  sequenceSum1 number;
  sequenceSum2 number;
  sequenceStep1 number;
  sequenceStep2 number;

  /*
    ������ �������� ������ �� �����.
  */
  procedure splitWordList(
    wordCol in out nocopy WordColT
    , sourceString varchar2
  )
  is
    normalizedString MaxVarchar2;
    -- ������� ���������� �����������
    nextDelimiterPos integer;
    -- ������� ����������� �����������
    lastDelimiterPos integer := 0;

    /*
      ���������� �����.
    */
    procedure addWord
    is
      newWord MaxVarchar2 :=
        substr( normalizedString, lastDelimiterPos + 1, nextDelimiterPos - lastDelimiterPos - 1)
      ;
    begin
      wordCol.extend( 1);
      wordCol( wordCol.count) := newWord;
      logger.trace( 'addWord: "' || newWord || '"');
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ���������� ����� � ���������'
          )
        , true
      );
    end addWord;

  begin
    -- �������� ��� ����������� �� �������
    normalizedString := translate(
      sourceString
      , ' ' || addonDelimiterList
      , ' ' || lpad( ' ', length( addonDelimiterList))
    );
    -- ������� ������������� �������
    normalizedString := trim( lower(
        regexp_replace( normalizedString, ' +', ' ')
      ));
    logger.trace( 'normalizedString: "'  || normalizedString || '"');
    if normalizedString is not null then
      for safeCycle in 1 .. length( normalizedString) loop
        nextDelimiterPos := instr( normalizedString, ' ', lastDelimiterPos + 1);
        if nextDelimiterPos = 0 then
          nextDelimiterPos := length( normalizedString) + 1;
          addWord();
          exit;
        else
          addWord();
          lastDelimiterPos := nextDelimiterPos;
        end if;
      end loop;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ������� �������� ������ ('
          || ' sourceString="' || sourceString || '"'
          || ').'
        )
      , true
    );
  end splitWordList;

-- wordListDistance
begin
  splitWordList( wordCol1, wordList1);
  splitWordList( wordCol2, wordList2);

  if ( wordCol1.count > 0 and wordCol2.count > 0) then
    sequenceSum1 := wordCol1.count * ( wordCol1.count + 1) / 2;
    sequenceSum2 := wordCol2.count * ( wordCol2.count + 1) / 2;
    for i in wordCol1.first .. wordCol1.last loop
      for j in wordCol2.first .. wordCol2.last loop
        wordDistance := pkg_TextUtility.levenshteinDistance(
          wordCol1( i)
          , wordCol2( j)
        ) / ( length( wordCol1(i)) + length( wordCol2(j)));
        logger.trace(
          'Distance between "' || wordCol1( i) || '" and "' || wordCol2( j) || '" = ' || to_char( wordDistance)
        );
        if wordDistance <= 0.1 then
          closeness :=
            -- ��� ������ �� �����, ��� ������ ���
            closeness
            +
            (
              i / sequenceSum1
              + j / sequenceSum2
            ) / 2
          ;
          logger.trace( 'closeness=' || to_char( closeness, 'FM999999.0000'));
        end if;
      end loop;
    end loop;
    return
      closeness
    ;
  else
    return null;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ���������� ���������� ����� �������� ���� ('
        || ' wordList1="' || wordList1 || '"'
        || ', wordList2="' || wordList2 || '"'
        || ', addonDelimiterList="' || addonDelimiterList || '"'
        || ').'
      )
    , true
  );
end wordListCloseness;

/* proc: testWordListCloseness
  ������������ ������� �������� ���� ������� ����.

  ���������:
  wordList1                   - ����� ���� 1
  wordList2                   - ����� ���� 2
  expectedCloseness           - ��������� �������� ��������
*/
procedure testWordListCloseness(
  wordList1 varchar2
  , wordList2 varchar2
  , expectedCloseness number
)
is
-- testWordListCloseness
begin
  pkg_TestUtility.beginTest( 'testWordListCloseness ( '
    || substr( wordList1, 1, 3) || '... - ' || substr( wordList2, 1, 3) || '...)'
  );
  pkg_TestUtility.compareChar(
    actualString => to_char(
      wordListCloseness(
        wordList1 => wordList1
        , wordList2 => wordList2
        , addonDelimiterList => '_-,.:;/\'
      )
    )
    , expectedString => to_char( expectedCloseness)
    , failMessageText => 'closeness'
  );
  pkg_TestUtility.endTest();
end testWordListCloseness;



/* group: ������� ��� ������ � ���������� ������� */

/* proc: testNormalizeSearchPhrase
  ������������ ������������ ������� ������������ ������.

  ���������:
  searchPhrase                - �������� ������
  expectedPhrase              - ��������� ������
*/
procedure testNormalizeSearchPhrase(
  searchPhrase varchar2
, expectedPhrase varchar2
)
is
-- testNormalizeSearchPhrase
begin
  pkg_TestUtility.beginTest( 'normalizeSearchPhrase ("' || searchPhrase || '")');
  pkg_TestUtility.compareChar(
    actualString     => pkg_ContextSearchUtility.normalizeSearchPhrase( searchPhrase)
  , expectedString   => expectedPhrase
  , failMessageText  => 'function result'
  );
  pkg_TestUtility.endTest();
end testNormalizeSearchPhrase;

end pkg_TextUtilityTest;
/
