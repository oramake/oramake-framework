package com.technology.oracle.scheduler.main.shared.service;
 
import java.util.List;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.technology.jep.jepria.shared.field.option.JepOption;
 
public interface SchedulerServiceAsync extends DataSourceServiceAsync {
  void getModule(AsyncCallback<List<JepOption>> callback);
  void getPrivilege(AsyncCallback<List<JepOption>> callback);
  void getRole(String roleName, AsyncCallback<List<JepOption>> callback);
}
