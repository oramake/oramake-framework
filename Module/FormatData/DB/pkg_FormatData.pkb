create or replace package body pkg_FormatData is
/* package body: pkg_FormatData::body */



/* group: ���� */

/* itype: TColAlias
  ��� ��� ���� ���������.
*/
type TColAlias is table of fd_alias.base_name%type index by varchar2(60);

/* group: ��������� */

/* iconst: Latin_SimilarChar
  ������ �������� ��������, ������� �� ��������� �� ������� ���������.
*/
Latin_SimilarChar constant varchar2(30) := 'AaBCcEeKMHOoPpTXxYy';

/* iconst: Cyrillic_SimilarChar
  ������ �������� ���������, ������� �� ��������� �� ������� ��������.
*/
Cyrillic_SimilarChar constant varchar2(30) := '�������������������';

/* iconst: Code_TrimChar
  �������, ��������� � ������� ������� ��� ������������ ����.
*/
Code_TrimChar constant varchar2(30) := '.,_=';

/* iconst: Code_DelChar
  ������ ��������, ��������� ��� ������������ ����.
*/
Code_DelChar constant varchar2(30) := '- ' || chr(9);

/* iconst: Code_InChar
  ������ �������� �������� ��� ������������ ����.
*/
Code_InChar constant varchar2(30) := '0' || Code_DelChar;

/* iconst: Code_OutChar
  ������ �������������� �������� ��� ������������ ����.
*/
Code_OutChar constant varchar2(30) := '0';

/* iconst: BaseCode_DelChar
  ������ ��������, ��������� ��� ��������� �������� �������� ����.
*/
BaseCode_DelChar constant varchar2(30) := Code_DelChar || '*';

/* iconst: BaseCode_InChar
  ������ �������� �������� ��� ��������� �������� �������� ����.
*/
BaseCode_InChar constant varchar2(30) :=
  '�����' || Cyrillic_SimilarChar || Code_DelChar || '*'
;

/* iconst: BaseCode_OutChar
  ������ �������������� �������� ��� ��������� �������� �������� ����.
*/
BaseCode_OutChar constant varchar2(30) :=
  'Ee3��' || Latin_SimilarChar
;

/* iconst: String_InChar
  ������ �������� �������� ��� ������������ ������.
*/
String_InChar constant varchar2(30) := chr(9);

/* iconst: String_OutChar
  ������ �������������� �������� ��� ������������ ������.
*/
String_OutChar constant varchar2(30) := ' ';

/* iconst: CyrillicString_InChar
  ������ �������� �������� ��� ������������ ������ � ����������.
*/
CyrillicString_InChar constant varchar2(30) := Latin_SimilarChar || '��';

/* iconst: CyrillicString_OutChar
  ������ �������������� �������� ��� ������������ ������ � ����������.
*/
CyrillicString_OutChar constant varchar2(30) := Cyrillic_SimilarChar || '��';

/* const: BaseName_InChar
  ������ �������� �������� ��� ��������� ������� ����� ��������.
*/
BaseName_InChar constant varchar2(30) := '��';

/* const: BaseName_OutChar
  ������ �������������� �������� ��� ��������� ������� ����� ��������.
*/
BaseName_OutChar constant varchar2(30) := '��';

/* iconst: BaseName_TrimChar
  �������, ��������� � ������� ������� ��� ��������� ������� ����� ��������.
*/
BaseName_TrimChar constant varchar2(30) := '.,_=' || pkg_FormatBase.Zero_Value;

/* iconst: UpperLatin_Char
  ������ � ������� ���������� �������� � ������� ��������.
*/
UpperLatin_Char constant varchar2(26) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

/* iconst: UpperLatin_CharLength
  ����� ������ � ������� ���������� �������� � ������� ��������
  <UpperLatin_Char>.
*/
UpperLatin_CharLength constant pls_integer := 26;

/* iconst: UpperCyrillic_Char
  ������ � ������� �������������� �������� � ������� ��������.
*/
UpperCyrillic_Char constant varchar2(33) := '�����Ũ��������������������������';

/* iconst: UpperCyrillic_CharLength
  ����� ������ � ������� �������������� �������� � ������� ��������
  <UpperCyrillic_Char>.
*/
UpperCyrillic_CharLength constant pls_integer := 33;

/* iconst: Vin_Char
  ������ � ���������, ����������� � VIN ( ����������������� ������ ����������).
*/
Vin_Char constant varchar2(50) := '0123456789ABCDEFGHJKLMNPRSTUVWXYZ';

/* iconst: Vin_Length
  ����� ����������� VIN ( ������������������ ������ ����������).
*/
Vin_Length constant pls_integer := 17;



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_FormatBase.Module_Name
  , objectName  => 'pkg_FormatData'
);

/* ivar: colAlias
  ��� ���������.
*/
colAlias TColAlias;



/* group: ������� */

/* func: getZeroValue
  ���������� ������, ������������ ���������� ��������.

  �������: �������� ��������� <pkg_FormatBase.Zero_Value>.
*/
function getZeroValue
return varchar2
is
begin
  return pkg_FormatBase.Zero_Value;
end getZeroValue;



/* group: �������������� */

/* func: formatCode
  ���������� ��������������� ���.

  ������������:
  - ��������� ������� �������, ��������� � ����;
  - ���������� ��� �������/����������� ������� �����, �������, �������������;
  - ���� ������� ����� ���� ( newLength), �� �������� ���������� �� ������
    ����� ��� ����������� �������� ������;

  ���������:
  sourceCode                  - �������� ���
  newLength                   - ��������� ����� ����

  �������:
  - ��������������� ���
*/
function formatCode(
  sourceCode varchar2
  , newLength integer := null
)
return varchar2
is



  function formatCodeString(
    sourceCode varchar2
  )
  return varchar2
  is
  begin
    return
      rtrim(
        ltrim(
          translate( sourceCode, Code_InChar, Code_OutChar)
          , Code_TrimChar
        )
        , Code_TrimChar
      )
    ;
  end formatCodeString;



