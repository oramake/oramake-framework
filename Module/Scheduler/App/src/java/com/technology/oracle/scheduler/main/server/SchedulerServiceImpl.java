package com.technology.oracle.scheduler.main.server;

import static com.technology.jep.jepria.server.JepRiaServerConstant.FOUND_RECORDS_SESSION_ATTRIBUTE;
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.DATA_SOURCE;

import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpSession;

import com.technology.jep.jepria.server.ejb.JepDataStandard;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.server.util.JepServerUtil;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.exceptions.SystemException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.load.FindConfig;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.load.PagingResult;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
import com.technology.oracle.scheduler.batch.server.ejb.Batch;
import com.technology.oracle.scheduler.main.server.ejb.Scheduler;
import com.technology.oracle.scheduler.main.shared.service.SchedulerService;


public class SchedulerServiceImpl extends JepDataServiceServlet implements SchedulerService {
	
	public SchedulerServiceImpl(JepRecordDefinition recordDefinition,
			String ejbName) {
		super(recordDefinition, ejbName);
	}
	
	public List<JepOption> getDataSource() throws ApplicationException {
		List<JepOption> result = null;
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			result = ((Scheduler) ejb).getDataSource();
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
	
	private void clearFoundRecords(FindConfig findConfig) {
		HttpSession session = getThreadLocalRequest().getSession();
		session.removeAttribute(FOUND_RECORDS_SESSION_ATTRIBUTE + findConfig.getListUID());
	}
	
	@Override
	public JepRecord create(FindConfig createConfig) {
		JepRecord record = createConfig.getTemplateRecord();
		
		logger.trace("BEGIN create(" + record + ")");
		JepRecord resultRecord = null;

		prepareFileFields(record);
		
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			Object recordId = ejb.create(record, getOperatorId());
			String[] primaryKey = recordDefinition.getPrimaryKey();
			if(recordId != null) {
				if(primaryKey.length == 1) {
					record.set(primaryKey[0], recordId); // TODO Разобраться со случаями (очень частыми), когда pk уже присутствует
				} else {
					throw new SystemException("When create return non-null, primary key should be simple, but detected: primaryKey = " + primaryKey);
				}
			}
			updateLobFields(record);
			resultRecord = findByPrimaryKey(recordDefinition.buildPrimaryKeyMap(record), record);
			clearFoundRecords(createConfig);
		} catch (Throwable th) {
			String message = "Create error";
			logger.error(message, th);
			throw buildException(message, th);
		}
		
		logger.trace("END create(" + record + ")");
		return resultRecord;
	}
	
	@Override
	public JepRecord update(FindConfig updateConfig) {
		JepRecord record = updateConfig.getTemplateRecord();
		
		logger.trace("BEGIN update(" + record + ")");
		JepRecord resultRecord = null;
		
		prepareFileFields(record);
		
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			ejb.update(record, getOperatorId());
			updateLobFields(record);
			resultRecord = findByPrimaryKey(recordDefinition.buildPrimaryKeyMap(record), record);
			clearFoundRecords(updateConfig);
		} catch (Throwable th) {
			String message = "Update error";
			logger.error(message, th);
			throw buildException(message, th);
		}

		logger.trace("END update(" + resultRecord + ")");
		return resultRecord;
	}
	
	protected JepRecord findByPrimaryKey(Map<String, Object> primaryKey, JepRecord record) {
		logger.trace("BEGIN findByPrimaryKey(" + primaryKey + ")");
		
		JepRecord templateRecord = new JepRecord();
		Set<String> keySet = primaryKey.keySet();
		for(String key: keySet) {
			templateRecord.set(key, primaryKey.get(key));
		}
		templateRecord.set(MAX_ROW_COUNT, 1);
		templateRecord.set(DATA_SOURCE, record.get(DATA_SOURCE));
		
		PagingConfig pagingConfig = new PagingConfig(templateRecord);
		PagingResult<JepRecord> pagingResult = find(pagingConfig);
		List<JepRecord> list = pagingResult.getData();
		
		JepRecord result = list.size() > 0 ? list.get(0) : null;
		
		logger.trace("END findByPrimaryKey(" + primaryKey + ")");
		
		return result;
	}
	
	

	public List<JepOption> getPrivilege(String dataSource) throws ApplicationException {
		List<JepOption> result = null;
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			result = ((Scheduler) ejb).getPrivilege(dataSource);
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
 
	public List<JepOption> getRole(String dataSource, String roleName) throws ApplicationException {
		List<JepOption> result = null;
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			result = ((Scheduler) ejb).getRole(dataSource, roleName);
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
	
	 
	public List<JepOption> getModule(String dataSource) throws ApplicationException {
		List<JepOption> result = null;
		try {
			JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
			result = ((Scheduler) ejb).getModule(dataSource);
		} catch (Throwable th) {
			throw new ApplicationException(th.getLocalizedMessage(), th);
		}
		return result;
	}
}
