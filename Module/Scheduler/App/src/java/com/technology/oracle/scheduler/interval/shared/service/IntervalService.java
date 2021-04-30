package com.technology.oracle.scheduler.interval.shared.service;
 
import java.util.List;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.scheduler.main.shared.service.SchedulerService;
 
@RemoteServiceRelativePath("IntervalService")
public interface IntervalService extends SchedulerService {
  List<JepOption> getIntervalType(String currentDataSource) throws ApplicationException;
}
