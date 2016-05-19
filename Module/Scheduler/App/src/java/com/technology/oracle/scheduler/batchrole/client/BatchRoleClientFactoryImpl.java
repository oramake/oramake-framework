package com.technology.oracle.scheduler.batchrole.client;
 
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.BATCHROLE_MODULE_ID;
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
import com.technology.oracle.scheduler.batchrole.client.ui.toolbar.BatchRoleToolBarViewImpl;
 
import com.technology.oracle.scheduler.batchrole.client.ui.form.detail.BatchRoleDetailFormPresenter;
import com.technology.oracle.scheduler.batchrole.client.ui.form.detail.BatchRoleDetailFormViewImpl;
import com.technology.oracle.scheduler.batchrole.client.ui.form.list.BatchRoleListFormViewImpl;
import com.technology.oracle.scheduler.batchrole.client.ui.form.list.BatchRoleListFormPresenter;
import com.technology.oracle.scheduler.batchrole.shared.service.BatchRoleService;
import com.technology.oracle.scheduler.batchrole.shared.service.BatchRoleServiceAsync;
import com.technology.oracle.scheduler.batchrole.shared.record.BatchRoleRecordDefinition;
 
public class BatchRoleClientFactoryImpl<E extends PlainEventBus, S extends BatchRoleServiceAsync>
	extends com.technology.jep.jepria.client.ui.plain.StandardClientFactoryImpl<E, S> {
 
	private static final IsWidget batchRoleDetailFormView = new BatchRoleDetailFormViewImpl();
	private static final IsWidget batchRoleToolBarView = new BatchRoleToolBarViewImpl();
	private static final IsWidget batchRoleListFormView = new BatchRoleListFormViewImpl();
 
	public static PlainClientFactoryImpl<PlainEventBus, JepDataServiceAsync> instance = null;
 
	public BatchRoleClientFactoryImpl() {
		super(BatchRoleRecordDefinition.instance);
		initActivityMappers(this);
	}
 
	static public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getInstance() {
		if(instance == null) {
			instance = GWT.create(BatchRoleClientFactoryImpl.class);
		}
		return instance;
	}
 
public JepPresenter createPlainModulePresenter(Place place) {
	return new StandardModulePresenter(BATCHROLE_MODULE_ID, place, this);
}
 
	public JepPresenter createDetailFormPresenter(Place place) {
		return new BatchRoleDetailFormPresenter(place, this);
	}
 
	public JepPresenter createListFormPresenter(Place place) {
		return new BatchRoleListFormPresenter(place, this);
	}
 
	public JepPresenter createToolBarPresenter(Place place) {
		return new ToolBarPresenter(place, this);
	}
 
	public IsWidget getToolBarView() {
		return batchRoleToolBarView;
	}
 
	public IsWidget getDetailFormView() {
		return batchRoleDetailFormView;
	}
 
	public IsWidget getListFormView() {
		return batchRoleListFormView;
	}
 
	public S getService() {
		if(dataService == null) {
			dataService = (S) GWT.create(BatchRoleService.class);
		}
		return dataService;
	}
}
