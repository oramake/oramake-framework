package com.technology.oracle.scheduler.interval.server.dao;
 
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.INTERVAL_ID;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.INTERVAL_TYPE_CODE;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.INTERVAL_TYPE_NAME;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.MAX_VALUE;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.MIN_VALUE;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.SCHEDULE_ID;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.STEP;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.oracle.scheduler.interval.shared.field.IntervalTypeOptions;
import com.technology.oracle.scheduler.main.server.dao.SchedulerDao;

public class IntervalDao extends SchedulerDao implements Interval {

  public List<JepRecord> find( JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin  " 
        +  "? := pkg_Scheduler.findInterval(" 
            + "intervalId => ? " 
            + ", scheduleId => ? " 
          + ", maxRowCount => ? " 
          + ", operatorId => ? " 
        + ");"
     + " end;";
    
    ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
      public void map(ResultSet rs, JepRecord record) throws SQLException {
        
        record.set(INTERVAL_ID, getInteger(rs, INTERVAL_ID));
        
        JepOption jepOption = new JepOption(rs.getString(INTERVAL_TYPE_NAME), rs.getString(INTERVAL_TYPE_CODE));
        record.set(INTERVAL_TYPE_NAME, jepOption.getName());
        record.set(INTERVAL_TYPE_CODE, jepOption);
        
        record.set(MIN_VALUE, getInteger(rs, MIN_VALUE));
        record.set(MAX_VALUE, getInteger(rs, MAX_VALUE));
        record.set(STEP, getInteger(rs, STEP));
        record.set(DATE_INS, getDate(rs, DATE_INS));
        record.set(OPERATOR_NAME, rs.getString(OPERATOR_NAME));
      }
    };
    
    return super.find(
        sqlQuery
        , resultSetMapper
        , templateRecord.get(INTERVAL_ID)
        , templateRecord.get(SCHEDULE_ID)
        , maxRowCount 
        , operatorId);
    
  }
  
  public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin " 
        + "pkg_Scheduler.deleteInterval(" 
            + "intervalId => ? " 
          + ", operatorId => ? " 
        + ");"
      + "end;";
    
    super.delete(sqlQuery, record.get(INTERVAL_ID), operatorId);
  }
 
  public void update(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin " 
        +  "pkg_Scheduler.updateInterval(" 
            + "intervalId => ? " 
            + ", intervalTypeCode => ? " 
            + ", minValue => ? " 
            + ", maxValue => ? " 
            + ", step => ? " 
          + ", operatorId => ? " 
        + ");"
     + "end;";
    
    super.update(
        sqlQuery
        , record.get(INTERVAL_ID)
        ,  JepOption.<String>getValue(record.get(INTERVAL_TYPE_CODE))
        , record.get(MIN_VALUE)
        , record.get(MAX_VALUE)
        , record.get(STEP)
        , operatorId);
  }
 
  public Integer create(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin " 
        + "? := pkg_Scheduler.createInterval(" 
            + "scheduleId => ? " 
            + ", intervalTypeCode => ? " 
            + ", minValue => ? " 
            + ", maxValue => ? " 
            + ", step => ? " 
          + ", operatorId => ? " 
        + ");"
      + "end;";
    
    return super.<Integer>create(sqlQuery,
        Integer.class 
        , record.get(SCHEDULE_ID)
        ,  JepOption.<String>getValue(record.get(INTERVAL_TYPE_CODE))
        , record.get(MIN_VALUE)
        , record.get(MAX_VALUE)
        , record.get(STEP)
        , operatorId);
  }
 
 
  public List<JepOption> getIntervalType() throws ApplicationException {
    String sqlQuery = 
      " begin " 
      + " ? := pkg_Scheduler.getIntervalType;" 
      + " end;";
 
    return super.getOptions(
        sqlQuery,
        new ResultSetMapper<JepOption>() {
          public void map(ResultSet rs, JepOption dto) throws SQLException {
            dto.setValue(rs.getString(IntervalTypeOptions.INTERVAL_TYPE_CODE));
            dto.setName(rs.getString(IntervalTypeOptions.INTERVAL_TYPE_NAME));
          }
        }
    );
  }
}
