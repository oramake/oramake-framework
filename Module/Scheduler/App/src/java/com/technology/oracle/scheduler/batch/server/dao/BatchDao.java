package com.technology.oracle.scheduler.batch.server.dao;

import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_NAME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_SHORT_NAME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.DURATION_SECOND;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.ERROR_COUNT;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.ERROR_JOB_COUNT;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.FAILURES;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.IS_JOB_BROKEN;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.JOB;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.LAST_DATE;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.LAST_DATE_FROM;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.LAST_DATE_TO;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.LAST_LOG_DATE;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.LAST_START_DATE;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.MODULE_ID;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.MODULE_NAME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.NEXT_DATE;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.ORACLE_JOB_ID;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.RESULT_NAME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.RETRIAL_COUNT;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.RETRIAL_NUMBER;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.RETRIAL_TIMEOUT;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.ROOT_LOG_ID;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.SERIAL;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.SID;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.THIS_DATE;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.TOTAL_TIME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.WARNING_COUNT;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.technology.jep.jepria.server.dao.DaoSupport;
import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.oracle.scheduler.main.server.dao.SchedulerDao;

public class BatchDao extends SchedulerDao implements Batch {
 
  public List<JepRecord> find(JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin  " 
        +  "? := pkg_Scheduler.findBatch(" 
            + "batchId => ? " 
            + ", batchShortName => ? " 
            + ", batchName => ? " 
            + ", moduleId => ? " 
            + ", lastDateFrom => ? " 
            + ", lastDateTo => ? " 
            + ", retrialCount => ? " 
          + ", rowCount => ? " 
          + ", operatorId => ? " 
        + ");"
     + " end;";
    
    ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
      public void map(ResultSet rs, JepRecord record) throws SQLException {
        
        record.set(BATCH_ID, getInteger(rs, BATCH_ID));
        record.set(BATCH_SHORT_NAME, rs.getString(BATCH_SHORT_NAME));
        record.set(BATCH_NAME, rs.getString(BATCH_NAME));
        record.set(MODULE_NAME, rs.getString(MODULE_NAME));
        record.set(RETRIAL_COUNT, getInteger(rs, RETRIAL_COUNT));
        record.set(RETRIAL_TIMEOUT, rs.getString(RETRIAL_TIMEOUT));
        record.set(ORACLE_JOB_ID, getInteger(rs, ORACLE_JOB_ID));
        record.set(RETRIAL_NUMBER, getInteger(rs, RETRIAL_NUMBER));
        record.set(DATE_INS, getDate(rs, DATE_INS));
        record.set(OPERATOR_NAME, rs.getString(OPERATOR_NAME));
        record.set(JOB, getInteger(rs, JOB));
        record.set(LAST_DATE, getDate(rs, LAST_DATE));
        record.set(THIS_DATE, getDate(rs, THIS_DATE));
        record.set(NEXT_DATE, getDate(rs, NEXT_DATE));
        record.set(TOTAL_TIME, getInteger(rs, TOTAL_TIME));
        record.set(FAILURES, getInteger(rs, FAILURES));
        record.set(IS_JOB_BROKEN, getInteger(rs, IS_JOB_BROKEN));
        record.set(SID, getInteger(rs, SID));
        record.set(SERIAL, getInteger(rs, SERIAL));
        record.set(ROOT_LOG_ID, getInteger(rs, ROOT_LOG_ID));
        record.set(LAST_START_DATE, getDate(rs, LAST_START_DATE));
        record.set(LAST_LOG_DATE, getDate(rs, LAST_LOG_DATE));
        record.set(RESULT_NAME, rs.getString(RESULT_NAME));
        record.set(ERROR_JOB_COUNT, getInteger(rs, ERROR_JOB_COUNT));
        record.set(ERROR_COUNT, getInteger(rs, ERROR_COUNT));
        record.set(WARNING_COUNT, getInteger(rs, WARNING_COUNT));
        record.set(DURATION_SECOND, getInteger(rs, DURATION_SECOND));
      }
    };
    
    return super.find(
        sqlQuery,
        resultSetMapper
        , templateRecord.get(BATCH_ID)
        , templateRecord.get(BATCH_SHORT_NAME)
        , templateRecord.get(BATCH_NAME)
        , JepOption.<String>getValue(templateRecord.get(MODULE_ID))
        , templateRecord.get(LAST_DATE_FROM)
        , templateRecord.get(LAST_DATE_TO)
        , templateRecord.get(RETRIAL_COUNT)
        , maxRowCount 
        , operatorId);
  }
 
  public void update(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin " 
        +  "pkg_Scheduler.updateBatch(" 
            + "batchId => ? " 
            + ", batchName => ? " 
            + ", retrialCount => ? " 
            + ", retrialTimeout => to_dsinterval(?) " 
          + ", operatorId => ? " 
        + ");"
     + "end;";

    super.update(
        sqlQuery
        , record.get(BATCH_ID)
        , record.get(BATCH_NAME)
        , record.get(RETRIAL_COUNT)
        , record.get(RETRIAL_TIMEOUT)
        , operatorId);
  }
 
  @Override
  public void activateBatch(Integer batchId, Integer operatorId) throws ApplicationException {

    String sqlQuery = 
        " begin"
        + " pkg_Scheduler.ActivateBatch("
            + "batchId => ? " 
          + ", operatorId => ? " 
        + " );"
        + " end;";

    DaoSupport.execute(sqlQuery, batchId, operatorId);
  }

  @Override
  public void deactivateBatch(Integer batchId, Integer operatorId) throws ApplicationException {
    
    String sqlQuery = 
        " begin"
        + " pkg_Scheduler.DeactivateBatch("
            + "batchId => ? " 
          + ", operatorId => ? " 
        + " );"
        + " end;";

    DaoSupport.execute(sqlQuery, batchId, operatorId);
  }

  @Override
  public void executeBatch(Integer batchId, Integer operatorId) throws ApplicationException {

    String sqlQuery = 
        " begin"
        + " pkg_Scheduler.SetNextDate("
            + "batchId => ? " 
          + ", operatorId => ? " 
        + " );"
        + " end;";

    DaoSupport.execute(sqlQuery, batchId, operatorId);
  }

  @Override
  public void abortBatch(Integer batchId, Integer operatorId) throws ApplicationException {

    String sqlQuery = 
        " begin"
        + " pkg_Scheduler.AbortBatch("
            + "batchId => ? " 
          + ", operatorId => ? " 
        + " );"
        + " end;";

    DaoSupport.execute(sqlQuery, batchId, operatorId);
  }
}
