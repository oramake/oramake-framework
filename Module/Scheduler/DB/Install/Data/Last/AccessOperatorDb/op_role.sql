-- script: Install/Data/Last/AccessOperatorDb/op_role.sql
-- ������� ����, ������������ �������.
--
-- ���������:
--  - ��� �������� ����� ������������ ���������, ���������� ��������
--    <Install/Data/Last/Custom/set-schDbRoleSuffixList.sql>;
--

prompt get local roles config...

@Install/Data/Last/Custom/set-schDbRoleSuffixList.sql



prompt refresh roles...

declare

  cursor localRoleCur(
        localRoleSuffix varchar2
      )
      is
    select
      pr.column_value as privilege_name
      , pr.column_value || 'AllBatch' || localRoleSuffix
        as role_short_name
      , '����: '
        || case pr.column_value
              when 'Admin'    then '�����������������'
              when 'Execute'  then '������'
              when 'Show'     then '��������'
           end
        || ' ���� ������ ' || localRoleSuffix
        as role_name
      , 'Batch: '
        || case pr.column_value
              when 'Admin'    then 'Administration of'
              when 'Execute'  then 'Execute'
              when 'Show'     then 'View'
           end
        || ' all batches ' || localRoleSuffix
        as role_name_en
      , '������ � '
        || case pr.column_value
              when 'Admin'    then '�����������������'
              when 'Execute'  then '�������'
              when 'Show'     then '���������'
           end
        || ' ���� ������ � ' || localRoleSuffix
        as description
    from
      table( cmn_string_table_t(
        'Admin'
        , 'Execute'
        , 'Show'
      )) pr
    order by
      1
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



  /*
    ��������� ��������� ����.
  */
  procedure refreshLocalRole
  is

    prodDbName varchar2(100);
    roleSuffix varchar2(100);

    nRow pls_integer := 0;

  begin
    dbms_output.put_line(
      'local roles:'
    );
    loop
      fetch :schDbRoleSuffixList into prodDbName, roleSuffix;
      exit when :schDbRoleSuffixList%notfound;
      nRow := nRow + 1;
      prodDbName := trim( prodDbName);
      roleSuffix := trim( roleSuffix);
      if roleSuffix is null then
        raise_application_error(
          pkg_Error.IllegalArgument
          , '�� ����� local_role_suffix ('
            || ' nRow=' || nRow
            || ', production_db_name="' || prodDbName || '"'
            || ').'
        );
      end if;
      for rec in localRoleCur(
            localRoleSuffix   => roleSuffix
          )
          loop
        mergeRole(
          roleShortName => rec.role_short_name
          , roleName    => rec.role_name
          , roleNameEn  => rec.role_name_en
          , description => rec.description
        );
      end loop;
    end loop;
    close :schDbRoleSuffixList;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ ��� ���������� ��������� �����.'
      , true
    );
  end refreshLocalRole;



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

  refreshLocalRole();

  dbms_output.put_line(
    'roles changed: ' || nChanged
  );
  commit;
end;
/
