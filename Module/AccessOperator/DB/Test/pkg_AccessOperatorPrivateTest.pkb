create or replace package body pkg_AccessOperatorPrivateTest is

/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_AccessOperator.Module_Name
  , objectName  => 'pkg_AccessOperatorPrivateTest'
);



/* group: Функции */

/* pproc: testAdminOperation
  Тестирует функции создания/редактирования/удаления
  операторов/ролей/групп.
*/
procedure testAdminOperation
is
  -- Тестовые данные
  birthPlace varchar2(20) := '_AccessOperator';
  -- Роли
  testRoleName1 op_role.role_name%type := 'Role Name 1' || birthPlace;
  testShortName1 op_role.short_name%type := 'RoleShortName1';
  testDescription1 op_role.description%type := 'Description for Role 1';
  roleId1 op_role.role_id%type;
  testRoleName2 op_role.role_name%type := 'Role Name 2' || birthPlace;
  testShortName2 op_role.short_name%type := 'RoleShortName2';
  testDescription2 op_role.description%type := 'Description for Role 2';
  roleId2 op_role.role_id%type;
  -- Операторы
  testOperatorName1 op_operator.operator_name%type := 'Operator Name 1' || birthPlace;
  testLogin1 op_operator.login%type := 'Login1' || birthPlace;
  testPassword1 op_operator.password%type := 'Password1';
  operatorId1 op_operator.operator_id%type;
  testOperatorName2 op_operator.operator_name%type := 'Operator Name 2' || birthPlace;
  testLogin2 op_operator.login%type := 'Login2' || birthPlace;
  testPassword2 op_operator.password%type := 'Password2';
  operatorId2 op_operator.operator_id%type;
  testOperatorName3 op_operator.operator_name%type := 'Operator Name 3' || birthPlace;
  testLogin3 op_operator.login%type := 'Login3' || birthPlace;
  testPassword3 op_operator.password%type := 'Password3';
  operatorId3 op_operator.operator_id%type;
  -- Группы
  groupId1 op_group.group_id%type;
  testGroupName1 op_group.group_name%type := 'Group Name 1' || birthPlace;

  /*
    Тестирование создания операторов
  */
  procedure checkCreateOperator
  is
  begin
    pkg_TestUtility.beginTest('create operator');
    operatorId1 := pkg_AccessOperator.createOperator(
      operatorName => testOperatorName1
      , operatorNameEn => testOperatorName1
      , login => testLogin1
      , password => testPassword1
      , changePassword => 0
      , operatorIdIns => pkg_Operator.getCurrentUserId()
    );
    operatorId2 := pkg_AccessOperator.createOperator(
      operatorName => testOperatorName2
      , operatorNameEn => testOperatorName2
      , login => testLogin2
      , password => testPassword2
      , changePassword => 0
      , operatorIdIns => pkg_Operator.getCurrentUserId()
    );
    operatorId3 := pkg_AccessOperator.createOperator(
      operatorName => testOperatorName3
      , operatorNameEn => testOperatorName3
      , login => testLogin3
      , password => testPassword3
      , changePassword => 0
      , operatorIdIns => pkg_Operator.getCurrentUserId()
    );
    pkg_TestUtility.endTest();
  exception
    when others then
      pkg_TestUtility.failTest( 'Exception: ' || pkg_Logging.getErrorStack());
  end checkCreateOperator;
  
  /*
    Тестирование создания ролей
  */
  procedure checkCreateRole
  is
  begin
    pkg_TestUtility.beginTest('create role');
    roleId1 := pkg_AccessOperator.createRole(
      roleName => testRoleName1
      , roleNameEn => testRoleName1
      , shortName => testShortName1
      , description => testDescription1
      , operatorId => pkg_Operator.getCurrentUserId()
    );
    roleId2 := pkg_AccessOperator.createRole(
      roleName => testRoleName2
      , roleNameEn => testRoleName2
      , shortName => testShortName2
      , description => testDescription2
      , operatorId => pkg_Operator.getCurrentUserId()
    );
    pkg_TestUtility.endTest();
  exception
    when others then
      pkg_TestUtility.failTest( 'Exception: ' || pkg_Logging.getErrorStack());
  end checkCreateRole;

  
  /*
    Тестировнаие создания групп
  */
  procedure checkCreateGroup
  is
  begin
    pkg_TestUtility.beginTest('create group');
    groupId1 := pkg_AccessOperator.createGroup(
      groupName => testGroupName1
      , groupNameEn => testGroupName1
      , operatorId => pkg_Operator.getCurrentUserId()
    );
    pkg_TestUtility.endTest();
  exception
    when others then
      pkg_TestUtility.failTest( 'Exception: ' || pkg_Logging.getErrorStack());
  end checkCreateGroup;
  
  /*
    Тестирование выдачи полномочий на роли и группы
  */
  procedure checkCreateGrant(
    testName varchar2
    , operatorId op_operator.operator_id%type
    , targetOperatorId op_operator.operator_id%type
    , roleId op_role.role_id%type default null
    , groupId op_group.group_id%type default null
    , isExceptionResult boolean default null
  )
  is
  begin
    pkg_TestUtility.beginTest(testName);
    if roleId is not null then
      pkg_AccessOperator.createOperatorRole(
        operatorId => targetOperatorId
        , roleId => roleId
        , userAccessFlag => 1
        , grantOptionFlag => 1
        , operatorIdIns => operatorId
      );
    end if;
    if groupId is not null then
      pkg_AccessOperator.createOperatorGroup(
        operatorId => targetOperatorId
        , groupId => groupId
        , userAccessFlag => 1
        , grantOptionFlag => 1
        , operatorIdIns => operatorId
      );
    end if;
    if isExceptionResult then
      pkg_TestUtility.failTest( 'Must be exception as result' );
    end if;
    pkg_TestUtility.endTest();
  exception
    when others then
      if isExceptionResult then
        logger.trace( 'Message: ' || pkg_Logging.getErrorStack());
        pkg_TestUtility.endTest();
      else
        pkg_TestUtility.failTest( 'Exception: ' || pkg_Logging.getErrorStack());
      end if;
  end checkCreateGrant;
  
  /*
    Тестирование удаления операторов
  */
  procedure checkDeleteOperator
  is
  begin
    pkg_TestUtility.beginTest('delete operator');
    pkg_AccessOperator.deleteOperator(
      operatorId => operatorId1
      , operatorIdIns => pkg_Operator.getCurrentUserId() 
      , operatorComment => 'test record' || birthPlace
    );
    pkg_AccessOperator.deleteOperator(
      operatorId => operatorId2
      , operatorIdIns => pkg_Operator.getCurrentUserId() 
      , operatorComment => 'test record' || birthPlace
    );
    pkg_AccessOperator.deleteOperator(
      operatorId => operatorId3
      , operatorIdIns => pkg_Operator.getCurrentUserId() 
      , operatorComment => 'test record' || birthPlace
    );
    pkg_TestUtility.endTest();
  exception
    when others then
      pkg_TestUtility.failTest( 'Exception: ' || pkg_Logging.getErrorStack());
  end checkDeleteOperator;
  
  /*
    Тестирование удаления ролей
  */
  procedure checkDeleteRole
  is
  begin
    pkg_TestUtility.beginTest('delete role');
    pkg_AccessOperator.deleteRole(
      roleId => roleId1
      , operatorId => pkg_Operator.getCurrentUserId() 
    );
    pkg_AccessOperator.deleteRole(
      roleId => roleId2
      , operatorId => pkg_Operator.getCurrentUserId() 
    );
    pkg_TestUtility.endTest();
  exception
    when others then
      pkg_TestUtility.failTest( 'Exception: ' || pkg_Logging.getErrorStack());
  end checkDeleteRole;
  
  /*
    Тестирование удаления групп
  */
  procedure checkDeleteGroup
  is
  begin
    pkg_TestUtility.beginTest('delete group');
    pkg_AccessOperator.deleteGroup(
      groupId => groupId1
      , operatorId => pkg_Operator.getCurrentUserId() 
    );
    pkg_TestUtility.endTest();
  exception
    when others then
      pkg_TestUtility.failTest( 'Exception: ' || pkg_Logging.getErrorStack());
   end checkDeleteGroup;

  /*
    Удаление(физическое) тестовых данных
  */
  procedure deleteTestData
  is
  begin
    delete from
      op_operator_role
    where 
      operator_id in (
        select 
          operator_id
        from
          op_operator
        where 
          operator_name like '%' || birthPlace || '%'
      )
    ;
    delete from
      op_operator_group
    where 
      operator_id in (
        select 
          operator_id
        from
          op_operator
        where 
          operator_name like '%' || birthPlace || '%'
      )
    ;
    delete from
      op_operator
    where 
      operator_name like '%' || birthPlace || '%'
    ;
    delete from 
      op_role 
    where 
      role_name like '%' || birthPlace || '%'
    ;
    delete from 
      op_group 
    where 
      group_name like '%' || birthPlace || '%'
    ;
  end deleteTestData;
