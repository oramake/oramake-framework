package com.technology.rfi.calendar.day.client;
 
import static com.technology.rfi.calendar.main.client.CalendarClientConstant.DAY_MODULE_ID;

import com.google.gwt.core.client.GWT;
import com.google.gwt.place.shared.Place;
import com.google.gwt.user.client.ui.IsWidget;
import com.technology.jep.jepria.client.ui.JepPresenter;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactoryImpl;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactoryImpl;
import com.technology.jep.jepria.client.ui.plain.StandardModulePresenter;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarPresenter;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarView;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.rfi.calendar.day.client.ui.form.detail.DayDetailFormPresenter;
import com.technology.rfi.calendar.day.client.ui.form.detail.DayDetailFormViewImpl;
import com.technology.rfi.calendar.day.client.ui.form.list.DayListFormViewImpl;
import com.technology.rfi.calendar.day.client.ui.toolbar.DayToolBarViewImpl;
import com.technology.rfi.calendar.day.shared.record.DayRecordDefinition;
import com.technology.rfi.calendar.day.shared.service.DayService;
import com.technology.rfi.calendar.day.shared.service.DayServiceAsync;

public class DayClientFactoryImpl<E extends PlainEventBus, S extends DayServiceAsync>
		extends StandardClientFactoryImpl<E, S> {
 
	private static final IsWidget dayDetailFormView = new DayDetailFormViewImpl();
	private static final ToolBarView dayToolBarView = new DayToolBarViewImpl();
	private static final IsWidget dayListFormView = new DayListFormViewImpl();
 
	private static PlainClientFactoryImpl<PlainEventBus, JepDataServiceAsync> instance = null;
	
	public DayClientFactoryImpl() {
		super(DAY_MODULE_ID, DayRecordDefinition.instance);
		initActivityMappers(this);
	}
 
	public static PlainClientFactory<PlainEventBus, JepDataServiceAsync> getInstance() {
    if(instance == null) {
      instance = GWT.create(DayClientFactoryImpl.class);
    }
    return instance;
  }
	
	@Override
	public JepPresenter createPlainModulePresenter(Place place) {
    return new StandardModulePresenter(moduleId, place, this);
  }
 
	@Override
  public JepPresenter createDetailFormPresenter(Place place) {
    return new DayDetailFormPresenter(place, this);
  }
 
	@Override
  public JepPresenter createListFormPresenter(Place place) {
    return new ListFormPresenter(place, this);
  }
  
	@Override
  public JepPresenter createToolBarPresenter(Place place) {
    return new ToolBarPresenter(place, this);
  }

	@Override
	public ToolBarView getToolBarView() {
		return dayToolBarView;
	}
 
	@Override
	public IsWidget getDetailFormView() {
		return dayDetailFormView;
	}
 
	@Override
	public IsWidget getListFormView() {
		return dayListFormView;
	}
 
	@Override
	public S getService() {
    if(dataService == null) {
      dataService = (S) GWT.create(DayService.class);
    }
    return dataService;
  }
	
	@Override
	public E getEventBus() {
    if(eventBus == null) {
      eventBus = new PlainEventBus(this);
    }
    return (E) eventBus;
  }
}
