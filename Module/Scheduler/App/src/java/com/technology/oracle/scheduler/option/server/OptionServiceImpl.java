package com.technology.oracle.scheduler.option.server;
 
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;

import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
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
}
