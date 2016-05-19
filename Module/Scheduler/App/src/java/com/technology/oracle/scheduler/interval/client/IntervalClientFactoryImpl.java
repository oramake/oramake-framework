package com.technology.oracle.scheduler.interval.client;
 
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.INTERVAL_MODULE_ID;
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
import com.technology.oracle.scheduler.interval.client.ui.toolbar.IntervalToolBarViewImpl;
 
import com.technology.oracle.scheduler.interval.client.ui.form.detail.IntervalDetailFormPresenter;
import com.technology.oracle.scheduler.interval.client.ui.form.detail.IntervalDetailFormViewImpl;
import com.technology.oracle.scheduler.interval.client.ui.form.list.IntervalListFormViewImpl;
import com.technology.oracle.scheduler.interval.client.ui.form.list.IntervalListFormPresenter;
import com.technology.oracle.scheduler.interval.shared.service.IntervalService;
import com.technology.oracle.scheduler.interval.shared.service.IntervalServiceAsync;
import com.technology.oracle.scheduler.interval.shared.record.IntervalRecordDefinition;
 
public class IntervalClientFactoryImpl<E extends PlainEventBus, S extends IntervalServiceAsync>
	extends com.technology.jep.jepria.client.ui.plain.StandardClientFactoryImpl<E, S> {
 
	private static final IsWidget intervalDetailFormView = new IntervalDetailFormViewImpl();
	private static final IsWidget intervalToolBarView = new IntervalToolBarViewImpl();
	private static final IsWidget intervalListFormView = new IntervalListFormViewImpl();
 
	public static PlainClientFactoryImpl<PlainEventBus, JepDataServiceAsync> instance = null;
 
	public IntervalClientFactoryImpl() {
		super(IntervalRecordDefinition.instance);
		initActivityMappers(this);
	}
 
	static public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getInstance() {
		if(instance == null) {
			instance = GWT.create(IntervalClientFactoryImpl.class);
		}
		return instance;
	}
 
public JepPresenter createPlainModulePresenter(Place place) {
	return new StandardModulePresenter(INTERVAL_MODULE_ID, place, this);
}
 
	public JepPresenter createDetailFormPresenter(Place place) {
		return new IntervalDetailFormPresenter(place, this);
	}
 
	public JepPresenter createListFormPresenter(Place place) {
		return new IntervalListFormPresenter(place, this);
	}
 
	public JepPresenter createToolBarPresenter(Place place) {
		return new ToolBarPresenter(place, this);
	}
 
	public IsWidget getToolBarView() {
		return intervalToolBarView;
	}
 
	public IsWidget getDetailFormView() {
		return intervalDetailFormView;
	}
 
	public IsWidget getListFormView() {
		return intervalListFormView;
	}
 
	public S getService() {
		if(dataService == null) {
			dataService = (S) GWT.create(IntervalService.class);
		}
		return dataService;
	}
}
