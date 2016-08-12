-- script: Install/Data/Last/opt_option.sql
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
--    <Install/Data/Last/Custom/set-optDbRoleSuffixList.sql>,
--    � �������� productionDbName;
--

define productionDbName = "&1"



prompt get local roles config...

@Install/Data/Last/Custom/set-optDbRoleSuffixList.sql



prompt refresh options...

declare

  productionDbName varchar2(30) := '&productionDbName';

  opt opt_option_list_t := opt_option_list_t(
    moduleSvnRoot => pkg_OptionMain.Module_SvnRoot
  );



  /*
    �������/��������� �������� ��������� LocalRoleSuffix.
  */
  procedure mergeLocalRoleSuffix
  is

    newValue varchar2(100);
    oldValue varchar2(100);



    /*
      ���������� ����� �������� ���������.
    */
    procedure getNewValue
    is

      prodDbName varchar2(100);
      roleSuffix varchar2(100);

    begin
      loop
        fetch :optDbRoleSuffixList into prodDbName, roleSuffix;
        exit when :optDbRoleSuffixList%notfound;
        if upper( trim( prodDbName)) = trim( upper( productionDbName)) then
          newValue := roleSuffix;
          exit;
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



  -- mergeLocalRoleSuffix
  begin
    dbms_output.put_line(
      'productionDbName: "' || productionDbName || '"'
    );
    getNewValue();

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
    else
      oldValue := opt.getString( pkg_OptionMain.LocalRoleSuffix_OptionSName);
      if coalesce(
              oldValue != newValue
              , coalesce( oldValue, newValue) is not null
            )
          then
        opt.setString(
          optionShortName => pkg_OptionMain.LocalRoleSuffix_OptionSName
          , stringValue   => newValue
        );
        dbms_output.put_line(
          '"' || pkg_OptionMain.LocalRoleSuffix_OptionSName || '"'
          || ' option value changed: "' || newValue || '"'
        );
      end if;
    end if;
  end mergeLocalRoleSuffix;



-- main
begin
  if productionDbName is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�� ������� ���������� ��� ������������ ��, � ������� ���������'
        || ' ��������� ('
        || ' ����� ������� � ������� ��������� ��������� PRODUCTION_DB_NAME'
        || ').'
    );
  end if;

  mergeLocalRoleSuffix();

  commit;
end;
/

undefine productionDbName
