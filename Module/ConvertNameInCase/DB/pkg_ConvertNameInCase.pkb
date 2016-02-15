create or replace package body pkg_ConvertNameInCase is
/* package body: pkg_ConvertNameInCase::body */



/* group: ������� */

/* ifunc: getExceptionCase
  ������� ������ ������ � ����������� ����������.

  ������� ���������:
    stringNativeCase            - ������ ���������� � ������������ ������
    sexCode                     - ��� (M - �������, W - �������)
    typeExceptionCode           - ��� ����������

  �������:
    ������ �� ����� ������ ������������� <v_ccs_case_exception>.
*/
function getExceptionCase(
  stringNativeCase varchar2
  , sexCode varchar2
  , typeExceptionCode varchar2
)
return v_ccs_case_exception%rowtype
is
  -- ������ � �����������
  exceptionRec v_ccs_case_exception%rowtype;

-- getExceptionCase
begin
  select
    *
  into
    exceptionRec
  from
    v_ccs_case_exception ce
  where
    upper( trim( ce.native_case_name ) ) = upper( trim( stringNativeCase ) )
    and ce.sex_code = sexCode
    and ce.type_exception_code = typeExceptionCode
  ;

  return exceptionRec;

exception
  when no_data_found then
    return null;
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ������ ������ � ����������� ����������'
        || ' ��������� ������ ('
        || sqlerrm
        || ').'
      , true
    );
end getExceptionCase;

/* iproc: mergeExceptionCase
  ��������� ����������/���������� ������ � ����������� ����������.
  �������� � ���������� ��������� ��� ���������� ���������� ����������
  ������� ����������.

  ������� ���������:
    stringException             - ������ ����������
    stringNativeCase            - ������ ���������� � ������������ ������
    sexCode                     - ��� (M - �������, W - �������)
    typeExceptionCode           - ��� ����������
    caseCode                    - ��� ������,
                                  (NAT - ������������, GEN -  �����������
                                  , DAT-���������, ACC - �����������
                                  , ABL- ������������, PREP- ����������)
    operatorId                  - �� ���������

  �������� ��������� �����������.
*/
procedure mergeExceptionCase(
  stringException varchar2
  , stringNativeCase varchar2
  , sexCode varchar2 default Women_SexCode
  , typeExceptionCode varchar2
  , caseCode varchar2
  , operatorId integer
)
is
  pragma autonomous_transaction;

-- mergeExceptionCase
begin
  -- ���������/��������� ������ � ������� ����������
  merge into
    ccs_case_exception dst
  using
    (
    select
      stringNativeCase as native_case_name
      , upper( trim( sexCode ) ) as sex_code
      , upper( trim( typeExceptionCode ) ) as type_exception_code
      , decode(
          upper( trim( caseCode ) )
          , pkg_ConvertNameInCase.Genetive_CaseCode
          , initcap( stringException )
          , null
        ) as genetive_case_name
      , decode(
          upper( trim( caseCode ) )
          , pkg_ConvertNameInCase.Dative_CaseCode
          , initcap( stringException )
          , null
        ) as dative_case_name
      , decode(
          upper( trim( caseCode ) )
          , pkg_ConvertNameInCase.Accusative_CaseCode
          , initcap( stringException )
          , null
        ) as accusative_case_name
      , decode(
          upper( trim( caseCode ) )
          , pkg_ConvertNameInCase.Ablative_CaseCode
          , initcap( stringException )
          , null
        ) as ablative_case_name
      , decode(
          upper( trim( caseCode ) )
          , pkg_ConvertNameInCase.Preposition_CaseCode
          , initcap( stringException )
          , null
        ) as preposition_case_name
      , operatorId as operator_id
    from
      dual
    ) src
  on
    (
    upper( trim( dst.native_case_name ) ) = upper( trim( src.native_case_name ) )
    and dst.sex_code = src.sex_code
    and dst.type_exception_code = src.type_exception_code
    )
  when matched then
    update set
      dst.genetive_case_name =
        coalesce( src.genetive_case_name, dst.genetive_case_name )
      , dst.dative_case_name =
          coalesce( src.dative_case_name, dst.dative_case_name )
      , dst.accusative_case_name =
          coalesce( src.accusative_case_name, dst.accusative_case_name )
      , dst.ablative_case_name =
          coalesce( src.ablative_case_name, dst.ablative_case_name )
      , dst.preposition_case_name =
          coalesce( src.preposition_case_name, dst.preposition_case_name )
      , dst.deleted = 0
  when not matched then
    insert(
      dst.native_case_name
      , dst.genetive_case_name
      , dst.dative_case_name
      , dst.accusative_case_name
      , dst.ablative_case_name
      , dst.preposition_case_name
      , dst.sex_code
      , dst.type_exception_code
      , dst.operator_id
    )
    values(
      src.native_case_name
      , src.genetive_case_name
      , src.dative_case_name
      , src.accusative_case_name
      , src.ablative_case_name
      , src.preposition_case_name
      , src.sex_code
      , src.type_exception_code
      , src.operator_id
    )
  ;

  commit;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ����������/���������� ������ � ����������� ����������'
        || ' ��������� ������ ('
        || sqlerrm
        || ').'
      , true
    );
