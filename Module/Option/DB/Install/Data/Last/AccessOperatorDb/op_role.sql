declare

  cursor localRoleCur is
    select
      db.column_value as db_name
      , pr.column_value as privilege_name
      , 'Opt' || pr.column_value || 'AllOption' || db.column_value
        as short_name
      , '��������: '
        || case pr.column_value
              when 'Admin'    then '�����������������'
              when 'Show'     then '��������'
           end
        || ' ���� ���������� ' || db.column_value
        as role_name
      , 'Option: '
        || case pr.column_value
              when 'Admin'    then 'Administration of'
              when 'Show'     then 'View'
           end
        || ' all options ' || db.column_value
        as role_name_en
      , '������ � '
        || case pr.column_value
              when 'Admin'    then '�����������������'
              when 'Show'     then '���������'
           end
        || ' ���� ���������� ������� � ' || db.column_value
        as description
    from
      table( cmn_string_table_t(
          -- ��� ������������ ��, � ������� ��������������� ������
          'DbName1'
          , 'DbName2'
          , 'DbName3'
        )) db
      cross join table( cmn_string_table_t(
          'Admin'
          , 'Show'
        )) pr
    order by
      1, 2
  ;

  -- ����� ����������� �����
  nCreated integer := 0;

  -- ����� ����� ��������� �����
  nExists integer := 0;



  /*
    ��������� ���� � ������ �� ����������.
  */
  procedure addRole(
    shortName varchar2
    , roleName varchar2
    , roleNameEn varchar2
    , description varchar2
    , oldShortName varchar2 := null
  )
  is

    cursor roleCur is
      select
        t.*
      from
        op_role t
      where
        t.short_name in ( oldShortName, shortName)
      order by
        nullif( t.short_name, oldShortName) nulls first
    ;

    rec roleCur%rowtype;

  begin
    open roleCur;
    fetch roleCur into rec;
    close roleCur;
    if rec.role_id is null then
      rec.role_id := pkg_AccessOperator.createRole(
        shortName     => shortName
        , roleName    => roleName
        , roleNameEn  => roleNameEn
        , description => description
        , operatorId  => pkg_Operator.getCurrentUserId()
      );
      dbms_output.put_line(
        'role created: ' || shortName || ' ( role_id=' || rec.role_id || ')'
      );
      nCreated := nCreated + 1;
    else
      if coalesce( rec.short_name != shortName
              , coalesce( rec.short_name, shortName) is not null)
          or coalesce( rec.role_name != roleName
              , coalesce( rec.role_name, roleName) is not null)
          or coalesce( rec.role_name_en != roleNameEn
              , coalesce( rec.role_name_en, roleNameEn) is not null)
          or coalesce( rec.description != description
              , coalesce( rec.description, description) is not null)
          then
        pkg_AccessOperator.updateRole(
          roleId        => rec.role_id
          , shortName   => shortName
          , roleName    => roleName
          , roleNameEn  => roleNameEn
          , description => description
          , operatorId  => pkg_Operator.getCurrentUserId()
        );
        dbms_output.put_line(
          'role updated: ' || shortName || ' ( role_id=' || rec.role_id || ')'
        );
      end if;
      nExists := nExists + 1;
    end if;
  end addRole;



-- main
begin
  addRole(
    shortName     => 'OptShowOption'
    , roleName    =>
        '��������: ������ � ����� ���������'
    , roleNameEn  =>
        'Option: Access to options form'
    , description =>
        '������������ � ������ ����� ����� ������ � ����� ���������'
  );

  addRole(
    shortName     => 'GlobalOptionAdmin'
    , roleName    =>
        '��������: ����������������� ���� ����������'
    , roleNameEn  =>
        'Option: All option admininstrator'
    , description =>
        '������������ � ������ ����� ����� ����� �� ����������������� ���������� ������� �� ���� ��'
  );

  addRole(
    shortName     => 'OptShowAllOption'
    , roleName    =>
        '��������: �������� ���� ����������'
    , roleNameEn  =>
        'Option: Show all option'
    , description =>
        '������������ � ������ ����� ����� ����� �� �������� ���������� ������� �� ���� ��'
  );

  for rec in localRoleCur loop
    addRole(
      shortName     => rec.short_name
      , roleName    => rec.role_name
      , roleNameEn  => rec.role_name_en
      , description => rec.description
    );
  end loop;

  dbms_output.put_line(
    'roles created: ' || nCreated
    || ' ( already exists: ' || nExists || ')'
  );
  commit;
end;
/
