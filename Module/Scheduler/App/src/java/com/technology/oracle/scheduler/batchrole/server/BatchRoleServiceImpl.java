package com.technology.oracle.scheduler.batchrole.server;
 
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.oracle.scheduler.batchrole.server.dao.BatchRole;
import com.technology.oracle.scheduler.batchrole.server.dao.BatchRoleDao;
import com.technology.oracle.scheduler.batchrole.shared.record.BatchRoleRecordDefinition;
import com.technology.oracle.scheduler.batchrole.shared.service.BatchRoleService;
import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;
 
@RemoteServiceRelativePath("BatchRoleService")
public class BatchRoleServiceImpl extends SchedulerServiceImpl<BatchRole> implements BatchRoleService {
 
  private static final long serialVersionUID = 1L;
 
  public BatchRoleServiceImpl() {
    super(BatchRoleRecordDefinition.instance, new BatchRoleDao());
  }
}
