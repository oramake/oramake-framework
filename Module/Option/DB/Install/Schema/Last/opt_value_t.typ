create or replace type
  opt_value_t
as object
(
/* db object type: opt_value_t
  �������� ������������ ���������.
  ����� ���������� �� ����� ������������� <v_opt_value> �����������
  ���� <encrypted_string_value> ( ��� ���� �������� � ���� <string_value>
  ������ ����������� � ��������������� ����).

  SVN root: Oracle/Module/Option
*/



/* group: �������� ���������� */

/* var: value_id
  Id ��������
*/
value_id                          integer,

/* var: option_id
  Id ���������
*/
option_id                         integer,

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

/* var: value_type_code
  ��� ���� �������� ���������
*/
value_type_code                   varchar2(10),

/* var: value_list_flag
  ���� ������� ��� ��������� ������ �������� ���������� ���� ( 1 ��, 0 ���)
*/
value_list_flag                   number(1),

/* var: list_separator
  ������, ������������ � �������� ����������� � ������ ��������, ����������� � ���� string_value ( null ���� ������ �� ������������)
*/
list_separator                    varchar2(1),

/* var: encryption_flag
  ���� �������� �������� ��������� � ������������� ���� ( �������� ������ ��� �������� ���������� ����) ( 1 ��, 0 ���)
*/
encryption_flag                   number(1),

/* var: storage_value_type_code
  ��� ����, ������������� ��� �������� �������� ��������� ( ���������� �� ���� �������� ��������� � ������ ������������� ������ ��������, �.�. ������ �������� � ���� ������)
*/
storage_value_type_code           varchar2(10),

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

/* var: change_number
  ���������� ����� ��������� ������ ( ������� � 1)
*/
change_number                     number,

/* var: change_date
  ���� ��������� ������
*/
change_date                       date,

/* var: change_operator_id
  Id ���������, ����������� ������
*/
change_operator_id                number,

/* var: date_ins
  ���� ���������� ������
*/
date_ins                          date,

/* var: operator_id
  Id ���������, ����������� ������
*/
operator_id                       number

)
/
