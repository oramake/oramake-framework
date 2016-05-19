package com.technology.oracle.scheduler.moduleroleprivilege.shared.service;
 
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.google.gwt.user.client.rpc.AsyncCallback;
import java.util.List;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.oracle.scheduler.main.shared.service.SchedulerServiceAsync;
 
public interface ModuleRolePrivilegeServiceAsync extends SchedulerServiceAsync {
	void getModule(String dataSource, AsyncCallback<List<JepOption>> callback);
	void getPrivilege(String dataSource, AsyncCallback<List<JepOption>> callback);
	void getRole(String dataSource, AsyncCallback<List<JepOption>> callback);
}
