package com.technology.oracle.scheduler.schedule.client.ui.form.list;
 
import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.form.list.ListFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.oracle.scheduler.schedule.shared.service.ScheduleServiceAsync;

public class ScheduleListFormPresenter<V extends ListFormView, E extends PlainEventBus, S extends ScheduleServiceAsync, F extends StandardClientFactory<E, S>> 
  extends ListFormPresenter<V, E, S, F> {     
 
  public ScheduleListFormPresenter(Place place, F clientFactory) {
    super(place, clientFactory);
  }
}

