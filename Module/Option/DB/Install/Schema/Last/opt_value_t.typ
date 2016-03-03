create or replace type
  opt_value_t
as object
(
/* db object type: opt_value_t
  Значение настроечного параметра.
  Набор отличается от полей представления <v_opt_value> добавлением
  поля <encrypted_string_value> ( при этом значение в поле <string_value>
  всегда указывается в незашифрованном виде).

  SVN root: Oracle/Module/Option
*/



/* group: Открытые объявления */

/* var: value_id
  Id значения
*/
value_id                          integer,

/* var: option_id
  Id параметра
*/
option_id                         integer,

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

/* var: value_type_code
  Код типа значения параметра
*/
value_type_code                   varchar2(10),

/* var: value_list_flag
  Флаг задания для параметра списка значений указанного типа ( 1 да, 0 нет)
*/
value_list_flag                   number(1),

/* var: list_separator
  Символ, используемый в качестве разделителя в списке значений, сохраненном в поле string_value ( null если список не используется)
*/
list_separator                    varchar2(1),

/* var: encryption_flag
  Флаг хранения значений параметра в зашифрованном виде ( возможно только для значений строкового типа) ( 1 да, 0 нет)
*/
encryption_flag                   number(1),

/* var: storage_value_type_code
  Код типа, используемого для хранения значения параметра ( отличается от типа значения параметра в случае использования списка значений, т.к. список хранится в виде строки)
*/
storage_value_type_code           varchar2(10),

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

/* var: change_number
  Порядковый номер изменения записи ( начиная с 1)
*/
change_number                     number,

/* var: change_date
  Дата изменения записи
*/
change_date                       date,

/* var: change_operator_id
  Id оператора, изменившего запись
*/
change_operator_id                number,

/* var: date_ins
  Дата добавления записи
*/
date_ins                          date,

/* var: operator_id
  Id оператора, добавившего запись
*/
operator_id                       number

)
/