-- testAdminOperation
begin
  -- Тестирование создания опреаторов/ролей/групп
  checkCreateRole();
  checkCreateGroup();
  checkCreateOperator();
  
  -- Настройка прав пользователей перед тестированием
  checkCreateGrant( 
    testName => 'Grant UserAdmin to Operator1'
    , operatorId => pkg_Operator.getCurrentUserId()
    , targetOperatorId => operatorId1
    , roleId => pkg_Operator.getRoleId('UserAdmin')
  );
  checkCreateGrant( 
    testName => 'Grant UserAdmin to Operator2'
    , operatorId => pkg_Operator.getCurrentUserId()
    , targetOperatorId => operatorId2
    , roleId => pkg_Operator.getRoleId('UserAdmin')
  );
  checkCreateGrant( 
    testName => 'Grant grant_option on Role1 to Operator1'
    , operatorId => pkg_Operator.getCurrentUserId()
    , targetOperatorId => operatorId1
    , roleId => roleId1
  );
  checkCreateGrant( 
    testName => 'Grant grant_option on Role2 to Operator1'
    , operatorId => pkg_Operator.getCurrentUserId()
    , targetOperatorId => operatorId1
    , roleId => roleId2
  );
  checkCreateGrant( 
    testName => 'Grant grant_option on Role1 to Operator2'
    , operatorId => pkg_Operator.getCurrentUserId()
    , targetOperatorId => operatorId2
    , roleId => roleId1
  );
  -- Тестирование полномочий на выдачу ролей и групп 
  checkCreateGrant( 
    testName => 'Grant Role1 from Operator1 to Operator3'
    , operatorId => operatorId1
    , targetOperatorId => operatorId3
    , roleId => roleId1
  );
  checkCreateGrant( 
    testName => 'Grant Role2 from Operator1 to Operator3'
    , operatorId => operatorId1
    , targetOperatorId => operatorId3
    , roleId => roleId2
  );
    checkCreateGrant( 
    testName => 'Grant Role1 from Operator2 to Operator3'
    , operatorId => operatorId2
    , targetOperatorId => operatorId3
    , roleId => roleId1
  );
  checkCreateGrant( 
    testName => 'Can''t grant Role2 from Operator2 to Operator3'
    , operatorId => operatorId2
    , targetOperatorId => operatorId3
    , roleId => roleId2
    , isExceptionResult => true
  );

  -- Тестирование удаления опреаторов/ролей/групп
  checkDeleteOperator();
  checkDeleteRole();
  checkDeleteGroup();
  
  -- Подчистка тестовых данных
  deleteTestData();
exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Во время тестирования функций создания/редактирования/удаления ' 
          || ' операторов/ролей/групп произошла ошибка.'
        )
      , true
    );
end testAdminOperation;

end pkg_AccessOperatorPrivateTest;
/
