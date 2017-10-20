package com.technology.oracle.optionasria.option.client.ui.toolbar;

import static com.technology.jep.jepria.client.ui.WorkstateEnum.SELECTED;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.VIEW_DETAILS;
import static com.technology.oracle.optionasria.option.client.ui.toolbar.OptionToolBarViewImpl.OPTION_CURRENT_VALUE;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.history.place.JepEditPlace;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarPresenter;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarView;
import com.technology.oracle.optionasria.main.client.history.scope.OptionAsRiaScope;
import com.technology.oracle.optionasria.option.client.ui.eventbus.OptionEventBus;
import com.technology.oracle.optionasria.option.shared.service.OptionServiceAsync;

public class OptionToolBarPresenter<V extends ToolBarView, E extends OptionEventBus, S extends OptionServiceAsync, F extends StandardClientFactory<E, S>>
  extends ToolBarPresenter<V, E, S, F> {

 	public OptionToolBarPresenter(Place place, F clientFactory) {
		super(place, clientFactory);
	}

 	public void edit() {
 		OptionAsRiaScope.instance.setIsEditValue(false);
 		super.edit();
 	}

	public void bind() {
		super.bind();
		bindButton(OPTION_CURRENT_VALUE, new WorkstateEnum[]{SELECTED, VIEW_DETAILS},	event -> {
    		OptionAsRiaScope.instance.setIsEditValue(true);
    		placeController.goTo(new JepEditPlace());
    	});
	}
}
