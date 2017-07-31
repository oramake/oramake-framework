package com.technology.oracle.scheduler.batch.client;
 
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.*;
import com.google.gwt.core.client.GWT;
import com.technology.oracle.scheduler.batch.shared.BatchConstant;
import com.technology.oracle.scheduler.batch.shared.text.BatchText;
 
public class BatchClientConstant extends BatchConstant {
 
  public static String[] scopeModuleIds = {BATCH_MODULE_ID, OPTION_MODULE_ID, SCHEDULE_MODULE_ID, ROOTLOG_MODULE_ID, BATCHROLE_MODULE_ID}; 
 
  public static BatchText batchText = (BatchText) GWT.create(BatchText.class);
}
