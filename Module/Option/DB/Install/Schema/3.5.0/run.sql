-- script: Install/Schema/3.5.0/run.sql
-- ���������� �������� ����� �� ������ 3.5.0.
--
-- �������� ���������:
--  - ��������� ������������ ����� ���� option_description ������
--    <opt_option> � <opt_option_history>;
--  - ������������ ��� <opt_option_value_t>;
--

@oms-run opt_option.sql
@oms-run opt_option_history.sql
@oms-run Install/Schema/Last/opt_option_value_t.typ