end mergeExceptionCase;

/* ifunc: getNormalizedString
  ������� ������������ ������ - �������� ���� �������� �� �
  ����� ������� "-" � �������� "(", ")" � ������ ������ ������.

  ������� ���������
    inputString                 - �������� ������

  �������:
    outputStr                   - ��������������� ������
*/
function getNormalizedString(
  inputString varchar2
)
return varchar2
is
-- getNormalizedString
begin
  -- ������� ��� ������� �� � ����� ������� "-"
  return regexp_replace(
    -- ������� ������� "(", ")" � ����� ������ ������
    regexp_replace(
      inputString
      , '\(([^()]*)\)'
    )
    , '\s*[-��]\s*'
    , '-'
  );
end getNormalizedString;

/* ifunc: getSexCode
  ������� ����������� ����, ���� �� �� ����� ����.

  ������� ���������:
    stringNativeCase               - ������ � ������������ ������
    formatString                   - ������ ��������������
*/
function getSexCode(
  stringNativeCase varchar2
  , formatString varchar2
)
return varchar2
is
  sexCode varchar2(1);

-- getSexCode
begin
  sexCode :=
    -- ���� ������� �������� � �������� ������ � �������� ���
    -- ���������
    case when
      -- ����� �� ���� ������ � ������, ����� � ������ ��� ���������
      instr( formatString, pkg_ConvertNameInCase.MiddleName_TypeExceptionCode, 1 ) > 0
      and (
        upper(
          substr(
            regexp_substr(
              stringNativeCase
              , '[^ ]+'
              , 1
              , instr( formatString, pkg_ConvertNameInCase.MiddleName_TypeExceptionCode, 1 )
            )
            , -1
          )
        ) = '�'
        or upper( stringNativeCase ) like '%����%'
      )
    then
      Men_SexCode
    else
      Women_SexCode
    end
  ;

  return coalesce( sexCode, Women_SexCode );

end getSexCode;

