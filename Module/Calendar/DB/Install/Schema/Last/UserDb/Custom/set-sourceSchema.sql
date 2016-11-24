-- script: Install/Schema/Last/UserDb/Custom/set-sourceSchema.sql
-- ���������� ����� � �������� ��, � ������� ����������� ������� ������,
-- � ��������� ��� � �������� �������� �� ��������� ��� ���������������
-- sourceSchema.
--
-- ������������ ���������������:
-- sourceDbLink               - ���� � �������� ��
--
--
-- ���������:
--  - ���� ��������������� ��� ��������� �������� ��������, �� ��� ��
--    ����������, ��� ��������� ���� ������ �������� ��������������� ���
--    ��������� � ������� ��������� <SQL_DEFINE>
--    ( ��. <��������� ������ � ��>);
--  - � �������� ����� ������� ����� ������� cdr_day ��
--    all_tables@<sourceDbLink>;
--

@oms-default sourceSchema ""

var defaultSchema varchar2(100)

declare

  sourceDbLink varchar2(200) := '&sourceDbLink';

begin
  if '&sourceSchema' is null then
    if sourceDbLink is null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '�� ����� ���� � �������� �� � ��������������� sourceDbLink.'
      );
    end if;
    begin
      execute immediate '
        select
          t.owner
        from
          all_tables t
        where
          t.table_name = upper( :tableName)
      '
      into
        :defaultSchema
      using
        'cdr_day'
      ;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '������ ��� ����������� ����� �� ������� ������� CDR_DAY'
           || ' � all_tables ('
           || ' sourceDbLink="' || sourceDbLink || '"'
           || ').'
        , true
      );
    end;
  end if;
end;
/

@oms-default sourceSchema "' || :defaultSchema || '"
