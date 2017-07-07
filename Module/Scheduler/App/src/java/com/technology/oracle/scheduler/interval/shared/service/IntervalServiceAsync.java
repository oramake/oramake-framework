package com.technology.oracle.scheduler.interval.shared.service;
 
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.google.gwt.user.client.rpc.AsyncCallback;
import java.util.List;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.oracle.scheduler.main.shared.service.SchedulerServiceAsync;
 
public interface IntervalServiceAsync extends SchedulerServiceAsync {
  void getIntervalType(String dataSource, AsyncCallback<List<JepOption>> callback);
}
