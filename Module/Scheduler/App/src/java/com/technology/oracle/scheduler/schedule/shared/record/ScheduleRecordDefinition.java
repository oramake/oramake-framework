package com.technology.oracle.scheduler.schedule.shared.record;
 
import static com.technology.jep.jepria.shared.field.JepTypeEnum.DATE;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.INTEGER;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.STRING;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.OPERATOR_ID;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.SCHEDULE_ID;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.SCHEDULE_NAME;

import java.util.HashMap;
import java.util.Map;

import com.technology.jep.jepria.shared.field.JepTypeEnum;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
 
public class ScheduleRecordDefinition extends JepRecordDefinition {
 
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
    return typeMap;
  }
}
