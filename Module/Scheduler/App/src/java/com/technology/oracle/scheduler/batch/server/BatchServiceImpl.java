package com.technology.oracle.scheduler.batch.server;
 
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_ID;

import com.technology.jep.jepria.server.DaoProvider;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
import com.technology.oracle.scheduler.batch.server.dao.Batch;
import com.technology.oracle.scheduler.batch.shared.service.BatchService;
import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;
 
public class BatchServiceImpl extends SchedulerServiceImpl<Batch, BatchService> implements BatchService {

  public BatchServiceImpl(JepRecordDefinition recordDefinition, DaoProvider<Batch> serverFactory) {
    super(recordDefinition, serverFactory);
  }
  
  private static final long serialVersionUID = 1L;
  
  @Override
  public JepRecord activateBatch (Integer batchId) throws ApplicationException {
    
    JepRecord resultRecord = null;

    try {

      dao.activateBatch(batchId, getOperatorId());
      
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
      
      dao.deactivateBatch(batchId, getOperatorId());
      
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
      
      dao.executeBatch(batchId, getOperatorId());
      
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
      
      dao.abortBatch(batchId, getOperatorId());
      
      JepRecord tmp = new JepRecord();
      tmp.set(BATCH_ID, batchId);
      resultRecord = findByPrimaryKey(recordDefinition.buildPrimaryKeyMap(tmp));
      
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    
    return resultRecord;
  }
}
