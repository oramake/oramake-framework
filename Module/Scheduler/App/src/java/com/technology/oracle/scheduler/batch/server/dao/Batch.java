package com.technology.oracle.scheduler.batch.server.dao;
 
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.oracle.scheduler.main.server.dao.Scheduler;
 
public interface Batch extends Scheduler {
  
  void activateBatch(Integer batchId, Integer operatorId) throws ApplicationException;
  void deactivateBatch(Integer batchId, Integer operatorId) throws ApplicationException;
  void executeBatch(Integer batchId, Integer operatorId) throws ApplicationException;
  void abortBatch(Integer batchId, Integer operatorId) throws ApplicationException;
}
