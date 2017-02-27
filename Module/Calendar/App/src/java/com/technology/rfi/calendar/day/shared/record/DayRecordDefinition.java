package com.technology.rfi.calendar.day.shared.record;
 
import static com.technology.jep.jepria.shared.field.JepTypeEnum.DATE;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.INTEGER;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.STRING;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DATE_BEGIN;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DATE_END;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DAY;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DAY_TYPE_ID;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DAY_TYPE_NAME;

import java.util.HashMap;
import java.util.Map;

import com.technology.jep.jepria.shared.field.JepTypeEnum;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
 
public class DayRecordDefinition extends JepRecordDefinition {
 
	public static DayRecordDefinition instance = new DayRecordDefinition();
 
	private DayRecordDefinition() {
		super(buildTypeMap()
			, new String[]{DAY}
		);
	}
 
	private static Map<String, JepTypeEnum> buildTypeMap() {
		Map<String, JepTypeEnum> typeMap = new HashMap<String, JepTypeEnum>();
		typeMap.put(DAY, DATE);
		typeMap.put(DAY_TYPE_ID, INTEGER);
		typeMap.put(DAY_TYPE_NAME, STRING);
		typeMap.put(DATE_BEGIN, DATE);
		typeMap.put(DATE_END, DATE);
		return typeMap;
	}
}
