package com.technology.oracle.scheduler.batch.server.ejb;
 
import static com.technology.oracle.scheduler.batch.server.BatchServerConstant.*;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.*;
import javax.ejb.Local;
import javax.ejb.Remote;
import javax.ejb.Stateless;
import javax.naming.InitialContext;
import javax.naming.NameClassPair;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;

import oracle.j2ee.ejb.StatelessDeployment;
import com.technology.jep.jepria.server.ejb.JepDataStandardBean;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.oracle.scheduler.batch.server.ejb.Batch;
import com.technology.jep.jepria.server.dao.DaoSupport;
import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.scheduler.main.server.ejb.SchedulerBean;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
 
@Local( { BatchLocal.class })
@Remote( { BatchRemote.class })
@StatelessDeployment
@Stateless
public class BatchBean extends SchedulerBean implements Batch {
 
	public BatchBean() {
		super(DATA_SOURCE_JNDI_NAME, RESOURCE_BUNDLE_NAME);
	}
 
	public List<JepRecord> find( JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin  " 
			  +	"? := pkg_Scheduler.findBatch(" 
				  	+ "batchId => ? " 
				  	+ ", batchShortName => ? " 
				  	+ ", batchName => ? " 
				  	+ ", moduleId => ? " 
				  	+ ", lastDateFrom => ? " 
				  	+ ", lastDateTo => ? " 
				  	+ ", retrialCount => ? " 
					+ ", rowCount => ? " 
					+ ", operatorId => ? " 
			  + ");"
		 + " end;";
		
		final String dataSource = getValueFromOption(templateRecord.get(DATA_SOURCE));
		
		ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
			public void map(ResultSet rs, JepRecord record) throws SQLException {
				
				JepOption jepOption = new JepOption(dataSource, dataSource);
				record.set(DATA_SOURCE, jepOption);
				
				record.set(BATCH_ID, getInteger(rs, BATCH_ID));
				record.set(BATCH_SHORT_NAME, rs.getString(BATCH_SHORT_NAME));
				record.set(BATCH_NAME, rs.getString(BATCH_NAME));
				record.set(MODULE_NAME, rs.getString(MODULE_NAME));
				record.set(RETRIAL_COUNT, getInteger(rs, RETRIAL_COUNT));
				record.set(RETRIAL_TIMEOUT, rs.getString(RETRIAL_TIMEOUT));
				record.set(ORACLE_JOB_ID, getInteger(rs, ORACLE_JOB_ID));
				record.set(RETRIAL_NUMBER, getInteger(rs, RETRIAL_NUMBER));
				record.set(DATE_INS, getDate(rs, DATE_INS));
				record.set(OPERATOR_NAME, rs.getString(OPERATOR_NAME));
				record.set(JOB, getInteger(rs, JOB));
				record.set(LAST_DATE, getDate(rs, LAST_DATE));
				record.set(THIS_DATE, getDate(rs, THIS_DATE));
				record.set(NEXT_DATE, getDate(rs, NEXT_DATE));
				record.set(TOTAL_TIME, getInteger(rs, TOTAL_TIME));
				record.set(FAILURES, getInteger(rs, FAILURES));
				record.set(IS_JOB_BROKEN, getInteger(rs, IS_JOB_BROKEN));
				record.set(SID, getInteger(rs, SID));
				record.set(SERIAL, getInteger(rs, SERIAL));
				record.set(ROOT_LOG_ID, getInteger(rs, ROOT_LOG_ID));
				record.set(LAST_START_DATE, getDate(rs, LAST_START_DATE));
				record.set(LAST_LOG_DATE, getDate(rs, LAST_LOG_DATE));
				record.set(RESULT_NAME, rs.getString(RESULT_NAME));
				record.set(ERROR_JOB_COUNT, getInteger(rs, ERROR_JOB_COUNT));
				record.set(ERROR_COUNT, getInteger(rs, ERROR_COUNT));
				record.set(WARNING_COUNT, getInteger(rs, WARNING_COUNT));
				record.set(DURATION_SECOND, getInteger(rs, DURATION_SECOND));
			}
		};
		