/* proc: updateExceptionCase
  ��������� ����������/���������� ������ � ����������� ����������.

  ������� ���������:
    exceptionCaseId             - �� ������ ����������
    stringException             - ������ ����������
    stringNativeCase            - ������ ���������� � ������������ ������
    stringConvertInCase         - ������, ���������� ���������� ��������
                                  convertNameInCase
    formatString                - ������ ������ ��� �������������� (
                                  "L"- ������ �������� �������
                                  , "F"- ������ �������� ���
                                  , "M" - ������ �������� ��������)
                                  , ���� �������� null, �� �������,
                                  ��� ������ ������ "LFM"
    sexCode                     - ��� (M - �������, W - �������)
    caseCode                    - ��� ������ (NAT - ������������
                                  , GEN - �����������
                                  , DAT - ���������, ACC - �����������
                                  , ABL - ������������, PREP - ����������)
    operatorId                  - �� ���������

  �������� ��������� �����������.
*/
procedure updateExceptionCase(
  exceptionCaseId integer default null
  , stringException varchar2
  , stringNativeCase varchar2
  , stringConvertInCase varchar2
  , formatString varchar2
  , sexCode varchar2 default null
  , caseCode varchar2
  , operatorId integer
)
is
  -- ��� ���� ����������
  typeExceptionCode ccs_case_exception.type_exception_code%type;
  -- ���
  sexCodeNormalized ccs_case_exception.sex_code%type;
  -- ������ ����������
  caseExceptionRec ccs_case_exception%rowtype;
  -- ��������������� ������ ������
  normalizedFormatStr varchar2(20) := upper( trim( formatString ) );
  -- ��� ������
  normalizedCaseCode varchar2(20) := upper( trim( caseCode ) );

  -- ��������������� �������� ����� ���
  -- ������ � �����������
  normalizedstringException varchar2(150);
  -- ������ � ������������ ������
  normalizedstringNativeCase varchar2(150);
  -- ������ ��������� �������������� �������
  normalizedStrConvertInCase varchar2(150);

  -- ��������� ������ �� ������ � ������������ � ��������
  -- ������ ����������
  stringExceptionPart varchar2(50);
  -- ������ � ������������ ������
  stringNativeCasePart varchar2(50);
  -- ������ ��������� ������ ������� ��������������
  strConvertInCasePart varchar2(50);

-- updateExceptionCase
begin
  -- �������� ��������������� ������
  normalizedstringException := getNormalizedString( stringException );
  normalizedstringNativeCase := getNormalizedString( stringNativeCase );
  normalizedStrConvertInCase := getNormalizedString( stringConvertInCase );

  -- ���
  sexCodeNormalized := coalesce(
    sexCode
    , getSexCode(
        stringNativeCase => normalizedStringNativeCase
        , formatString => normalizedFormatStr
      )
  );

  -- ���� ������ �� ������ - ����������� ��
  if exceptionCaseId is not null then
    -- ��������� ��������� ������
    select
      *
    into
      caseExceptionRec
    from
      ccs_case_exception ce
    where
      ce.exception_case_id = exceptionCaseId
    ;

    if caseExceptionRec.Deleted = 1 then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '���������� ������������� ��������� ������.'
        , true
      );
    end if;

    -- �������� ���������� �� ������
    -- ��� ���������� ����� �� ������ �� ��-�� � ����������
    -- ����� ����� �������� ������ � ����������� ���������� ���������
    stringExceptionPart := regexp_substr(
      normalizedstringException
      , '[^ ]+'
      , 1
      , instr( normalizedFormatStr, caseExceptionRec.Type_Exception_Code, 1 )
    );
    -- �������� ������������ ����� ����������
    stringNativeCasePart := regexp_substr(
      normalizedStringNativeCase
      , '[^ ]+'
      , 1
      , instr( normalizedFormatStr, caseExceptionRec.Type_Exception_Code, 1 )
    );
    -- ��������� ������ � ������� ����������
    update
      ccs_case_exception ce
    set
      ce.genetive_case_name =
        case when
          normalizedCaseCode = pkg_ConvertNameInCase.Genetive_CaseCode
        then
          stringExceptionPart
        else
          ce.genetive_case_name
        end
      , ce.dative_case_name =
          case when
            normalizedCaseCode = pkg_ConvertNameInCase.Dative_CaseCode
          then
            stringExceptionPart
          else
            ce.dative_case_name
          end
      , ce.accusative_case_name =
          case when
            normalizedCaseCode = pkg_ConvertNameInCase.Accusative_CaseCode
          then
            stringExceptionPart
          else
            ce.accusative_case_name
          end
      , ce.ablative_case_name =
          case when
            normalizedCaseCode = pkg_ConvertNameInCase.Ablative_CaseCode
          then
            stringExceptionPart
          else
            ce.ablative_case_name
          end
      , ce.preposition_case_name =
          case when
            normalizedCaseCode = pkg_ConvertNameInCase.Preposition_CaseCode
          then
            stringExceptionPart
          else
            ce.preposition_case_name
          end
      , ce.sex_code = sexCodeNormalized
    where
      ce.exception_case_id = exceptionCaseId
    ;

  -- ���� ����� ������������ ����� - ���������/��������� ����������
  elsif stringNativeCase is not null then
    for i in 1..length( normalizedFormatStr ) loop
      -- ���������� ��� ���� ����������
      typeExceptionCode := substr( normalizedFormatStr, i, 1 );

      -- �������� ����� �� ������ � ������������ ������� ��
      -- �������, ��������������� ���� ����������
      stringNativeCasePart := regexp_substr(
        normalizedStringNativeCase
        , '[^ ]+'
        , 1
        , i
      );
      -- �������� ����� �� ������ � ����������� ��
      -- �������, ��������������� ���� ����������
      stringExceptionPart := regexp_substr(
        normalizedstringException
        , '[^ ]+'
        , 1
        , i
      );
      -- �������� ����� �� ������ � ����������� ������� �������������� ��
      -- �������, ��������������� ���� ����������
      strConvertInCasePart := regexp_substr(
        normalizedStrConvertInCase
        , '[^ ]+'
        , 1
        , i
      );

      -- ���� ���������� �� ��������� �
      -- ����������� ������� �������������� - ��������� ��� � �������
      if stringExceptionPart != strConvertInCasePart then
        mergeExceptionCase(
          stringException => stringExceptionPart
          , stringNativeCase => stringNativeCasePart
          , sexCode => sexCodeNormalized
          , typeExceptionCode => typeExceptionCode
          , caseCode => caseCode
          , operatorId => operatorId
        );
      end if;

    end loop;
  -- ���� �� ����� �� 1 �������� - ���������� ������
  else
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '���������� �������� ������ � ������� ����������.'
      , true
    );
  end if;

