package com.technology.oracle.scheduler.schedule.shared.record;
 
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.*;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.*;

import com.technology.jep.jepria.shared.field.JepTypeEnum;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
 
import java.util.HashMap;
import java.util.Map;
 
public class ScheduleRecordDefinition extends JepRecordDefinition {
 
  private static final long serialVersionUID = 1L;
 
  public static ScheduleRecordDefinition instance = new ScheduleRecordDefinition();
 
  private ScheduleRecordDefinition() {
    super(buildTypeMap()
      , new String[]{SCHEDULE_ID}
    );
  }
 
  private static Map<String, JepTypeEnum> buildTypeMap() {
    Map<String, JepTypeEnum> typeMap = new HashMap<String, JepTypeEnum>();
    typeMap.put(SCHEDULE_ID, INTEGER);
    typeMap.put(BATCH_ID, INTEGER);
    typeMap.put(SCHEDULE_NAME, STRING);
    typeMap.put(DATE_INS, DATE);
    typeMap.put(OPERATOR_ID, INTEGER);
    typeMap.put(OPERATOR_NAME, STRING);

    typeMap.put(DATA_SOURCE, STRING);
    return typeMap;
  }
}
