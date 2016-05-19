package com.technology.oracle.scheduler.detailedlog.server.ejb;
 
import static com.technology.oracle.scheduler.batch.server.BatchServerConstant.PREFIX_DATA_SOURCE_JNDI_NAME;
import static com.technology.oracle.scheduler.detailedlog.server.DetailedLogServerConstant.DATA_SOURCE_JNDI_NAME;
import static com.technology.oracle.scheduler.detailedlog.server.DetailedLogServerConstant.RESOURCE_BUNDLE_NAME;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.DATA_SOURCE;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.LOG_ID;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.LOG_LEVEL;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.MESSAGE_TEXT;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.MESSAGE_TYPE_NAME;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.MESSAGE_VALUE;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.OPERATOR_NAME;
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.PARENT_LOG_ID;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import javax.ejb.Local;
import javax.ejb.Remote;
import javax.ejb.Stateless;

import oracle.j2ee.ejb.StatelessDeployment;

import com.technology.jep.jepria.server.dao.DaoSupport;
import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.server.ejb.JepDataBean;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;
 
@Local( { DetailedLogLocal.class })
@Remote( { DetailedLogRemote.class })
@StatelessDeployment
@Stateless
public class DetailedLogBean extends JepDataBean implements DetailedLog {
 
	public DetailedLogBean() {
		super(DATA_SOURCE_JNDI_NAME, RESOURCE_BUNDLE_NAME);
	}
 
	public List<JepRecord> find( JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin  " 
			  +	"? := pkg_Scheduler.GetDetailedLog(" 
				  	+ "parentLogId => ? " 
					+ ", operatorId => ? " 
			  + ");"
		 + " end;";
		
		final String dataSource = getValueFromOption(templateRecord.get(DATA_SOURCE));
		ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
			public void map(ResultSet rs, JepRecord record) throws SQLException {
				
				JepOption jepOption = new JepOption(dataSource, dataSource);
				record.set(DATA_SOURCE, jepOption);

				Integer logLevel = getInteger(rs, LOG_LEVEL); 
				//в зависимости от уровня иерархии дополняем текст сообщения пробелами.
				String messageText = new String();
				for (int i = 0; i < logLevel; i++){
					if (i == 0) 
						messageText = "&nbsp;<!-- в зависимости от уровня иерархии дополняем текст сообщения пробелами. -->";
					else
						messageText += "&nbsp;&nbsp;&nbsp;";
				}
				
				record.set(LOG_ID, getInteger(rs, LOG_ID));
				record.set(PARENT_LOG_ID, getInteger(rs, PARENT_LOG_ID));
				record.set(DATE_INS, getDate(rs, DATE_INS));
				record.set(MESSAGE_TEXT, messageText + rs.getString(MESSAGE_TEXT));
				record.set(MESSAGE_VALUE, rs.getString(MESSAGE_VALUE));
				record.set(MESSAGE_TYPE_NAME, rs.getString(MESSAGE_TYPE_NAME));
				record.set(OPERATOR_NAME, rs.getString(OPERATOR_NAME));
			}
		};
		
		
		return DaoSupport.find(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
				resourceBundleName,
				resultSetMapper,
				JepRecord.class
				, templateRecord.get(LOG_ID)
				, operatorId);
	}
	
	public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
		throw new UnsupportedOperationException();
	}
 
	public void update(JepRecord record, Integer operatorId) throws ApplicationException {
		throw new UnsupportedOperationException();
	}
 
	public Integer create(JepRecord record, Integer operatorId) throws ApplicationException {
		throw new UnsupportedOperationException();
	}
 
}
