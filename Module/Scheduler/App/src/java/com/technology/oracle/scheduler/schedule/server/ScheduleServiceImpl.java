package com.technology.oracle.scheduler.schedule.server;
 
import java.util.List;

import com.technology.oracle.scheduler.batch.server.ejb.Batch;
import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;
import com.technology.oracle.scheduler.schedule.shared.service.ScheduleService;
import com.technology.jep.jepria.server.ejb.JepDataStandard;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.server.util.JepServerUtil;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.scheduler.schedule.shared.record.ScheduleRecordDefinition;
import static com.technology.oracle.scheduler.schedule.server.ScheduleServerConstant.BEAN_JNDI_NAME;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
 
@RemoteServiceRelativePath("ScheduleService")
public class ScheduleServiceImpl extends SchedulerServiceImpl implements ScheduleService  {
 
	private static final long serialVersionUID = 1L;
 
	public ScheduleServiceImpl() {
		super(ScheduleRecordDefinition.instance, BEAN_JNDI_NAME);
	}
}
