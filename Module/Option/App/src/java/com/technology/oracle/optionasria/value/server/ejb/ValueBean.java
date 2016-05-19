package com.technology.oracle.optionasria.value.server.ejb;
 
import static com.technology.jep.jepria.client.JepRiaClientConstant.JepTexts;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.optionasria.option.server.OptionServerConstant.PREFIX_DATA_SOURCE_JNDI_NAME;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.dateValueTypeCode;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.numberValueTypeCode;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.stringValueTypeCode;
import static com.technology.oracle.optionasria.value.server.ValueServerConstant.DATA_SOURCE_JNDI_NAME;
import static com.technology.oracle.optionasria.value.server.ValueServerConstant.RESOURCE_BUNDLE_NAME;
import static com.technology.oracle.optionasria.value.shared.field.ValueFieldNames.*;

import javax.ejb.Local;
import javax.ejb.Remote;
import javax.ejb.Stateless;
import oracle.j2ee.ejb.StatelessDeployment;
import com.technology.jep.jepria.server.ejb.JepDataStandardBean;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.time.JepTime;
import com.technology.jep.jepria.shared.util.JepRiaUtil;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.oracle.optionasria.value.server.ejb.Value;
import com.technology.oracle.optionasria.value.shared.field.OperatorOptions;
import com.technology.jep.jepria.server.dao.DaoSupport;
import com.technology.jep.jepria.server.dao.ResultSetMapper;

import java.util.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.List;
 
@Local( { ValueLocal.class })
@Remote( { ValueRemote.class })
@StatelessDeployment
@Stateless
public class ValueBean extends JepDataStandardBean implements Value {
 
	public ValueBean() {
		super(DATA_SOURCE_JNDI_NAME, RESOURCE_BUNDLE_NAME);
	}
	

	private SimpleDateFormat dateFormat = new SimpleDateFormat(DEFAULT_DATE_FORMAT+" "+DEFAULT_TIME_FORMAT);
 
	public List<JepRecord> find( JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin  " 
			  +	"? := pkg_option.findValue(" 
				  	+ "valueId => ? " 
				  	+ ", optionId => ? " 
					+ ", maxRowCount => ? " 
					+ ", operatorId => ? " 
			  + ");"
		 + " end;";
		
//		String _dataSource = templateRecord.get(DATA_SOURCE);
		
//		if(_dataSource == null)
//			_dataSource = this.dataSource;
		
//		final String dataSource = _dataSource;
//		this.dataSource = dataSource;
		
		ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
			public void map(ResultSet rs, JepRecord record) throws SQLException {
				record.set(VALUE_ID, getInteger(rs, VALUE_ID));
				record.set(OPTION_ID, getInteger(rs, OPTION_ID));
				
				record.set(INSTANCE_NAME, rs.getString(INSTANCE_NAME));
				
				JepOption option = new JepOption(rs.getString(VALUE_TYPE_NAME),rs.getString(VALUE_TYPE_CODE));
				record.set(VALUE_TYPE_CODE, option);
				record.set(VALUE_TYPE_NAME, option.getName());

				Boolean prodValueFlag = JepRiaUtil.isEmpty(rs.getString(PROD_VALUE_FLAG)) ? null : rs.getBoolean(PROD_VALUE_FLAG);
				if(Boolean.TRUE.equals(prodValueFlag)){
					option = new JepOption("Да", 1);
				}else if(JepRiaUtil.isEmpty(prodValueFlag)){
					option = new JepOption(null,null);
				}else{
					option = new JepOption("Нет", 0);
				}
				
				record.set(PROD_VALUE_FLAG_CHECKBOX, option);
				record.set(PROD_VALUE_FLAG, prodValueFlag);
				record.set(USED_VALUE_FLAG, rs.getBoolean(USED_VALUE_FLAG));
				
				record.set(STRING_VALUE, rs.getString(STRING_VALUE));
				
				Date date = getDate(rs, DATE_VALUE);
				record.set(DATE_VALUE, date);
				record.set(TIME_VALUE, JepRiaUtil.isEmpty(date) ? null : new JepTime(date));
				
				record.set(NUMBER_VALUE, rs.getBigDecimal(NUMBER_VALUE));
				record.set(ENCRYPTION_FLAG, rs.getBoolean(ENCRYPTION_FLAG));
				record.set(LIST_SEPARATOR, rs.getString(LIST_SEPARATOR));
				
				option = new JepOption(rs.getString(USED_OPERATOR_NAME), getInteger(rs, USED_OPERATOR_ID));
				record.set(USED_OPERATOR_NAME, option.getName());
				record.set(USED_OPERATOR_ID, option);
			}
		};
		
