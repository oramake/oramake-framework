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
    roleShortName     => 'OptShowOption'
    , roleName    =>
        '��������: ������ � ����� ���������'
    , roleNameEn  =>
        'Option: Access to options form'
    , description =>
        '������������ � ������ ����� ����� ������ � ����� ���������'
  );

  mergeRole(
    roleShortName     => 'GlobalOptionAdmin'
    , roleName    =>
        '��������: ����������������� ���� ����������'
    , roleNameEn  =>
        'Option: All option admininstrator'
    , description =>
        '������������ � ������ ����� ����� ����� �� ����������������� ���������� ������� �� ���� ��'
  );

  mergeRole(
    roleShortName     => 'OptShowAllOption'
    , roleName    =>
        '��������: �������� ���� ����������'
    , roleNameEn  =>
        'Option: Show all option'
    , description =>
        '������������ � ������ ����� ����� ����� �� �������� ���������� ������� �� ���� ��'
  );

  dbms_output.put_line(
    'roles changed: ' || nChanged
  );
  commit;
end;
/
