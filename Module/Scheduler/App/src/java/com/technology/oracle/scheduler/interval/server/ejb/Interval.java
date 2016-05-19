package com.technology.oracle.scheduler.interval.server.ejb;
 
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import java.util.List;
import com.technology.jep.jepria.server.ejb.JepDataStandard;
import com.technology.oracle.scheduler.main.server.ejb.Scheduler;
 
public interface Interval extends Scheduler {
	List<JepOption> getIntervalType(String dataSource) throws ApplicationException;
}
