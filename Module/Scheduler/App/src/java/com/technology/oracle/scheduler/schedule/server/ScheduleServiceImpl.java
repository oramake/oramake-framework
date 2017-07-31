package com.technology.oracle.scheduler.schedule.server;
 
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.oracle.scheduler.main.server.SchedulerServiceImpl;
import com.technology.oracle.scheduler.schedule.server.dao.Schedule;
import com.technology.oracle.scheduler.schedule.server.dao.ScheduleDao;
import com.technology.oracle.scheduler.schedule.shared.record.ScheduleRecordDefinition;
import com.technology.oracle.scheduler.schedule.shared.service.ScheduleService;
 
@RemoteServiceRelativePath("ScheduleService")
public class ScheduleServiceImpl extends SchedulerServiceImpl<Schedule> implements ScheduleService  {
 
  private static final long serialVersionUID = 1L;
 
  public ScheduleServiceImpl() {
    super(ScheduleRecordDefinition.instance, new ScheduleDao());
  }
}
