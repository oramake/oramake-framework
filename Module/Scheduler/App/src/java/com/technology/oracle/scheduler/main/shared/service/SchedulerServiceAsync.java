package com.technology.oracle.scheduler.main.shared.service;
 
import java.util.List;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.technology.jep.jepria.shared.field.option.JepOption;
 
public interface SchedulerServiceAsync extends DataSourceServiceAsync {
  void getModule(String currentDataSource, AsyncCallback<List<JepOption>> callback);
  void getPrivilege(String currentDataSource, AsyncCallback<List<JepOption>> callback);
  void getRole(String roleName, String currentDataSource, AsyncCallback<List<JepOption>> callback);
}
