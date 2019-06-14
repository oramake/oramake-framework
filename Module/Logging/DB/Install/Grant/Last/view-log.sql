-- script: Install/Grant/Last/view-log.sql
-- ������ ����� �� �������� ����.
--
-- ���������:
-- toUserName                  - ��� ������������, �������� �������� �����
--
-- ���������:
--  - ������ ����������� ��� �������������, �������� ����������� ������� ������;
--

declare

  toUserName varchar2(30) := '&1';

  -- ������ �������� ��� ������ ����
  type ObjectListT is table of varchar2(30);

  objectList ObjectListT := ObjectListT(
    'lg_context_type'
    , 'lg_log'
    , 'v_lg_context_change'
    , 'v_lg_context_change_log'
  );

  -- ������� ������ ���� ��� ���� �������������
  isToPublic boolean := upper( toUserName) = 'PUBLIC';

  -- ������ �������� ������� � ������
  i pls_integer := objectList.first();



  /*
    ��������� SQL � DDL-��������.
  */
  procedure execSql(
    sqlText varchar2
  )
  is
  begin
    execute immediate sqlText;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ ��� ��������� SQL:' || chr(10) || sqlText
      , true
    );
  end execSql;



begin
  while i is not null loop
    begin
      if objectList( i) like 'pkg\_%' escape '\'
            or objectList( i) like '%\_t' escape '\'
          then
        execSql(
          'grant execute on ' || objectList( i) || ' to ' || toUserName
        );
      else
        execSql(
          'grant select on ' || objectList( i) || ' to ' || toUserName
        );
      end if;
      if isToPublic then
        execSql(
          'create or replace public synonym ' || objectList( i)
          || ' for ' || objectList( i)
        );
      else
        execSql(
          'create or replace synonym ' || toUserName || '.' || objectList( i)
          || ' for ' || objectList( i)
        );
      end if;
      dbms_output.put_line(
        'privs granted: ' || objectList( i)
      );
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '������ ��� ������ ���� �� ������ "' || objectList( i) || '".'
        , true
      );
    end;
    i := objectList.next( i);
  end loop;
end;
/
