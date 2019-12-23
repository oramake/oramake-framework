package com.technology.oracle.scheduler.moduleroleprivilege.server.dao;

import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.MODULE_ID;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.MODULE_NAME;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.MODULE_ROLE_PRIVILEGE_ID;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.PRIVILEGE_CODE;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.PRIVILEGE_CODE_STR;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.PRIVILEGE_NAME;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.ROLE_ID;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.ROLE_NAME;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.ROLE_SHORT_NAME;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.oracle.scheduler.main.server.dao.SchedulerDao;

public class ModuleRolePrivilegeDao extends SchedulerDao implements ModuleRolePrivilege {

  public List<JepRecord> find( JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
    String sqlQuery =
      "begin  "
        +  "? := pkg_Scheduler.findModuleRolePrivilege("
            + "moduleRolePrivilegeId => ? "
            + ", moduleId => ? "
            + ", privilegeCode => ? "
            + ", roleId => ? "
          + ", maxRowCount => ? "
          + ", operatorId => ? "
        + ");"
     + " end;";

    ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
      public void map(ResultSet rs, JepRecord record) throws SQLException {

        record.set(MODULE_ROLE_PRIVILEGE_ID, getInteger(rs, MODULE_ROLE_PRIVILEGE_ID));

        JepOption jepOption = new JepOption(rs.getString(MODULE_NAME), getInteger(rs, MODULE_ID));
        record.set(MODULE_ID, jepOption);
        record.set(MODULE_NAME, jepOption.getName());

        String privilegeCode = rs.getString(PRIVILEGE_CODE);
        jepOption = new JepOption(rs.getString(PRIVILEGE_NAME), rs.getString(PRIVILEGE_CODE));
        record.set(PRIVILEGE_CODE_STR, privilegeCode);
        record.set(PRIVILEGE_CODE, jepOption);
        record.set(PRIVILEGE_NAME, jepOption.getName());

        record.set(ROLE_SHORT_NAME, rs.getString(ROLE_SHORT_NAME));

        jepOption = new JepOption(rs.getString(ROLE_NAME), getInteger(rs, ROLE_ID));
        record.set(ROLE_ID, jepOption);
        record.set(ROLE_NAME, jepOption.getName());

        record.set(DATE_INS, rs.getTimestamp(DATE_INS));
        record.set(OPERATOR_NAME, rs.getString(OPERATOR_NAME));
      }
    };

    return super.find(
        sqlQuery
        , resultSetMapper
        , templateRecord.get(MODULE_ROLE_PRIVILEGE_ID)
        , JepOption.<Integer>getValue(templateRecord.get(MODULE_ID))
        , JepOption.<String>getValue(templateRecord.get(PRIVILEGE_CODE))
        , JepOption.<Integer>getValue(templateRecord.get(ROLE_ID))
        , maxRowCount
        , operatorId);
  }
  public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery =
      "begin "
        + "pkg_Scheduler.deleteModuleRolePrivilege("
            + "moduleRolePrivilegeId => ? "
          + ", operatorId => ? "
        + ");"
      + "end;";

    super.delete(sqlQuery, record.get(MODULE_ROLE_PRIVILEGE_ID), operatorId);
  }

  public void update(JepRecord record, Integer operatorId) throws ApplicationException {
    throw new UnsupportedOperationException();
  }

  public Integer create(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery =
      "begin "
        + "? := pkg_Scheduler.createModuleRolePrivilege("
            + "moduleId => ? "
            + ", privilegeCode => ? "
            + ", roleId => ? "
          + ", operatorId => ? "
        + ");"
      + "end;";

    return super.<Integer> create(sqlQuery,
        Integer.class
        , JepOption.<Integer>getValue(record.get(MODULE_ID))
        , JepOption.<String>getValue(record.get(PRIVILEGE_CODE))
        , JepOption.<Integer>getValue(record.get(ROLE_ID))
        , operatorId);
  }
}
