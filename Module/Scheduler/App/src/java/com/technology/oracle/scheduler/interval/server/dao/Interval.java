package com.technology.oracle.scheduler.interval.server.dao;
 
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;

import java.util.List;

import com.technology.jep.jepria.server.ejb.JepDataStandard;
import com.technology.oracle.scheduler.main.server.dao.Scheduler;
 
public interface Interval extends Scheduler {
  List<JepOption> getIntervalType(String dataSource) throws ApplicationException;
}
