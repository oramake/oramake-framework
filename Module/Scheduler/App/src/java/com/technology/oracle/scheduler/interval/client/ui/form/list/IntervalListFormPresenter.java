package com.technology.oracle.scheduler.interval.client.ui.form.list;
 
import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.form.list.ListFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.oracle.scheduler.interval.shared.service.IntervalServiceAsync;

public class IntervalListFormPresenter<V extends ListFormView, E extends PlainEventBus, S extends IntervalServiceAsync, F extends StandardClientFactory<E, S>> 
  extends ListFormPresenter<V, E, S, F> {  
 
  public IntervalListFormPresenter(Place place, F clientFactory) {
    super(place, clientFactory);
  }
}
