package com.technology.oracle.scheduler.moduleroleprivilege.server.dao;
 
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;

import java.util.List;

import com.technology.jep.jepria.server.ejb.JepDataStandard;
import com.technology.oracle.scheduler.main.server.dao.Scheduler;
 
public interface ModuleRolePrivilege extends Scheduler {
  List<JepOption> getModule(String dataSource) throws ApplicationException;
  List<JepOption> getPrivilege(String dataSource) throws ApplicationException;
  List<JepOption> getRole(String dataSource) throws ApplicationException;
}
