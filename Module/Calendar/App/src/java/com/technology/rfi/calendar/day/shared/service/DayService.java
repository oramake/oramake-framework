package com.technology.rfi.calendar.day.shared.service;
 
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import java.util.List;
import com.technology.jep.jepria.shared.service.data.JepDataService;
 
@RemoteServiceRelativePath("DayService")
public interface DayService extends JepDataService {
	List<JepOption> getDayType() throws ApplicationException;
}
