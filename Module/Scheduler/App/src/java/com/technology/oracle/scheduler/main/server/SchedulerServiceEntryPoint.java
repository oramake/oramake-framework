package com.technology.oracle.scheduler.main.server;

import java.util.List;

import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
import com.technology.oracle.scheduler.main.server.dao.Scheduler;
import com.technology.oracle.scheduler.main.shared.service.SchedulerService;

public class SchedulerServiceEntryPoint<S extends SchedulerService, D extends Scheduler> 
    extends DataSourceServiceProvider<S, D> implements SchedulerService {

  protected SchedulerServiceEntryPoint(JepRecordDefinition recordDefinition,
      Class<? extends JepDataServiceServlet<D>> serviceClass, D dao) {
    super(recordDefinition, serviceClass, dao);
  }

  private static final long serialVersionUID = 1L;
  
  public List<JepOption> getPrivilege() throws ApplicationException {
    return getService().getPrivilege();
  }
 
  public List<JepOption> getRole(String roleName) throws ApplicationException {
    return getService().getRole(roleName);
  }
  
  public List<JepOption> getModule() throws ApplicationException {
    return getService().getModule();
  }
}

