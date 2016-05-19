package com.technology.oracle.scheduler.batch.server.ejb;
 
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import java.util.List;

import javax.naming.NamingException;

import com.technology.jep.jepria.server.ejb.JepDataStandard;
import com.technology.oracle.scheduler.main.server.ejb.Scheduler;
 
public interface Batch extends Scheduler {
	
	void activateBatch(String dataSource, Integer batchId, Integer operatorId) throws ApplicationException;
	void deactivateBatch(String dataSource, Integer batchId, Integer operatorId) throws ApplicationException;
	void executeBatch(String dataSource, Integer batchId, Integer operatorId) throws ApplicationException;
	void abortBatch(String dataSource, Integer batchId, Integer operatorId) throws ApplicationException;
}
