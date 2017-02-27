package com.technology.rfi.calendar.main.client;
 
import static com.technology.rfi.calendar.main.client.CalendarClientConstant.DAY_MODULE_ID;
import static com.technology.rfi.calendar.main.client.CalendarClientConstant.calendarText;

import com.google.gwt.activity.shared.Activity;
import com.google.gwt.core.client.GWT;
import com.technology.jep.jepria.client.ModuleItem;
import com.technology.jep.jepria.client.async.LoadAsyncCallback;
import com.technology.jep.jepria.client.async.LoadPlainClientFactory;
import com.technology.jep.jepria.client.ui.eventbus.main.MainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.main.MainClientFactory;
import com.technology.jep.jepria.client.ui.main.MainClientFactoryImpl;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.jep.jepria.shared.service.JepMainServiceAsync;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.rfi.calendar.day.client.DayClientFactoryImpl;
import com.technology.rfi.calendar.main.client.ui.module.CalendarMainModulePresenter;
 
public class CalendarClientFactoryImpl<E extends MainEventBus, S extends JepMainServiceAsync>
	extends MainClientFactoryImpl<E, S> {
	
  public static MainClientFactory<MainEventBus, JepMainServiceAsync> getInstance() {
		if(instance == null) {
			instance = new CalendarClientFactoryImpl<MainEventBus, JepMainServiceAsync>();
		}
		return instance;
	}
 
	private CalendarClientFactoryImpl() {
		super(new ModuleItem(DAY_MODULE_ID, calendarText.submodule_day_title()));
		initActivityMappers(this);
	}
 
	@Override
	public void getPlainClientFactory(String moduleId, final LoadAsyncCallback<PlainClientFactory<PlainEventBus, JepDataServiceAsync>> callback) {
		if(DAY_MODULE_ID.equals(moduleId)) {
			GWT.runAsync(new LoadPlainClientFactory(callback) {
				public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getPlainClientFactory() {
					return DayClientFactoryImpl.getInstance();
				}
			});
		}
	}

  @Override
  public Activity createMainModulePresenter() {
    return new CalendarMainModulePresenter<E, S>(this);
  }
}
