package com.technology.oracle.scheduler.main.shared.service;
 
import java.util.List;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
 
public interface SchedulerServiceAsync extends JepDataServiceAsync {
  void getDataSource(AsyncCallback<JepRecord> callback);
  void getModule(AsyncCallback<List<JepOption>> callback);
  void getPrivilege(AsyncCallback<List<JepOption>> callback);
  void getRole(String roleName, AsyncCallback<List<JepOption>> callback);
  void setCurrentDataSource(String dataSource, AsyncCallback<Void> callback);
}
