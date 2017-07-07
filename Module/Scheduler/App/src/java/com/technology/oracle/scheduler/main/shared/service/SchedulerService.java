package com.technology.oracle.scheduler.main.shared.service;
 
import java.util.List;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.service.data.JepDataService;
 
@RemoteServiceRelativePath("SchedulerService")
public interface SchedulerService extends JepDataService {
  JepRecord getDataSource() throws ApplicationException;
  List<JepOption> getModule() throws ApplicationException;
  List<JepOption> getPrivilege() throws ApplicationException;
  List<JepOption> getRole(String roleName) throws ApplicationException;
  void setCurrentDataSource(String dataSource) throws ApplicationException;
}
