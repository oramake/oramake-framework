package com.technology.rfi.calendar.day.server.service;
 
import java.util.List;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.rfi.calendar.day.server.DayServerFactory;
import com.technology.rfi.calendar.day.server.dao.Day;
import com.technology.rfi.calendar.day.shared.record.DayRecordDefinition;
import com.technology.rfi.calendar.day.shared.service.DayService;
 
@RemoteServiceRelativePath("DayService")
public class DayServiceImpl extends JepDataServiceServlet<Day> implements DayService  {
 
	private static final long serialVersionUID = 1L;
 
	public DayServiceImpl() {
		super(DayRecordDefinition.instance, DayServerFactory.instance);
	}
 
	public List<JepOption> getDayType() throws ApplicationException {
		List<JepOption> result = null;
		try {
			result = dao.getDayType(getOperatorId());
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
}
