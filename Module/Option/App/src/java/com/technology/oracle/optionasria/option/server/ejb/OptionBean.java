package com.technology.oracle.optionasria.option.server.ejb;
 
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.optionasria.option.server.OptionServerConstant.*;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.dateValueTypeCode;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.numberValueTypeCode;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.stringValueTypeCode;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.*;

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
import com.technology.jep.jepria.shared.time.JepTime;
import com.technology.jep.jepria.shared.util.JepRiaUtil;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.jep.jepria.server.dao.DaoSupport;
import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.optionasria.main.client.history.scope.OptionAsRiaScope;
import com.technology.oracle.optionasria.option.server.ejb.Option;
import com.technology.oracle.optionasria.option.shared.field.ModuleOptions;
import com.technology.oracle.optionasria.option.shared.field.ObjectTypeOptions;
import com.technology.oracle.optionasria.option.shared.field.ValueTypeOptions;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
 
@Local( { OptionLocal.class })
@Remote( { OptionRemote.class })
@StatelessDeployment
@Stateless
public class OptionBean extends JepDataStandardBean implements Option {
 
	public OptionBean() {
		super(DATA_SOURCE_JNDI_NAME, RESOURCE_BUNDLE_NAME);
	}
	
	private SimpleDateFormat dateFormat = new SimpleDateFormat(DEFAULT_DATE_FORMAT+" "+DEFAULT_TIME_FORMAT);
 
//	private String dataSource;
	
	public List<JepRecord> find( JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin  " 
			  +	"? := pkg_option.findOption(" 
				  	+ "optionId => ? " 
				  	+ ", moduleId => ? " 
				  	+ ", objectShortName => ? " 
				  	+ ", objectTypeId => ? " 
				  	+ ", optionShortName => ? " 
				  	+ ", optionName => ? " 
				  	+ ", optionDescription => ? " 
				  	+ ", stringValue => ? " 
					+ ", maxRowCount => ? " 
					+ ", operatorId => ? " 
			  + ");"
		 + " end;";
		
		final String dataSource = getValueFromOption(templateRecord.get(DATA_SOURCE));
//		String _dataSource = getValueFromOption(templateRecord.get(DATA_SOURCE));
		
//		if(_dataSource == null)
//			_dataSource = this.dataSource;
		
//		final String dataSource = _dataSource;
//		this.dataSource = dataSource;
		
		ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
			public void map(ResultSet rs, JepRecord record) throws SQLException {
				
				JepOption jepOption = new JepOption(dataSource, dataSource);
				record.set(DATA_SOURCE, jepOption);
				record.set(OPTION_ID, getInteger(rs, OPTION_ID));

				jepOption = new JepOption(rs.getString(MODULE_NAME), getInteger(rs, MODULE_ID));
				record.set(MODULE_ID, jepOption);
				record.set(MODULE_NAME, jepOption.getName());
				
				jepOption = new JepOption(rs.getString(OBJECT_TYPE_NAME), getInteger(rs, OBJECT_TYPE_ID));
				record.set(OBJECT_TYPE_ID, jepOption);
				record.set(OBJECT_TYPE_NAME, jepOption.getName());
				
				record.set(OBJECT_SHORT_NAME, rs.getString(OBJECT_SHORT_NAME));
				record.set(OPTION_SHORT_NAME, rs.getString(OPTION_SHORT_NAME));
				record.set(OPTION_NAME, rs.getString(OPTION_NAME));
				record.set(OPTION_DESCRIPTION, rs.getString(OPTION_DESCRIPTION));
				record.set(STRING_VALUE, rs.getString(STRING_VALUE));
				
				Date date = getDate(rs, DATE_VALUE);
				record.set(DATE_VALUE, date);
				record.set(TIME_VALUE, JepRiaUtil.isEmpty(date) ? null : new JepTime(date));
				
				record.set(NUMBER_VALUE, rs.getBigDecimal(NUMBER_VALUE));
				
				jepOption = new JepOption(rs.getString(VALUE_TYPE_NAME), rs.getString(VALUE_TYPE_CODE));
				record.set(VALUE_TYPE_CODE, jepOption);
				record.set(VALUE_TYPE_NAME, jepOption.getName());
				
				record.set(OBJECT_TYPE_SHORT_NAME, rs.getString(OBJECT_TYPE_SHORT_NAME));
				record.set(VALUE_LIST_FLAG, rs.getBoolean(VALUE_LIST_FLAG));
				record.set(LIST_SEPARATOR, rs.getString(LIST_SEPARATOR));
				record.set(ENCRYPTION_FLAG, rs.getBoolean(ENCRYPTION_FLAG));
				record.set(TEST_PROD_SENSITIVE_FLAG, rs.getBoolean(TEST_PROD_SENSITIVE_FLAG));
				record.set(ACCESS_LEVEL_NAME, rs.getString(ACCESS_LEVEL_NAME));
				record.set(MODULE_SVN_ROOT, rs.getString(MODULE_SVN_ROOT));
			}
		};
		
