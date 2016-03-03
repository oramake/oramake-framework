create or replace type
  opt_option_value_t
as object
(
/* db object type: opt_option_value_t
  ����������� �������� � ������� ������������ ���������.
  ����� ���������� �� ����� ������������� <v_opt_option_value> �����������
  ���� <encrypted_string_value> ( ��� ���� �������� � ���� <string_value>
  ������ ����������� � ��������������� ����).

  SVN root: Oracle/Module/Option
*/



/* group: �������� ���������� */

/* var: option_id
  Id ���������
*/
option_id                         integer,

/* var: value_id
  Id �������� ( null ��� ���������� ����������� ��������)
*/
value_id                          integer,

/* var: module_name
  �������� ������, � �������� ��������� ��������
*/
module_name                       varchar2(100),

/* var: object_short_name
  �������� �������� ������� ������ ( ���������� � ������ ������), � �������� ��������� �������� ( null ���� �� ��������� ���������� ���������� �� �������� ���� �������� ��������� �� ����� ������)
*/
object_short_name                 varchar2(100),

/* var: object_type_short_name
  �������� �������� ���� �������
*/
object_type_short_name            varchar2(50),

/* var: option_short_name
  �������� �������� ��������� ( ���������� � ������ ������ ���� � ������ ������� ������, ���� ��������� ���� object_short_name)
*/
option_short_name                 varchar2(50),

/* var: value_type_code
  ��� ���� �������� ���������
*/
value_type_code                   varchar2(10),

/* var: date_value
  �������� ��������� ���� ����
*/
date_value                        date,

/* var: number_value
  �������� �������� ���������
*/
number_value                      number,

/* var: string_value
  ��������� �������� ��������� ( ���� �� ������ �������� � ���� list_separator) ���� ������ �������� � ������������, ��������� � ���� list_separator ( ���� ��� ������). �������� ��������� ���������� ���� �������� � ������ ��� ���������, �������� ���� ���� �������� � ������� "yyyy-mm-dd hh24:mi:ss", ����� �������� � ������� "tm9" � ���������� ������������ �����. � ������ ���� �������� ������ ����������� � ��������������� ���� ( ���� �������� �������� � ������������� ����, �� ������������� �������� ����������� � ���� encrypted_string_value).
*/
string_value                      varchar2(4000),

/* var: encrypted_string_value
  ��������� �������� ��������� ���� ������ �������� � ������������ � ������������� ���� ( null ���� �������� ��������� �� �������� � ������������� ����)
*/
encrypted_string_value            varchar2(4000),

/* var: list_separator
  ������, ������������ � �������� ����������� � ������ ��������, ����������� � ���� string_value ( null ���� ������ �� ������������)
*/
list_separator                    varchar2(1),

/* var: value_list_flag
  ���� ������� ��� ��������� ������ �������� ���������� ���� ( 1 ��, 0 ���)
*/
value_list_flag                   number(1),

/* var: encryption_flag
  ���� �������� �������� ��������� � ������������� ���� ( �������� ������ ��� �������� ���������� ����) ( 1 ��, 0 ���)
*/
encryption_flag                   number(1),

/* var: test_prod_sensitive_flag
  ���� �������� ��� �������� ��������� ���� ���� ������ ( �������� ��� ������������), ��� �������� ��� ������������� ( 1 ��, 0 ���)
*/
test_prod_sensitive_flag          number(1),

/* var: access_level_code
  ��� ������ ������� � ��������� ����� ���������������� ���������
*/
access_level_code                 varchar2(10),

/* var: option_name
  �������� ���������
*/
option_name                       varchar2(250),

/* var: option_description
  �������� ���������
*/
option_description                varchar2(1000),

/* var: prod_value_flag
  ���� ������������� �������� ������ � ������������ ( ���� ��������) �� ( 1 ������ � ������������ ��, 0 ������ � �������� ��, null ��� �����������)
*/
prod_value_flag                   number,

/* var: instance_name
  ��� ���������� ��, � ������� ����� �������������� �������� ( � ������� ��������, null ��� �����������)
*/
instance_name                     varchar2(30),

/* var: used_operator_id
  Id ���������, ��� �������� ����� �������������� �������� ( null ��� �����������)
*/
used_operator_id                  integer,

/* var: module_id
  Id ������, � �������� ��������� ��������
*/
module_id                         integer,

/* var: module_svn_root
  ������: ���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ��������: "Oracle/Module/ModuleInfo")
*/
module_svn_root                   varchar2(100),

/* var: object_type_id
  Id ���� �������
*/
object_type_id                    integer,

/* var: object_type_name
  �������� ���� �������
*/
object_type_name                  varchar2(100),

/* var: object_type_module_id
  ������ ���� �������: Id ������
*/
object_type_module_id             integer,

/* var: object_type_module_name
  ������ ���� �������: �������� ������
*/
object_type_module_name           varchar2(100),

/* var: object_type_module_svn_root
  ������ ���� �������: ���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ��������: "Oracle/Module/ModuleInfo")
*/
object_type_module_svn_root       varchar2(100),

/* var: option_change_number
  ��������: ���������� ����� ��������� ������ ( ������� � 1)
*/
option_change_number              integer,

/* var: option_change_date
  ��������: ���� ��������� ������
*/
option_change_date                date,

/* var: option_change_operator_id
  ��������: Id ���������, ����������� ������
*/
option_change_operator_id         integer,

/* var: option_date_ins
  ��������: ���� ���������� ������
*/
option_date_ins                   date,

/* var: option_operator_id
  ��������: Id ���������, ����������� ������
*/
option_operator_id                integer,

/* var: value_change_number
  ��������: ���������� ����� ��������� ������ ( ������� � 1)
*/
value_change_number               number,

/* var: value_change_date
  ��������: ���� ��������� ������
*/
value_change_date                 date,

/* var: value_change_operator_id
  ��������: Id ���������, ����������� ������
*/
value_change_operator_id          number,

/* var: value_date_ins
  ��������: ���� ���������� ������
*/
value_date_ins                    date,

/* var: value_operator_id
  ��������: Id ���������, ����������� ������
*/
value_operator_id                 number

)
/
