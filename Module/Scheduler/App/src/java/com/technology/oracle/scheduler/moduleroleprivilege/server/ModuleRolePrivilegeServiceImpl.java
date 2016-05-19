package com.technology.oracle.scheduler.moduleroleprivilege.server;
 
import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;
import com.technology.oracle.scheduler.moduleroleprivilege.shared.service.ModuleRolePrivilegeService;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.server.util.JepServerUtil;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.server.ejb.JepDataStandard;
import com.technology.oracle.scheduler.moduleroleprivilege.server.ejb.ModuleRolePrivilege;
import java.util.List;
import com.technology.oracle.scheduler.moduleroleprivilege.shared.record.ModuleRolePrivilegeRecordDefinition;
import static com.technology.oracle.scheduler.moduleroleprivilege.server.ModuleRolePrivilegeServerConstant.BEAN_JNDI_NAME;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
 
@RemoteServiceRelativePath("ModuleRolePrivilegeService")
public class ModuleRolePrivilegeServiceImpl extends SchedulerServiceImpl implements ModuleRolePrivilegeService  {
 
	private static final long serialVersionUID = 1L;
 
	public ModuleRolePrivilegeServiceImpl() {
		super(ModuleRolePrivilegeRecordDefinition.instance, BEAN_JNDI_NAME);
	}

	
	public List<JepOption> getModule(String dataSource) throws ApplicationException {
		List<JepOption> result = null;
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			result = ((ModuleRolePrivilege) ejb).getModule(dataSource);
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
 
	public List<JepOption> getPrivilege(String dataSource) throws ApplicationException {
		List<JepOption> result = null;
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			result = ((ModuleRolePrivilege) ejb).getPrivilege(dataSource);
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
 
	public List<JepOption> getRole(String dataSource) throws ApplicationException {
		List<JepOption> result = null;
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			result = ((ModuleRolePrivilege) ejb).getRole(dataSource);
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
}
