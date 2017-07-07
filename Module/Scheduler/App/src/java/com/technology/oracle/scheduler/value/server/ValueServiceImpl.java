package com.technology.oracle.scheduler.value.server;
 
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;
import com.technology.oracle.scheduler.value.shared.service.ValueService;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.load.PagingResult;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.value.shared.record.ValueRecordDefinition;

import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.DATA_SOURCE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.value.server.ValueServerConstant.BEAN_JNDI_NAME;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
 
@RemoteServiceRelativePath("ValueService")
public class ValueServiceImpl extends SchedulerServiceImpl implements ValueService  {
 
  private static final long serialVersionUID = 1L;
 
  public ValueServiceImpl() {
    super(ValueRecordDefinition.instance, BEAN_JNDI_NAME);
  }
  
  @Override
  protected JepRecord findByPrimaryKey(Map<String, Object> primaryKey, JepRecord record) {
    logger.trace("BEGIN findByPrimaryKey(" + primaryKey + ")");
    
    JepRecord templateRecord = new JepRecord();
    Set<String> keySet = primaryKey.keySet();
    for(String key: keySet) {
      templateRecord.set(key, primaryKey.get(key));
    }
    templateRecord.set(MAX_ROW_COUNT, 1);
    templateRecord.set(DATA_SOURCE, record.get(DATA_SOURCE));
    templateRecord.set(BATCH_ID, record.get(BATCH_ID));
    
    PagingConfig pagingConfig = new PagingConfig(templateRecord);
    PagingResult<JepRecord> pagingResult = find(pagingConfig);
    List<JepRecord> list = pagingResult.getData();
    
    JepRecord result = list.size() > 0 ? list.get(0) : null;
    
    logger.trace("END findByPrimaryKey(" + primaryKey + ")");
    
    return result;
  }
}
