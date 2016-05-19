package com.technology.oracle.optionasria.option.client.ui.toolbar;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.*;
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl.*;
import static com.technology.oracle.optionasria.main.client.history.scope.OptionAsRiaScope.*;
import static com.technology.oracle.optionasria.option.client.ui.toolbar.OptionToolBarViewImpl.*;

import com.extjs.gxt.ui.client.event.ButtonEvent;
import com.extjs.gxt.ui.client.event.Listener;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.JepEventBus;
import com.technology.jep.jepria.client.history.place.JepEditPlace;
import com.technology.jep.jepria.client.history.place.JepWorkstatePlace;
import com.technology.jep.jepria.client.ui.module.JepClientFactory;
import com.technology.jep.jepria.client.history.place.*;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarPresenter;
import com.technology.oracle.optionasria.main.client.history.scope.OptionAsRiaScope;
import com.technology.oracle.optionasria.option.client.ui.eventbus.OptionEventBus;
import com.technology.oracle.optionasria.option.shared.service.OptionServiceAsync;

 
public class OptionToolBarPresenter<E extends OptionEventBus, S extends OptionServiceAsync> extends ToolBarPresenter<E, S, JepClientFactory<E, S>> {
 
 	public OptionToolBarPresenter(JepWorkstatePlace place, JepClientFactory<E, S> clientFactory) {
		super(place, clientFactory);
	}
 
 	public void edit() {
 		OptionAsRiaScope.instance.setIsEditValue(false);
 		super.edit();
 	}
 	
	public void bind() {
		
		super.bind();
		
		bindButton(
			OPTION_CURRENT_VALUE, 
			new WorkstateEnum[]{SELECTED, VIEW_DETAILS},
			new Listener<ButtonEvent>() {
				public void handleEvent(ButtonEvent event) {
					OptionAsRiaScope.instance.setIsEditValue(true);
					placeController.goTo(new JepEditPlace());
				}
			});
 
	}
}
