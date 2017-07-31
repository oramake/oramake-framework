package com.technology.oracle.scheduler.main.client.history.scope;

public enum SchedulerScope {
  INSTANCE;
  
  String prevModuleId = null;
  String currentModuleId = null;
  
  public String getPrevModuleId() {
    return prevModuleId;
  }
  
  public void setPrevModuleId(String prevModuleId) {
    this.prevModuleId = prevModuleId;
  }

  public String getCurrentModuleId() {
    return currentModuleId;
  }

  public void setCurrentModuleId(String currentModuleId) {
    this.currentModuleId = currentModuleId;
  }
}
