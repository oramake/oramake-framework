package com.technology.rfi.calendar.day.server.dao;
 
import java.util.List;

import com.technology.jep.jepria.server.dao.JepDataStandard;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
 
public interface Day extends JepDataStandard {
	List<JepOption> getDayType(Integer operatorId) throws ApplicationException;
}
