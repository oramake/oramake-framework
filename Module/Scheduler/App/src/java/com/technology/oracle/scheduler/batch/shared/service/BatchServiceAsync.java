package com.technology.oracle.scheduler.batch.shared.service;
 
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.main.shared.service.SchedulerServiceAsync;
 
public interface BatchServiceAsync extends SchedulerServiceAsync {

  void activateBatch(Integer batchId, String dataSource, AsyncCallback<JepRecord> callback);
  void deactivateBatch(Integer batchId, String dataSource, AsyncCallback<JepRecord> callback);
  void executeBatch(Integer batchId, String dataSource, AsyncCallback<JepRecord> callback);
  void abortBatch(Integer batchId, String dataSource, AsyncCallback<JepRecord> callback);
}
