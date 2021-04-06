package com.technology.oracle.optionasria.main.server;

import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;

import java.util.List;
import java.util.Map;
import java.util.Set;


import com.technology.jep.jepria.server.dao.JepDataStandard;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.exceptions.SystemException;
import com.technology.jep.jepria.shared.load.FindConfig;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.load.PagingResult;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
import com.technology.oracle.optionasria.main.shared.service.OptionAsRiaService;

import static com.technology.oracle.optionasria.main.shared.OptionAsRiaConstant.CURRENT_DATA_SOURCE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.*;


public class OptionAsRiaServiceImpl<D extends JepDataStandard> extends DataSourceServiceImpl<D> implements OptionAsRiaService {

	public OptionAsRiaServiceImpl(JepRecordDefinition recordDefinition,	D dao) {
		super(recordDefinition, dao);
	}
	/*
	private void clearFoundRecords(FindConfig findConfig) {
		HttpSession session = getThreadLocalRequest().getSession();
		session.removeAttribute(FOUND_RECORDS_SESSION_ATTRIBUTE + findConfig.getListUID());
	}*/
	
	@Override
	public JepRecord create(FindConfig createConfig) throws ApplicationException {
		JepRecord record = createConfig.getTemplateRecord();
		
		logger.trace("BEGIN create(" + record + ")");
		JepRecord resultRecord = null;

		prepareFileFields(record);
		
		try {
			Object recordId = getProxyDao(createConfig.getTemplateRecord().get(CURRENT_DATA_SOURCE)).create(record, getOperatorId());
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
	public JepRecord update(FindConfig updateConfig) throws ApplicationException {
		JepRecord record = updateConfig.getTemplateRecord();

		logger.trace("BEGIN update(" + record + ")");
		JepRecord resultRecord = null;
		
		prepareFileFields(record);
		
		try {
		  getProxyDao(updateConfig.getTemplateRecord().get(CURRENT_DATA_SOURCE)).update(record, getOperatorId());
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
	
	protected JepRecord findByPrimaryKey(Map<String, Object> primaryKey, JepRecord record) throws ApplicationException {
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
}
