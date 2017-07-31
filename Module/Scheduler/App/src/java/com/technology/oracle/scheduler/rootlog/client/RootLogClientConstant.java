package com.technology.oracle.scheduler.rootlog.client;
 
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.*;
import com.google.gwt.core.client.GWT;
import com.technology.oracle.scheduler.rootlog.shared.RootLogConstant;
import com.technology.oracle.scheduler.rootlog.shared.text.RootLogText;
 
public class RootLogClientConstant extends RootLogConstant {
 
  public static String[] scopeModuleIds = {ROOTLOG_MODULE_ID, DETAILEDLOG_MODULE_ID}; 
 
  public static RootLogText rootLogText = (RootLogText) GWT.create(RootLogText.class);
}
