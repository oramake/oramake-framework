-- script: Install/Data/Last/AccessOperatorDb/op_role.sql
-- ������� ����, ������������ �������.
--

declare

  -- ����� ���������
  nChanged integer := 0;



  /*
    ���������� ��� ���������� ����.
  */
  procedure mergeRole(
    roleShortName varchar2
    , roleName varchar2
    , roleNameEn varchar2
    , description varchar2
  )
  is

    changedFlag integer;

  begin
    changedFlag := pkg_AccessOperator.mergeRole(
      roleShortName   => roleShortName
      , roleName      => roleName
      , roleNameEn    => roleNameEn
      , description   => description
    );
    if changedFlag = 1 then
      dbms_output.put_line(
        'changed role: ' || roleShortName
      );
      nChanged := nChanged + 1;
    else
      dbms_output.put_line(
        'checked role: ' || roleShortName
      );
    end if;
  end mergeRole;



-- main
begin
  mergeRole(
    roleShortName => 'CdrUser'
    , roleName    =>
        '������������ ������ Calendar'
    , roleNameEn  =>
        'Calendar user'
    , description =>
        '���� ����� �� �������� ������ �� ����������� ���������� �������/�������� ����'
  );
  mergeRole(
    roleShortName => 'CdrAdministrator'
    , roleName    =>
        '������������� ������ Calendar'
    , roleNameEn  =>
        'Calendar administrator'
    , description =>
        '���� ����� �� ��������, ��������������, ���������� � �������� ������ �� ����������� ���������� �������/�������� ����'
  );
  commit;
end;
/
