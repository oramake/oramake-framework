package com.technology.oracle.scheduler.rootlog.server;
 
import com.technology.oracle.scheduler.rootlog.shared.service.RootLogService;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.oracle.scheduler.rootlog.shared.record.RootLogRecordDefinition;
import static com.technology.oracle.scheduler.rootlog.server.RootLogServerConstant.BEAN_JNDI_NAME;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
 
@RemoteServiceRelativePath("RootLogService")
public class RootLogServiceImpl extends JepDataServiceServlet implements RootLogService  {
 
	private static final long serialVersionUID = 1L;
 
	public RootLogServiceImpl() {
		super(RootLogRecordDefinition.instance, BEAN_JNDI_NAME);
	}
}