		return DaoSupport.find(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
				resourceBundleName,
				resultSetMapper,
				JepRecord.class
				, templateRecord.get(BATCH_ID)
				, templateRecord.get(BATCH_SHORT_NAME)
				, templateRecord.get(BATCH_NAME)
				, getValueFromOption(templateRecord.get(MODULE_ID))
				, templateRecord.get(LAST_DATE_FROM)
				, templateRecord.get(LAST_DATE_TO)
				, templateRecord.get(RETRIAL_COUNT)
				, maxRowCount 
				, operatorId);
	}
	
	public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
		throw new UnsupportedOperationException();
	}
 
	public void update(JepRecord record, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin " 
			  +	"pkg_Scheduler.updateBatch(" 
				  	+ "batchId => ? " 
				  	+ ", batchName => ? " 
				  	+ ", retrialCount => ? " 
				  	+ ", retrialTimeout => to_dsinterval(?) " 
					+ ", operatorId => ? " 
			  + ");"
		 + "end;";

		DaoSupport.update(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(record.get(DATA_SOURCE)),
				resourceBundleName
				, record.get(BATCH_ID)
				, record.get(BATCH_NAME)
				, record.get(RETRIAL_COUNT)
				, record.get(RETRIAL_TIMEOUT)
				, operatorId);
	}
 
	public Integer create(JepRecord record, Integer operatorId) throws ApplicationException {
		throw new UnsupportedOperationException();
	}
 


	@Override
	public void activateBatch(String dataSource, Integer batchId, Integer operatorId) throws ApplicationException {

		String sqlQuery = 
				" begin"
				+ " pkg_Scheduler.ActivateBatch("
				  	+ "batchId => ? " 
					+ ", operatorId => ? " 
				+ " );"
				+ " end;";

		DaoSupport.execute(sqlQuery, sessionContext, PREFIX_DATA_SOURCE_JNDI_NAME+dataSource, RESOURCE_BUNDLE_NAME,
			batchId	
			, operatorId);
	}

	@Override
	public void deactivateBatch(String dataSource, Integer batchId, Integer operatorId) throws ApplicationException {
		
		String sqlQuery = 
				" begin"
				+ " pkg_Scheduler.DeactivateBatch("
				  	+ "batchId => ? " 
					+ ", operatorId => ? " 
				+ " );"
				+ " end;";

		DaoSupport.execute(sqlQuery, sessionContext, PREFIX_DATA_SOURCE_JNDI_NAME+dataSource, RESOURCE_BUNDLE_NAME,
			batchId	
			, operatorId);
	}

	@Override
	public void executeBatch(String dataSource, Integer batchId, Integer operatorId) throws ApplicationException {

		String sqlQuery = 
				" begin"
				+ " pkg_Scheduler.SetNextDate("
				  	+ "batchId => ? " 
					+ ", operatorId => ? " 
				+ " );"
				+ " end;";

		DaoSupport.execute(sqlQuery, sessionContext, PREFIX_DATA_SOURCE_JNDI_NAME+dataSource, RESOURCE_BUNDLE_NAME,
			batchId	
			, operatorId);
	}

	@Override
	public void abortBatch(String dataSource, Integer batchId, Integer operatorId) throws ApplicationException {

		String sqlQuery = 
				" begin"
				+ " pkg_Scheduler.AbortBatch("
				  	+ "batchId => ? " 
					+ ", operatorId => ? " 
				+ " );"
				+ " end;";

		DaoSupport.execute(sqlQuery, sessionContext, PREFIX_DATA_SOURCE_JNDI_NAME+dataSource, RESOURCE_BUNDLE_NAME,
			batchId	
			, operatorId);
	}
}
