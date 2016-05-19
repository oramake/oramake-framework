package com.technology.oracle.scheduler.main.client;
 
import com.google.gwt.core.client.GWT;
import com.technology.oracle.scheduler.main.shared.text.SchedulerText;
import com.technology.jep.jepria.shared.JepRiaConstant;
 
public class SchedulerClientConstant extends JepRiaConstant {
	public static final String BATCH_MODULE_ID = "Batch";
	public static final String SCHEDULE_MODULE_ID = "Schedule";
	public static final String INTERVAL_MODULE_ID = "Interval";
	public static final String ROOTLOG_MODULE_ID = "RootLog";
	public static final String DETAILEDLOG_MODULE_ID = "DetailedLog";
	public static final String BATCHROLE_MODULE_ID = "BatchRole";
	public static final String OPTION_MODULE_ID = "Option";
	public static final String VALUE_MODULE_ID = "Value";
	public static final String MODULEROLEPRIVILEGE_MODULE_ID = "ModuleRolePrivilege";
	public static SchedulerText SchedulerText = (SchedulerText) GWT.create(SchedulerText.class);
}