		return DaoSupport.find(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(templateRecord.get(DATA_SOURCE)),
				resourceBundleName,
				resultSetMapper,
				JepRecord.class
				, templateRecord.get(VALUE_ID)
				, templateRecord.get(OPTION_ID)
				, maxRowCount 
				, operatorId);
	}
	
	public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin " 
			  + "pkg_option.deleteValue(" 
				  	+ "valueId => ? " 
					+ ", operatorId => ? " 
			  + ");"
		  + "end;";
		
		DaoSupport.delete(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(record.get(DATA_SOURCE)),
				resourceBundleName
				, record.get(VALUE_ID) 
				, operatorId);
	}
 
	public void update(JepRecord record, Integer operatorId) throws ApplicationException {
		
		String sqlQuery = 
			"begin " 
			  +	"pkg_option.updateValue(" 
				  	+ "valueId => ? " 
				  	+ ", stringValue => ? " 
				  	+ ", dateValue => to_date(?, 'dd.MM.yyyy HH24:mi:ss') "
				  	+ ", numberValue => ? " 
				  	+ ", valueIndex => ? " 
					+ ", operatorId => ? " 
			  + ");"
		 + "end;";
		
		String valueTypeCode = getValueFromOption(record.get(VALUE_TYPE_CODE));	
		Date dateTimeValue = addTime((Date)record.get(DATE_VALUE), (JepTime) record.get(TIME_VALUE));
		String _dateTimeValue = (JepRiaUtil.isEmpty(dateTimeValue)) ? null : dateFormat.format(dateTimeValue);
		
		DaoSupport.update(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(record.get(DATA_SOURCE)),
				resourceBundleName
				, record.get(VALUE_ID)
				, stringValueTypeCode.equals(valueTypeCode) ? record.get(STRING_VALUE) : null
				, dateValueTypeCode.equals(valueTypeCode) ? _dateTimeValue : null
				, numberValueTypeCode.equals(valueTypeCode) ? record.get(NUMBER_VALUE) : null
				, record.get(VALUE_INDEX)
				, operatorId);
	}
 
	public Integer create(JepRecord record, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin " 
			  + "? := pkg_option.createValue(" 
				  	+ "prodValueFlag => ? " 
				  	+ ", optionId => ? " 
				  	+ ", instanceName => ? " 
				  	+ ", usedOperatorId => ? " 
				  	+ ", stringValue => ? " 
				  	+ ", dateValue => to_date(?, 'dd.MM.yyyy HH24:mi:ss') "
				  	+ ", numberValue => ? " 
				  	+ ", stringListSeparator => ? " 
					+ ", operatorId => ? " 
			  + ");"
			+ "end;";
		
		String valueTypeCode = getValueFromOption(record.get(VALUE_TYPE_CODE));		
		Date dateTimeValue = addTime((Date)record.get(DATE_VALUE), (JepTime) record.get(TIME_VALUE));
		String _dateTimeValue = (JepRiaUtil.isEmpty(dateTimeValue)) ? null : dateFormat.format(dateTimeValue);
		
		return DaoSupport.<Integer> create(sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(record.get(DATA_SOURCE)),
				resourceBundleName,
				Integer.class 
				, getValueFromOption(record.get(PROD_VALUE_FLAG_CHECKBOX))
				, record.get(OPTION_ID)
				, record.get(INSTANCE_NAME)
				, getValueFromOption(record.get(USED_OPERATOR_ID))
				, stringValueTypeCode.equals(valueTypeCode) ? record.get(STRING_VALUE) : null
				, dateValueTypeCode.equals(valueTypeCode) ?_dateTimeValue : null
				, numberValueTypeCode.equals(valueTypeCode) ? record.get(NUMBER_VALUE) : null
				, record.get(STRING_LIST_SEPARATOR)
				, operatorId);
	}
	
	public List<JepOption> getOperator(String dataSource, String operatorName, Integer maxRowCount) throws ApplicationException {
		String sqlQuery = 
			" begin " 
			+ " ? := pkg_option.getOperator(" 
				  	+ "operatorName => ? " 
				  	+ ", maxRowCount => ? " 
			  + ");"
			+ " end;";
 
		return DaoSupport.find(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
				resourceBundleName,
				new ResultSetMapper<JepOption>() {
					public void map(ResultSet rs, JepOption dto) throws SQLException {
						dto.setValue(getInteger(rs, OperatorOptions.USED_OPERATOR_ID));
						dto.setName(rs.getString(OperatorOptions.USED_OPERATOR_NAME));
					}
				},
				JepOption.class
				, operatorName
				, maxRowCount); 
	}
	
	protected Date addTime(Date date, JepTime time) {
		if (date == null && time == null) return null; 
		Date result = date == null ? null : (Date)date.clone();
		if(time != null) {
			result = time.addDate(result == null ? new Date() : result);
		}
		return result;
	}
 
}
