package com.technology.oracle.scheduler.option.shared.service;
 
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.google.gwt.user.client.rpc.AsyncCallback;
import java.util.List;
import com.technology.oracle.scheduler.main.shared.service.SchedulerServiceAsync;
 
public interface OptionServiceAsync extends SchedulerServiceAsync {
  void getValueType(String dataSource, AsyncCallback<List<JepOption>> callback);
}
