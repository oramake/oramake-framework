package com.technology.oracle.scheduler.detailedlog.client.ui.toolbar;
 
import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarPresenter;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarView;
import com.technology.oracle.scheduler.detailedlog.shared.service.DetailedLogServiceAsync;
 
public class DetailedLogToolBarPresenter<V extends ToolBarView, E extends PlainEventBus, S extends DetailedLogServiceAsync, F extends StandardClientFactory<E, S>>
	extends ToolBarPresenter<V, E, S, F> {
 
 	public DetailedLogToolBarPresenter(Place place, F clientFactory) {
		super(place, clientFactory);
	}
}
