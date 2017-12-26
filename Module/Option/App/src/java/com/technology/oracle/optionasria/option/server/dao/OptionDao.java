package com.technology.oracle.optionasria.option.server.dao;

import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.dateValueTypeCode;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.numberValueTypeCode;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.stringValueTypeCode;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.ACCESS_LEVEL_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.DATA_SOURCE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.DATE_VALUE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.ENCRYPTION_FLAG;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.IS_EDIT_VALUE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.LIST_SEPARATOR;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.MODULE_ID;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.MODULE_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.MODULE_SVN_ROOT;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.NUMBER_VALUE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OBJECT_SHORT_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OBJECT_TYPE_ID;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OBJECT_TYPE_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OBJECT_TYPE_SHORT_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OPTION_DESCRIPTION;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OPTION_ID;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OPTION_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.OPTION_SHORT_NAME;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.STRING_LIST_SEPARATOR;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.STRING_VALUE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.TEST_PROD_SENSITIVE_FLAG;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.TIME_VALUE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.VALUE_INDEX;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.VALUE_LIST_FLAG;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.VALUE_TYPE_CODE;
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.VALUE_TYPE_NAME;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import javax.naming.InitialContext;
import javax.naming.NameClassPair;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;

import com.technology.jep.jepria.server.dao.DaoSupport;
import com.technology.jep.jepria.server.dao.JepDao;
import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.time.JepTime;
import com.technology.jep.jepria.shared.util.JepRiaUtil;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.oracle.optionasria.option.shared.field.ModuleOptions;
import com.technology.oracle.optionasria.option.shared.field.ObjectTypeOptions;
import com.technology.oracle.optionasria.option.shared.field.ValueTypeOptions;

public class OptionDao extends JepDao implements Option {

	private SimpleDateFormat dateFormat = new SimpleDateFormat(DEFAULT_DATE_FORMAT+" "+DEFAULT_TIME_FORMAT);

//	private String dataSource;

	public List<JepRecord> find(JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
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

		final String dataSource = JepOption.getValue(templateRecord.get(DATA_SOURCE));

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

				Date date = getTimestamp(rs, DATE_VALUE);
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
				resultSetMapper,
				JepRecord.class
				, templateRecord.get(OPTION_ID)
				, JepOption.getValue(templateRecord.get(MODULE_ID))
				, templateRecord.get(OBJECT_SHORT_NAME)
				, JepOption.getValue(templateRecord.get(OBJECT_TYPE_ID))
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
				record.get(OPTION_ID)
				, operatorId);
	}

	public void update(JepRecord record, Integer operatorId) throws ApplicationException {
		//String dataSource = JepOption.getValue(record.get(DATA_SOURCE));
		if((Boolean) record.get(IS_EDIT_VALUE) == true) {
			String valueTypeCode = JepOption.getValue(record.get(VALUE_TYPE_CODE));
			Date dateTimeValue = addTime((Date)record.get(DATE_VALUE), (JepTime) record.get(TIME_VALUE));
			String _dateTimeValue = (JepRiaUtil.isEmpty(dateTimeValue)) ? null : dateFormat.format(dateTimeValue);
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
					record.get(OPTION_ID)
					, stringValueTypeCode.equals(valueTypeCode) ? record.get(STRING_VALUE) : null
					, dateValueTypeCode.equals(valueTypeCode) ? _dateTimeValue : null
					, numberValueTypeCode.equals(valueTypeCode) ? record.get(NUMBER_VALUE) : null
					, record.get(VALUE_INDEX)
					, operatorId);
		} else {
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
					record.get(OPTION_ID)
					, record.get(OPTION_NAME)
					, record.get(OPTION_DESCRIPTION)
					, JepOption.getValue(record.get(VALUE_TYPE_CODE))
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

		String valueTypeCode = JepOption.getValue(record.get(VALUE_TYPE_CODE));
		String dataSource = JepOption.getValue(record.get(DATA_SOURCE));
		Date dateTimeValue = addTime((Date)record.get(DATE_VALUE), (JepTime) record.get(TIME_VALUE));
		String _dateTimeValue = (JepRiaUtil.isEmpty(dateTimeValue)) ? null : dateFormat.format(dateTimeValue);

		return DaoSupport.<Integer> create(sqlQuery,
				Integer.class
				, JepOption.getValue(record.get(MODULE_ID))
				, record.get(OBJECT_SHORT_NAME)
				, JepOption.getValue(record.get(OBJECT_TYPE_ID))
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
		Collections.sort(dataSourceList, (m1, m2) -> m1.getName().compareTo(m2.getName()));
		return dataSourceList;
	}

	public List<JepOption> getModule() throws ApplicationException {
		String sqlQuery =
			" begin "
			+ " ? := pkg_option.findModule;"
			+ " end;";

		return DaoSupport.find(
				sqlQuery,
				new ResultSetMapper<JepOption>() {
					public void map(ResultSet rs, JepOption dto) throws SQLException {
						dto.setValue(getInteger(rs, ModuleOptions.MODULE_ID));
						dto.setName(rs.getString(ModuleOptions.MODULE_NAME));
					}
				},
				JepOption.class);
	}

	public List<JepOption> getObjectType() throws ApplicationException {
		String sqlQuery =
			" begin "
			+ " ? := pkg_option.getObjectType;"
			+ " end;";

		return DaoSupport.find(
				sqlQuery,
				new ResultSetMapper<JepOption>() {
					public void map(ResultSet rs, JepOption dto) throws SQLException {
						dto.setValue(getInteger(rs, ObjectTypeOptions.OBJECT_TYPE_ID));
						dto.setName(rs.getString(ObjectTypeOptions.OBJECT_TYPE_NAME));
					}
				},
				JepOption.class);
	}

	public List<JepOption> getValueType() throws ApplicationException {
		String sqlQuery =
			" begin "
			+ " ? := pkg_option.getValueType;"
			+ " end;";

		return DaoSupport.find(
				sqlQuery,
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
