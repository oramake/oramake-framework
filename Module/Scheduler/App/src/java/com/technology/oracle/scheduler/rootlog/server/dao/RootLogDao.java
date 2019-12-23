package com.technology.oracle.scheduler.rootlog.server.dao;

import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.LOG_ID;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.MESSAGE_TEXT;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.MESSAGE_TYPE_NAME;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.OPERATOR_NAME;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.technology.jep.jepria.server.dao.JepDao;
import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;

public class RootLogDao extends JepDao implements RootLog {

  public List<JepRecord> find( JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
    String sqlQuery =
      "begin  "
        +  "? := pkg_Scheduler.findRootLog("
             + "batchId => ? "
          + ", maxRowCount => ? "
          + ", operatorId => ? "
        + ");"
     + " end;";

    ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
      public void map(ResultSet rs, JepRecord record) throws SQLException {
        record.set(LOG_ID, rs.getLong(LOG_ID));
        record.set(DATE_INS, rs.getTimestamp(DATE_INS));
        record.set(MESSAGE_TYPE_NAME, rs.getString(MESSAGE_TYPE_NAME));
        record.set(MESSAGE_TEXT, rs.getString(MESSAGE_TEXT));
        record.set(OPERATOR_NAME, rs.getString(OPERATOR_NAME));
      }
    };


    return super.find(
        sqlQuery
        , resultSetMapper
        , templateRecord.get(BATCH_ID)
        , 100
        , operatorId);
  }

  public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
    throw new UnsupportedOperationException();
  }

  public void update(JepRecord record, Integer operatorId) throws ApplicationException {
    throw new UnsupportedOperationException();
  }

  public Integer create(JepRecord record, Integer operatorId) throws ApplicationException {
    throw new UnsupportedOperationException();
  }

}
