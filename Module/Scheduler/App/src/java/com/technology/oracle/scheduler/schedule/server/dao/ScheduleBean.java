package com.technology.oracle.scheduler.schedule.server.dao;
 
import static com.technology.oracle.scheduler.batch.server.BatchServerConstant.PREFIX_DATA_SOURCE_JNDI_NAME;
import static com.technology.oracle.scheduler.schedule.server.ScheduleServerConstant.DATA_SOURCE_JNDI_NAME;
import static com.technology.oracle.scheduler.schedule.server.ScheduleServerConstant.RESOURCE_BUNDLE_NAME;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.*;

import javax.ejb.Local;
import javax.ejb.Remote;
import javax.ejb.Stateless;
import javax.naming.InitialContext;
import javax.naming.NameClassPair;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;

import oracle.j2ee.ejb.StatelessDeployment;

import com.technology.jep.jepria.server.ejb.JepDataStandardBean;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.oracle.scheduler.main.server.dao.SchedulerDao;
import com.technology.oracle.scheduler.schedule.server.dao.Schedule;
import com.technology.jep.jepria.server.dao.DaoSupport;
import com.technology.jep.jepria.server.dao.ResultSetMapper;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
 
@Local( { ScheduleLocal.class })
@Remote( { ScheduleRemote.class })
@StatelessDeployment
@Stateless
public class ScheduleBean extends SchedulerDao implements Schedule {
 
  public ScheduleBean() {
    super(DATA_SOURCE_JNDI_NAME, RESOURCE_BUNDLE_NAME);
  }
 
  
  public List<JepRecord> find( JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin  " 
        +  "? := pkg_Scheduler.findSchedule(" 
            + "scheduleId => ? " 
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
        
        record.set(SCHEDULE_ID, getInteger(rs, SCHEDULE_ID));
        record.set(SCHEDULE_NAME, rs.getString(SCHEDULE_NAME));
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
        , templateRecord.get(SCHEDULE_ID)
        , templateRecord.get(BATCH_ID)
        , maxRowCount 
        , operatorId);
  }
  public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin " 
        + "pkg_Scheduler.deleteSchedule(" 
            + "scheduleId => ? " 
          + ", operatorId => ? " 
        + ");"
      + "end;";
    
    DaoSupport.delete(
        sqlQuery,
        sessionContext,
        PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(record.get(DATA_SOURCE)),
        resourceBundleName
        , record.get(SCHEDULE_ID) 
        , operatorId);
  }
 
  public void update(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin " 
        +  "pkg_Scheduler.updateSchedule(" 
            + "scheduleId => ? " 
            + ", scheduleName => ? " 
          + ", operatorId => ? " 
        + ");"
     + "end;";
    
    DaoSupport.update(
        sqlQuery,
        sessionContext,
        PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(record.get(DATA_SOURCE)),
        resourceBundleName
        , record.get(SCHEDULE_ID)
        , record.get(SCHEDULE_NAME)
        , operatorId);
  }
 
  public Integer create(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin " 
        + "? := pkg_Scheduler.createSchedule(" 
            + "batchId => ? " 
            + ", scheduleName => ? " 
          + ", operatorId => ? " 
        + ");"
      + "end;";
    
    return DaoSupport.<Integer> create(sqlQuery,
        sessionContext,
        PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(record.get(DATA_SOURCE)),
        resourceBundleName,
        Integer.class 
        , record.get(BATCH_ID)
        , record.get(SCHEDULE_NAME)
        , operatorId);
  }
 
}
