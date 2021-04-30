package com.technology.oracle.scheduler.batch.server;
 
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.main.shared.SchedulerConstant.CURRENT_DATA_SOURCE;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.load.PagingResult;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.batch.server.dao.Batch;
import com.technology.oracle.scheduler.batch.server.dao.BatchDao;
import com.technology.oracle.scheduler.batch.shared.record.BatchRecordDefinition;
import com.technology.oracle.scheduler.batch.shared.service.BatchService;
import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;

import java.util.List;

@RemoteServiceRelativePath("BatchService")
public class BatchServiceImpl extends SchedulerServiceImpl<Batch> implements BatchService  {
 
  private static final long serialVersionUID = 1L;
 
  public BatchServiceImpl() {
    super(BatchRecordDefinition.instance, new BatchDao());
  }
  
  @Override
  public JepRecord activateBatch (Integer batchId, String dataSource) throws ApplicationException {
    
    PagingResult<JepRecord> resultRecord = null;

    try {

      getProxyDao(dataSource).activateBatch(batchId, getOperatorId());

      JepRecord tmp = new JepRecord();
      tmp.set(BATCH_ID, batchId);
      tmp.set(CURRENT_DATA_SOURCE, dataSource);
      resultRecord = find(new PagingConfig(tmp));

    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }

    return resultRecord.getData().get(0);
  }


  @Override
  public JepRecord deactivateBatch(Integer batchId, String dataSource) throws ApplicationException {
    
    PagingResult<JepRecord> resultRecord = null;
    
    try {
      
      getProxyDao(dataSource).deactivateBatch(batchId, getOperatorId());
      
      JepRecord tmp = new JepRecord();
      tmp.set(BATCH_ID, batchId);
      tmp.set(CURRENT_DATA_SOURCE, dataSource);

      resultRecord = find(new PagingConfig(tmp));
      
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    
    return resultRecord.getData().get(0);
  }

  @Override
  public JepRecord executeBatch(Integer batchId, String dataSource) throws ApplicationException {
    
    PagingResult<JepRecord> resultRecord = null;

    try {
      
      getProxyDao(dataSource).executeBatch(batchId, getOperatorId());
      JepRecord tmp = new JepRecord();
      tmp.set(BATCH_ID, batchId);
      tmp.set(CURRENT_DATA_SOURCE, dataSource);
      resultRecord = find(new PagingConfig(tmp));
      
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }

    return resultRecord.getData().get(0);
  }

  @Override
  public JepRecord abortBatch(Integer batchId, String dataSource) throws ApplicationException {

    PagingResult<JepRecord> resultRecord = null;
    
    try {
      
      getProxyDao(dataSource).abortBatch(batchId, getOperatorId());

      JepRecord tmp = new JepRecord();
      tmp.set(BATCH_ID, batchId);
      tmp.set(CURRENT_DATA_SOURCE, dataSource);

      resultRecord = find(new PagingConfig(tmp));

    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }

    return resultRecord.getData().get(0);
  }
}
