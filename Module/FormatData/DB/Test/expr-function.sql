-- script: Test/expr-function.sql
-- ���� �������, ������������ ��������� ��� ������������� SQL ( ������� *Expr
-- ������ <pkg_FormatData>).
-- ������� ���������� ����������� � ��������� �������� ��������, ���������� ��
-- ������ �������� ��������.
--
-- ���������:
-- funcName                   - ��� ������� ( ��������, "getBaseFirstNameExpr")
-- inData                     - ������� �������� ��� ����
-- addonParamList             - ������ �������� ��� �������������� ����������
--                              ������� ( ��������, ", 1" �������� 1 � ��������
--                              ������� ���������)

define funcName = "&1"
define inData   = "&2"
define addonParamList = "&3"

@reconn

var exprText varchar2(4000)

begin
  :exprText := replace(
    pkg_FormatData.&funcName( 't.data_field'&addonParamList)
    , chr(9), ' '                       -- ��������� �������� ������������
                                        -- ����������� � �������
  );
end;
/

print exprText

declare
  outData varchar2( 240);
begin
  execute immediate '
select
  ' || pkg_FormatData.&funcName( 't.data_field'&addonParamList) || ' as out_data
from
  (
  select
    ''&inData'' as data_field
  from
    dual
  ) t
'
  into
    outData
  ;
  dbms_output.put_line( 'out: ' || outData);
end;
/

undefine funcName
undefine inData
undefine addonParamList
