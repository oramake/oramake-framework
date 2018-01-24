package com.technology.oracle.scheduler.batchrole.server.dao;

import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.BATCH_ROLE_ID;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.PRIVILEGE_CODE;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.PRIVILEGE_CODE_STR;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.PRIVILEGE_NAME;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.ROLE_ID;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.ROLE_NAME;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.ROLE_SHORT_NAME;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.oracle.scheduler.main.server.dao.SchedulerDao;

public class BatchRoleDao extends SchedulerDao implements BatchRole {

  public List<JepRecord> find( JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
    String sqlQuery =
      "begin  "
        +  "? := pkg_Scheduler.findBatchRole("
            + "batchRoleId => ? "
            + ", batchId => ? "
          + ", maxRowCount => ? "
          + ", operatorId => ? "
        + ");"
     + " end;";

    ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
      public void map(ResultSet rs, JepRecord record) throws SQLException {

        record.set(BATCH_ROLE_ID, getInteger(rs, BATCH_ROLE_ID));
        String privilegeCode = rs.getString(PRIVILEGE_CODE);
        record.set(PRIVILEGE_CODE_STR, privilegeCode);
        record.set(ROLE_SHORT_NAME, rs.getString(ROLE_SHORT_NAME));

        JepOption jepOption = new JepOption(rs.getString(PRIVILEGE_NAME), privilegeCode);
        record.set(PRIVILEGE_NAME, jepOption.getName());
        record.set(PRIVILEGE_CODE, jepOption);

        jepOption = new JepOption(rs.getString(ROLE_NAME), getInteger(rs, ROLE_ID));
        record.set(ROLE_NAME, jepOption.getName());
        record.set(ROLE_ID, jepOption);
        record.set(DATE_INS, getTimestamp(rs, DATE_INS));
        record.set(OPERATOR_NAME, rs.getString(OPERATOR_NAME));
      }
    };

    return super.find(
        sqlQuery
        , resultSetMapper
        , templateRecord.get(BATCH_ROLE_ID)
        , templateRecord.get(BATCH_ID)
        , maxRowCount
        , operatorId);
  }
  public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery =
      "begin "
        + "pkg_Scheduler.deleteBatchRole("
            + "batchRoleId => ? "
          + ", operatorId => ? "
        + ");"
      + "end;";

    super.delete(sqlQuery, record.get(BATCH_ROLE_ID), operatorId);
  }

  public void update(JepRecord record, Integer operatorId) throws ApplicationException {
    throw new UnsupportedOperationException();
  }

  public Integer create(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery =
      "begin "
        + "? := pkg_Scheduler.createBatchRole("
            + "batchId => ? "
            + ", privilegeCode => ? "
            + ", roleId => ? "
          + ", operatorId => ? "
        + ");"
      + "end;";

    return super.<Integer> create(sqlQuery,
        Integer.class
        , record.get(BATCH_ID)
        ,  JepOption.<String>getValue(record.get(PRIVILEGE_CODE))
        ,  JepOption.<Integer>getValue(record.get(ROLE_ID))
        , operatorId);
  }

}
