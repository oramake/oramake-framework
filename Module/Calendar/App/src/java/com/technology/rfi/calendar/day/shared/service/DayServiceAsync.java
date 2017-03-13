package com.technology.rfi.calendar.day.shared.service;
 
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.google.gwt.user.client.rpc.AsyncCallback;
import java.util.List;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
 
public interface DayServiceAsync extends JepDataServiceAsync {
	void getDayType(AsyncCallback<List<JepOption>> callback);
}
