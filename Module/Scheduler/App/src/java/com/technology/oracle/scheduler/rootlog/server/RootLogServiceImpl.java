package com.technology.oracle.scheduler.rootlog.server;
 
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.oracle.scheduler.main.server.DataSourceServiceImpl;
import com.technology.oracle.scheduler.rootlog.server.dao.RootLog;
import com.technology.oracle.scheduler.rootlog.server.dao.RootLogDao;
import com.technology.oracle.scheduler.rootlog.shared.record.RootLogRecordDefinition;
import com.technology.oracle.scheduler.rootlog.shared.service.RootLogService;
 
@RemoteServiceRelativePath("RootLogService")
public class RootLogServiceImpl extends DataSourceServiceImpl<RootLog> implements RootLogService  {
 
  private static final long serialVersionUID = 1L;
 
  public RootLogServiceImpl() {
    super(RootLogRecordDefinition.instance, new RootLogDao());
  }
}
