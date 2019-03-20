package com.technology.oracle.scheduler.option.server.dao;

import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;
import static com.technology.oracle.scheduler.option.shared.OptionConstant.DATE_VALUE_TYPE_CODE;
import static com.technology.oracle.scheduler.option.shared.OptionConstant.NUMBER_VALUE_TYPE_CODE;
import static com.technology.oracle.scheduler.option.shared.OptionConstant.STRING_VALUE_TYPE_CODE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.ACCESS_LEVEL_NAME;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.DATE_VALUE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.ENCRYPTION_FLAG;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.IS_EDIT_VALUE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.LIST_SEPARATOR;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.NUMBER_VALUE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.NUMBER_VALUE_LIST;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.OPTION_DESCRIPTION;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.OPTION_ID;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.OPTION_NAME;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.OPTION_SHORT_NAME;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.STRING_LIST_SEPARATOR;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.STRING_VALUE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.TEST_PROD_SENSITIVE_FLAG;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.TIME_VALUE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.VALUE_INDEX;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.VALUE_LIST_FLAG;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.VALUE_TYPE_CODE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.VALUE_TYPE_NAME;

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
import com.technology.oracle.scheduler.batch.client.history.scope.BatchScope;
import com.technology.oracle.scheduler.main.server.dao.SchedulerDao;
import com.technology.oracle.scheduler.option.shared.field.ValueTypeOptions;

public class OptionDao extends SchedulerDao implements Option {

  public List<JepRecord> find(JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
    String sqlQuery =
      "begin  "
        +  "? := pkg_Scheduler.findOption("
            + " optionId => ? "
            + ", batchId => ? "
          + ", maxRowCount => ? "
          + ", operatorId => ? "
        + ");"
     + " end;";

    final Integer batchId = templateRecord.get(BATCH_ID);

    ResultSetMapper<JepRecord> resultSetMapper = new ResultSetMapper<JepRecord>() {
      public void map(ResultSet rs, JepRecord record) throws SQLException {

          record.set(BATCH_ID, batchId);
          record.set(OPTION_ID, getInteger(rs, OPTION_ID));
          record.set(OPTION_SHORT_NAME, rs.getString(OPTION_SHORT_NAME));
          record.set(OPTION_NAME, rs.getString(OPTION_NAME));
          record.set(OPTION_DESCRIPTION, rs.getString(OPTION_DESCRIPTION));
          record.set(STRING_VALUE, rs.getString(STRING_VALUE));

          Date date = getTimestamp(rs, DATE_VALUE);
          record.set(DATE_VALUE, date);
          record.set(TIME_VALUE, JepRiaUtil.isEmpty(date) ? null : new JepTime(date));

          record.set(NUMBER_VALUE, rs.getBigDecimal(NUMBER_VALUE));
          record.set(NUMBER_VALUE_LIST, rs.getString(NUMBER_VALUE));

          JepOption jepOption = new JepOption(rs.getString(VALUE_TYPE_NAME), rs.getString(VALUE_TYPE_CODE));
          record.set(VALUE_TYPE_CODE, jepOption);
          record.set(VALUE_TYPE_NAME, jepOption.getName());

          record.set(VALUE_LIST_FLAG, getBoolean(rs, VALUE_LIST_FLAG));
          record.set(LIST_SEPARATOR, rs.getString(LIST_SEPARATOR));
          record.set(ENCRYPTION_FLAG, getBoolean(rs, ENCRYPTION_FLAG));
          record.set(TEST_PROD_SENSITIVE_FLAG, getBoolean(rs, TEST_PROD_SENSITIVE_FLAG));
          record.set(ACCESS_LEVEL_NAME, rs.getString(ACCESS_LEVEL_NAME));
        }
    };

    return super.find(
        sqlQuery
        , resultSetMapper
        , templateRecord.get(OPTION_ID)
        , templateRecord.get(BATCH_ID)
        , maxRowCount
        , operatorId);
  }

  public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery =
      "begin "
        + "pkg_Scheduler.deleteOption("
            + "optionId => ? "
            + ", batchId => ? "
          + ", operatorId => ? "
        + ");"
      + "end;";

