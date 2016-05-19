package com.technology.oracle.scheduler.batchrole.client.ui.toolbar;
 
import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarPresenter;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarView;
import com.technology.oracle.scheduler.batchrole.shared.service.BatchRoleServiceAsync;
 
public class BatchRoleToolBarPresenter<V extends ToolBarView, E extends PlainEventBus, S extends BatchRoleServiceAsync, F extends StandardClientFactory<E, S>>
	extends ToolBarPresenter<V, E, S, F> {
 
 	public BatchRoleToolBarPresenter(Place place, F clientFactory) {
		super(place, clientFactory);
	}
 
}
