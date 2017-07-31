package com.technology.oracle.scheduler.detailedlog.server;
 
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.oracle.scheduler.detailedlog.server.dao.DetailedLog;
import com.technology.oracle.scheduler.detailedlog.server.dao.DetailedLogDao;
import com.technology.oracle.scheduler.detailedlog.shared.record.DetailedLogRecordDefinition;
import com.technology.oracle.scheduler.detailedlog.shared.service.DetailedLogService;
import com.technology.oracle.scheduler.main.server.DataSourceServiceImpl;
 
@RemoteServiceRelativePath("DetailedLogService")
public class DetailedLogServiceImpl extends DataSourceServiceImpl<DetailedLog> implements DetailedLogService  {
 
  private static final long serialVersionUID = 1L;
 
  public DetailedLogServiceImpl() {
    super(DetailedLogRecordDefinition.instance, new DetailedLogDao());
  }
}
