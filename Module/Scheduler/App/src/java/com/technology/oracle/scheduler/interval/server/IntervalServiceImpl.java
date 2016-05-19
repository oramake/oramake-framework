package com.technology.oracle.scheduler.interval.server;
 
import com.technology.oracle.scheduler.interval.shared.service.IntervalService;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.server.util.JepServerUtil;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.server.ejb.JepDataStandard;
import com.technology.oracle.scheduler.interval.server.ejb.Interval;
import java.util.List;
import com.technology.oracle.scheduler.interval.shared.record.IntervalRecordDefinition;
import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;

import static com.technology.oracle.scheduler.interval.server.IntervalServerConstant.BEAN_JNDI_NAME;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
 
@RemoteServiceRelativePath("IntervalService")
public class IntervalServiceImpl extends SchedulerServiceImpl implements IntervalService  {
 
	private static final long serialVersionUID = 1L;
 
	public IntervalServiceImpl() {
		super(IntervalRecordDefinition.instance, BEAN_JNDI_NAME);
	}
 
	public List<JepOption> getIntervalType(String dataSource) throws ApplicationException {
		List<JepOption> result = null;
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			result = ((Interval) ejb).getIntervalType(dataSource);
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
}
