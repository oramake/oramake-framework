package com.technology.oracle.scheduler.batchrole.shared.record;
 
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.*;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.*;

import com.technology.jep.jepria.shared.field.JepTypeEnum;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
 
import java.util.HashMap;
import java.util.Map;
 
public class BatchRoleRecordDefinition extends JepRecordDefinition {
 
	private static final long serialVersionUID = 1L;
 
	public static BatchRoleRecordDefinition instance = new BatchRoleRecordDefinition();
 
	private BatchRoleRecordDefinition() {
		super(buildTypeMap()
			, new String[]{BATCH_ROLE_ID}
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

		typeMap.put(DATA_SOURCE, STRING);
		return typeMap;
	}
}
