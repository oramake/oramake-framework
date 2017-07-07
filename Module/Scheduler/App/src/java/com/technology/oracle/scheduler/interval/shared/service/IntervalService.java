package com.technology.oracle.scheduler.interval.shared.service;
 
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import java.util.List;
import com.technology.jep.jepria.shared.service.data.JepDataService;
import com.technology.oracle.scheduler.main.shared.service.SchedulerService;
 
@RemoteServiceRelativePath("IntervalService")
public interface IntervalService extends SchedulerService {
  List<JepOption> getIntervalType(String dataSource) throws ApplicationException;
}
