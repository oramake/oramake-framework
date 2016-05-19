package com.technology.oracle.scheduler.schedule.server.ejb;
 
import javax.ejb.Remote;
import com.technology.oracle.scheduler.schedule.server.ejb.Schedule;
 
@Remote
public interface ScheduleRemote extends Schedule {
}