exception
  when no_data_found then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ �� �������������� ������ ('
        || 'exceptionCaseId="' || to_char( exceptionCaseId ) || '"'
        || ').'
      , true
    );
  when dup_val_on_index then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ � ������ ����������� ��� ���������� � �����������'
        || ' ���������� ('
        || 'exceptionCaseId="' || to_char( exceptionCaseId ) || '"'
        || ', sexCode="' || sexCode || '"'
        || ').'
      , true
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� ����������/���������� ������ � ����������� ���������� '
        || ' ��������� ������ ('
        || 'exceptionCaseId="' || to_char( exceptionCaseId ) || '"'
        || ', stringException="' || stringException || '"'
        || ', stringNativeCase="' || stringNativeCase || '"'
        || ', stringConvertInCase="' || stringConvertInCase || '"'
        || ', formatString="' || formatString || '"'
        || ', sexCode="' || sexCode || '"'
        || ', caseCode="' || caseCode || '"'
        || ', operatorId="' || to_char( operatorId ) || '"'
        || ').'
      , true
    );
end updateExceptionCase;

/* ifunc: convertInCase
  ������� �������������� ��� � ���������� ������.

  ������� ���������:
    nameText                    - ������ ��� ��������������
    typeExceptionCode           - ������ ������ ��� ��������������
    caseCode                    - ��� ������ �������������� (
                                  NAT - ������������, GEN -  �����������
                                  , DAT-���������, ACC - �����������
                                  , ABL- ������������, PREP- ����������)
    sexCode                     - ��� W-women (�������), M-men (�������)

  �������:
    ������ � ��������� ������.
*/

