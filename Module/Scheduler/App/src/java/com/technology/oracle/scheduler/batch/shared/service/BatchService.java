package com.technology.oracle.scheduler.batch.shared.service;
 
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.main.shared.service.SchedulerService;
 
@RemoteServiceRelativePath("BatchService")
public interface BatchService extends SchedulerService {
  
  JepRecord activateBatch(Integer batchId, String dataSource) throws ApplicationException;
  JepRecord deactivateBatch(Integer batchId, String dataSource) throws ApplicationException;
  JepRecord executeBatch(Integer batchId, String dataSource) throws ApplicationException;
  JepRecord abortBatch(Integer batchId, String dataSource) throws ApplicationException;
}
