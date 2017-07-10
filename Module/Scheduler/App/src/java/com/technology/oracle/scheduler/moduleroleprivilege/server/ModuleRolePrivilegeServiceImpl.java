package com.technology.oracle.scheduler.moduleroleprivilege.server;
 
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;
import com.technology.oracle.scheduler.moduleroleprivilege.server.dao.ModuleRolePrivilege;
import com.technology.oracle.scheduler.moduleroleprivilege.server.dao.ModuleRolePrivilegeDao;
import com.technology.oracle.scheduler.moduleroleprivilege.shared.record.ModuleRolePrivilegeRecordDefinition;
import com.technology.oracle.scheduler.moduleroleprivilege.shared.service.ModuleRolePrivilegeService;
 
@RemoteServiceRelativePath("ModuleRolePrivilegeService")
public class ModuleRolePrivilegeServiceImpl extends SchedulerServiceImpl<ModuleRolePrivilege> implements ModuleRolePrivilegeService  {
 
  private static final long serialVersionUID = 1L;
 
  public ModuleRolePrivilegeServiceImpl() {
    super(ModuleRolePrivilegeRecordDefinition.instance, new ModuleRolePrivilegeDao());
  }
}
