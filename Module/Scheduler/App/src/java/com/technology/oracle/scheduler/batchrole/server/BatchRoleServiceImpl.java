package com.technology.oracle.scheduler.batchrole.server;
 
import com.technology.oracle.scheduler.batchrole.shared.service.BatchRoleService;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.server.util.JepServerUtil;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.server.ejb.JepDataStandard;
import com.technology.oracle.scheduler.batchrole.server.ejb.BatchRole;
import java.util.List;
import com.technology.oracle.scheduler.batchrole.shared.record.BatchRoleRecordDefinition;
import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;

import static com.technology.oracle.scheduler.batchrole.server.BatchRoleServerConstant.BEAN_JNDI_NAME;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
 
@RemoteServiceRelativePath("BatchRoleService")
public class BatchRoleServiceImpl extends SchedulerServiceImpl implements BatchRoleService  {
 
	private static final long serialVersionUID = 1L;
 
	public BatchRoleServiceImpl() {
		super(BatchRoleRecordDefinition.instance, BEAN_JNDI_NAME);
	}
 
}
