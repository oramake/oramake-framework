package com.technology.oracle.scheduler.batchrole.shared.record;
 
import static com.technology.jep.jepria.shared.field.JepTypeEnum.DATE;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.INTEGER;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.STRING;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.BATCH_ROLE_ID;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.OPERATOR_ID;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.PRIVILEGE_CODE;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.PRIVILEGE_NAME;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.ROLE_ID;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.ROLE_NAME;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.ROLE_SHORT_NAME;
import static com.technology.oracle.scheduler.main.shared.SchedulerConstant.CURRENT_DATA_SOURCE;

import java.util.HashMap;
import java.util.Map;

import com.technology.jep.jepria.shared.field.JepTypeEnum;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
 
public class BatchRoleRecordDefinition extends JepRecordDefinition {
 
  public static BatchRoleRecordDefinition instance = new BatchRoleRecordDefinition();
 
  private BatchRoleRecordDefinition() {
    super(buildTypeMap()
      , new String[]{BATCH_ROLE_ID, CURRENT_DATA_SOURCE}
    );
  }
 
  private static Map<String, JepTypeEnum> buildTypeMap() {
    Map<String, JepTypeEnum> typeMap = new HashMap<String, JepTypeEnum>();
    typeMap.put(BATCH_ROLE_ID, INTEGER);
    typeMap.put(BATCH_ID, INTEGER);
    typeMap.put(PRIVILEGE_CODE, STRING);
    typeMap.put(ROLE_ID, INTEGER);
    typeMap.put(ROLE_SHORT_NAME, STRING);
    typeMap.put(PRIVILEGE_NAME, STRING);
    typeMap.put(ROLE_NAME, STRING);
    typeMap.put(DATE_INS, DATE);
    typeMap.put(OPERATOR_ID, INTEGER);
    typeMap.put(OPERATOR_NAME, STRING);
    typeMap.put(CURRENT_DATA_SOURCE, STRING);
    return typeMap;
  }
}
