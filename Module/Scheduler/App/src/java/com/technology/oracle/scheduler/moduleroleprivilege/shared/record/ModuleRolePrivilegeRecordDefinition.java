package com.technology.oracle.scheduler.moduleroleprivilege.shared.record;
 
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.*;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.*;
import com.technology.jep.jepria.shared.field.JepTypeEnum;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
 
import java.util.HashMap;
import java.util.Map;
 
public class ModuleRolePrivilegeRecordDefinition extends JepRecordDefinition {
 
	private static final long serialVersionUID = 1L;
 
	public static ModuleRolePrivilegeRecordDefinition instance = new ModuleRolePrivilegeRecordDefinition();
 
	private ModuleRolePrivilegeRecordDefinition() {
		super(buildTypeMap()
			, new String[]{MODULE_ROLE_PRIVILEGE_ID}
		);
	}
 
	private static Map<String, JepTypeEnum> buildTypeMap() {
		Map<String, JepTypeEnum> typeMap = new HashMap<String, JepTypeEnum>();
		typeMap.put(DATA_SOURCE, STRING);
		typeMap.put(MODULE_ROLE_PRIVILEGE_ID, INTEGER);
		typeMap.put(MODULE_ID, INTEGER);
		typeMap.put(MODULE_NAME, STRING);
		typeMap.put(PRIVILEGE_CODE, STRING);
		typeMap.put(PRIVILEGE_CODE_STR, STRING);
		typeMap.put(ROLE_ID, INTEGER);
		typeMap.put(ROLE_SHORT_NAME, STRING);
		typeMap.put(PRIVILEGE_NAME, STRING);
		typeMap.put(ROLE_NAME, STRING);
		typeMap.put(DATE_INS, DATE);
		typeMap.put(OPERATOR_NAME, STRING);
		return typeMap;
	}
}
