create or replace type
  opt_option_value_t
as object
(
/* db object type: opt_option_value_t
  Настроечный параметр с текущим используемым значением.
  Набор отличается от полей представления <v_opt_option_value> добавлением
  поля <encrypted_string_value> ( при этом значение в поле <string_value>
  всегда указывается в незашифрованном виде).

  SVN root: Oracle/Module/Option
*/



/* group: Открытые объявления */

/* var: option_id
  Id параметра
*/
option_id                         integer,

/* var: value_id
  Id значения ( null при отсутствии подходящего значения)
*/
value_id                          integer,

/* var: module_name
  Название модуля, к которому относится параметр
*/
module_name                       varchar2(100),

/* var: object_short_name
  Короткое название объекта модуля ( уникальное в рамках модуля), к которому относится параметр ( null если не требуется разделения параметров по объектам либо параметр относится ко всему модулю)
*/
object_short_name                 varchar2(100),

/* var: object_type_short_name
  Короткое название типа объекта
*/
object_type_short_name            varchar2(50),

/* var: option_short_name
  Короткое название параметра ( уникальное в рамках модуля либо в рамках объекта модуля, если заполнено поле object_short_name)
*/
option_short_name                 varchar2(50),

/* var: value_type_code
  Код типа значения параметра
*/
value_type_code                   varchar2(10),

/* var: date_value
  Значение параметра типа дата
*/
date_value                        date,

/* var: number_value
  Числовое значение параметра
*/
number_value                      number,

/* var: string_value
  Строковое значение параметра ( если не задано значение в поле list_separator) либо список значений с разделителем, указанным в поле list_separator ( если оно задано). Значения параметра строкового типа хранятся в списке без изменений, значения типа дата хранятся в формате "yyyy-mm-dd hh24:mi:ss", числа хранятся в формате "tm9" с десятичным разделителем точка. В данном поле значение всегда указывается в незашифрованном виде ( если значение хранится в зашифрованном виде, то зашифрованное значение указывается в поле encrypted_string_value).
*/
string_value                      varchar2(4000),

/* var: encrypted_string_value
  Строковое значение параметра либо список значений с разделителем в зашифрованном виде ( null если значение параметра не хранится в зашифрованном виде)
*/
encrypted_string_value            varchar2(4000),

/* var: list_separator
  Символ, используемый в качестве разделителя в списке значений, сохраненном в поле string_value ( null если список не используется)
*/
list_separator                    varchar2(1),

/* var: value_list_flag
  Флаг задания для параметра списка значений указанного типа ( 1 да, 0 нет)
*/
value_list_flag                   number(1),

/* var: encryption_flag
  Флаг хранения значений параметра в зашифрованном виде ( возможно только для значений строкового типа) ( 1 да, 0 нет)
*/
encryption_flag                   number(1),

/* var: test_prod_sensitive_flag
  Флаг указания для значения параметра типа базы данных ( тестовая или промышленная), для которого оно предназначено ( 1 да, 0 нет)
*/
test_prod_sensitive_flag          number(1),

/* var: access_level_code
  Код уровня доступа к параметру через пользовательский интерфейс
*/
access_level_code                 varchar2(10),

/* var: option_name
  Название параметра
*/
option_name                       varchar2(250),

/* var: option_description
  Описание параметра
*/
option_description                varchar2(1000),

/* var: prod_value_flag
  Флаг использования значения только в промышленных ( либо тестовых) БД ( 1 только в промышленных БД, 0 только в тестовых БД, null без ограничений)
*/
prod_value_flag                   number,

/* var: instance_name
  Имя экземпляра БД, в которой может использоваться значение ( в верхнем регистре, null без ограничений)
*/
instance_name                     varchar2(30),

/* var: used_operator_id
  Id оператора, для которого может использоваться значение ( null без ограничений)
*/
used_operator_id                  integer,

/* var: module_id
  Id модуля, к которому относится параметр
*/
module_id                         integer,

/* var: module_svn_root
  Модуль: Путь к корневому каталогу модуля в Subversion ( начиная с имени репозитария, например: "Oracle/Module/ModuleInfo")
*/
module_svn_root                   varchar2(100),

/* var: object_type_id
  Id типа объекта
*/
object_type_id                    integer,

/* var: object_type_name
  Название типа объекта
*/
object_type_name                  varchar2(100),

/* var: object_type_module_id
  Модуль типа объекта: Id модуля
*/
object_type_module_id             integer,

/* var: object_type_module_name
  Модуль типа объекта: Название модуля
*/
object_type_module_name           varchar2(100),

/* var: object_type_module_svn_root
  Модуль типа объекта: Путь к корневому каталогу модуля в Subversion ( начиная с имени репозитария, например: "Oracle/Module/ModuleInfo")
*/
object_type_module_svn_root       varchar2(100),

/* var: option_change_number
  Параметр: Порядковый номер изменения записи ( начиная с 1)
*/
option_change_number              integer,

/* var: option_change_date
  Параметр: Дата изменения записи
*/
option_change_date                date,

/* var: option_change_operator_id
  Параметр: Id оператора, изменившего запись
*/
option_change_operator_id         integer,

/* var: option_date_ins
  Параметр: Дата добавления записи
*/
option_date_ins                   date,

/* var: option_operator_id
  Параметр: Id оператора, добавившего запись
*/
option_operator_id                integer,

/* var: value_change_number
  Значение: Порядковый номер изменения записи ( начиная с 1)
*/
value_change_number               number,

/* var: value_change_date
  Значение: Дата изменения записи
*/
value_change_date                 date,

/* var: value_change_operator_id
  Значение: Id оператора, изменившего запись
*/
value_change_operator_id          number,

/* var: value_date_ins
  Значение: Дата добавления записи
*/
value_date_ins                    date,

/* var: value_operator_id
  Значение: Id оператора, добавившего запись
*/
value_operator_id                 number

)
/