--formatCode
begin
  return
    case when newLength is null then
      formatCodeString( sourceCode)
    else
      lpad(
        formatCodeString( sourceCode)
        , newLength
        , '0'
      )
    end
  ;
end formatCode;

/* func: formatCodeExpr
  ���������� ��������� ��� ������������ ����.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immediate), ������������ ��������� ����������� � �������
  <formatCode>.

  ���������:
  varName                     - ��� ���������� � �������� �����
  newLength                   - ��������� ����� ����

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������
*/
function formatCodeExpr(
  varName varchar2
  , newLength integer := null
)
return varchar2
is
--formatCodeExpr
begin
  return
    case when newLength is not null then
        'lpad( '
      end
    || 'rtrim( '
      || 'ltrim( '
        || 'translate( '
          || varName
          || ', ''' || Code_InChar || ''''
          || ', ''' || Code_OutChar || ''''
        || ')'
        || ', ''' || Code_TrimChar || ''''
      || ')'
      || ', ''' || Code_TrimChar || ''''
    || ')'
    || case when newLength is not null then
        ', ' || to_char( newLength) || ', ''0'')'
      end
  ;
end formatCodeExpr;

/* ifunc: formatString( INTERNAL)
  ���������� ��������������� ������.

  ������������ ����������� �������� �������� � ������� <formatString>.
  ����� ���� ��������� �������������� ���������� �������� � ������ ��������
  ��������������� ����������.

  ���������:
  sourceString                - �������� ������
  addonInChar                 - ������ �������� �������� ��� ��������������
                                ����������
  addonOutChar                - ������ �������������� �������� ���
                                �������������� ����������

  �������:
  - ��������������� ������
*/
function formatString(
  sourceString varchar2
  , addonInChar varchar2
  , addonOutChar varchar2
)
return varchar2
is

--formatString
begin
  return
    replace( replace( trim( translate(
      sourceString
      , String_InChar || addonInChar
      , String_OutChar || addonOutChar
    )), '   ', ' '), '  ', ' ')
  ;
end formatString;

/* ifunc: formatStringExpr( INTERNAL)
  ���������� ��������� ��� ������������ ������.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immeaidiate), ������������ ��������� ����������� � �������
  <formatString( INTERNAL)>.

  ���������:
  varName                     - ��� ���������� � �������� �������
  addonInChar                 - ������ �������� �������� ��� ��������������
                                ����������
  addonOutChar                - ������ �������������� �������� ���
                                �������������� ����������

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������
*/
function formatStringExpr(
  varName varchar2
  , addonInChar varchar2
  , addonOutChar varchar2
)
return varchar2
is
--formatStringExpr
begin
  return
    'replace( replace( trim( translate( '
    || varName
    || ', ''' || String_InChar || addonInChar || ''''
    || ', ''' || String_OutChar || addonOutChar || ''''
    || ')), ''   '', '' ''), ''  '', '' '')'
  ;
end formatStringExpr;

/* func: formatString
  ���������� ��������������� ������.

  ������������:
  - ������ ��������� ���������� �� ������;
  - ���������� ��������� � �������� �������;
  - ��������� ������ ������ �������� ( �� 2 �� 4) ������ ������ ���������� ��
    ���� ������;

  ���������:
  sourceString                - �������� ������

  �������:
  - ��������������� ������
*/
function formatString(
  sourceString varchar2
)
return varchar2
is

--formatString
begin
  return
    formatString(
      sourceString    => sourceString
      , addonInChar   => null
      , addonOutChar  => null
    )
  ;
end formatString;

/* func: formatStringExpr
  ���������� ��������� ��� ������������ ������.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immediate), ������������ ��������� ����������� � �������
  <formatString>.

  ���������:
  varName                     - ��� ���������� � �������� �������
                                �������������� ����������

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������
*/
function formatStringExpr(
  varName varchar2
)
return varchar2
is
--formatStringExpr
begin
  return
    formatStringExpr(
      varName         => varName
      , addonInChar   => null
      , addonOutChar  => null
    )
  ;
end formatStringExpr;

/* func: formatCyrillicString
  ���������� ��������������� ������ � ����������.

  ������������� � ������������, ����������� �������� <formatString>,
  ������������:
  - ������� ������� �� ��������� ��������� �������� �� �������������;
  - ������ ����� "�" �� ����� "�";

  ���������:
  sourceString                - �������� ������

  �������:
  - ��������������� ������
*/
function formatCyrillicString(
  sourceString varchar2
)
return varchar2
is

--formatCyrillicString
begin
  return
    formatString(
      sourceString    => sourceString
      , addonInChar   => CyrillicString_InChar
      , addonOutChar  => CyrillicString_OutChar
    )
  ;
end formatCyrillicString;

/* func: formatCyrillicStringExpr
  ���������� ��������� ��� ������������ ������ � ����������.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immediate), ������������ ��������� ����������� � �������
  <formatCyrillicString>.

  ���������:
  varName                     - ��� ���������� � �������� �������
                                �������������� ����������

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������
*/
function formatCyrillicStringExpr(
  varName varchar2
)
return varchar2
is
--formatCyrillicStringExpr
begin
  return
    formatStringExpr(
      varName         => varName
      , addonInChar   => CyrillicString_InChar
      , addonOutChar  => CyrillicString_OutChar
    )
  ;
end formatCyrillicStringExpr;

/* func: formatName
  ���������� ��������������� ��������.

  ������������� � ������������, ����������� �������� <formatCyrillicString>,
  ������������:
  - ��������� �������� �������� ( ������ ����� ����� ���������, ���������
    ��������);

  ���������:
  sourceString                - �������� ������ � ���������

  �������:
  - ��������������� ���
*/
function formatName(
  sourceString varchar2
)
return varchar2
is
--formatName
begin
  return
    initcap( formatCyrillicString( sourceString))
  ;
end formatName;

/* func: formatNameExpr
  ���������� ��������� ��� ������������ ��������.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immediate), ������������ ��������� ����������� � �������
  <formatName>.

  ���������:
  varName                     - ��� ���������� � �������� �������

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������
*/
function formatNameExpr(
  varName varchar2
)
return varchar2
is
--formatNameExpr
begin
  return
    'initcap( ' || formatCyrillicStringExpr( varName) || ')'
  ;
end formatNameExpr;



/* group: ������� ����� */

/* ifunc: findBaseName
  ���� ������� �������� �� ��������.
  �������� ������� �� ������� <fd_alias> ( ���������� ��� ������ ���������).

  ���������:
  aliasName                   - �������
  aliasTypeCode               - ��� ���� ��������

  �������:
  - ������� �������� ��� null, ���� �� �������

  ���������:
  - ��� ���������� ������ aliasName ������ ������������ � ���������������
    ���� ( � ������� ����������� ���� alias_name � ������� <fd_alias>);
*/
function findBaseName(
  aliasName varchar2
  , aliasTypeCode varchar2
)
return varchar2
is



  function getKey(
    aliasTypeCode varchar2
    , aliasName varchar2
  )
  return varchar2
  is
  --���������� ���� ������ � ���� ���������.
  begin
    return aliasTypeCode || ':' || aliasName;
  end getKey;



  procedure LoadAlias
  is
  --��������� �������� � ���.

    cursor curAliasData is
      select
        a.alias_type_code
        , a.alias_name
        , a.base_name
      from
        fd_alias a
    ;

    type TColAliasData is table of curAliasData%rowtype;
    colAliasData TColAliasData;

  --LoadAlias
  begin
    open curAliasData;
    fetch curAliasData bulk collect into colAliasData;
    close curAliasData;
    if colAliasData.count > 0 then
      for i in colAliasData.first .. colAliasData.last loop
        colAlias( getKey(
              aliasTypeCode => colAliasData( i).alias_type_code
              , aliasName => colAliasData( i).alias_name
            )
          )
          := colAliasData( i).base_name
        ;
      end loop;
    end if;
  end LoadAlias;



--findBaseName
begin
                                        --��������� �������� � ��� ���� ������
  if colAlias.count = 0 then
    LoadAlias;
  end if;
                                        --����� � ������ ��������
  if aliasName is not null
      and colAlias.exists( getKey( aliasTypeCode, aliasName))
      then
    return colAlias( getKey( aliasTypeCode, aliasName));
  else
    return null;
  end if;
end findBaseName;

/* ifunc: findBaseNameExpr
  ���������� ��������� ��� ��������� �������� �������� ����.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immediate), ��������� ���������� ����������� � �������
  <findBaseName>.

  ���������:
  varName                     - ��� ���������� � �������� ���������
  aliasTypeCode               - ��� ���� ��������

  �������:
  - ������ � SQL-���������� ��� ���������� varName

  ���������:
  - ��� ���������� ������ �������� � varName ������ ���� � ���������������
    ���� ( � ������� ����������� ���� alias_name � ������� <fd_alias>);
*/
function findBaseNameExpr(
  varName varchar2
  , aliasTypeCode varchar2
)
return varchar2
is
--findBaseNameExpr
begin
  return
    '( select al.base_name from '
      || case aliasTypeCode
          when pkg_FormatBase.FirstName_AliasTypeCode then
            'v_fd_first_name_alias'
          when pkg_FormatBase.MiddleName_AliasTypeCode then
            'v_fd_middle_name_alias'
          when pkg_FormatBase.NoValue_AliasTypeCode then
            'v_fd_no_value_alias'
        end
      || ' al'
    || ' where al.alias_name=' || varName
    || ')'
  ;
end findBaseNameExpr;

/* ifunc: replaceAlias
  �������� ������� �� ������� ��������.
  �������� ������� �� ������� <fd_alias> ( ���������� ��� ������ ���������).

  ���������:
  nameString                  - ������ � ������
  aliasTypeCode               - ��� ���� ��������

  �������:
  - ������� ��������, ���� �������� ������ �������� ���������, ����� ��������
    ������ ��� ���������;

  ���������:
  - ��� ���������� ������ nameString ������ ������������ � ���������������
    ���� ( � ������� ����������� ���� alias_name � ������� <fd_alias>);
*/
function replaceAlias(
  nameString varchar2
  , aliasTypeCode varchar2
)
return varchar2
is
begin
  return
    coalesce(
      findBaseName( nameString, aliasTypeCode)
      , nameString
    )
  ;
end replaceAlias;

/* ifunc: replaceAliasExpr
  ���������� ��������� ��� ������ �������� �� ������� ��������.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immediate), ��������� ���������� ����������� � �������
  <replaceAlias>.

  ���������:
  varName                     - ��� ���������� � �������� ���������
  aliasTypeCode               - ��� ���� ��������

  �������:
  - ������ � SQL-���������� ��� ���������� varName

  ���������:
  - ��� ���������� ������ �������� � varName ������ ���� � ���������������
    ���� ( � ������� ����������� ���� alias_name � ������� <fd_alias>);
*/
function replaceAliasExpr(
  varName varchar2
  , aliasTypeCode varchar2
)
return varchar2
is
--replaceAliasExpr
begin
  return
    'coalesce( '
      || findBaseNameExpr( varName, aliasTypeCode)
      || ', ' || varName
    || ')'
  ;
end replaceAliasExpr;

/* func: getBaseCode
  ���������� ������� �������� ����.

  ������������:
  - ��������� ������� �������, ���������, ����, ��������� ( "*");
  - ����������� �������������� ������ �� ��������� �������� ��������� �
    ��������;
  - ����� "�" ���������� �� ����� 3, ����� "��" �� "��";
  - ���������� ��� �������/����������� ������� �����, �������, �������������,
    ���������;
  - ������� ����������� � ������� �������;
  - ����������� ������ �������� "-", � ����� ��������� �������������� ��������
    �� <fd_alias>, �� null;
  - ���� ����� minLength � ����� ���� ������ minLength, �� �� ���������
    ������������ � ��������������� �������� null;

  ���������:
  sourceCode                  - �������� ���
  minLength                   - ����������� ����� ���� ( ���� ����� ���� ������,
                                �� �� ��������� ������������ � ���������� ��
                                null, �� ��������� ��� �����������)

  �������:
  - ������� �������� ����
*/
function getBaseCode(
  sourceCode varchar2
  , minLength integer := null
)
return varchar2
is

--getBaseCode
begin
  return
    case when minLength > 1
      and length(
          rtrim(
            ltrim(
              translate(
                sourceCode
                , BaseCode_InChar
                , BaseCode_OutChar
              )
              , Code_TrimChar
            )
            , Code_TrimChar
          )
        ) < minLength
    then
      null
    else
      nullif(
        upper(
          rtrim(
            ltrim(
              translate(
                coalesce(
                  findBaseName(
                    formatName( sourceCode)
                    , pkg_FormatBase.NoValue_AliasTypeCode
                  )
                  , sourceCode
                )
                , BaseCode_InChar
                , BaseCode_OutChar
              )
              , Code_TrimChar
            )
            , Code_TrimChar
          )
        )
        , pkg_FormatBase.Zero_Value
      )
    end
  ;
end getBaseCode;

/* func: getBaseCodeExpr
  ���������� ��������� ��� ��������� �������� �������� ����.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immediate), ������������ ���������� ����������� � �������
  <getBaseCode>.

  ���������:
  varName                     - ��� ���������� � �������� �����
  minLength                   - ����������� ����� ���� ( ���� ����� ���� ������,
                                �� �� ��������� ������������ � ���������� ��
                                null, �� ��������� ��� �����������)

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������
*/
function getBaseCodeExpr(
  varName varchar2
  , minLength integer := null
)
return varchar2
is
--getBaseCodeExpr
begin
  return
    case when minLength > 1 then
      'case when length( '
          || 'rtrim( '
            || 'ltrim( '
              || 'translate( '
                || varName
                || ', ''' || BaseCode_InChar || ''''
                || ', ''' || BaseCode_OutChar || ''''
              || ')'
              || ', ''' || Code_TrimChar || ''''
            || ')'
            || ', ''' || Code_TrimChar || ''''
          || ')'
        || ') < ' || to_char( minLength)
      || ' then null else '
    end
    || 'nullif( '
        || 'upper( '
          || 'rtrim( '
            || 'ltrim( '
              || 'translate( '
                || 'coalesce( '
                  || findBaseNameExpr(
                      formatNameExpr( varName)
                      , pkg_FormatBase.NoValue_AliasTypeCode
                    )
                  || ', ' || varName
                || ')'
                || ', ''' || BaseCode_InChar || ''''
                || ', ''' || BaseCode_OutChar || ''''
              || ')'
              || ', ''' || Code_TrimChar || ''''
            || ')'
            || ', ''' || Code_TrimChar || ''''
          || ')'
        || ')'
      || ', ''' || pkg_FormatBase.Zero_Value || ''''
      || ')'
    || case when minLength > 1 then
      ' end'
      end
  ;
end getBaseCodeExpr;

/* func: getBaseName
  ���������� ������� ����� �������� ��� ������������� ��� ���������.

  ������������� � ���������������, ����������� �������� <formatName>,
  ������������:
  - ������ ��������� �������������� �������� �� <fd_alias>, �� null;
  - ������ ����� "�" �� "�";
  - ���������� ��� �������/����������� ������� �����, �������, �������������,
    ���������, ����;

  ���������:
  sourceName                  - �������� ������ � ���������

  �������:
  - ������� ����� ��������
*/
function getBaseName(
  sourceName varchar2
)
return varchar2
is
begin
                                        --Zero_Value ������������� � null ��
                                        --���� ��������� BaseName_TrimChar,
                                        --� ������� ��� ��������
  return
    rtrim(
      ltrim(
        translate(
          replaceAlias(
            formatName( sourceName)
            , pkg_FormatBase.NoValue_AliasTypeCode
          )
          , BaseName_InChar
          , BaseName_OutChar
        )
        , BaseName_TrimChar
      )
      , BaseName_TrimChar
    )
  ;
end getBaseName;

/* func: getBaseNameExpr
  ���������� ��������� ��� ��������� �������� �������� ��������.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immediate), ������������ ���������� ����������� � �������
  <getBaseName>.

  ���������:
  varName                     - ��� ���������� � �������� ���������

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������
*/
function getBaseNameExpr(
  varName varchar2
)
return varchar2
is
--getBaseStringExpr
begin
  return
       'rtrim( '
      || 'ltrim( '
        || 'translate( '
          || replaceAliasExpr(
              formatNameExpr( varName)
              , pkg_FormatBase.NoValue_AliasTypeCode
            )
          || ', ''' || BaseName_InChar || ''''
          || ', ''' || BaseName_OutChar || ''''
        || ')'
        || ', ''' || BaseName_TrimChar || ''''
      || ')'
      || ', ''' || BaseName_TrimChar || ''''
    || ')'
  ;
end getBaseNameExpr;

/* func: getBaseLastName
  ���������� ������� ����� ������� ��� ������������� ��� ���������.

  ������������� � ���������������, ����������� �������� <formatName>,
  ������������ ������ ����� "�" �� "�".

  ���������:
  lastName                    - �������� ������ � ��������

  �������:
  - ������� ����� �������
*/
function getBaseLastName(
  lastName varchar2
)
return varchar2
is
--getBaseLastName
begin
  return
    translate(
      formatName( lastName)
      , BaseName_InChar
      , BaseName_OutChar
    )
  ;
end getBaseLastName;

/* func: getBaseLastNameExpr
  ���������� ��������� ��� ��������� �������� �������� �������.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immediate), ������������ ���������� ����������� � �������
  <getBaseLastName>.

  ���������:
  varName                     - ��� ���������� � �������� ���������

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������
*/
function getBaseLastNameExpr(
  varName varchar2
)
return varchar2
is
--getBaseLastNameExpr
begin
  return
    'translate( '
    || formatNameExpr( varName)
    || ', ''' || BaseName_InChar || ''''
    || ', ''' || BaseName_OutChar || ''''
    || ')'
  ;
end getBaseLastNameExpr;

/* func: getBaseFirstName
  ���������� ������� ����� ����� ��� ������������� ��� ���������.

  ���������� ������� <getBaseLastName> � �������������� ������� ��������� �����
  �� ������� �����.

  ���������:
  firstName                - �������� ������ � ������

  �������:
  - ������� ����� �����
*/
function getBaseFirstName(
  firstName varchar2
)
return varchar2
is
begin
  return
    translate(
      replaceAlias(
        formatName( firstName)
        , pkg_FormatBase.FirstName_AliasTypeCode
      )
      , BaseName_InChar
      , BaseName_OutChar
    )
  ;
end getBaseFirstName;

/* func: getBaseFirstNameExpr
  ���������� ��������� ��� ��������� �������� �������� �����.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immediate), ������������ ���������� ����������� � �������
  <getBaseFirstName>.

  ���������:
  varName                     - ��� ���������� � �������� ���������

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������
*/
function getBaseFirstNameExpr(
  varName varchar2
)
return varchar2
is
--getBaseFirstNameExpr
begin
  return
    'translate( '
      || replaceAliasExpr(
          formatNameExpr( varName)
          , pkg_FormatBase.FirstName_AliasTypeCode
        )
      || ', ''' || BaseName_InChar || ''''
      || ', ''' || BaseName_OutChar || ''''
    || ')'
  ;
end getBaseFirstNameExpr;

/* func: getBaseMiddleName
  ���������� ������� ����� �������� ��� ������������� ��� ���������.

  ���������� ������� <getBaseLastName> � �������������� ������� ���������
  �������� �� ������� ����� � �������� '-' ( <getZeroValue>) ������ null.

  ���������:
  middleName                  - �������� ������ � ���������

  �������:
  - ������� ����� ��������
*/
function getBaseMiddleName(
  middleName varchar2
)
return varchar2
is
begin
  return
    coalesce(
      translate(
        replaceAlias(
          formatName( middleName)
          , pkg_FormatBase.MiddleName_AliasTypeCode
        )
        , BaseName_InChar
        , BaseName_OutChar
      )
      , pkg_FormatBase.Zero_Value
    )
  ;
end getBaseMiddleName;

/* func: getBaseMiddleNameExpr
  ���������� ��������� ��� ��������� �������� �������� ��������.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immediate), ������������ ���������� ����������� � �������
  <getBaseMiddleName>.

  ���������:
  varName                     - ��� ���������� � �������� ���������

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������
*/
function getBaseMiddleNameExpr(
  varName varchar2
)
return varchar2
is
--getBaseMiddleNameExpr
begin
  return
    'coalesce( '
      || 'translate( '
        || replaceAliasExpr(
            formatNameExpr( varName)
            , pkg_FormatBase.MiddleName_AliasTypeCode
          )
        || ', ''' || BaseName_InChar || ''''
        || ', ''' || BaseName_OutChar || ''''
      || ')'
    || ', ''' || pkg_FormatBase.Zero_Value || ''''
    || ')'
  ;
end getBaseMiddleNameExpr;



/* group: �������� ������������ */

/* func: checkDrivingLicense
  ��������� ������������ ������ ������������� �������������.

  ������� ������������: ������������� ������� "99��999999" ( ��� "9" �����
  ����� �� 0 �� 9, "�" ����� ������������� �����).

  ���������:
  sourceCode                  - ����� ��������� ( ��� ���������� ������� ������
                                ���� �������������� �������)

  �������:
  1     - ���������� �����
  0     - ������������ �����
  null  - �������� ����������� ( ���� � �������� ��������� ��� ������� null)
*/
function checkDrivingLicense(
  sourceCode varchar2
)
return integer
is
begin
  return
case
  when
      translate(
        upper( sourceCode)
        , '0123456789' || UpperCyrillic_Char
        , '9999999999' || rpad( '�', UpperCyrillic_CharLength, '�')
      )
      = '99��999999'
    then 1
  when
      sourceCode is not null
    then 0
end
  ;
end checkDrivingLicense;

/* func: checkDrivingLicenseExpr
  ���������� ��������� ��� �������� ������������ ������ �������������
  �������������, ��������� ���������� �������� ��������� ������ �������
  <checkDrivingLicense>.

  ���������:
  varName                     - ��� ���������� � ������� ���������

  �������:
  ������ � SQL-���������� ��� ���������� varName ��� ���������� ��������.
*/
function checkDrivingLicenseExpr(
  varName varchar2
)
return varchar2
is
begin
  return
    replace( replace( replace( replace( replace(
'case
  when
      translate(
        upper( sourceCode)
        , ''0123456789' || UpperCyrillic_Char || '''
        , ''9999999999' || rpad( '�', UpperCyrillic_CharLength, '�') || '''
      )
      = ''99��999999''
    then 1
  when
      sourceCode is not null
    then 0
