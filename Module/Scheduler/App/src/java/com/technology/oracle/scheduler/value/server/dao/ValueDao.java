package com.technology.oracle.scheduler.value.server.dao;
 
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.scheduler.option.shared.OptionConstant.DATE_VALUE_TYPE_CODE;
import static com.technology.oracle.scheduler.option.shared.OptionConstant.NUMBER_VALUE_TYPE_CODE;
import static com.technology.oracle.scheduler.option.shared.OptionConstant.STRING_VALUE_TYPE_CODE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.NUMBER_VALUE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.STRING_VALUE;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.DATE_VALUE;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.ENCRYPTION_FLAG;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.INSTANCE_NAME;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.LIST_SEPARATOR;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.NUMBER_VALUE_LIST;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.OPTION_ID;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.PROD_VALUE_FLAG;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.PROD_VALUE_FLAG_COMBOBOX;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.STRING_LIST_SEPARATOR;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.TIME_VALUE;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.USED_VALUE_FLAG;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.VALUE_ID;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.VALUE_INDEX;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.VALUE_TYPE_CODE;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.VALUE_TYPE_CODE_LIST;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.VALUE_TYPE_NAME;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.time.JepTime;
import com.technology.jep.jepria.shared.util.JepRiaUtil;
import com.technology.jep.jepria.shared.util.Mutable;
import com.technology.oracle.scheduler.main.server.dao.SchedulerDao;
 
public class ValueDao extends SchedulerDao implements Value {
  
  protected Date addTime(Date date, JepTime time) {
    if (date == null && time == null) return null; 
    Date result = date == null ? null : (Date)date.clone();
    if(time != null) {
      result = time.addDate(result == null ? new Date() : result);
    }
    return result;
  }
  
  private SimpleDateFormat dateFormat = new SimpleDateFormat(DEFAULT_DATE_FORMAT+" "+DEFAULT_TIME_FORMAT);
  
 
  public List<JepRecord> find( JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin  " 
        +  "? := pkg_scheduler.findValue(" 
            + "valueId => ? " 
            + ", optionId => ? " 
            + ", batchId => ? " 
          + ", maxRowCount => ? " 
          + ", operatorId => ? " 
        + ");"
     + " end;";

    ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
      public void map(ResultSet rs, JepRecord record) throws SQLException {

          record.set(VALUE_ID, getInteger(rs, VALUE_ID));
          record.set(OPTION_ID, getInteger(rs, OPTION_ID));
          record.set(USED_VALUE_FLAG, getBoolean(rs, USED_VALUE_FLAG));

          Boolean prodValueFlag = getBoolean(rs, PROD_VALUE_FLAG);
          
          JepOption jepOption = null;
          
          //TODO: взять тексты из JepTexts 
          if(Boolean.TRUE.equals(prodValueFlag)) {
            
            jepOption = new JepOption("Да", 1);
          } else if(prodValueFlag == null) {
            
            jepOption = JepOption.EMPTY_OPTION;
          } else{
            
            jepOption = new JepOption("Нет", 0);
          }
          
          record.set(PROD_VALUE_FLAG_COMBOBOX, jepOption);
          record.set(PROD_VALUE_FLAG, prodValueFlag);
          
          record.set(INSTANCE_NAME, rs.getString(INSTANCE_NAME));
          
          jepOption = new JepOption(rs.getString(VALUE_TYPE_NAME),rs.getString(VALUE_TYPE_CODE));
          record.set(VALUE_TYPE_CODE, jepOption);
          record.set(VALUE_TYPE_CODE_LIST, jepOption.getValue());
          record.set(VALUE_TYPE_NAME, jepOption.getName());
          
          record.set(STRING_VALUE, rs.getString(STRING_VALUE));

          Date date = getDate(rs, DATE_VALUE);
          record.set(DATE_VALUE, date);
          record.set(TIME_VALUE, JepRiaUtil.isEmpty(date) ? null : new JepTime(date));
          
          record.set(NUMBER_VALUE, rs.getBigDecimal(NUMBER_VALUE));
          record.set(NUMBER_VALUE_LIST, rs.getString(NUMBER_VALUE));
          record.set(ENCRYPTION_FLAG, getBoolean(rs, ENCRYPTION_FLAG));
          record.set(LIST_SEPARATOR, rs.getString(LIST_SEPARATOR));
      }
    };
    
