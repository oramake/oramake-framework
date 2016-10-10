declare

  cursor localRoleCur is
    select
      db.column_value as db_name
      , pr.column_value as privilege_name
      , pr.column_value || 'AllBatch' || db.column_value
        as role_short_name
      , '����: '
        || case pr.column_value
              when 'Admin'    then '�����������������'
              when 'Execute'  then '������'
              when 'Show'     then '��������'
           end
        || ' ���� ������ ' || db.column_value
        as role_name
      , 'Batch: '
        || case pr.column_value
              when 'Admin'    then 'Administration of'
              when 'Execute'  then 'Execute'
              when 'Show'     then 'View'
           end
        || ' all batches ' || db.column_value
        as role_name_en
      , '������ � '
        || case pr.column_value
              when 'Admin'    then '�����������������'
              when 'Execute'  then '�������'
              when 'Show'     then '���������'
           end
        || ' ���� ������ ' || db.column_value
        || '. ��� ��'
        as description
    from
      table( cmn_string_table_t(
          'DbName1'
          , 'DbName2'
          , 'DbName3'
        )) db
      cross join table( cmn_string_table_t(
          'Admin'
          , 'Execute'
          , 'Show'
        )) pr
    order by
      1, 2
  ;

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

  for rec in localRoleCur loop
    mergeRole(
      roleShortName => rec.role_short_name
      , roleName    => rec.role_name
      , roleNameEn  => rec.role_name_en
      , description => rec.description
    );
  end loop;

  dbms_output.put_line(
    'roles changed: ' || nChanged
  );
  commit;
end;
/
