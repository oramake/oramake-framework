package com.technology.oracle.scheduler.main.server;

import java.util.List;

import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
import com.technology.oracle.scheduler.main.server.dao.Scheduler;
import com.technology.oracle.scheduler.main.shared.service.SchedulerService;

public class SchedulerServiceImpl<D extends Scheduler> extends DataSourceServiceImpl<D> implements SchedulerService {
  
  protected SchedulerServiceImpl(JepRecordDefinition recordDefinition, D dao) {
    super(recordDefinition, dao);
  }

  private static final long serialVersionUID = 1L;
    
  public List<JepOption> getPrivilege() throws ApplicationException {
    List<JepOption> result = null;
    try {
      result = getProxyDao().getPrivilege();
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    return result;
  }
 
  public List<JepOption> getRole(String roleName) throws ApplicationException {
    List<JepOption> result = null;
    try {
      result = getProxyDao().getRole(roleName);
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    return result;
  }
  
   
  public List<JepOption> getModule() throws ApplicationException {
    List<JepOption> result = null;
    try {
      result = getProxyDao().getModule();
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    return result;
  }
}