function convertInCase(
  nameText varchar2
  , typeExceptionCode varchar2
  , caseCode varchar2
  , sexCode varchar2 default Women_SexCode
)
return varchar2
is
  tailChr varchar2(1);
  nameInCase varchar2(50) := nameText;

  --
  function termCompare(
    nameText varchar2
    , tail varchar2
  )
  return boolean
  is
  -- termCompare
  begin
    if nvl( length( nameText ) , 0 ) < nvl( length( tail ), 0 ) then
      return false;
    end if;

    if lower( substr( nameText, -length( tail ) ) ) = lower( tail ) then
      return true;
    else
      return false;
    end if;

  end termCompare;

  /*
    ��������� ���������� ����������� ���������� � ����������� �� ������.
  */
  procedure makeName(
    nameText in out varchar2
    , posNumber number
    , genTail varchar2
    , datTail varchar2
    , accTail varchar2
    , ablTail varchar2
    , preTail varchar2
  )
  is
  begin
    select
      substr( nameText, 1, length( nameText ) - posNumber )
      || decode(
        caseCode
        , pkg_ConvertNameInCase.Genetive_CaseCode
        , genTail
        , pkg_ConvertNameInCase.Dative_CaseCode
        , datTail
        , pkg_ConvertNameInCase.Ablative_CaseCode
        , ablTail
        , pkg_ConvertNameInCase.Accusative_CaseCode
        , accTail
        , pkg_ConvertNameInCase.Preposition_CaseCode
        , preTail
      )
    into
      nameText
    from
      dual
    ;
  end makeName;

