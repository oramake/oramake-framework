package com.technology.oracle.scheduler.schedule.server.dao;

import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.SCHEDULE_ID;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.SCHEDULE_NAME;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.oracle.scheduler.main.server.dao.SchedulerDao;

public class ScheduleDao extends SchedulerDao implements Schedule {

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

    ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
      public void map(ResultSet rs, JepRecord record) throws SQLException {
        record.set(SCHEDULE_ID, getInteger(rs, SCHEDULE_ID));
        record.set(SCHEDULE_NAME, rs.getString(SCHEDULE_NAME));
        record.set(DATE_INS, rs.getTimestamp(DATE_INS));
        record.set(OPERATOR_NAME, rs.getString(OPERATOR_NAME));
      }
    };

    return super.find(
        sqlQuery
        , resultSetMapper
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

    super.delete(sqlQuery, record.get(SCHEDULE_ID), operatorId);
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

    super.update(
        sqlQuery
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

    return super.<Integer> create(sqlQuery, Integer.class
        , record.get(BATCH_ID)
        , record.get(SCHEDULE_NAME)
        , operatorId);
  }

}