    return super.find(
        sqlQuery
        ,resultSetMapper
        , templateRecord.get(VALUE_ID)
        , templateRecord.get(OPTION_ID)
        , templateRecord.get(BATCH_ID)
        , maxRowCount 
        , operatorId);
  }
  
  public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin " 
        + "pkg_scheduler.deleteValue(" 
            + "valueId => ? " 
            + ", batchId => ? " 
          + ", operatorId => ? " 
        + ");"
      + "end;";
    
    super.delete(
        sqlQuery
        , record.get(VALUE_ID) 
        , record.get(BATCH_ID) 
        , operatorId);
  }
 
  public void update(JepRecord record, Integer operatorId) throws ApplicationException {
    
    String valueTypeCode =  JepOption.<String>getValue(record.get(VALUE_TYPE_CODE));  
    Date dateTimeValue = addTime((Date)record.get(DATE_VALUE), (JepTime) record.get(TIME_VALUE));
    String _dateTimeValue = (JepRiaUtil.isEmpty(dateTimeValue)) ? null : dateFormat.format(dateTimeValue);
    
    String sqlQuery = 
      "begin " 
        +  "pkg_scheduler.updateValue(" 
            + "valueId => ? " 
            + ", batchId => ? " 
            + ", stringValue => ? " 
            + ", dateValue => to_date(?, 'dd.MM.yyyy HH24:mi:ss') "
            + ", numberValue => ? " 
            + ", valueIndex => ? " 
          + ", operatorId => ? " 
        + ");"
     + "end;";
    
    super.update(
        sqlQuery
        , record.get(VALUE_ID)
        , record.get(BATCH_ID)
        , STRING_VALUE_TYPE_CODE.equals(valueTypeCode) ? record.get(STRING_VALUE) : null
        , DATE_VALUE_TYPE_CODE.equals(valueTypeCode) ? _dateTimeValue : null
        , NUMBER_VALUE_TYPE_CODE.equals(valueTypeCode) ? record.get(NUMBER_VALUE) : null
        , record.get(VALUE_INDEX)
        , operatorId);
  }
 
  public Integer create(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery = 
      "begin " 
        + "? := pkg_scheduler.createValue(" 
            + "optionId => ? " 
            + ", batchId => ? " 
            + ", prodValueFlag => ? " 
            + ", instanceName => ? " 
            + ", stringValue => ? " 
            + ", dateValue => to_date(?, 'dd.MM.yyyy HH24:mi:ss') "
            + ", numberValue => ? " 
            + ", stringListSeparator => ? " 
          + ", operatorId => ? " 
        + ");"
      + "end;";
    
    String valueTypeCode =  JepOption.<String>getValue(record.get(VALUE_TYPE_CODE));
    Date dateTimeValue = addTime((Date)record.get(DATE_VALUE), (JepTime) record.get(TIME_VALUE));
    String _dateTimeValue = (JepRiaUtil.isEmpty(dateTimeValue)) ? null : dateFormat.format(dateTimeValue);
    
    return super.<Integer> create(sqlQuery,
        Integer.class 
        , record.get(OPTION_ID)
        , record.get(BATCH_ID)
        ,  JepOption.<Integer>getValue(record.get(PROD_VALUE_FLAG_COMBOBOX))
        , record.get(INSTANCE_NAME)
        , STRING_VALUE_TYPE_CODE.equals(valueTypeCode) ? record.get(STRING_VALUE) : null
        , DATE_VALUE_TYPE_CODE.equals(valueTypeCode) ? _dateTimeValue : null
        , NUMBER_VALUE_TYPE_CODE.equals(valueTypeCode) ? record.get(NUMBER_VALUE) : null
        , record.get(STRING_LIST_SEPARATOR)
        , operatorId);
  }
 
}