-- convertInCase
begin
  -- �������
  if typeExceptionCode = pkg_ConvertNameInCase.LastName_TypeExceptionCode then
    -- ������������ ��������� ��������� �������:
    if instr( nameText, '-' ) > 0 then
      nameInCase :=
        -- ��� �������, ���������� ��������� -�����, -���,
        -- -���, -����, -����, -���, -����
        -- ������ ����� ������� �� ��������
        case when
          upper(
            substr( nameText, instr( nameText, '-' ) + 1 )
          ) not in (
            '�����'
            , '���'
            , '���'
            , '����'
            , '����'
            , '���'
            , '����'
          )
        then
          convertNameInCase(
            nameText => substr( nameText, 1, instr( nameText, '-' ) - 1 )
            , formatString => pkg_ConvertNameInCase.LastName_TypeExceptionCode
            , caseCode => caseCode
            , sexCode => sexCode
          )
        else
          substr( nameText, 1, instr( nameText, '-' ) - 1 )
        end
        || '-'
        || convertNameInCase(
             nameText => substr( nameText, instr( nameText, '-' ) + 1 )
             , formatString => pkg_ConvertNameInCase.LastName_TypeExceptionCode
             , caseCode => caseCode
             , sexCode => sexCode
           )
      ;
    else

      tailChr := lower( substr( nameText, -1 ) );
      -- �������
      if sexCode = Men_SexCode then
        if tailChr not in ( '�', '�', '�', '�', '�', '�', '�' ) then
          if tailChr = '�' then
            makeName( nameInCase, 0, '�', '�', '�', '��', '�' );
          elsif tailChr = '�'
            and termCompare( nameInCase, '��' )
          then
            makeName( nameInCase, 0, '�', '�', '�', '��', '�' );
          elsif tailChr = '�'
            and termCompare( nameText, '��' )
          then
            if length( nameText ) > 3
              and lower( substr( nameText, -3 ) ) in (
                '���', '���', '���', '���', '���'
              )
            then
              makeName( nameInCase, 2, '���', '���', '���', '����', '���' );
            elsif length( nameText ) > 3
              and lower( substr( nameText, -3 ) ) in (
                '���', '���', '���', '���', '���', '���', '���'
              )
              and lower( substr( nameText, -4, 1 ) ) in (
                '�', '�', '�', '�', '�', '�', '�', '�', '�', '�'
              )
            then
              makeName( nameInCase, 2, '��', '��', '��', '���', '��' );
            elsif length( nameText ) > 3
              and lower( substr( nameText, -3 ) ) = '���'
            then
              makeName( nameInCase, 2, '���', '���', '���', '����', '���' );
            else
              makeName( nameInCase, 0, '�', '�', '�', '��', '�' );
            end if;
          elsif tailChr = '�'
            and (
              termCompare( nameText, '��' )
              or termCompare( nameText, '��' )
            )
          then
            makeName( nameInCase, 0, null, null, null, null, null );
          elsif tailChr in (
            '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�'
            , '�', '�', '�', '�', '�', '�', '�'
          )
          then
            makeName( nameInCase, 0, '�', '�', '�', '��', '�' );
          elsif tailChr = '�'
            and not(
              termCompare( nameText, '��' )
              or termCompare( nameText, '��' )
            )
          then
            makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
          elsif tailChr = '�'
            and not(
              termCompare( nameText, '��' )
              or termCompare( nameText, '��' )
            )
          then
            makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
          elsif tailChr = '�' then
            makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
          elsif tailChr = '�' then
            if length( nameText ) > 4
              and termCompare( nameText, '��' )
            then
              makeName( nameInCase, 2, '��', '��', '��', '���', '��' );
            elsif length( nameText ) > 4
              and (
                termCompare( nameText, '���' )
                or termCompare( nameText, '���' )
              )
            then
              makeName( nameInCase, 2, '���', '���', '���', '����', '���' );
            else
              makeName( nameInCase, 0, '�', '�', '�', '��', '�' );
            end if;
          elsif tailChr = '�' then
            if length( nameText ) > 4 then
              if termCompare( nameText, '����' )
                or termCompare( nameText, '����' )
              then
                makeName( nameInCase, 2, '���', '���', '���', '��', '��' );
              elsif termCompare( nameText, '��' ) then
                makeName( nameInCase, 2, '���', '���', '���', '��', '��' );
              elsif termCompare( nameText, '��' ) then
                makeName( nameInCase, 2, '���', '���', '���', '��', '��' );
              elsif lower( substr( nameText, -3 ) ) in (
                '���', '���', '���', '���', '���'
                , '���', '���', '���', '���', '���', '���', '���', '���', '���'
              )
              then
                makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
              elsif termCompare( nameText, '��' ) then
                makeName( nameInCase, 2, '���', '���', '���', '��', '��' );
              else
                makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
              end if;
            else
              makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
            end if;
          end if;
        end if;
      -- �������
      elsif sexCode = Women_SexCode then
        if lower( substr( nameText, -3 ) ) in (
          '���', '���', '���', '���', '���'
        )
        then
          makeName( nameInCase, 1, '��', '��', '�', '��', '��' );
        elsif termCompare( nameText, '��' )
          and lower( substr( nameText, -3, 1 ) ) = '�'
        then
          makeName( nameInCase, 2, '��', '��', '��', '��', '��' );
        elsif termCompare( nameText, '��' ) then
          makeName( nameInCase, 2, '��', '��', '��', '��', '��' );
        elsif termCompare( nameText, '��' )
          or termCompare( nameText, '��' )
        then
          makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
        elsif termCompare( nameText, '�' )
          and lower( substr( nameText, -2, 1 ) ) = '�'
        then
          makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
        end if;
      end if;
    end if;

  -- ���
  elsif typeExceptionCode = pkg_ConvertNameInCase.FirstName_TypeExceptionCode then
    tailChr := lower( substr( nameText, -1 ) );
    -- �������
    if sexCode = Men_SexCode then
      if tailChr not in ( '�', '�', '�' ) then
        if upper( nameText ) = '���' then
          makeName( nameInCase, 2, '���', '���', '���', '����', '���' );
        elsif tailChr in (
          '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�'
          , '�', '�', '�', '�', '�', '�', '�', '�'
        )
        then
          makeName( nameInCase, 0, '�', '�', '�', '��', '�' );
        elsif tailChr = '�' then
          makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
        elsif tailChr = '�' then
          makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
        elsif tailChr = '�' then
          if termCompare( nameText, '��' ) then
            makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
          elsif termCompare( nameText, '��' ) then
            makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
          else
            makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
          end if;
        elsif tailChr = '�' then
          if termCompare( nameText, '��' ) then
            makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
          else
            if termCompare( nameText, '��' ) then
              makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
            else
              makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
            end if;
          end if;
        elsif tailChr = '�' then
          makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
        elsif tailChr = '�' then
          if termCompare( nameText, '����' ) then
            makeName( nameInCase, 2, '��', '��', '��', '���', '��' );
          else
            makeName( nameInCase, 0, '�', '�', '�', '��', '�' );
          end if;
        end if;
      end if;
    -- �������
    elsif sexCode = Women_SexCode then
      if tailChr = '�'
        and length( nameText ) > 1
      then
        if lower( substr( nameText, -2 ) ) in (
          '��', '��', '��', '��', '��', '��', '��'
        )
        then
          makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
        else
          makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
        end if;
      elsif tailChr = '�'
        and length( nameText ) > 1
      then
        if termCompare( nameText, '��' )
          and lower( substr( nameText, -4 ) ) = '����'
        then
          makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
        elsif termCompare( nameText, '��' ) then
          makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
        else
          makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
        end if;
      elsif tailChr = '�' then
        if termCompare( nameText, '��' ) then
          makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
        else
          makeName( nameInCase, 1, '�', '�', '�', '��', '��' );
        end if;
      end if;
    end if;

  -- ��������
  elsif typeExceptionCode = pkg_ConvertNameInCase.MiddleName_TypeExceptionCode then
    tailChr := lower( substr( nameText, -1 ) );
    -- �������
    if sexCode = Men_SexCode then
      if tailChr = '�' then
        makeName( nameInCase, 0, '�', '�', '�', '��', '�' );
      end if;
    -- �������
    elsif sexCode = Women_SexCode then
      if tailChr = '�'
        and length( nameText ) != 1
      then
        makeName( nameInCase, 1, '�', '�', '�', '��', '�' );
      end if;
    end if;
  end if;

  return nameInCase;

