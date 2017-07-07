package com.technology.oracle.scheduler.option.client;
 
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.*;
import com.google.gwt.core.client.GWT;
import com.technology.oracle.scheduler.option.shared.OptionConstant;
import com.technology.oracle.scheduler.option.shared.text.OptionText;
 
public class OptionClientConstant extends OptionConstant {
 
  public static String[] scopeModuleIds = {OPTION_MODULE_ID, VALUE_MODULE_ID}; 
 
  public static OptionText optionText = (OptionText) GWT.create(OptionText.class);
}
