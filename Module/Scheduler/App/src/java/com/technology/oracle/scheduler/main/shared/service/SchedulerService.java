package com.technology.oracle.scheduler.main.shared.service;
 
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import java.util.List;
import com.technology.jep.jepria.shared.service.data.JepDataService;
 
@RemoteServiceRelativePath("SchedulerService")
public interface SchedulerService extends JepDataService {
	List<JepOption> getDataSource() throws ApplicationException;
	List<JepOption> getModule(String dataSource) throws ApplicationException;
	List<JepOption> getPrivilege(String dataSource) throws ApplicationException;
	List<JepOption> getRole(String dataSource, String roleName) throws ApplicationException;
}
