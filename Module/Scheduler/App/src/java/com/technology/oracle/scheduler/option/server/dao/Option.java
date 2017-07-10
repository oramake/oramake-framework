package com.technology.oracle.scheduler.option.server.dao;
 
import java.util.List;

import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.scheduler.main.server.dao.Scheduler;
 
public interface Option extends Scheduler {
  List<JepOption> getValueType() throws ApplicationException;
}
