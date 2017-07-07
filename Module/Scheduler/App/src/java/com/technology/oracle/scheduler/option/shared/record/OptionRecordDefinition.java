package com.technology.oracle.scheduler.option.shared.record;
 
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.*;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.*;
import com.technology.jep.jepria.shared.field.JepTypeEnum;
import static com.technology.jep.jepria.shared.field.JepLikeEnum.*;
import com.technology.jep.jepria.shared.field.JepLikeEnum;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
 
import java.util.HashMap;
import java.util.Map;
 
public class OptionRecordDefinition extends JepRecordDefinition {
 
  private static final long serialVersionUID = 1L;
 
  public static OptionRecordDefinition instance = new OptionRecordDefinition();
 
  private OptionRecordDefinition() {
    super(buildTypeMap()
      , new String[]{OPTION_ID}
    );
    super.setLikeMap(buildLikeMap());
  }
 
  private static Map<String, JepTypeEnum> buildTypeMap() {
    Map<String, JepTypeEnum> typeMap = new HashMap<String, JepTypeEnum>();
    typeMap.put(DATA_SOURCE, STRING);
    typeMap.put(OPTION_ID, INTEGER);
    typeMap.put(BATCH_ID, INTEGER);
    typeMap.put(OPTION_SHORT_NAME, STRING);
    typeMap.put(OPTION_NAME, STRING);
    typeMap.put(OPTION_DESCRIPTION, STRING);
    typeMap.put(STRING_VALUE, STRING);
    typeMap.put(DATE_VALUE, DATE);
    typeMap.put(TIME_VALUE, TIME);
    typeMap.put(NUMBER_VALUE, BIGDECIMAL);
    typeMap.put(VALUE_TYPE_CODE, STRING);
    typeMap.put(VALUE_TYPE_NAME, STRING);
    typeMap.put(VALUE_LIST_FLAG, BOOLEAN);
    typeMap.put(LIST_SEPARATOR, STRING);
    typeMap.put(ENCRYPTION_FLAG, BOOLEAN);
    typeMap.put(TEST_PROD_SENSITIVE_FLAG, BOOLEAN);
    typeMap.put(STRING_LIST_SEPARATOR, STRING);
    typeMap.put(ACCESS_LEVEL_NAME, STRING);
    typeMap.put(VALUE_INDEX, STRING);
    return typeMap;
  }
 
  private static Map<String, JepLikeEnum> buildLikeMap() {
    Map<String, JepLikeEnum> likeMap = new HashMap<String, JepLikeEnum>();
    likeMap.put(OPTION_SHORT_NAME, CONTAINS);
    likeMap.put(OPTION_NAME, CONTAINS);
    likeMap.put(OPTION_DESCRIPTION, CONTAINS);
    likeMap.put(STRING_VALUE, CONTAINS);
    return likeMap;
  }
}