end'
      -- ������� ������ �������, ����� ��������� �����
      , '     ', ' ')
      , '   '  , ' ')
      , '  '   , ' ')
      , chr(10) || ' ' , chr(10))
      -- ����������� ��� ���������
      ,  'sourceCode', varName)
  ;
end checkDrivingLicenseExpr;

/* func: checkForeignPassport
  ��������� ������������ ������ ������������ ��������.

  ������� ������������: ������������� ������� "999999999" ( ������ ���� ��
  0 �� 9).

  ���������:
  sourceCode                  - ����� ��������� ( ��� ���������� ������� ������
                                ���� �������������� �������)

  �������:
  1     - ���������� �����
  0     - ������������ �����
  null  - �������� ����������� ( ���� � �������� ��������� ��� ������� null)
*/
function checkForeignPassport(
  sourceCode varchar2
)
return integer
is
begin
  return
case
  when
      translate(
        sourceCode
        , '0123456789'
        , '9999999999'
      )
      = '999999999'
    then 1
  when
      sourceCode is not null
    then 0
end
  ;
end checkForeignPassport;

/* func: checkForeignPassportExpr
  ���������� ��������� ��� �������� ������������ ������ ������������ ��������,
  ��������� ���������� �������� ��������� ������ �������
  <checkForeignPassport>.

  ���������:
  varName                     - ��� ���������� � ������� ���������

  �������:
  ������ � SQL-���������� ��� ���������� varName ��� ���������� ��������.
*/
function checkForeignPassportExpr(
  varName varchar2
)
return varchar2
is
begin
  return
    replace( replace( replace( replace( replace(
'case
  when
      translate(
        sourceCode
        , ''0123456789''
        , ''9999999999''
      )
      = ''999999999''
    then 1
  when
      sourceCode is not null
    then 0
end'
      -- ������� ������ �������, ����� ��������� �����
      , '     ', ' ')
      , '   '  , ' ')
      , '  '   , ' ')
      , chr(10) || ' ' , chr(10))
      -- ����������� ��� ���������
      ,  'sourceCode', varName)
  ;
