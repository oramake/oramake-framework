package com.technology.oracle.scheduler.moduleroleprivilege.client.ui.form.list;
 
import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.form.list.ListFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.oracle.scheduler.moduleroleprivilege.shared.service.ModuleRolePrivilegeServiceAsync;

public class ModuleRolePrivilegeListFormPresenter<V extends ListFormView, E extends PlainEventBus, S extends ModuleRolePrivilegeServiceAsync, F extends StandardClientFactory<E, S>> 
	extends ListFormPresenter<V, E, S, F> {  
 
	public ModuleRolePrivilegeListFormPresenter(Place place, F clientFactory) {
		super(place, clientFactory);
	}
}
