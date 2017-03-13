-- script: Install/Grant/Last/run.sql
-- ������ ����� �� ������������� ������.
--
-- ���������:
-- toUserName                 - ��� ������������, �������� �������� �����
--                              ( "public" ��� ������ ���� ���� �������������)
--
-- ���������:
--   - ��� ��������� ���������� ������� ��� "public" ��������� ����� ��
--    �������� ��������� ���������;
--



declare

  toUserName varchar2(30) := '&1';

  -- ������ ���� �� ������� � ������� "<object_name>[:<privs_list>]", ���
  -- object_name        - ��� �������, �� ������� �������� �����
  -- privs_list         - ������ ���� ( ����� �������), �� ���������
  --                      "execute" ��� �������� � ������ "pkg_%" �
  --                      "select" ��� ��������� ��������
  --
  type PrivsListT is table of varchar2(1000);

  privsList PrivsListT := PrivsListT(
    'pkg_Mail'
  );

  -- ������� ������ ���� ��� ���� �������������
  isToPublic boolean := upper( toUserName) = 'PUBLIC';

  -- ������ �������� ������� � ������
  i pls_integer := privsList.first();

  -- ��� �������
  objectName varchar2(30);

  -- �����, ���������� �� ������
  objectPrivs varchar2(1000);



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
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , '������ ��� ��������� SQL:' || chr(10) || sqlText
      , true
    );
  end execSql;



begin
  dbms_output.put_line(
    'granted to ' || toUserName || ':'
  );
  while i is not null loop
    begin
      objectName :=
        trim( substr( privsList( i), 1, instr( privsList( i) || ':', ':') - 1))
      ;
      objectPrivs := coalesce(
        trim( substr( privsList( i), instr( privsList( i) || ':', ':') + 1))
        , case when objectName like 'pkg_%' then
            'execute'
          else
            'select'
          end
      );
      execSql(
        'grant ' || objectPrivs || ' on ' || objectName || ' to ' || toUserName
      );
      if isToPublic then
        execSql(
          'create or replace public synonym ' || objectName
          || ' for ' || objectName
        );
      else
        execSql(
          'create or replace synonym ' || toUserName || '.' || objectName
          || ' for ' || objectName
        );
      end if;
      dbms_output.put_line(
        rpad( objectName, 30) || ' : ' || objectPrivs
      );
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '������ ��� ������ ���� "' || privsList( i) || '" ('
          || ' objectName="' || objectName || '"'
          || ' , objectPrivs="' || objectPrivs || '"'
          || ').'
        , true
      );
    end;
    i := privsList.next( i);
  end loop;
end;
/
