package com.technology.oracle.scheduler.batch.shared.service;
 
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.google.gwt.user.client.rpc.AsyncCallback;
import java.util.List;

import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.oracle.scheduler.main.shared.service.SchedulerServiceAsync;
 
public interface BatchServiceAsync extends SchedulerServiceAsync {

	void activateBatch(String dataSource, Integer batchId, AsyncCallback<JepRecord> callback);
	void deactivateBatch(String dataSource, Integer batchId, AsyncCallback<JepRecord> callback);
	void executeBatch(String dataSource, Integer batchId, AsyncCallback<JepRecord> callback);
	void abortBatch(String dataSource, Integer batchId, AsyncCallback<JepRecord> callback);
}
