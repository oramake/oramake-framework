package com.technology.oracle.scheduler.main.server;

import java.util.List;

import com.technology.jep.jepria.server.DaoProvider;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
import com.technology.jep.jepria.shared.service.data.JepDataService;
import com.technology.oracle.scheduler.main.server.dao.Scheduler;
import com.technology.oracle.scheduler.main.shared.service.SchedulerService;

public class SchedulerServiceImpl<D extends Scheduler, S extends JepDataService> extends JepDataServiceServlet<D> implements SchedulerService {

  protected SchedulerServiceImpl(JepRecordDefinition recordDefinition, DaoProvider<D> serverFactory) {
    super(recordDefinition, serverFactory);
  }

  private static final long serialVersionUID = 1L;
  
  public List<JepOption> getPrivilege() throws ApplicationException {
    List<JepOption> result = null;
    try {
      result = dao.getPrivilege();
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    return result;
  }
 
  public List<JepOption> getRole(String roleName) throws ApplicationException {
    List<JepOption> result = null;
    try {
      result = dao.getRole(roleName);
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    return result;
  }
  
   
  public List<JepOption> getModule() throws ApplicationException {
    List<JepOption> result = null;
    try {
      result = dao.getModule();
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    return result;
  }

  @Override
  public JepRecord getDataSource() throws ApplicationException {
    throw new UnsupportedOperationException();
  }

  @Override
  public void setCurrentDataSource(String dataSource) throws ApplicationException {
    throw new UnsupportedOperationException();
  }
}

