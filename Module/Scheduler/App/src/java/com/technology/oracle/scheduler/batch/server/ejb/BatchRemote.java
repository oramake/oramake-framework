package com.technology.oracle.scheduler.batch.server.ejb;
 
import javax.ejb.Remote;
import com.technology.oracle.scheduler.batch.server.ejb.Batch;
 
@Remote
public interface BatchRemote extends Batch {
}
