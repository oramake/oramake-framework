package com.technology.oracle.scheduler.detailedlog.server;
 
import com.technology.oracle.scheduler.detailedlog.shared.service.DetailedLogService;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.oracle.scheduler.detailedlog.shared.record.DetailedLogRecordDefinition;
import static com.technology.oracle.scheduler.detailedlog.server.DetailedLogServerConstant.BEAN_JNDI_NAME;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
 
@RemoteServiceRelativePath("DetailedLogService")
public class DetailedLogServiceImpl extends JepDataServiceServlet implements DetailedLogService  {
 
	private static final long serialVersionUID = 1L;
 
	public DetailedLogServiceImpl() {
		super(DetailedLogRecordDefinition.instance, BEAN_JNDI_NAME);
	}
}
