package com.technology.oracle.scheduler.main.server.ejb;
 
import javax.ejb.Local;
import com.technology.oracle.scheduler.batch.server.ejb.Batch;
 
@Local
public interface SchedulerLocal extends Batch {
}
