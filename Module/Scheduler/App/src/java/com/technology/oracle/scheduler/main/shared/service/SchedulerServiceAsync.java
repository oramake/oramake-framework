package com.technology.oracle.scheduler.main.shared.service;
 
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.google.gwt.user.client.rpc.AsyncCallback;
import java.util.List;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
 
public interface SchedulerServiceAsync extends JepDataServiceAsync {
	void getDataSource(AsyncCallback<List<JepOption>> callback);
	void getModule(String dataSource, AsyncCallback<List<JepOption>> callback);
	void getPrivilege(String dataSource, AsyncCallback<List<JepOption>> callback);
	void getRole(String dataSource, String roleName, AsyncCallback<List<JepOption>> callback);
}
