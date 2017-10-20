package com.technology.oracle.scheduler.option.client.ui.form.list;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.form.list.ListFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
//import com.technology.oracle.optionlib.option.shared.service.OptionServiceAsync;
import com.technology.oracle.scheduler.option.shared.service.OptionServiceAsync;

public class OptionListFormPresenter<V extends ListFormView, E extends PlainEventBus, S extends OptionServiceAsync, F extends StandardClientFactory<E, S>>
  extends ListFormPresenter<V, E, S, F> {

  public OptionListFormPresenter(Place place, F clientFactory) {
    super(place, clientFactory);
  }
}
