package com.technology.oracle.scheduler.option.shared.service;
 
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import java.util.List;
import com.technology.jep.jepria.shared.service.data.JepDataService;
import com.technology.oracle.scheduler.main.shared.service.SchedulerService;
 
@RemoteServiceRelativePath("OptionService")
public interface OptionService extends SchedulerService {
  List<JepOption> getValueType(String dataSource) throws ApplicationException;
}
