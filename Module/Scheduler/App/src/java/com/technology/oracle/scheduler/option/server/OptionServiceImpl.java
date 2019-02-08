package com.technology.oracle.scheduler.option.server;

import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;

import static com.technology.oracle.scheduler.option.shared.field.OptionFieldNames.*;

import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.load.FindConfig;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.load.PagingResult;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;
import com.technology.oracle.scheduler.option.server.dao.Option;
import com.technology.oracle.scheduler.option.server.dao.OptionDao;
import com.technology.oracle.scheduler.option.shared.record.OptionRecordDefinition;
import com.technology.oracle.scheduler.option.shared.service.OptionService;

@RemoteServiceRelativePath("OptionService")
public class OptionServiceImpl extends SchedulerServiceImpl<Option> implements OptionService  {

  private static final long serialVersionUID = 1L;

  public OptionServiceImpl() {
    super(OptionRecordDefinition.instance, new OptionDao());
  }

  public List<JepOption> getValueType() throws ApplicationException {
    List<JepOption> result = null;
    try {
      result = getProxyDao().getValueType();
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    return result;
  }

  @Override
  public JepRecord update(FindConfig updateConfig) throws ApplicationException {
    JepRecord record = updateConfig.getTemplateRecord();

    logger.trace("BEGIN update(" + record + ")");
    JepRecord resultRecord = new JepRecord();

    prepareFileFields(record);

    getProxyDao().update(record, getOperatorId());
    updateLobFields(record);
    //resultRecord = findByPrimaryKey(recordDefinition.buildPrimaryKeyMap(record));
    resultRecord.set(BATCH_ID, record.get(BATCH_ID));
    resultRecord = record;
    clearFoundRecords(updateConfig);

    logger.trace("END update(" + resultRecord + ")");
    return resultRecord;
  }
}