end checkForeignPassportExpr;

/* func: checkInn
  ��������� ������������ ��� ( ������������������ ������ �����������������)
  � ������� �������� ����������� ���� ������.

  ���������:
  sourceCode                  - ��� ( ��� ���������� ������� ������ ����
                                �������������� �������)

  �������:
  1     - ���������� �����
  0     - ������������ �����
  null  - �������� ����������� ( ���� � �������� ��������� ��� ������� null)
*/
function checkInn(
  sourceCode varchar2
)
return integer
is
begin
  return
case
  when
    translate( sourceCode, '.0123456789', '.') is null
    and (
      length( sourceCode) = 12
        and mod( mod(
              to_number( substr( sourceCode, 1, 1)) *  7
            + to_number( substr( sourceCode, 2, 1)) *  2
            + to_number( substr( sourceCode, 3, 1)) *  4
            + to_number( substr( sourceCode, 4, 1)) * 10
            + to_number( substr( sourceCode, 5, 1)) *  3
            + to_number( substr( sourceCode, 6, 1)) *  5
            + to_number( substr( sourceCode, 7, 1)) *  9
            + to_number( substr( sourceCode, 8, 1)) *  4
            + to_number( substr( sourceCode, 9, 1)) *  6
            + to_number( substr( sourceCode,10, 1)) *  8
            , 11), 10)
          = to_number( substr( sourceCode, 11, 1))
        and mod( mod(
              to_number( substr( sourceCode, 1, 1)) *  3
            + to_number( substr( sourceCode, 2, 1)) *  7
            + to_number( substr( sourceCode, 3, 1)) *  2
            + to_number( substr( sourceCode, 4, 1)) *  4
            + to_number( substr( sourceCode, 5, 1)) * 10
            + to_number( substr( sourceCode, 6, 1)) *  3
            + to_number( substr( sourceCode, 7, 1)) *  5
            + to_number( substr( sourceCode, 8, 1)) *  9
            + to_number( substr( sourceCode, 9, 1)) *  4
            + to_number( substr( sourceCode,10, 1)) *  6
            + to_number( substr( sourceCode,11, 1)) *  8
            , 11), 10)
          = to_number( substr( sourceCode, 12, 1))
      or length( sourceCode) = 10
        and mod( mod(
              to_number( substr( sourceCode, 1, 1)) *  2
            + to_number( substr( sourceCode, 2, 1)) *  4
            + to_number( substr( sourceCode, 3, 1)) * 10
            + to_number( substr( sourceCode, 4, 1)) *  3
            + to_number( substr( sourceCode, 5, 1)) *  5
            + to_number( substr( sourceCode, 6, 1)) *  9
            + to_number( substr( sourceCode, 7, 1)) *  4
            + to_number( substr( sourceCode, 8, 1)) *  6
            + to_number( substr( sourceCode, 9, 1)) *  8
            , 11), 10)
          = to_number( substr( sourceCode, 10, 1))
      )
    then 1
  when
    sourceCode is not null
    then 0
