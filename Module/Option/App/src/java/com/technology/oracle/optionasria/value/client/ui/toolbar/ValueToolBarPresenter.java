package com.technology.oracle.optionasria.value.client.ui.toolbar;
 
import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarPresenter;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarView;
import com.technology.oracle.optionasria.value.shared.service.ValueServiceAsync;
 
public class ValueToolBarPresenter<V extends ToolBarView, E extends PlainEventBus, S extends ValueServiceAsync, F extends StandardClientFactory<E, S>>
extends ToolBarPresenter<V, E, S, F> {

 public ValueToolBarPresenter(Place place, F clientFactory) {
  super(place, clientFactory);
}
 
}
