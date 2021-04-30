package com.technology.oracle.scheduler.option.shared.service;
 
import java.util.List;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.scheduler.main.shared.service.SchedulerService;
 
@RemoteServiceRelativePath("OptionService")
public interface OptionService extends SchedulerService {
  List<JepOption> getValueType(String currentDataSource) throws ApplicationException;
}
