package com.technology.oracle.scheduler.schedule.client.ui.form.list;
 
import com.google.gwt.place.shared.Place;
import com.google.gwt.storage.client.Storage;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SearchEvent;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.form.list.ListFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.oracle.scheduler.schedule.shared.service.ScheduleServiceAsync;

import static com.technology.oracle.scheduler.main.shared.SchedulerConstant.CURRENT_DATA_SOURCE;

public class ScheduleListFormPresenter<V extends ListFormView, E extends PlainEventBus, S extends ScheduleServiceAsync, F extends StandardClientFactory<E, S>> 
  extends ListFormPresenter<V, E, S, F> {     
 
  public ScheduleListFormPresenter(Place place, F clientFactory) {
    super(place, clientFactory);
  }

  @Override
  public void onSearch(SearchEvent event) {
    Storage storage = Storage.getSessionStorageIfSupported();
    event.getPagingConfig().getTemplateRecord().set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
    super.onSearch(event);
  }
}

