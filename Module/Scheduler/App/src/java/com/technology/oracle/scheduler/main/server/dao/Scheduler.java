package com.technology.oracle.scheduler.main.server.dao;
 
import java.util.List;

import com.technology.jep.jepria.server.dao.JepDataStandard;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
 
public interface Scheduler extends JepDataStandard {
  List<JepOption> getModule() throws ApplicationException;
  List<JepOption> getPrivilege() throws ApplicationException;
  List<JepOption> getRole(String roleName) throws ApplicationException;
}
