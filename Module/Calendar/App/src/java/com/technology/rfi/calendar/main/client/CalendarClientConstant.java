package com.technology.rfi.calendar.main.client;
 
import com.google.gwt.core.client.GWT;
import com.technology.rfi.calendar.main.shared.text.CalendarText;
import com.technology.jep.jepria.shared.JepRiaConstant;
 
public class CalendarClientConstant extends JepRiaConstant {
	public static final String DAY_MODULE_ID = "Day";
	public static CalendarText calendarText = (CalendarText) GWT.create(CalendarText.class);
}
