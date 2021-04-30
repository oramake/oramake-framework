package com.technology.oracle.scheduler.main.shared.service;
 
import java.util.List;

import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
 
public interface SchedulerService extends DataSourceService {
  List<JepOption> getModule(String currentDataSource) throws ApplicationException;
  List<JepOption> getPrivilege(String currentDataSource) throws ApplicationException;
  List<JepOption> getRole(String roleName, String currentDataSource) throws ApplicationException;
}
