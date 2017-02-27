package com.technology.rfi.calendar.main.client.entrance;
 
import com.technology.jep.jepria.client.entrance.JepEntryPoint;
import com.technology.rfi.calendar.main.client.CalendarClientFactoryImpl;
 
public class CalendarEntryPoint extends JepEntryPoint {
 
	CalendarEntryPoint() {
		super(CalendarClientFactoryImpl.getInstance());
	}
}
