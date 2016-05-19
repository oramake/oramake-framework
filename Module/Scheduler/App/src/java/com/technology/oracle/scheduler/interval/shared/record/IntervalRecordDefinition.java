package com.technology.oracle.scheduler.interval.shared.record;
 
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.*;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.*;

import com.technology.jep.jepria.shared.field.JepTypeEnum;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
 
import java.util.HashMap;
import java.util.Map;
 
public class IntervalRecordDefinition extends JepRecordDefinition {
 
	private static final long serialVersionUID = 1L;
 
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

		typeMap.put(DATA_SOURCE, STRING);
		return typeMap;
	}
}
