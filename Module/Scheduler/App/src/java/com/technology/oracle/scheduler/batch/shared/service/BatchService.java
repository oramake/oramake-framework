package com.technology.oracle.scheduler.batch.shared.service;
 
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import java.util.List;

import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.service.data.JepDataService;
import com.technology.oracle.scheduler.main.shared.service.SchedulerService;
 
@RemoteServiceRelativePath("BatchService")
public interface BatchService extends SchedulerService {
	
	JepRecord activateBatch(String dataSource, Integer batchId) throws ApplicationException;
	JepRecord deactivateBatch(String dataSource, Integer batchId) throws ApplicationException;
	JepRecord executeBatch(String dataSource, Integer batchId) throws ApplicationException;
	JepRecord abortBatch(String dataSource, Integer batchId) throws ApplicationException;
}
