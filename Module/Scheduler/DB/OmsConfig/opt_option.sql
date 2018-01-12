-- ModuleConfig/Scheduler/opt_option.sql
-- ������� ����������� ��������� ������ Scheduler, ����������� ��� �� ���
-- ������������ � ��.
--
-- ���������:
-- productionDbName           - ��� ������������ ��, � ������� ���������
--                              ����������� ��������� ( �������� ���������
--                              ��������� <PRODUCTION_DB_NAME>)
--
-- ���������:
--  - �������� ��� ��������� <pkg_SchedulerMain.LocalRoleSuffix_OptSName>
--    ������������ �������� ����������, �������� ��������
--    <ModuleConfig/Scheduler/set-schDbRoleSuffixList.sql>;
--    �� �������� productionDbName � ������ ������� �����, ��� ����
--    ���� ��������� ��� ���� ��������� ��������, �������� �� null, �� ��� ��
--    ����������;
--

define productionDbName = "&1"



prompt get local roles config...

@@set-schDbRoleSuffixList.sql



prompt refresh options...

declare

  productionDbName varchar2(30) := '&productionDbName';

  opt opt_option_list_t := opt_option_list_t(
    moduleSvnRoot => pkg_SchedulerMain.Module_SvnRoot
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
        fetch :schDbRoleSuffixList into prodDbName, roleSuffix;
        exit when :schDbRoleSuffixList%notfound;
        if upper( trim( prodDbName)) = findSchema then
          newValue := roleSuffix;
          -- �������, �.�. ������� �������� ������ ����������
          exit;
        elsif upper( trim( prodDbName)) = findDbName then
          newValue := roleSuffix;
        end if;
      end loop;
      close :schDbRoleSuffixList;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '������ ��� ����������� �������� ��������� �������� ����������.'
        , true
      );
    end getNewValue;



  -- setLocalRoleSuffix
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
    dbms_output.put_line(
      'productionDbName: "' || productionDbName || '"'
    );
    getNewValue();

    if opt.existsOption( pkg_SchedulerMain.LocalRoleSuffix_OptSName) = 0 then
      opt.addString(
        optionShortName       => pkg_SchedulerMain.LocalRoleSuffix_OptSName
        , optionName          =>
            '������� ��� �����, � ������� ������� �������� ����� �� ��� �������� �������, ��������� � �������� ������������� ������ Scheduler'
        , accessLevelCode     => opt_option_list_t.getReadAccessLevelCode()
        , optionDescription   =>
'��� �������� ���� ������� ����������� ����:

AdminAllBatch<LocalRoleSuffix>    - ������ �����
ExecuteAllBatch<LocalRoleSuffix>  - ���������� �������� �������
ShowAllBatch<LocalRoleSuffix>     - �������� ������

��� <LocalRoleSuffix> ��� �������� ������� ���������.

����� ������ �� ��� �������� �������, ����������� � ������ Scheduler, � ������� ����� ������ ��������. ��� ���� ���������������, ��� ��� ��������� ��������� ������ �������� ����� ����� ��������� ��������, ������� �������� ��� ��������� ������ Scheduler.

������:
��� ��������� � �� ProdDb �������� ����� �������� "Prod", � ���������� ����� �� ��� �������� �������, ��������� � �� ProdDb, ����� ������ � ������� ����� "AdminAllBatchProd", "ExecuteAllBatchProd", "ShowAllBatchProd".
'
        , stringValue         => newValue
      );
      dbms_output.put_line(
        '"' || pkg_SchedulerMain.LocalRoleSuffix_OptSName || '"'
        || ' option created with value: "' || newValue || '"'
      );
    elsif newValue is not null then
      opt.setString(
        optionShortName => pkg_SchedulerMain.LocalRoleSuffix_OptSName
        , stringValue   => newValue
      );
      dbms_output.put_line(
        '"' || pkg_SchedulerMain.LocalRoleSuffix_OptSName || '"'
        || ' option set value: "' || newValue || '"'
      );
    end if;
  end setLocalRoleSuffix;



-- main
begin

  --  ������������� �������� ��������� LocalRoleSuffix, ���� ��� �� ����
  --  ������ ����� �������� �� null.
  if opt.getString(
          pkg_SchedulerMain.LocalRoleSuffix_OptSName
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
