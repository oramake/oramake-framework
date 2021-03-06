package com.technology.oracle.scheduler.rootlog.shared.record;
 
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.*;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.*;

import com.technology.jep.jepria.shared.field.JepTypeEnum;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
 
import java.util.HashMap;
import java.util.Map;
 
public class RootLogRecordDefinition extends JepRecordDefinition {
 
  public static RootLogRecordDefinition instance = new RootLogRecordDefinition();
 
  private RootLogRecordDefinition() {
    super(buildTypeMap()
      , new String[]{LOG_ID}
    );
  }
 
  private static Map<String, JepTypeEnum> buildTypeMap() {
    Map<String, JepTypeEnum> typeMap = new HashMap<String, JepTypeEnum>();
    typeMap.put(LOG_ID, INTEGER);
    typeMap.put(DATE_INS, DATE_TIME);
    typeMap.put(MESSAGE_TYPE_NAME, STRING);
    typeMap.put(MESSAGE_TEXT, STRING);
    typeMap.put(OPERATOR_NAME, STRING);
    return typeMap;
  }
}
