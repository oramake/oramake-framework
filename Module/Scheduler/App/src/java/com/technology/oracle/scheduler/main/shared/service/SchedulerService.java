package com.technology.oracle.scheduler.main.shared.service;
 
import java.util.List;

import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
 
public interface SchedulerService extends DataSourceService {
  List<JepOption> getModule() throws ApplicationException;
  List<JepOption> getPrivilege() throws ApplicationException;
  List<JepOption> getRole(String roleName) throws ApplicationException;
}
