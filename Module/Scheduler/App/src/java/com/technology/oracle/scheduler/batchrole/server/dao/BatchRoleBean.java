package com.technology.oracle.scheduler.batchrole.server.dao;
 
import static com.technology.oracle.scheduler.batch.server.BatchServerConstant.PREFIX_DATA_SOURCE_JNDI_NAME;
import static com.technology.oracle.scheduler.batchrole.server.BatchRoleServerConstant.DATA_SOURCE_JNDI_NAME;
import static com.technology.oracle.scheduler.batchrole.server.BatchRoleServerConstant.RESOURCE_BUNDLE_NAME;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.*;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.DATA_SOURCE;

import javax.ejb.Local;
import javax.ejb.Remote;
import javax.ejb.Stateless;

import oracle.j2ee.ejb.StatelessDeployment;

import com.technology.jep.jepria.server.ejb.JepDataStandardBean;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.oracle.scheduler.batchrole.server.dao.BatchRole;
import com.technology.jep.jepria.server.dao.DaoSupport;
import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.scheduler.batchrole.shared.field.PrivilegeOptions;
import com.technology.oracle.scheduler.batchrole.shared.field.RoleOptions;
import com.technology.oracle.scheduler.main.server.dao.SchedulerDao;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
 
@Local( { BatchRoleLocal.class })
@Remote( { BatchRoleRemote.class })
@StatelessDeployment
@Stateless
public class BatchRoleBean extends SchedulerDao implements BatchRole {
 
  public BatchRoleBean() {
    super(DATA_SOURCE_JNDI_NAME, RESOURCE_BUNDLE_NAME);
  }
 
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
    
    
    final String dataSource = getValueFromOption(templateRecord.get(DATA_SOURCE));
    ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
      public void map(ResultSet rs, JepRecord record) throws SQLException {
        
        JepOption jepOption = new JepOption(dataSource, dataSource);
        record.set(DATA_SOURCE, jepOption);

        record.set(BATCH_ROLE_ID, getInteger(rs, BATCH_ROLE_ID));
        String privilegeCode = rs.getString(PRIVILEGE_CODE);
        record.set(PRIVILEGE_CODE_STR, privilegeCode);
        record.set(ROLE_SHORT_NAME, rs.getString(ROLE_SHORT_NAME));
        
        jepOption = new JepOption(rs.getString(PRIVILEGE_NAME), privilegeCode);
        record.set(PRIVILEGE_NAME, jepOption.getName());
        record.set(PRIVILEGE_CODE, jepOption);
        
        jepOption = new JepOption(rs.getString(ROLE_NAME), getInteger(rs, ROLE_ID));
        record.set(ROLE_NAME, jepOption.getName());
        record.set(ROLE_ID, jepOption);
        record.set(DATE_INS, getDate(rs, DATE_INS));
        record.set(OPERATOR_NAME, rs.getString(OPERATOR_NAME));
      }
    };
    
    return DaoSupport.find(
        sqlQuery,
        sessionContext,
        PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
        resourceBundleName,
        resultSetMapper,
        JepRecord.class
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
    
    DaoSupport.delete(
        sqlQuery,
        sessionContext,
        PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(record.get(DATA_SOURCE)),
        resourceBundleName
        , record.get(BATCH_ROLE_ID) 
        , operatorId);
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
    
    return DaoSupport.<Integer> create(sqlQuery,
        sessionContext,
        PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(record.get(DATA_SOURCE)),
        resourceBundleName,
        Integer.class 
        , record.get(BATCH_ID)
        , getValueFromOption(record.get(PRIVILEGE_CODE))
        , getValueFromOption(record.get(ROLE_ID))
        , operatorId);
  }
 
}