		return DaoSupport.find(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
				resourceBundleName,
				resultSetMapper,
				JepRecord.class
				, templateRecord.get(OPTION_ID)
				, getValueFromOption(templateRecord.get(MODULE_ID))
				, templateRecord.get(OBJECT_SHORT_NAME)
				, getValueFromOption(templateRecord.get(OBJECT_TYPE_ID))
				, templateRecord.get(OPTION_SHORT_NAME)
				, templateRecord.get(OPTION_NAME)
				, templateRecord.get(OPTION_DESCRIPTION)
				, templateRecord.get(STRING_VALUE)
				, maxRowCount 
				, operatorId);
	}
	
	public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin " 
			  + "pkg_option.deleteOption(" 
				  	+ "optionId => ? " 
					+ ", operatorId => ? " 
			  + ");"
		  + "end;";
		
		DaoSupport.delete(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+getValueFromOption(record.get(DATA_SOURCE)),
				resourceBundleName
				, record.get(OPTION_ID) 
				, operatorId);
	}
 
	public void update(JepRecord record, Integer operatorId) throws ApplicationException {

		String dataSource = getValueFromOption(record.get(DATA_SOURCE));
		
		if((Boolean) record.get(IS_EDIT_VALUE) == true){
			
			String valueTypeCode = getValueFromOption(record.get(VALUE_TYPE_CODE));	
			Date dateTimeValue = addTime((Date)record.get(DATE_VALUE), (JepTime) record.get(TIME_VALUE));
//			dateTimeValue = (JepRiaUtil.isEmpty(dateTimeValue)) ? null : dateTimeValue;
			String _dateTimeValue = (JepRiaUtil.isEmpty(dateTimeValue)) ? null : dateFormat.format(dateTimeValue);
//			java.sql.Date _dateTimeValue = (JepRiaUtil.isEmpty(dateTimeValue)) ? null : new java.sql.Date(dateTimeValue.getTime());
			
			String sqlQuery = 
					"begin " 
					  +	"pkg_option.setOptionValue("
						  	+ "optionId => ? "
						  	+ ", stringValue => ? " 
						  	+ ", dateValue => to_date(?, 'dd.MM.yyyy HH24:mi:ss') " 
						  	+ ", numberValue => ? " 
						  	+ ", valueIndex => ? " 
							+ ", operatorId => ? " 
					  + ");"
				 + "end;";
			
			DaoSupport.update(
					sqlQuery,
					sessionContext,
					PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
					resourceBundleName
					, record.get(OPTION_ID)
					, stringValueTypeCode.equals(valueTypeCode) ? record.get(STRING_VALUE) : null
					, dateValueTypeCode.equals(valueTypeCode) ? _dateTimeValue : null
					, numberValueTypeCode.equals(valueTypeCode) ? record.get(NUMBER_VALUE) : null
					, record.get(VALUE_INDEX)
					, operatorId);
		}else{
			String sqlQuery = 
					"begin " 
					  +	"pkg_option.updateOption(" 
						  	+ "optionId => ? " 
						  	+ ", optionName => ? " 
						  	+ ", optionDescription => ? " 
						  	+ ", valueTypeCode => ? " 
						  	+ ", valueListFlag => ? " 
						  	+ ", encryptionFlag => ? " 
						  	+ ", testProdSensitiveFlag => ? " 
							+ ", operatorId => ? " 
					  + ");"
				 + "end;";
			
			DaoSupport.update(
					sqlQuery,
					sessionContext,
					PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
					resourceBundleName
					, record.get(OPTION_ID)
					, record.get(OPTION_NAME)
					, record.get(OPTION_DESCRIPTION)
					, getValueFromOption(record.get(VALUE_TYPE_CODE))
					, record.get(VALUE_LIST_FLAG)
					, record.get(ENCRYPTION_FLAG)
					, record.get(TEST_PROD_SENSITIVE_FLAG)
					, operatorId);
		}
	}
 
	public Integer create(JepRecord record, Integer operatorId) throws ApplicationException {
		String sqlQuery = 
			"begin " 
			  + "? := pkg_option.createOption(" 
				  	+ "moduleId => ? " 
				  	+ ", objectShortName => ? " 
				  	+ ", objectTypeId => ? " 
				  	+ ", optionShortName => ? " 
				  	+ ", optionName => ? " 
				  	+ ", optionDescription => ? " 
				  	+ ", stringValue => ? "
				  	+ ", dateValue => to_date(?, 'dd.MM.yyyy HH24:mi:ss') " 
				  	+ ", numberValue => ? " 
				  	+ ", valueTypeCode => ? " 
				  	+ ", valueListFlag => ? " 
				  	+ ", encryptionFlag => ? " 
				  	+ ", testProdSensitiveFlag => ? " 
				  	+ ", stringListSeparator => ? " 
					+ ", operatorId => ? " 
			  + ");"
			+ "end;";
		
		String valueTypeCode = getValueFromOption(record.get(VALUE_TYPE_CODE));		
		String dataSource = getValueFromOption(record.get(DATA_SOURCE));
		Date dateTimeValue = addTime((Date)record.get(DATE_VALUE), (JepTime) record.get(TIME_VALUE));
		String _dateTimeValue = (JepRiaUtil.isEmpty(dateTimeValue)) ? null : dateFormat.format(dateTimeValue);
//		dateTimeValue = (JepRiaUtil.isEmpty(dateTimeValue)) ? null : dateTimeValue;
		
		return DaoSupport.<Integer> create(sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
				resourceBundleName,
				Integer.class 
				, getValueFromOption(record.get(MODULE_ID))
				, record.get(OBJECT_SHORT_NAME)
				, getValueFromOption(record.get(OBJECT_TYPE_ID))
				, record.get(OPTION_SHORT_NAME)
				, record.get(OPTION_NAME)
				, record.get(OPTION_DESCRIPTION)
				, stringValueTypeCode.equals(valueTypeCode) ? record.get(STRING_VALUE) : null
				, dateValueTypeCode.equals(valueTypeCode) ? _dateTimeValue : null
				, numberValueTypeCode.equals(valueTypeCode) ? record.get(NUMBER_VALUE) : null
				, valueTypeCode
				, record.get(VALUE_LIST_FLAG)
				, record.get(ENCRYPTION_FLAG)
				, record.get(TEST_PROD_SENSITIVE_FLAG)
				, record.get(STRING_LIST_SEPARATOR)
				, operatorId);
	}
 
 
	public List<JepOption> getDataSource() throws ApplicationException, NamingException {
 
		List<JepOption> dataSourceList = new ArrayList<JepOption>();
		
		try{
			InitialContext ic = new InitialContext();		
			NamingEnumeration<NameClassPair> nameEnum = ic.list("jdbc");
			
			while (nameEnum.hasMoreElements()) {
				NameClassPair nameClassPair = nameEnum.nextElement();
				dataSourceList.add(new JepOption(nameClassPair.getName(), nameClassPair.getName()));
			}
			
		}
		catch(Throwable e){
			throw new ApplicationException("No one datasource!", e);
		}
		
		Collections.sort(dataSourceList, new Comparator<JepOption>() {
	        @Override
			public int compare(JepOption m1, JepOption m2) {
	        	
	        	return m1.getName().compareTo(m2.getName());
			}
	    });
		
		return dataSourceList;
	}
 
	public List<JepOption> getModule(String dataSource) throws ApplicationException {
		String sqlQuery = 
			" begin " 
			+ " ? := pkg_option.findModule;" 
			+ " end;";
 
		
		return DaoSupport.find(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
				resourceBundleName,
				new ResultSetMapper<JepOption>() {
					public void map(ResultSet rs, JepOption dto) throws SQLException {
						dto.setValue(getInteger(rs, ModuleOptions.MODULE_ID));
						dto.setName(rs.getString(ModuleOptions.MODULE_NAME));
					}
				},
				JepOption.class); 
	}
 
	public List<JepOption> getObjectType(String dataSource) throws ApplicationException {
		String sqlQuery = 
			" begin " 
			+ " ? := pkg_option.getObjectType;" 
			+ " end;";
 
		return DaoSupport.find(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
				resourceBundleName,
				new ResultSetMapper<JepOption>() {
					public void map(ResultSet rs, JepOption dto) throws SQLException {
						dto.setValue(getInteger(rs, ObjectTypeOptions.OBJECT_TYPE_ID));
						dto.setName(rs.getString(ObjectTypeOptions.OBJECT_TYPE_NAME));
					}
				},
				JepOption.class); 
	}
 
	public List<JepOption> getValueType(String dataSource) throws ApplicationException {
		String sqlQuery = 
			" begin " 
			+ " ? := pkg_option.getValueType;" 
			+ " end;";
 
		return DaoSupport.find(
				sqlQuery,
				sessionContext,
				PREFIX_DATA_SOURCE_JNDI_NAME+dataSource,
				resourceBundleName,
				new ResultSetMapper<JepOption>() {
					public void map(ResultSet rs, JepOption dto) throws SQLException {
						dto.setValue(rs.getString(ValueTypeOptions.VALUE_TYPE_CODE));
						dto.setName(rs.getString(ValueTypeOptions.VALUE_TYPE_NAME));
					}
				},
				JepOption.class); 
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