end
  ;
end checkInn;

/* func: checkInnExpr
  ���������� ��������� ��� �������� ������������ ��� ( ������������������
  ������ �����������������), ��������� ���������� �������� ��������� ������
  ������� <checkInn>.

  ���������:
  varName                     - ��� ���������� �� ��������� ���

  �������:
  ������ � SQL-���������� ��� ���������� varName ��� ���������� ��������
*/
function checkInnExpr(
  varName varchar2
)
return varchar2
is
begin
  return
    replace( replace( replace( replace( replace(
'case
  when
    translate( sourceCode, ''.0123456789'', ''.'') is null
    and (
      length( sourceCode) = 12
        and mod( mod(
              to_number( substr( sourceCode, 1, 1)) *  7
            + to_number( substr( sourceCode, 2, 1)) *  2
            + to_number( substr( sourceCode, 3, 1)) *  4
            + to_number( substr( sourceCode, 4, 1)) * 10
            + to_number( substr( sourceCode, 5, 1)) *  3
            + to_number( substr( sourceCode, 6, 1)) *  5
            + to_number( substr( sourceCode, 7, 1)) *  9
            + to_number( substr( sourceCode, 8, 1)) *  4
            + to_number( substr( sourceCode, 9, 1)) *  6
            + to_number( substr( sourceCode,10, 1)) *  8
            , 11), 10)
          = to_number( substr( sourceCode, 11, 1))
        and mod( mod(
              to_number( substr( sourceCode, 1, 1)) *  3
            + to_number( substr( sourceCode, 2, 1)) *  7
            + to_number( substr( sourceCode, 3, 1)) *  2
            + to_number( substr( sourceCode, 4, 1)) *  4
            + to_number( substr( sourceCode, 5, 1)) * 10
            + to_number( substr( sourceCode, 6, 1)) *  3
            + to_number( substr( sourceCode, 7, 1)) *  5
            + to_number( substr( sourceCode, 8, 1)) *  9
            + to_number( substr( sourceCode, 9, 1)) *  4
            + to_number( substr( sourceCode,10, 1)) *  6
            + to_number( substr( sourceCode,11, 1)) *  8
            , 11), 10)
          = to_number( substr( sourceCode, 12, 1))
      or length( sourceCode) = 10
        and mod( mod(
              to_number( substr( sourceCode, 1, 1)) *  2
            + to_number( substr( sourceCode, 2, 1)) *  4
            + to_number( substr( sourceCode, 3, 1)) * 10
            + to_number( substr( sourceCode, 4, 1)) *  3
            + to_number( substr( sourceCode, 5, 1)) *  5
            + to_number( substr( sourceCode, 6, 1)) *  9
            + to_number( substr( sourceCode, 7, 1)) *  4
            + to_number( substr( sourceCode, 8, 1)) *  6
            + to_number( substr( sourceCode, 9, 1)) *  8
            , 11), 10)
          = to_number( substr( sourceCode, 10, 1))
      )
    then 1
  when
    sourceCode is not null
    then 0
end'
      -- ������� ������ �������, ����� ��������� �����
      , '     ', ' ')
      , '   '  , ' ')
      , '  '   , ' ')
      , chr(10) || ' ' , chr(10))
      -- ����������� ��� ���������
      ,  'sourceCode', varName)
  ;
