package com.technology.oracle.scheduler.main.server.ejb;
 
import javax.ejb.Remote;
import com.technology.oracle.scheduler.batch.server.ejb.Batch;
 
@Remote
public interface SchedulerRemote extends Batch {
}
