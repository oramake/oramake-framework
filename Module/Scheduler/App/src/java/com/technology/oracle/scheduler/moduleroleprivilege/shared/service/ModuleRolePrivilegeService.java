package com.technology.oracle.scheduler.moduleroleprivilege.shared.service;
 
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import java.util.List;
import com.technology.jep.jepria.shared.service.data.JepDataService;
import com.technology.oracle.scheduler.main.shared.service.SchedulerService;
 
@RemoteServiceRelativePath("ModuleRolePrivilegeService")
public interface ModuleRolePrivilegeService extends SchedulerService {
	List<JepOption> getModule(String dataSource) throws ApplicationException;
	List<JepOption> getPrivilege(String dataSource) throws ApplicationException;
	List<JepOption> getRole(String dataSource) throws ApplicationException;
}