end checkInnExpr;

/* func: checkPensionFundNumber
  ��������� ������������ ������ ����������� ������������� � ������� ��������
  ����������� ���� ������.

  ���������:
  sourceCode                  - ������ ����������� ������������� ( ���
                                ���������� ������� ������ ���� ��������������
                                �������)

  �������:
  1     - ���������� �����
  0     - ������������ �����
  null  - �������� ����������� ( ���� � �������� ��������� ��� ������� null)
*/
function checkPensionFundNumber(
  sourceCode varchar2
)
return integer
is
begin
  return
case
  when
    length( sourceCode) = 11
    and translate( sourceCode, '.0123456789', '.') is null
    and mod( mod(
          to_number( substr( sourceCode, 1, 1)) * 9
        + to_number( substr( sourceCode, 2, 1)) * 8
        + to_number( substr( sourceCode, 3, 1)) * 7
        + to_number( substr( sourceCode, 4, 1)) * 6
        + to_number( substr( sourceCode, 5, 1)) * 5
        + to_number( substr( sourceCode, 6, 1)) * 4
        + to_number( substr( sourceCode, 7, 1)) * 3
        + to_number( substr( sourceCode, 8, 1)) * 2
        + to_number( substr( sourceCode, 9, 1)) * 1
        , 101), 100)
      = to_number( substr( sourceCode, 10, 2))
    then 1
  when
    sourceCode is not null
    then 0
