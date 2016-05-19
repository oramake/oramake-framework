package com.technology.oracle.scheduler.interval.server.ejb;
 
import static com.technology.oracle.scheduler.batch.server.BatchServerConstant.PREFIX_DATA_SOURCE_JNDI_NAME;
import static com.technology.oracle.scheduler.interval.server.IntervalServerConstant.DATA_SOURCE_JNDI_NAME;
import static com.technology.oracle.scheduler.interval.server.IntervalServerConstant.RESOURCE_BUNDLE_NAME;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.*;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.DATA_SOURCE;

import javax.ejb.Local;
import javax.ejb.Remote;
import javax.ejb.Stateless;
import oracle.j2ee.ejb.StatelessDeployment;
import com.technology.jep.jepria.server.ejb.JepDataStandardBean;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.oracle.scheduler.interval.server.ejb.Interval;
import com.technology.jep.jepria.server.dao.DaoSupport;
import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.scheduler.interval.shared.field.IntervalTypeOptions;
import com.technology.oracle.scheduler.main.server.ejb.SchedulerBean;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
 
@Local( { IntervalLocal.class })
@Remote( { IntervalRemote.class })
@StatelessDeployment
@Stateless
public class IntervalBean extends SchedulerBean implements Interval {
 
	public IntervalBean() {
		super(DATA_SOURCE_JNDI_NAME, RESOURCE_BUNDLE_NAME);
	}
 
	public List<JepRecord> find( JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin  " 
			  +	"? := pkg_Scheduler.findInterval(" 
				  	+ "intervalId => ? " 
				  	+ ", scheduleId => ? " 
					+ ", maxRowCount => ? " 
					+ ", operatorId => ? " 
			  + ");"
		 + " end;";
		
		final String dataSource = getValueFromOption(templateRecord.get(DATA_SOURCE));
		ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
			public void map(ResultSet rs, JepRecord record) throws SQLException {
				
				JepOption jepOption = new JepOption(dataSource, dataSource);
				record.set(DATA_SOURCE, jepOption);
				
				record.set(INTERVAL_ID, getInteger(rs, INTERVAL_ID));
				
				jepOption = new JepOption(rs.getString(INTERVAL_TYPE_NAME), rs.getString(INTERVAL_TYPE_CODE));
				record.set(INTERVAL_TYPE_NAME, jepOption.getName());
				record.set(INTERVAL_TYPE_CODE, jepOption);
				
				record.set(MIN_VALUE, getInteger(rs, MIN_VALUE));
				record.set(MAX_VALUE, getInteger(rs, MAX_VALUE));
				record.set(STEP, getInteger(rs, STEP));
				record.set(DATE_INS, getDate(rs, DATE_INS));
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
				, templateRecord.get(INTERVAL_ID)
				, templateRecord.get(SCHEDULE_ID)
				, maxRowCount 
				, operatorId);
		
	}
	public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin " 
			  + "pkg_Scheduler.deleteInterval(" 
				  	+ "intervalId => ? " 
					+ ", operatorId => ? " 
			  + ");"
		  + "end;";
		
		DaoSupport.delete(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(record.get(DATA_SOURCE)),
				resourceBundleName
				, record.get(INTERVAL_ID) 
				, operatorId);
	}
 
	public void update(JepRecord record, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin " 
			  +	"pkg_Scheduler.updateInterval(" 
				  	+ "intervalId => ? " 
				  	+ ", intervalTypeCode => ? " 
				  	+ ", minValue => ? " 
				  	+ ", maxValue => ? " 
				  	+ ", step => ? " 
					+ ", operatorId => ? " 
			  + ");"
		 + "end;";
		
		DaoSupport.update(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(record.get(DATA_SOURCE)),
				resourceBundleName
				, record.get(INTERVAL_ID)
				, getValueFromOption(record.get(INTERVAL_TYPE_CODE))
				, record.get(MIN_VALUE)
				, record.get(MAX_VALUE)
				, record.get(STEP)
				, operatorId);
	}
 
	public Integer create(JepRecord record, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin " 
			  + "? := pkg_Scheduler.createInterval(" 
				  	+ "scheduleId => ? " 
				  	+ ", intervalTypeCode => ? " 
				  	+ ", minValue => ? " 
				  	+ ", maxValue => ? " 
				  	+ ", step => ? " 
					+ ", operatorId => ? " 
			  + ");"
			+ "end;";
		
		return DaoSupport.<Integer> create(sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(record.get(DATA_SOURCE)),
				resourceBundleName,
				Integer.class 
				, record.get(SCHEDULE_ID)
				, getValueFromOption(record.get(INTERVAL_TYPE_CODE))
				, record.get(MIN_VALUE)
				, record.get(MAX_VALUE)
				, record.get(STEP)
				, operatorId);
	}
 
 
	public List<JepOption> getIntervalType(String dataSource) throws ApplicationException {
		String sqlQuery = 
			" begin " 
			+ " ? := pkg_Scheduler.getIntervalType;" 
			+ " end;";
 
		return DaoSupport.find(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
				resourceBundleName,
				new ResultSetMapper<JepOption>() {
					public void map(ResultSet rs, JepOption dto) throws SQLException {
						dto.setValue(rs.getString(IntervalTypeOptions.INTERVAL_TYPE_CODE));
						dto.setName(rs.getString(IntervalTypeOptions.INTERVAL_TYPE_NAME));
					}
				},
				JepOption.class
		);
	}
}