end convertInCase;

/* func: convertNameInCase
  ������� �������������� ��� � ���������� ������. ������� ����
  � ������� � � ���������� ������ ������ ���������. ������� �������
  ������ ���������� ���� �� ����� ������ "-", ��� ���� ���������� �������� ��
  � ����� ����� �� �����.

  ������� ���������:
    nameText                    - ������ ��� ��������������
    formatString                - ������ ������ ��� ��������������
    caseCode                    - ��� ������ ��������������
    sexCode                     - ���

  �������:
    ������ � ��������� ������.
*/
function convertNameInCase(
  nameText varchar2
  , formatString varchar2
  , caseCode varchar2
  , sexCode varchar2 default null
)
return varchar2
is
  -- ��������� ��������������
  strConvertInCase varchar2(150);
  -- ��� ���� ����������
  typeExceptionCode ccs_case_exception.type_exception_code%type;
  -- ���
  normalizedsexCode ccs_case_exception.sex_code%type;
  -- ��������������� ������ ������
  normalizedFormatStr varchar2(20) := upper( trim( formatString ) );
  -- ��� ������
  normalizedCaseCode varchar2(20) := upper( trim( caseCode ) );

  -- ��������������� ������ � ������������ ������
  normalizedStringNativeCase varchar2(150);

  -- ������ ��������� ������ ������� ��������������
  strConvertInCasePart varchar2(50);

  -- ������ � �����������
  exceptionRec v_ccs_case_exception%rowtype;

  -- ������ � ������������ ������
  stringNativeCasePart varchar2(50);

  -- ���������� ��� ������������ �������
  UncorrectFormat exception;
  -- ���� ������� ���� ���� ���������� � �����������
  isExceptionTypeCodeExists integer;

  -- ����, ����
  isOglyExists integer;
  isKyzyExists integer;

