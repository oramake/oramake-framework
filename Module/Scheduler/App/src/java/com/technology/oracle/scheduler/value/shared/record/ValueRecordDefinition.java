package com.technology.oracle.scheduler.value.shared.record;
 
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.*;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.*;
import com.technology.jep.jepria.shared.field.JepTypeEnum;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
 
import java.util.HashMap;
import java.util.Map;
 
public class ValueRecordDefinition extends JepRecordDefinition {
 
	private static final long serialVersionUID = 1L;
 
	public static ValueRecordDefinition instance = new ValueRecordDefinition();
 
	private ValueRecordDefinition() {
		super(buildTypeMap()
			, new String[]{VALUE_ID}
		);
	}
 
	private static Map<String, JepTypeEnum> buildTypeMap() {
		Map<String, JepTypeEnum> typeMap = new HashMap<String, JepTypeEnum>();
		typeMap.put(VALUE_ID, INTEGER);
		typeMap.put(OPTION_ID, INTEGER);
		typeMap.put(BATCH_ID, INTEGER);
		typeMap.put(USED_VALUE_FLAG, BOOLEAN);
		typeMap.put(PROD_VALUE_FLAG, BOOLEAN);
		typeMap.put(INSTANCE_NAME, STRING);
		typeMap.put(VALUE_TYPE_CODE, STRING);
		typeMap.put(VALUE_TYPE_NAME, STRING);
		typeMap.put(STRING_VALUE, STRING);
		typeMap.put(DATE_VALUE, DATE);
		typeMap.put(NUMBER_VALUE, BIGDECIMAL);
		typeMap.put(ENCRYPTION_FLAG, BOOLEAN);
		typeMap.put(LIST_SEPARATOR, STRING);
		typeMap.put(STRING_LIST_SEPARATOR, STRING);
		typeMap.put(VALUE_INDEX, STRING);
		typeMap.put(DATA_SOURCE, STRING);
		return typeMap;
	}
}
