package com.technology.oracle.scheduler.batch.shared.record;

import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.*;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.*;

import com.google.gwt.storage.client.Storage;
import com.google.gwt.user.client.Window;
import com.technology.jep.jepria.shared.field.JepTypeEnum;
import static com.technology.jep.jepria.shared.field.JepLikeEnum.*;
import static com.technology.oracle.scheduler.main.shared.SchedulerConstant.CURRENT_DATA_SOURCE;

import com.technology.jep.jepria.shared.field.JepLikeEnum;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
 
import java.util.HashMap;
import java.util.Map;
 
public class BatchRecordDefinition extends JepRecordDefinition {
 
  public static BatchRecordDefinition instance = new BatchRecordDefinition();
 
  private BatchRecordDefinition() {
    super(buildTypeMap()
      , new String[]{BATCH_ID}
    );
    super.setLikeMap(buildLikeMap());
  }
 
  private static Map<String, JepTypeEnum> buildTypeMap() {

    Map<String, JepTypeEnum> typeMap = new HashMap<String, JepTypeEnum>();
    typeMap.put(BATCH_ID, INTEGER);
    typeMap.put(BATCH_SHORT_NAME, STRING);
    typeMap.put(BATCH_NAME, STRING);
    typeMap.put(DATA_SOURCE, STRING);
    typeMap.put(MODULE_ID, INTEGER);
    typeMap.put(MODULE_NAME, STRING);
    typeMap.put(LAST_DATE_FROM, DATE);
    typeMap.put(LAST_DATE_TO, DATE);
    typeMap.put(RETRIAL_COUNT, INTEGER);
    typeMap.put(RETRIAL_TIMEOUT, STRING);
    typeMap.put(ORACLE_JOB_ID, INTEGER);
    typeMap.put(RETRIAL_NUMBER, INTEGER);
    typeMap.put(DATE_INS, DATE);
    typeMap.put(OPERATOR_ID, INTEGER);
    typeMap.put(OPERATOR_NAME, STRING);
    typeMap.put(JOB, INTEGER);
    typeMap.put(LAST_DATE, DATE);
    typeMap.put(THIS_DATE, DATE);
    typeMap.put(NEXT_DATE, DATE);
    typeMap.put(TOTAL_TIME, INTEGER);
    typeMap.put(FAILURES, INTEGER);
    typeMap.put(IS_JOB_BROKEN, INTEGER);
    typeMap.put(SID, INTEGER);
    typeMap.put(SERIAL, INTEGER);
    typeMap.put(ROOT_LOG_ID, INTEGER);
    typeMap.put(LAST_START_DATE, DATE);
    typeMap.put(LAST_LOG_DATE, DATE);
    typeMap.put(RESULT_NAME, STRING);
    typeMap.put(ERROR_JOB_COUNT, INTEGER);
    typeMap.put(ERROR_COUNT, INTEGER);
    typeMap.put(WARNING_COUNT, INTEGER);
    typeMap.put(DURATION_SECOND, INTEGER);
    typeMap.put(CURRENT_DATA_SOURCE, STRING);
    return typeMap;
  }
 
  private static Map<String, JepLikeEnum> buildLikeMap() {
    Map<String, JepLikeEnum> likeMap = new HashMap<String, JepLikeEnum>();
    likeMap.put(BATCH_SHORT_NAME, FIRST);
    likeMap.put(BATCH_NAME, FIRST);
    return likeMap;
  }

}
