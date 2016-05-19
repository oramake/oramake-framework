package com.technology.oracle.scheduler.batch.server;
 
import com.technology.oracle.scheduler.batch.shared.service.BatchService;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.server.util.JepServerUtil;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.server.ejb.JepDataStandard;
import com.technology.oracle.scheduler.batch.server.ejb.Batch;
import java.util.List;
import com.technology.oracle.scheduler.batch.shared.record.BatchRecordDefinition;
import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;

import static com.technology.oracle.scheduler.batch.server.BatchServerConstant.BEAN_JNDI_NAME;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.*;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
 
@RemoteServiceRelativePath("BatchService")
public class BatchServiceImpl extends SchedulerServiceImpl implements BatchService  {
 
	private static final long serialVersionUID = 1L;
 
	public BatchServiceImpl() {
		super(BatchRecordDefinition.instance, BEAN_JNDI_NAME);
	}
	
	@Override
	public JepRecord activateBatch (String dataSource, Integer batchId) throws ApplicationException {
		
		JepRecord resultRecord = null;

		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			((Batch) ejb).activateBatch(dataSource, batchId, getOperatorId());
			
			JepRecord tmp = new JepRecord();
			tmp.set(DATA_SOURCE, new JepOption(dataSource, dataSource));
			tmp.set(BATCH_ID, batchId);
			resultRecord = findByPrimaryKey(recordDefinition.buildPrimaryKeyMap(tmp), tmp);
			
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		
		return resultRecord;
	}


	@Override
	public JepRecord deactivateBatch(String dataSource, Integer batchId) throws ApplicationException {
		
		JepRecord resultRecord = null;
		
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			((Batch) ejb).deactivateBatch(dataSource, batchId, getOperatorId());
			
			JepRecord tmp = new JepRecord();
			tmp.set(DATA_SOURCE, new JepOption(dataSource, dataSource));
			tmp.set(BATCH_ID, batchId);
			resultRecord = findByPrimaryKey(recordDefinition.buildPrimaryKeyMap(tmp), tmp);
			
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		
		return resultRecord;
	}

	@Override
	public JepRecord executeBatch(String dataSource, Integer batchId) throws ApplicationException {
		
		JepRecord resultRecord = null;
		
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			((Batch) ejb).executeBatch(dataSource, batchId, getOperatorId());
			
			JepRecord tmp = new JepRecord();
			tmp.set(DATA_SOURCE, new JepOption(dataSource, dataSource));
			tmp.set(BATCH_ID, batchId);
			resultRecord = findByPrimaryKey(recordDefinition.buildPrimaryKeyMap(tmp), tmp);
			
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		
		return resultRecord;
	}

	@Override
	public JepRecord abortBatch(String dataSource, Integer batchId) throws ApplicationException {

		JepRecord resultRecord = null;
		
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			((Batch) ejb).abortBatch(dataSource, batchId, getOperatorId());
			
			JepRecord tmp = new JepRecord();
			tmp.set(DATA_SOURCE, new JepOption(dataSource, dataSource));
			tmp.set(BATCH_ID, batchId);
			resultRecord = findByPrimaryKey(recordDefinition.buildPrimaryKeyMap(tmp), tmp);
			
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		
		return resultRecord;
	}
}
