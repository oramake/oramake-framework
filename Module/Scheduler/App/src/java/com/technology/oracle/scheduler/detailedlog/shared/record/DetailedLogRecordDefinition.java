package com.technology.oracle.scheduler.detailedlog.shared.record;
 
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.*;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.*;

import com.technology.jep.jepria.shared.field.JepTypeEnum;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
 
import java.util.HashMap;
import java.util.Map;
 
public class DetailedLogRecordDefinition extends JepRecordDefinition {
 
	private static final long serialVersionUID = 1L;
 
	public static DetailedLogRecordDefinition instance = new DetailedLogRecordDefinition();
 
	private DetailedLogRecordDefinition() {
		super(buildTypeMap()
			, new String[]{LOG_ID}
		);
	}
 
	private static Map<String, JepTypeEnum> buildTypeMap() {
		Map<String, JepTypeEnum> typeMap = new HashMap<String, JepTypeEnum>();
		typeMap.put(LOG_ID, INTEGER);
		typeMap.put(PARENT_LOG_ID, INTEGER);
		typeMap.put(DATE_INS, DATE);
		typeMap.put(MESSAGE_TEXT, STRING);
		typeMap.put(MESSAGE_VALUE, STRING);
		typeMap.put(MESSAGE_TYPE_NAME, STRING);
		typeMap.put(OPERATOR_NAME, STRING);

		typeMap.put(DATA_SOURCE, STRING);
		return typeMap;
	}
}
