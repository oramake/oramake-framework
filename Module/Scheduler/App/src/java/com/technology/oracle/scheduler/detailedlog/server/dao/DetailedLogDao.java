package com.technology.oracle.scheduler.detailedlog.server.dao;

import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.LOG_ID;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.LOG_LEVEL;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.MESSAGE_TEXT;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.MESSAGE_TYPE_NAME;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.MESSAGE_VALUE;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.PARENT_LOG_ID;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.technology.jep.jepria.server.dao.JepDao;
import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;

public class DetailedLogDao extends JepDao implements DetailedLog {

  public List<JepRecord> find( JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
    String sqlQuery =
      "begin  "
        +  "? := pkg_Scheduler.GetDetailedLog("
            + "parentLogId => ? "
          + ", operatorId => ? "
        + ");"
     + " end;";

    ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
      public void map(ResultSet rs, JepRecord record) throws SQLException {

        Integer logLevel = getInteger(rs, LOG_LEVEL);
        //в зависимости от уровня иерархии дополняем текст сообщения пробелами.
        String messageText = new String();
        for (int i = 0; i < logLevel; i++){
          if (i == 0)
            messageText = "&nbsp;<!-- в зависимости от уровня иерархии дополняем текст сообщения пробелами. -->";
          else
            messageText += "&nbsp;&nbsp;&nbsp;";
        }

        record.set(LOG_ID, rs.getLong(LOG_ID));
        record.set(PARENT_LOG_ID, rs.getLong(PARENT_LOG_ID));
        record.set(DATE_INS, rs.getTimestamp(DATE_INS));
        record.set(MESSAGE_TEXT, messageText + rs.getString(MESSAGE_TEXT));
        record.set(MESSAGE_VALUE, rs.getString(MESSAGE_VALUE));
        record.set(MESSAGE_TYPE_NAME, rs.getString(MESSAGE_TYPE_NAME));
        record.set(OPERATOR_NAME, rs.getString(OPERATOR_NAME));
      }
    };


    return super.find(
        sqlQuery
        , resultSetMapper
        , templateRecord.get(LOG_ID)
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
