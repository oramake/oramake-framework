package com.technology.oracle.scheduler.batch.server;
 
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.batch.server.dao.Batch;
import com.technology.oracle.scheduler.batch.server.dao.BatchDao;
import com.technology.oracle.scheduler.batch.shared.record.BatchRecordDefinition;
import com.technology.oracle.scheduler.batch.shared.service.BatchService;
import com.technology.oracle.scheduler.main.server.SchedulerServiceEntryPoint;
 
@RemoteServiceRelativePath("BatchService")
public class BatchServiceEntryPoint extends SchedulerServiceEntryPoint<BatchService, Batch> implements BatchService {

  public BatchServiceEntryPoint() {
    super(BatchRecordDefinition.instance, BatchServiceImpl.class, new BatchDao());
  }

  private static final long serialVersionUID = 1L;

  
  @Override
  public JepRecord activateBatch (Integer batchId) throws ApplicationException {
    return getService().activateBatch(batchId);
  }


  @Override
  public JepRecord deactivateBatch(Integer batchId) throws ApplicationException {
    return getService().deactivateBatch(batchId);
  }

  @Override
  public JepRecord executeBatch(Integer batchId) throws ApplicationException {
    return getService().executeBatch(batchId);
  }

  @Override
  public JepRecord abortBatch(Integer batchId) throws ApplicationException {
    return getService().abortBatch(batchId);
  }
}
