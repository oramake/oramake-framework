package com.technology.oracle.scheduler.value.server;
 
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;
import com.technology.oracle.scheduler.value.server.dao.Value;
import com.technology.oracle.scheduler.value.server.dao.ValueDao;
import com.technology.oracle.scheduler.value.shared.record.ValueRecordDefinition;
import com.technology.oracle.scheduler.value.shared.service.ValueService;
 
@RemoteServiceRelativePath("ValueService")
public class ValueServiceImpl extends SchedulerServiceImpl<Value> implements ValueService  {
 
  private static final long serialVersionUID = 1L;
 
  public ValueServiceImpl() {
    super(ValueRecordDefinition.instance, new ValueDao());
  }
  
  /*
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
  }*/
}
