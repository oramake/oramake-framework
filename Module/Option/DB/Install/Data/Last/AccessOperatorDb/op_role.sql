-- script: Install/Data/Last/AccessOperatorDb/op_role.sql
-- ������� ����, ������������ �������.
--
-- ���������:
--  - ��� �������� ����� ������������ ���������, ���������� ��������
--    <Install/Data/Last/Custom/set-optDbRoleSuffixList.sql>;
--

prompt get local roles config...

@Install/Data/Last/Custom/set-optDbRoleSuffixList.sql



prompt refresh roles...

declare

  cursor localRoleCur(
        productionDbName varchar2
        , localRoleSuffix varchar2
      )
      is
    select
      pr.column_value as privilege_name
      , 'Opt' || pr.column_value || 'AllOption' || localRoleSuffix
        as role_short_name
      , '��������: '
        || case pr.column_value
              when 'Admin'    then '�����������������'
              when 'Show'     then '��������'
           end
        || ' ���� ���������� ' || productionDbName
        as role_name
      , 'Option: '
        || case pr.column_value
              when 'Admin'    then 'Administration of'
              when 'Show'     then 'View'
           end
        || ' all options ' || productionDbName
        as role_name_en
      , '������ � '
        || case pr.column_value
              when 'Admin'    then '�����������������'
              when 'Show'     then '���������'
           end
        || ' ���� ���������� ������� � ' || productionDbName
        as description
    from
      table( cmn_string_table_t(
        'Admin'
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
      fetch :optDbRoleSuffixList into prodDbName, roleSuffix;
      exit when :optDbRoleSuffixList%notfound;
      nRow := nRow + 1;
      if trim( prodDbName) is null then
        raise_application_error(
          pkg_Error.IllegalArgument
          , '�� ����� production_db_name ('
            || ' nRow=' || nRow
            || ').'
        );
      end if;
      if trim( roleSuffix) is null then
        raise_application_error(
          pkg_Error.IllegalArgument
          , '�� ����� local_role_suffix ('
            || ' nRow=' || nRow
            || ', production_db_name="' || prodDbName || '"'
            || ').'
        );
      end if;
      for rec in localRoleCur(
            productionDbName    => trim( prodDbName)
            , localRoleSuffix   => trim( roleSuffix)
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
    close :optDbRoleSuffixList;
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

  refreshLocalRole();

  dbms_output.put_line(
    'roles changed: ' || nChanged
  );
  commit;
end;
/
