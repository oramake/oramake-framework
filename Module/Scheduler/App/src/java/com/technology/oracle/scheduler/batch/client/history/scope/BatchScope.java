package com.technology.oracle.scheduler.batch.client.history.scope;


public class BatchScope {
  
  private Integer batchId;
//  private String currentDataSource;

  public static BatchScope instance = new BatchScope();

  public Integer getBatchId() {
    return batchId;
  }

  public void setBatchId(Integer batchId) {
    this.batchId = batchId;
  }

//  public String getCurrentDataSource() {
//    return currentDataSource;
//  }
//
//  public void setCurrentDataSource(String currentDataSource) {
//    this.currentDataSource = currentDataSource;
//  }
}
