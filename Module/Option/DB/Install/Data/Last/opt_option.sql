-- script: Install/Data/Last/opt_option.sql
-- ������� ����������� ��������� ������.
--
-- ���������:
-- productionDbName           - ��� ������������ ��, � ������� ���������
--                              ����������� ��������� ( �������� ���������
--                              ��������� <PRODUCTION_DB_NAME>)
--

define productionDbName = "&1"

declare

  productionDbName varchar2(30) := '&productionDbName';

  opt opt_option_list_t := opt_option_list_t(
    moduleSvnRoot => pkg_OptionMain.Module_SvnRoot
  );



  /*
    ��������� ����� LocalRoleSuffix, ���� ��� �� ����������.
  */
  procedure addLocalRoleSuffix
  is

    localRoleSuffix varchar2(30);

  begin
    if opt.existsOption( pkg_OptionMain.LocalRoleSuffix_OptionSName) = 0 then
      dbms_output.put_line(
        'productionDbName: "' || productionDbName || '"'
      );
      localRoleSuffix :=
        case when productionDbName like '%___P' then
          substr( productionDbName, 1, length( productionDbName) - 1)
        else
          productionDbName
        end
      ;
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
        , stringValue         => localRoleSuffix
      );
      dbms_output.put_line(
        '"' || pkg_OptionMain.LocalRoleSuffix_OptionSName || '"'
        || ' option created with value: "' || localRoleSuffix || '"'
      );
    end if;
  end addLocalRoleSuffix;



-- main
begin
  if productionDbName is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�� ������� ��� ������������ ��, � ������� ��������� ���������'
        || ' ( productionDbName).'
    );
  end if;
  addLocalRoleSuffix();

  commit;
end;
/

undefine productionDbName