-- convertNameInCase
begin
  -- �������� ��������������� ������
  normalizedStringNativeCase := getNormalizedString( nameText );

  select
    count(*)
  into
    isExceptionTypeCodeExists
  from
    ccs_type_exception te
  where
    instr( normalizedFormatStr, te.type_exception_code, 1 ) > 0
  ;

  if normalizedStringNativeCase is null
    or isExceptionTypeCodeExists = 0
    or normalizedCaseCode not in (
      pkg_ConvertNameInCase.Genetive_CaseCode
      , pkg_ConvertNameInCase.Dative_CaseCode
      , pkg_ConvertNameInCase.Accusative_CaseCode
      , pkg_ConvertNameInCase.Ablative_CaseCode
      , pkg_ConvertNameInCase.Preposition_CaseCode
    )
  then
    raise UncorrectFormat;
  end if;

  -- ���
  normalizedSexCode := coalesce(
    sexCode
    , getSexCode(
        stringNativeCase => normalizedStringNativeCase
        , formatString => normalizedFormatStr
      )
  );

  -- ��������� ������� "����" � "����"
  -- ����
  select
    count(*)
  into
    isOglyExists
  from
    (
    select
      regexp_substr(
        normalizedStringNativeCase
        , '[^ ]+'
        , 1
        , level
      ) as name
    from
      dual
    connect by
      level <= length( normalizedStringNativeCase ) -
        length( replace( normalizedStringNativeCase, ' ' ) ) + 1
    ) t
  where
    upper( t.name ) = upper( '����' )
    -- ��������� ������ ���������, ���� ��� ����
    -- �������� - � ����� �� ��������� "����"
    and length( t.name ) > 4
  ;
  -- ����
  select
    count(*)
  into
    isKyzyExists
  from
    (
    select
      regexp_substr(
        normalizedStringNativeCase
        , '[^ ]+'
        , 1
        , level
      ) as name
    from
      dual
    connect by
      level <= length( normalizedStringNativeCase ) -
        length( replace( normalizedStringNativeCase, ' ' ) ) + 1
    ) t
  where
    upper( t.name ) = upper( '����' )
    -- ��������� ������ ���������, ���� ��� ����
    -- �������� - � ����� �� ��������� "����"
    and length( t.name ) > 4
  ;

  -- � ����� �� ������� ��������������
  for i in 1..length( normalizedFormatStr ) loop
    -- ���������� ��� ���� ����������
    typeExceptionCode := substr( normalizedFormatStr, i, 1 );
    -- �������� ������������ ����� �� ������
    stringNativeCasePart := regexp_substr(
      normalizedStringNativeCase
      , '[^ ]+'
      , 1
      , i
    );

    -- ���� � ����������� ����������
    exceptionRec := getExceptionCase(
      stringNativeCase => stringNativeCasePart
      , sexCode => normalizedSexCode
      , typeExceptionCode => typeExceptionCode
    );


    strConvertInCase := ltrim(
      strConvertInCase
      || ' '
      || coalesce(
           case
             normalizedCaseCode
           when
             Pkg_ConvertNameInCase.Genetive_CaseCode
           then
             exceptionRec.genetive_case_name
           when
             Pkg_ConvertNameInCase.Dative_CaseCode
           then
             exceptionRec.dative_case_name
           when
             Pkg_ConvertNameInCase.Accusative_CaseCode
           then
             exceptionRec.accusative_case_name
           when
             Pkg_ConvertNameInCase.Ablative_CaseCode
           then
             exceptionRec.ablative_case_name
           when
             Pkg_ConvertNameInCase.Preposition_CaseCode
           then
             exceptionRec.preposition_case_name
           end
           , convertInCase(
               nameText => stringNativeCasePart
               , typeExceptionCode => typeExceptionCode
               , caseCode => normalizedCaseCode
               , sexCode => normalizedsexCode
             )
         )
      -- ����, ����
      || case when
           typeExceptionCode = pkg_ConvertNameInCase.MiddleName_TypeExceptionCode
           and isOglyExists = 1
         then
           ' ����'
         when
           typeExceptionCode = pkg_ConvertNameInCase.MiddleName_TypeExceptionCode
           and isKyzyExists = 1
         then
           ' ����'
         end
    );

  end loop;

  return initCap( trim( strConvertInCase ) );

exception
  when UncorrectFormat then
    return normalizedStringNativeCase;
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '�� ����� �������������� ��� � ���������� ������ ��������� ������ ('
        || 'nameText="' || nameText || '"'
        || ', formatString="' || formatString || '"'
        || ', caseCode="' || caseCode || '"'
        || ', sexCode="' || sexCode || '"'
        || '):'
        || sqlerrm
        || '.'
      , true
    );
end convertNameInCase;

end pkg_ConvertNameInCase;
/
