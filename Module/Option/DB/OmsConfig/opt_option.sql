-- script: ModuleConfig/Option/opt_option.sql
-- ������� ����������� ��������� ������.
--
-- ���������:
-- productionDbName           - ��� ������������ ��, � ������� ���������
--                              ����������� ��������� ( �������� ���������
--                              ��������� <PRODUCTION_DB_NAME>)
--
-- ���������:
--  - �������� ��� ��������� <pkg_OptionMain.LocalRoleSuffix_OptionSName>
--    ������������ �������� ����������, �������� ��������
--    <ModuleConfig/Option/set-optDbRoleSuffixList.sql>,
--    �� �������� productionDbName � ������ ������� �����, ��� ����
--    ���� ��������� ��� ���� ��������� ��������, �������� �� null, �� ��� ��
--    ����������;
--

define productionDbName = "&1"



prompt get local roles config...

@@set-optDbRoleSuffixList.sql



prompt refresh options...

declare

  productionDbName varchar2(30) := '&productionDbName';

  opt opt_option_list_t := opt_option_list_t(
    moduleSvnRoot => pkg_OptionMain.Module_SvnRoot
  );



  /*
    ������������� �������� ��������� LocalRoleSuffix �������� ����������.
  */
  procedure setLocalRoleSuffix
  is

    newValue varchar2(100);



    /*
      ���������� ����� �������� ���������.
    */
    procedure getNewValue
    is

      findDbName varchar2(100);
      findSchema varchar2(100);

      prodDbName varchar2(100);
      roleSuffix varchar2(100);

    begin
      findDbName := upper( trim( productionDbName));
      findSchema :=
        upper( sys_context( 'USERENV', 'CURRENT_SCHEMA'))
        || '@' || findDbName
      ;
      loop
        fetch :optDbRoleSuffixList into prodDbName, roleSuffix;
        exit when :optDbRoleSuffixList%notfound;
        if upper( trim( prodDbName)) = findSchema then
          newValue := roleSuffix;
          -- �������, �.�. ������� �������� ������ ����������
          exit;
        elsif upper( trim( prodDbName)) = findDbName then
          newValue := roleSuffix;
        end if;
      end loop;
      close :optDbRoleSuffixList;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '������ ��� ����������� �������� ��������� �������� ����������.'
        , true
      );
    end getNewValue;



  -- setLocalRoleSuffix
  begin
    dbms_output.put_line(
      'productionDbName: "' || productionDbName || '"'
    );
    if productionDbName is not null then
      getNewValue();
    end if;

    if opt.existsOption( pkg_OptionMain.LocalRoleSuffix_OptionSName) = 0 then
      opt.addString(
        optionShortName       => pkg_OptionMain.LocalRoleSuffix_OptionSName
        , optionName          =>
            '������� ��� �����, � ������� ������� �������� ����� �� ��� ���������, ��������� � �������� ������������� ������ Option'
        , accessLevelCode     => opt_option_list_t.getReadAccessLevelCode()
        , optionDescription   =>
'��� �������� ���� ������� ����������� ����:

OptAdminAllOption<LocalRoleSuffix>    - ������ �����
OptShowAllOption<LocalRoleSuffix>     - �������� ������

��� <LocalRoleSuffix> ��� �������� ������� ���������.

����� ������ �� ��� ���������, ����������� � ������ Option, � ������� �����
������ ��������. ��� ���� ���������������, ��� � ��������� �� ������
�������� ����� ��������� ��������, ������� �������� ��� ��������� ������
Option.

������:
� �� DbNameP �������� ����� �������� "DbName", � ���������� ����� ��
��� ���������, ��������� � �� DbNameP, ����� ������ � �������
����� "OptAdminAllOptionDbName" � "OptShowAllOptionDbName".
'
        , stringValue         => newValue
      );
      dbms_output.put_line(
        '"' || pkg_OptionMain.LocalRoleSuffix_OptionSName || '"'
        || ' option created with value: "' || newValue || '"'
      );
    elsif newValue is not null then
      opt.setString(
        optionShortName => pkg_OptionMain.LocalRoleSuffix_OptionSName
        , stringValue   => newValue
      );
      dbms_output.put_line(
        '"' || pkg_OptionMain.LocalRoleSuffix_OptionSName || '"'
        || ' option set value: "' || newValue || '"'
      );
    end if;
  end setLocalRoleSuffix;



-- main
begin

  --  ������������� �������� ��������� LocalRoleSuffix, ���� ��� �� ����
  --  ������ ����� �������� �� null.
  if opt.getString(
          pkg_OptionMain.LocalRoleSuffix_OptionSName
          , raiseNotFoundFlag => 0
        )
        is null
      then
    setLocalRoleSuffix();
  end if;

  commit;
end;
/

undefine productionDbName
