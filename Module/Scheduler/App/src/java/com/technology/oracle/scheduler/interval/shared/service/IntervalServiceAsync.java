package com.technology.oracle.scheduler.interval.shared.service;
 
import java.util.List;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.scheduler.main.shared.service.SchedulerServiceAsync;
 
public interface IntervalServiceAsync extends SchedulerServiceAsync {
  void getIntervalType(String currentDataSource, AsyncCallback<List<JepOption>> callback);
}
