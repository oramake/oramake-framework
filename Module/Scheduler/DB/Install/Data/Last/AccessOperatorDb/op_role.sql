-- script: Install/Data/Last/AccessOperatorDb/op_role.sql
-- ������� ����, ������������ ������� (����� ��� ���� ��).
--

prompt get local roles config...




prompt refresh roles...

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
    roleShortName => 'AllBatchAdmin'
    , roleName    =>
        '������������� ���� �������� ������� �� ���� ��'
    , roleNameEn  =>
        'All batch admininstrator'
    , description =>
        '������������ � ������ ����� ����� ������ ����� �� �������� ������� �� ���� ��'
  );
  mergeRole(
    roleShortName => 'SchShowBatch'
    , roleName    =>
        'Scheduler: ������ � ����� ��������� �������'
    , roleNameEn  =>
        'Scheduler: Access to batch form'
    , description =>
        '������������ � ������ ����� ����� ������ � ����� ��������� �������'
  );
  mergeRole(
    roleShortName => 'SchShowBatchOption'
    , roleName    =>
        'Scheduler: ������ � �������� ����������� ����� ��������� �������'
    , roleNameEn  =>
        'Scheduler: Access to batch option form'
    , description =>
        '������������ � ������ ����� ����� ������ � �������� ����������� ����� ��������� �������'
  );
  mergeRole(
    roleShortName => 'SchShowSchedule'
    , roleName    =>
        'Scheduler: ������ � �������� ����������� ����� ��������� �������'
    , roleNameEn  =>
        'Scheduler: Access to schedule form'
    , description =>
        '������������ � ������ ����� ����� ������ � �������� ����������� ����� ��������� �������'
  );
  mergeRole(
    roleShortName => 'SchShowLog'
    , roleName    =>
        'Scheduler: ������ � �������� ���� ����� ��������� �������'
    , roleNameEn  =>
        'Scheduler: Access to log form'
    , description =>
        '������������ � ������ ����� ����� ������ � �������� ���� ����� ��������� �������'
  );
  mergeRole(
    roleShortName => 'SchShowBatchRole'
    , roleName    =>
        'Scheduler: ������ � �������� ����� - ����� ����� ��������� �������'
    , roleNameEn  =>
        'Scheduler: Access to batch-role form'
    , description =>
        '������������ � ������ ����� ����� ������ � �������� ����� - ����� ����� ��������� �������'
  );
  mergeRole(
    roleShortName => 'SchShowModuleRolePrivilege'
    , roleName    =>
        'Scheduler: ������ � ����� ������ �� �������� ������� �������'
    , roleNameEn  =>
        'Scheduler: Access to batch type -  role form'
    , description =>
        '������������ � ������ ����� ����� ������ � ����� ������ �� �������� ������� �������'
  );

  dbms_output.put_line(
    'roles changed: ' || nChanged
  );
  commit;
end;
/
