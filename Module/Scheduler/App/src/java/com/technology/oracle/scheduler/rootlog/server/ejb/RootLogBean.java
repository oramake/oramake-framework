package com.technology.oracle.scheduler.rootlog.server.ejb;
 
import static com.technology.oracle.scheduler.batch.server.BatchServerConstant.PREFIX_DATA_SOURCE_JNDI_NAME;
import static com.technology.oracle.scheduler.rootlog.server.RootLogServerConstant.DATA_SOURCE_JNDI_NAME;
import static com.technology.oracle.scheduler.rootlog.server.RootLogServerConstant.RESOURCE_BUNDLE_NAME;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.DATA_SOURCE;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.DATE_INS;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.LOG_ID;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.MESSAGE_TEXT;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.MESSAGE_TYPE_NAME;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.OPERATOR_NAME;

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
 
@Local( { RootLogLocal.class })
@Remote( { RootLogRemote.class })
@StatelessDeployment
@Stateless
public class RootLogBean extends JepDataBean implements RootLog {
 
	public RootLogBean() {
		super(DATA_SOURCE_JNDI_NAME, RESOURCE_BUNDLE_NAME);
	}
 
	public List<JepRecord> find( JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin  " 
			  +	"? := pkg_Scheduler.findRootLog(" 
				  	 + "batchId => ? " 
					+ ", maxRowCount => ? " 
					+ ", operatorId => ? " 
			  + ");"
		 + " end;";
		
		final String dataSource = getValueFromOption(templateRecord.get(DATA_SOURCE));
		ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
			public void map(ResultSet rs, JepRecord record) throws SQLException {
				
				JepOption jepOption = new JepOption(dataSource, dataSource);
				record.set(DATA_SOURCE, jepOption);

				record.set(LOG_ID, getInteger(rs, LOG_ID));
				record.set(DATE_INS, getDate(rs, DATE_INS));
				record.set(MESSAGE_TYPE_NAME, rs.getString(MESSAGE_TYPE_NAME));
				record.set(MESSAGE_TEXT, rs.getString(MESSAGE_TEXT));
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
				, templateRecord.get(BATCH_ID) 
				, maxRowCount 
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
