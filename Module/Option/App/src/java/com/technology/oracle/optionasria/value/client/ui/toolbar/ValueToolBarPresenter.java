package com.technology.oracle.optionasria.value.client.ui.toolbar;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.*;
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl.*;
import com.technology.jep.jepria.client.ui.eventbus.plain.JepEventBus;
import com.technology.jep.jepria.client.history.place.JepWorkstatePlace;
import com.technology.jep.jepria.client.ui.module.JepClientFactory;
import com.technology.jep.jepria.client.history.place.*;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarPresenter;
import com.technology.oracle.optionasria.value.shared.service.ValueServiceAsync;
 
public class ValueToolBarPresenter<E extends JepEventBus, S extends ValueServiceAsync> extends ToolBarPresenter<E, S, JepClientFactory<E, S>> {
 
 	public ValueToolBarPresenter(JepWorkstatePlace place, JepClientFactory<E, S> clientFactory) {
		super(place, clientFactory);
	}
 
}
