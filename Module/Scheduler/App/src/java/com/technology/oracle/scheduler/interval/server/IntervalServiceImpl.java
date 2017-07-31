package com.technology.oracle.scheduler.interval.server;
 
import java.util.List;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.scheduler.interval.server.dao.Interval;
import com.technology.oracle.scheduler.interval.server.dao.IntervalDao;
import com.technology.oracle.scheduler.interval.shared.record.IntervalRecordDefinition;
import com.technology.oracle.scheduler.interval.shared.service.IntervalService;
import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;
 
@RemoteServiceRelativePath("IntervalService")
public class IntervalServiceImpl extends SchedulerServiceImpl<Interval> implements IntervalService  {
 
  private static final long serialVersionUID = 1L;
 
  public IntervalServiceImpl() {
    super(IntervalRecordDefinition.instance, new IntervalDao());
  }
 
  public List<JepOption> getIntervalType() throws ApplicationException {
    List<JepOption> result = null;
    try {
      result = getProxyDao().getIntervalType();
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    return result;
  }
}
