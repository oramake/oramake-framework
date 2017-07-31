package com.technology.oracle.scheduler.interval.shared.record;
 
import static com.technology.jep.jepria.shared.field.JepTypeEnum.DATE;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.INTEGER;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.STRING;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.INTERVAL_ID;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.INTERVAL_TYPE_CODE;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.INTERVAL_TYPE_NAME;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.MAX_VALUE;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.MIN_VALUE;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.OPERATOR_ID;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.SCHEDULE_ID;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.STEP;

import java.util.HashMap;
import java.util.Map;

import com.technology.jep.jepria.shared.field.JepTypeEnum;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
 
public class IntervalRecordDefinition extends JepRecordDefinition {
 
  public static IntervalRecordDefinition instance = new IntervalRecordDefinition();
 
  private IntervalRecordDefinition() {
    super(buildTypeMap()
      , new String[]{INTERVAL_ID}
    );
  }
 
  private static Map<String, JepTypeEnum> buildTypeMap() {
    Map<String, JepTypeEnum> typeMap = new HashMap<String, JepTypeEnum>();
    typeMap.put(INTERVAL_ID, INTEGER);
    typeMap.put(SCHEDULE_ID, INTEGER);
    typeMap.put(INTERVAL_TYPE_CODE, STRING);
    typeMap.put(INTERVAL_TYPE_NAME, STRING);
    typeMap.put(MIN_VALUE, INTEGER);
    typeMap.put(MAX_VALUE, INTEGER);
    typeMap.put(STEP, INTEGER);
    typeMap.put(DATE_INS, DATE);
    typeMap.put(OPERATOR_ID, INTEGER);
    typeMap.put(OPERATOR_NAME, STRING);
    return typeMap;
  }
}