end
  ;
end checkPensionFundNumber;

/* func: checkPensionFundNumberExpr
  ���������� ��������� ��� �������� ������������ ������ �����������
  �������������, ��������� ���������� �������� ��������� ������ �������
  <checkPensionFundNumber>.

  ���������:
  varName                     - ��� ���������� � ������� �����������
                                �������������

  �������:
  ������ � SQL-���������� ��� ���������� varName ��� ���������� ��������
*/
function checkPensionFundNumberExpr(
  varName varchar2
)
return varchar2
is
begin
  return
    replace( replace( replace( replace( replace(
'case
  when
    length( sourceCode) = 11
    and translate( sourceCode, ''.0123456789'', ''.'') is null
    and mod( mod(
          to_number( substr( sourceCode, 1, 1)) * 9
        + to_number( substr( sourceCode, 2, 1)) * 8
        + to_number( substr( sourceCode, 3, 1)) * 7
        + to_number( substr( sourceCode, 4, 1)) * 6
        + to_number( substr( sourceCode, 5, 1)) * 5
        + to_number( substr( sourceCode, 6, 1)) * 4
        + to_number( substr( sourceCode, 7, 1)) * 3
        + to_number( substr( sourceCode, 8, 1)) * 2
        + to_number( substr( sourceCode, 9, 1)) * 1
        , 101), 100)
      = to_number( substr( sourceCode, 10, 2))
    then 1
  when
    sourceCode is not null
    then 0
end'
      -- ������� ������ �������, ����� ��������� �����
      , '     ', ' ')
      , '   '  , ' ')
      , '  '   , ' ')
      , chr(10) || ' ' , chr(10))
      -- ����������� ��� ���������
      ,  'sourceCode', varName)
  ;
end checkPensionFundNumberExpr;

/* func: checkPts
  ��������� ������������ ����� � ������ ��� ( �������� ������������� ��������).

  ������� ������������: ������������� ������� "99CC999999" ( ��� "9" �����
  ����� �� 0 �� 9, "C" ����� ����� ( �� ��������� ������ ���������, ��.
  ��������� ����)).

  ���������:
  sourceCode                  - ����� � ����� ��������� ( ��� ����������
                                ������� ������ ���� �������������� �������)
  isUseCyrillic               - � ������� � �������� "�" ����� ��������������
                                ���������
                                ( 1 �� ( �� ���������), 0 ���)
  isUseLatin                  - � ������� � �������� "�" ����� ��������������
                                ��������
                                ( 1 ��, 0 ��� ( �� ���������))

  �������:
  1     - ���������� ��������
  0     - ������������ ��������
  null  - �������� ����������� ( ���� � �������� ��������� ��� ������� null)
*/
function checkPts(
  sourceCode varchar2
  , isUseCyrillic integer := null
  , isUseLatin integer := null
)
return integer
is

  -- ��������� ���������� ���������� ��������
  inChar varchar2(100);
  outChar varchar2(100);
  charPattern varchar2(10);