    super.delete(
        sqlQuery
        , record.get(OPTION_ID)
        , record.get(BATCH_ID)
        , operatorId);
  }

  protected Date addTime(Date date, JepTime time) {
    if (date == null && time == null) return null;
    Date result = date == null ? null : (Date)date.clone();
    if(time != null) {
      result = time.addDate(result == null ? new Date() : result);
    }
    return result;
  }

  private SimpleDateFormat dateFormat = new SimpleDateFormat(DEFAULT_DATE_FORMAT+" "+DEFAULT_TIME_FORMAT);

  public void update(JepRecord record, Integer operatorId) throws ApplicationException {

    if((Boolean) record.get(IS_EDIT_VALUE) == true) {

      String valueTypeCode = JepOption.<String>getValue(record.get(VALUE_TYPE_CODE));
      Date dateTimeValue = addTime((Date)record.get(DATE_VALUE), (JepTime) record.get(TIME_VALUE));
      String _dateTimeValue = (JepRiaUtil.isEmpty(dateTimeValue)) ? null : dateFormat.format(dateTimeValue);

      String sqlQuery =
          "begin "
            +  "pkg_Scheduler.setOptionValue("
                + "optionId => ? "
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
          , record.get(OPTION_ID)
          , record.get(BATCH_ID)
          , STRING_VALUE_TYPE_CODE.equals(valueTypeCode) ? record.get(STRING_VALUE) : null
          , DATE_VALUE_TYPE_CODE.equals(valueTypeCode) ? _dateTimeValue : null
          , NUMBER_VALUE_TYPE_CODE.equals(valueTypeCode) ? record.get(NUMBER_VALUE) : null
          , record.get(VALUE_INDEX)
          , operatorId);

    } else {

      String sqlQuery =
          "begin "
            +  "pkg_Scheduler.updateOption("
                + "optionId => ? "
                + ", batchId => ? "
                + ", optionName => ? "
                + ", optionDescription => ? "
                + ", valueTypeCode => ? "
                + ", valueListFlag => ? "
                + ", encryptionFlag => ? "
                + ", testProdSensitiveFlag => ? "
              + ", operatorId => ? "
            + ");"
         + "end;";

      super.update(
          sqlQuery
          , record.get(OPTION_ID)
          , record.get(BATCH_ID)
          , record.get(OPTION_NAME)
          , record.get(OPTION_DESCRIPTION)
          ,  JepOption.<String>getValue(record.get(VALUE_TYPE_CODE))
          , record.get(VALUE_LIST_FLAG)
          , record.get(ENCRYPTION_FLAG)
          , record.get(TEST_PROD_SENSITIVE_FLAG)
          , operatorId);
    }
  }

  public Integer create(JepRecord record, Integer operatorId) throws ApplicationException {
    String sqlQuery =
      "begin "
        + "? := pkg_Scheduler.createOption("
            + "batchId => ? "
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

    String valueTypeCode =  JepOption.<String>getValue(record.get(VALUE_TYPE_CODE));

    Date dateTimeValue = addTime((Date)record.get(DATE_VALUE), (JepTime) record.get(TIME_VALUE));
    String _dateTimeValue = (JepRiaUtil.isEmpty(dateTimeValue)) ? null : dateFormat.format(dateTimeValue);

    return super.<Integer> create(sqlQuery
        , Integer.class
        , record.get(BATCH_ID)
        , record.get(OPTION_SHORT_NAME)
        , record.get(OPTION_NAME)
        , record.get(OPTION_DESCRIPTION)
        , STRING_VALUE_TYPE_CODE.equals(valueTypeCode) ? record.get(STRING_VALUE) : null
        , DATE_VALUE_TYPE_CODE.equals(valueTypeCode) ? _dateTimeValue : null
        , NUMBER_VALUE_TYPE_CODE.equals(valueTypeCode) ? record.get(NUMBER_VALUE) : null
        ,  JepOption.<String>getValue(record.get(VALUE_TYPE_CODE))
        , record.get(VALUE_LIST_FLAG)
        , record.get(ENCRYPTION_FLAG)
        , record.get(TEST_PROD_SENSITIVE_FLAG)
        , record.get(STRING_LIST_SEPARATOR)
        , operatorId);
  }


  public List<JepOption> getValueType() throws ApplicationException {
    String sqlQuery =
      " begin "
      + " ? := pkg_Scheduler.getValueType;"
      + " end;";

    return super.getOptions(
        sqlQuery,
        new ResultSetMapper<JepOption>() {
          public void map(ResultSet rs, JepOption dto) throws SQLException {
            dto.setValue(rs.getString(ValueTypeOptions.VALUE_TYPE_CODE));
            dto.setName(rs.getString(ValueTypeOptions.VALUE_TYPE_NAME));
          }
        }
    );
  }
}
