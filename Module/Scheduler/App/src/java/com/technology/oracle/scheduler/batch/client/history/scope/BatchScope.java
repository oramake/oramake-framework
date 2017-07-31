package com.technology.oracle.scheduler.batch.client.history.scope;


public class BatchScope {
  
  private Integer batchId;

  public static BatchScope instance = new BatchScope();

  public Integer getBatchId() {
    return batchId;
  }

  public void setBatchId(Integer batchId) {
    this.batchId = batchId;
  }
  
}