begin

  if coalesce( isUseCyrillic != 0, true) then
    charPattern := '��';
    inChar := UpperCyrillic_Char;
    outChar := rpad( charPattern, UpperCyrillic_CharLength, charPattern);
  end if;

  if isUseLatin = 1 then
    if charPattern is null then
      charPattern := 'ZZ';
    end if;
    inChar := inChar || UpperLatin_Char;
    outChar :=
      outChar || rpad( charPattern, UpperLatin_CharLength, charPattern)
    ;
  end if;

  if charPattern is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�� ������ ���������� ������� ��� ����.'
    );
  end if;

  return
case
  when
      translate(
        upper( sourceCode)
        , '0123456789' || inChar
        , '9999999999' || outChar
      )
      = '99' || charPattern || '999999'
    then 1
  when
      sourceCode is not null
    then 0
end
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ����� � ������ ��� ('
        || ' sourceCode="' || sourceCode || '"'
        || ', isUseCyrillic=' || isUseCyrillic
        || ', isUseLatin=' || isUseLatin
        || ').'
      )
    , true
  );
end checkPts;

/* func: checkPtsExpr
  ���������� ��������� ��� �������� ������������ ����� � ������ ���
  ( �������� ������������� ��������), ��������� ���������� �������� ���������
  ������ ������� <checkPts>.

  ���������:
  varName                     - ��� ���������� � ������� ���������
  isUseCyrillic               - � ������� � �������� "�" ����� ��������������
                                ���������
                                ( 1 �� ( �� ���������), 0 ���)
  isUseLatin                  - � ������� � �������� "�" ����� ��������������
                                ��������
                                ( 1 ��, 0 ��� ( �� ���������))

  �������:
  ������ � SQL-���������� ��� ���������� varName ��� ���������� ��������.
*/
function checkPtsExpr(
  varName varchar2
  , isUseCyrillic integer := null
  , isUseLatin integer := null
)
return varchar2
is

  -- ��������� ���������� ���������� ��������
  inChar varchar2(100);
  outChar varchar2(100);
  charPattern varchar2(10);

begin

  if coalesce( isUseCyrillic != 0, true) then
    charPattern := '��';
    inChar := UpperCyrillic_Char;
    outChar := rpad( charPattern, UpperCyrillic_CharLength, charPattern);
  end if;

  if isUseLatin = 1 then
    if charPattern is null then
      charPattern := 'ZZ';
    end if;
    inChar := inChar || UpperLatin_Char;
    outChar :=
      outChar || rpad( charPattern, UpperLatin_CharLength, charPattern)
    ;
  end if;

  if charPattern is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�� ������ ���������� ������� ��� ����.'
    );
  end if;

  return
    replace( replace( replace( replace( replace(
'case
  when
      translate(
        upper( sourceCode)
        , ''0123456789' || inChar || '''
        , ''9999999999' || outChar || '''
      )
      = ''99' || charPattern || '999999''
    then 1
  when
      sourceCode is not null
    then 0
end'
      -- ������� ������ �������, ����� ��������� �����
      , '     ', ' ')
      , '   '  , ' ')
      , '  '   , ' ')
      , chr(10) || ' ' , chr(10))
      -- ����������� ��� ���������
      ,  'sourceCode', varName)
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ��������� ��� �������� ����� � ������ ��� ('
        || ' varName="' || varName || '"'
        || ', isUseCyrillic=' || isUseCyrillic
        || ', isUseLatin=' || isUseLatin
        || ').'
      )
    , true
  );
end checkPtsExpr;

/* func: checkVin
  ��������� ������������ VIN ( ������������������ ������ ����������).

  ������� ������������: ����� ����� 17 � ������������ ������ ���������� �������.

  ���������:
  sourceCode                  - VIN ( ��� ���������� ������� ������
                                ���� �������������� �������)

  �������:
  1     - ���������� �����
  0     - ������������ �����
  null  - �������� ����������� ( ���� � �������� ��������� ��� ������� null)
*/
function checkVin(
  sourceCode varchar2
)
return integer
is
begin
  return
case
  when
      length( sourceCode) = Vin_Length
      and translate(
          sourceCode
          , '.' || Vin_Char
          , '.'
        )
        is null
    then 1
  when
      sourceCode is not null
    then 0
end
  ;
end checkVin;

/* func: checkVinExpr
  ���������� ��������� ��� �������� ������������ VIN ( ������������������
  ������ ����������), ��������� ���������� �������� ��������� ������ �������
  <checkVin>.

  ���������:
  varName                     - ��� ���������� �� ��������� VIN

  �������:
  ������ � SQL-���������� ��� ���������� varName ��� ���������� ��������.
*/
function checkVinExpr(
  varName varchar2
)
return varchar2
is
begin
  return
    replace( replace( replace( replace( replace(
'case
  when
      length( sourceCode) = ' || Vin_Length || '
      and translate(
          sourceCode
          , ''.' || Vin_Char || '''
          , ''.''
        )
        is null
    then 1
  when
      sourceCode is not null
    then 0
end'
      -- ������� ������ �������, ����� ��������� �����
      , '     ', ' ')
      , '   '  , ' ')
      , '  '   , ' ')
      , chr(10) || ' ' , chr(10))
      -- ����������� ��� ���������
      ,  'sourceCode', varName)
  ;
end checkVinExpr;

end pkg_FormatData;
/
