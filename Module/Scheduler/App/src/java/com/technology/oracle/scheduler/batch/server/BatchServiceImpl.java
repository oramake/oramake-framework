package com.technology.oracle.scheduler.batch.server;
 
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_ID;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.batch.server.dao.Batch;
import com.technology.oracle.scheduler.batch.server.dao.BatchDao;
import com.technology.oracle.scheduler.batch.shared.record.BatchRecordDefinition;
import com.technology.oracle.scheduler.batch.shared.service.BatchService;
import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;
 
@RemoteServiceRelativePath("BatchService")
public class BatchServiceImpl extends SchedulerServiceImpl<Batch> implements BatchService  {
 
  private static final long serialVersionUID = 1L;
 
  public BatchServiceImpl() {
    super(BatchRecordDefinition.instance, new BatchDao());
  }
  
  @Override
  public JepRecord activateBatch (Integer batchId) throws ApplicationException {
    
    JepRecord resultRecord = null;

    try {

      getProxyDao().activateBatch(batchId, getOperatorId());
      
      JepRecord tmp = new JepRecord();
      tmp.set(BATCH_ID, batchId);
      resultRecord = findByPrimaryKey(recordDefinition.buildPrimaryKeyMap(tmp));
      
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    
    return resultRecord;
  }


  @Override
  public JepRecord deactivateBatch(Integer batchId) throws ApplicationException {
    
    JepRecord resultRecord = null;
    
    try {
      
      getProxyDao().deactivateBatch(batchId, getOperatorId());
      
      JepRecord tmp = new JepRecord();
      tmp.set(BATCH_ID, batchId);
      resultRecord = findByPrimaryKey(recordDefinition.buildPrimaryKeyMap(tmp));
      
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    
    return resultRecord;
  }

  @Override
  public JepRecord executeBatch(Integer batchId) throws ApplicationException {
    
    JepRecord resultRecord = null;
    
    try {
      
      getProxyDao().executeBatch(batchId, getOperatorId());
      
      JepRecord tmp = new JepRecord();
      tmp.set(BATCH_ID, batchId);
      resultRecord = findByPrimaryKey(recordDefinition.buildPrimaryKeyMap(tmp));
      
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    
    return resultRecord;
  }

  @Override
  public JepRecord abortBatch(Integer batchId) throws ApplicationException {

    JepRecord resultRecord = null;
    
    try {
      
      getProxyDao().abortBatch(batchId, getOperatorId());
      
      JepRecord tmp = new JepRecord();
      tmp.set(BATCH_ID, batchId);
      resultRecord = findByPrimaryKey(recordDefinition.buildPrimaryKeyMap(tmp));
      
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    
    return resultRecord;
  }
}
