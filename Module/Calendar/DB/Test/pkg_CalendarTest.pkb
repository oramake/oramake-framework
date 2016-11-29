create or replace package body pkg_CalendarTest is
/* package body: pkg_CalendarTest::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Calendar.Module_Name
  , objectName  => 'pkg_CalendarTest'
);



/* group: ������� */

/* proc: testWebApi
  ���� API ��� web-����������.

  ���������:
  saveDataFlag                - ��������� �������� ������ � �������� ���
                                �������� ���������� �����
                                ( 1 ��, 0 ��� ( �� ���������))
*/
procedure testWebApi(
  saveDataFlag integer := null
)
is

  -- ������� ��������
  currentOperatorId integer;

  -- Id ���������, ����������� ��� ��������� ������
  adminOperatorId integer := pkg_AccessOperatorTest.getTestOperatorId(
    baseName        => 'CalendarAdmin'
    , roleSNameList =>
        cmn_string_table_t(
          pkg_CalendarEdit.Admin_RoleSName
        )
  );

  -- Id ��������� ��� ���� �� ������
  guestOperatorId integer := pkg_AccessOperatorTest.getTestOperatorId(
    baseName        => 'Guest'
    , roleSNameList => cmn_string_table_t()
  );



  /*
    ���������� ������ ��� �����.
  */
  procedure prepareData
  is
  begin
    delete
      cdr_day d
    where
      d.day between DATE '1980-01-01' and DATE '1980-12-31'
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� ������ ��� �����.'
        )
      , true
    );
  end prepareData;



  /*
    �������� ������ ������� ��� ���� ���������.
  */
  procedure testDayApi
  is

    day date;

    rc sys_refcursor;

  begin

    -- ��������
    day := pkg_CalendarEdit.createDay(
      day               =>
          to_date( '01.01.1980 10:30:00', 'dd.mm.yyyy hh24:mi:ss')
      , dayTypeId       => pkg_Calendar.PublicHoliday_DayTypeId
      , operatorId      => adminOperatorId
    );
    pkg_TestUtility.compareChar(
      actualString        => to_char( day, 'dd.mm.yyyy hh24:mi:ss')
        -- �������� ������ ���� �������� �� ���
      , expectedString    => '01.01.1980 00:00:00'
      , failMessageText   => 'createDay: ������������ ���������'
    );
    pkg_TestUtility.compareRowCount(
      tableName           => 'cdr_day'
      , filterCondition   =>
          'day = DATE ''1980-01-01'''
      , expectedRowCount  => 1
      , failMessageText   => 'createDay: ������ �� �������'
    );
    pkg_TestUtility.compareRowCount(
      tableName           => 'cdr_day'
      , filterCondition   =>
          'day = DATE ''1980-01-01'''
          || ' and day_type_id = ' || pkg_Calendar.PublicHoliday_DayTypeId
      , expectedRowCount  => 1
      , failMessageText   =>
          'createDay: ������������ ������ ������'
    );

    day := pkg_CalendarEdit.createDay(
      day               => DATE '1980-01-05'
      , dayTypeId       => pkg_Calendar.DayOff_DayTypeId
      , operatorId      => adminOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName           => 'cdr_day'
      , filterCondition   =>
          'day = DATE ''1980-01-05'''
          || ' and day_type_id = ' || pkg_Calendar.DayOff_DayTypeId
      , expectedRowCount  => 1
      , failMessageText   =>
          'createDay: ������������ ������ ������'
    );

    day := pkg_CalendarEdit.createDay(
      day               => DATE '1980-01-15'
      , dayTypeId       => pkg_Calendar.WorkingDay_DayTypeId
      , operatorId      => adminOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName           => 'cdr_day'
      , filterCondition   =>
          'day = DATE ''1980-01-15'''
          || ' and day_type_id = ' || pkg_Calendar.WorkingDay_DayTypeId
      , expectedRowCount  => 1
      , failMessageText   =>
          'createDay: ������������ ������ ������'
    );


    -- �����
    rc := pkg_CalendarEdit.findDay(
      day               => DATE '1980-01-01'
      , dayTypeId       => pkg_Calendar.PublicHoliday_DayTypeId
      , dateBegin       => DATE '1980-01-01'
      , dateEnd         => DATE '1980-01-01'
      , maxRowCount     => 10
      , operatorId      => guestOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 1
      , failMessageText       =>
          'findDay[ all args]: ������������ ���������'
    );

    rc := pkg_CalendarEdit.findDay(
      dateBegin         => DATE '1980-01-01'
      , dateEnd         => DATE '1980-01-30'
      , operatorId      => guestOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 3
      , failMessageText       =>
          'findDay[ period]: ������������ ���������'
    );


    -- ��������
    pkg_CalendarEdit.deleteDay(
      day               => DATE '1980-01-15'
      , operatorId      => adminOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName           => 'cdr_day'
      , filterCondition   =>
          'day = DATE ''1980-01-15'''
      , expectedRowCount  => 0
      , failMessageText   =>
          'deleteDay: ������������ ������ ������'
    );

    -- ����������
    rc := pkg_CalendarEdit.getDayType(
      operatorId            => guestOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 3
      , failMessageText       =>
          'getDayType: ������������ ���������'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ������� ��� ���� ���������.'
        )
      , true
    );
  end testDayApi;


-- testWebApi
begin

  -- ������� �������� ���������, ����� ����������� ������ �����
  -- web-���������
  currentOperatorId := pkg_Operator.getCurrentUserId();
  pkg_Operator.logoff();

  prepareData();

  pkg_TestUtility.beginTest( 'web API');

  testDayApi();

  pkg_TestUtility.endTest();

  -- ��������������� ����������� ���������
  pkg_Operator.setCurrentUserId( currentOperatorId);

  if coalesce( saveDataFlag, 0) != 1 then
    rollback;
  end if;
exception when others then
  pkg_Operator.setCurrentUserId( currentOperatorId);
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������������ API ��� web-����������.'
      )
    , true
  );
end testWebApi;

end pkg_CalendarTest;
/
