package com.technology.oracle.scheduler.schedule.client;
 
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.*;
import com.google.gwt.core.client.GWT;
import com.technology.oracle.scheduler.schedule.shared.ScheduleConstant;
import com.technology.oracle.scheduler.schedule.shared.text.ScheduleText;
 
public class ScheduleClientConstant extends ScheduleConstant {
 
  public static String[] scopeModuleIds = {SCHEDULE_MODULE_ID, INTERVAL_MODULE_ID}; 
 
  public static ScheduleText scheduleText = (ScheduleText) GWT.create(ScheduleText.class);
}
