-- script: Test/expr-function.sql
-- Тест функций, возвращающих выражения для динамического SQL ( функции *Expr
-- пакета <pkg_FormatData>).
-- Функция вызывается динамически и выводится выходное значение, полученное на
-- основе входного значения.
--
-- Параметры:
-- funcName                   - имя функции ( например, "getBaseFirstNameExpr")
-- inData                     - входное значение для поля
-- addonParamList             - список значений для дополнительных параметров
--                              функции ( например, ", 1" передает 1 в качестве
--                              второго параметра)

define funcName = "&1"
define inData   = "&2"
define addonParamList = "&3"

@reconn

var exprText varchar2(4000)

begin
  :exprText := replace(
    pkg_FormatData.&funcName( 't.data_field'&addonParamList)
    , chr(9), ' '                       -- табуляция вызывает некорректное
                                        -- отображение в консоли
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
