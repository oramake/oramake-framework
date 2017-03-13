package com.technology.rfi.calendar.day.server.dao;
 
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DATE_BEGIN;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DATE_END;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DAY;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DAY_TYPE_ID;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DAY_TYPE_NAME;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

import com.technology.jep.jepria.server.dao.JepDao;
import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.rfi.calendar.day.shared.field.DayTypeOptions;
 
public class DayDao extends JepDao implements Day {
 
	@Override
	public List<JepRecord> find(JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin  " 
			  +	"? := pkg_CalendarEdit.findDay(" 
				  	+ "day => ? " 
				  	+ ", dayTypeId => ? " 
				  	+ ", dateBegin => ? " 
				  	+ ", dateEnd => ? " 
					+ ", maxRowCount => ? " 
					+ ", operatorId => ? " 
			  + ");"
		 + " end;";
		return super.find( sqlQuery,
				new ResultSetMapper<JepRecord>() {
					public void map(ResultSet rs, JepRecord record) throws SQLException {
						record.set(DAY, getTimestamp(rs, DAY));
						record.set(DAY_TYPE_NAME, rs.getString(DAY_TYPE_NAME));
					}
				}
				, templateRecord.get(DAY)
				, JepOption.getValue(templateRecord.get(DAY_TYPE_ID))
				, templateRecord.get(DATE_BEGIN)
				, templateRecord.get(DATE_END)
				, maxRowCount 
				, operatorId);
	}
	
	@Override
	public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin " 
			  + "pkg_CalendarEdit.deleteDay(" 
				  	+ "day => ? " 
					+ ", operatorId => ? " 
			  + ");"
		  + "end;";
		super.delete(sqlQuery 
				, record.get(DAY) 
				, operatorId);
	}
 
	@Override
	public void update(JepRecord record, Integer operatorId) throws ApplicationException {
		throw new UnsupportedOperationException();
	}

	@Override
	public Timestamp create(JepRecord record, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin " 
			  + "? := pkg_CalendarEdit.createDay(" 
				  	+ "day => ? " 
				  	+ ", dayTypeId => ? " 
					+ ", operatorId => ? " 
			  + ");"
			+ "end;";
		return super.create(sqlQuery, 
				Timestamp.class 
				, record.get(DAY)
				, JepOption.getValue(record.get(DAY_TYPE_ID))
				, operatorId);
	}
 
	@Override
	public List<JepOption> getDayType(Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			" begin " 
			+ " ? := pkg_CalendarEdit.getDayType(" +
					"operatorId => ? " +
					");" 
			+ " end;";
 
		return super.getOptions(
				sqlQuery,
				new ResultSetMapper<JepOption>() {
					public void map(ResultSet rs, JepOption dto) throws SQLException {
						dto.setValue(getInteger(rs, DayTypeOptions.DAY_TYPE_ID));
						dto.setName(rs.getString(DayTypeOptions.DAY_TYPE_NAME));
					}
				},
				operatorId
		);
	}
}
