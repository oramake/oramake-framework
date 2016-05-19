package com.technology.oracle.scheduler.moduleroleprivilege.client;
 
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.MODULEROLEPRIVILEGE_MODULE_ID;
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
import com.technology.oracle.scheduler.moduleroleprivilege.client.ui.toolbar.ModuleRolePrivilegeToolBarViewImpl;
 
import com.technology.oracle.scheduler.moduleroleprivilege.client.ui.form.detail.ModuleRolePrivilegeDetailFormPresenter;
import com.technology.oracle.scheduler.moduleroleprivilege.client.ui.form.detail.ModuleRolePrivilegeDetailFormViewImpl;
import com.technology.oracle.scheduler.moduleroleprivilege.client.ui.form.list.ModuleRolePrivilegeListFormViewImpl;
import com.technology.oracle.scheduler.moduleroleprivilege.client.ui.form.list.ModuleRolePrivilegeListFormPresenter;
import com.technology.oracle.scheduler.moduleroleprivilege.shared.service.ModuleRolePrivilegeService;
import com.technology.oracle.scheduler.moduleroleprivilege.shared.service.ModuleRolePrivilegeServiceAsync;
import com.technology.oracle.scheduler.moduleroleprivilege.shared.record.ModuleRolePrivilegeRecordDefinition;
 
public class ModuleRolePrivilegeClientFactoryImpl<E extends PlainEventBus, S extends ModuleRolePrivilegeServiceAsync>
	extends com.technology.jep.jepria.client.ui.plain.StandardClientFactoryImpl<E, S> {
 
	private static final IsWidget moduleRolePrivilegeDetailFormView = new ModuleRolePrivilegeDetailFormViewImpl();
	private static final IsWidget moduleRolePrivilegeToolBarView = new ModuleRolePrivilegeToolBarViewImpl();
	private static final IsWidget moduleRolePrivilegeListFormView = new ModuleRolePrivilegeListFormViewImpl();
 
	public static PlainClientFactoryImpl<PlainEventBus, JepDataServiceAsync> instance = null;
 
	public ModuleRolePrivilegeClientFactoryImpl() {
		super(ModuleRolePrivilegeRecordDefinition.instance);
		initActivityMappers(this);
	}
 
	static public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getInstance() {
		if(instance == null) {
			instance = GWT.create(ModuleRolePrivilegeClientFactoryImpl.class);
		}
		return instance;
	}
 
public JepPresenter createPlainModulePresenter(Place place) {
	return new StandardModulePresenter(MODULEROLEPRIVILEGE_MODULE_ID, place, this);
}
 
	public JepPresenter createDetailFormPresenter(Place place) {
		return new ModuleRolePrivilegeDetailFormPresenter(place, this);
	}
 
	public JepPresenter createListFormPresenter(Place place) {
		return new ModuleRolePrivilegeListFormPresenter(place, this);
	}
 
	public JepPresenter createToolBarPresenter(Place place) {
		return new ToolBarPresenter(place, this);
	}
 
	public IsWidget getToolBarView() {
		return moduleRolePrivilegeToolBarView;
	}
 
	public IsWidget getDetailFormView() {
		return moduleRolePrivilegeDetailFormView;
	}
 
	public IsWidget getListFormView() {
		return moduleRolePrivilegeListFormView;
	}
 
	public S getService() {
		if(dataService == null) {
			dataService = (S) GWT.create(ModuleRolePrivilegeService.class);
		}
		return dataService;
	}
}
