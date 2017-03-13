package com.technology.rfi.calendar.day.client;
 
import com.google.gwt.core.client.GWT;
import com.technology.rfi.calendar.day.shared.DayConstant;
import com.technology.rfi.calendar.day.shared.text.DayText;
 
public class DayClientConstant extends DayConstant {
 
	public static DayText dayText = (DayText) GWT.create(DayText.class);
}
