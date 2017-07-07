package com.technology.oracle.scheduler.option.server;
 
import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;
import com.technology.oracle.scheduler.option.shared.service.OptionService;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.server.util.JepServerUtil;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.load.PagingResult;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.server.ejb.JepDataStandard;
import com.technology.oracle.scheduler.option.server.dao.Option;

import java.util.List;
import java.util.Map;
import java.util.Set;

import com.technology.oracle.scheduler.option.shared.record.OptionRecordDefinition;

import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.DATA_SOURCE;
import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.*;
import static com.technology.oracle.scheduler.option.server.OptionServerConstant.BEAN_JNDI_NAME;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
 
@RemoteServiceRelativePath("OptionService")
public class OptionServiceImpl extends SchedulerServiceImpl implements OptionService  {
 
  private static final long serialVersionUID = 1L;
 
  public OptionServiceImpl() {
    super(OptionRecordDefinition.instance, BEAN_JNDI_NAME);
  }
 
  public List<JepOption> getValueType(String dataSource) throws ApplicationException {
    List<JepOption> result = null;
    try {
      JepDataStandard ejb = (JepDataStandard) JepServerUtil.ejbLookup(ejbName);
      result = ((Option) ejb).getValueType(dataSource);
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    return result;
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
