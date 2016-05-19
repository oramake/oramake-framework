package com.technology.oracle.scheduler.value.client;
 
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.VALUE_MODULE_ID;
import com.google.gwt.core.client.GWT;
import com.google.gwt.place.shared.Place;
import com.google.gwt.user.client.ui.IsWidget;
 
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.jep.jepria.client.ui.JepPresenter;
import com.technology.jep.jepria.client.ui.form.list.ListFormView;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactoryImpl;
import com.technology.jep.jepria.client.ui.plain.StandardModulePresenter;
import com.technology.jep.jepria.client.history.place.JepWorkstatePlace;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarPresenter;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarView;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl;
import com.technology.oracle.scheduler.value.client.ui.toolbar.ValueToolBarViewImpl;
 
import com.technology.oracle.scheduler.value.client.ui.form.detail.ValueDetailFormPresenter;
import com.technology.oracle.scheduler.value.client.ui.form.detail.ValueDetailFormViewImpl;
import com.technology.oracle.scheduler.value.client.ui.form.list.ValueListFormViewImpl;
import com.technology.oracle.scheduler.value.client.ui.form.list.ValueListFormPresenter;
import com.technology.oracle.scheduler.value.shared.service.ValueService;
import com.technology.oracle.scheduler.value.shared.service.ValueServiceAsync;
import com.technology.oracle.scheduler.value.shared.record.ValueRecordDefinition;
 
public class ValueClientFactoryImpl<E extends PlainEventBus, S extends ValueServiceAsync>
	extends com.technology.jep.jepria.client.ui.plain.StandardClientFactoryImpl<E, S> {
 
	private static final IsWidget valueDetailFormView = new ValueDetailFormViewImpl();
	private static final IsWidget valueToolBarView = new ValueToolBarViewImpl();
	private static final IsWidget valueListFormView = new ValueListFormViewImpl();
 
	public static PlainClientFactoryImpl<PlainEventBus, JepDataServiceAsync> instance = null;
 
	public ValueClientFactoryImpl() {
		super(ValueRecordDefinition.instance);
		initActivityMappers(this);
	}
 
	static public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getInstance() {
		if(instance == null) {
			instance = GWT.create(ValueClientFactoryImpl.class);
		}
		return instance;
	}
 
public JepPresenter createPlainModulePresenter(Place place) {
	return new StandardModulePresenter(VALUE_MODULE_ID, place, this);
}
 
	public JepPresenter createDetailFormPresenter(Place place) {
		return new ValueDetailFormPresenter(place, this);
	}
 
	public JepPresenter createListFormPresenter(Place place) {
		return new ValueListFormPresenter(place, this);
	}
 
	public JepPresenter createToolBarPresenter(Place place) {
		return new ToolBarPresenter(place, this);
	}
 
	public IsWidget getToolBarView() {
		return valueToolBarView;
	}
 
	public IsWidget getDetailFormView() {
		return valueDetailFormView;
	}
 
	public IsWidget getListFormView() {
		return valueListFormView;
	}
 
	public S getService() {
		if(dataService == null) {
			dataService = (S) GWT.create(ValueService.class);
		}
		return dataService;
	}
}
