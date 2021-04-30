package com.technology.oracle.scheduler.batchrole.client.ui.form.list;
 
import com.google.gwt.place.shared.Place;
import com.google.gwt.storage.client.Storage;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SearchEvent;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.form.list.ListFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.batchrole.shared.service.BatchRoleServiceAsync;

public class BatchRoleListFormPresenter<V extends ListFormView, E extends PlainEventBus, S extends BatchRoleServiceAsync, F extends StandardClientFactory<E, S>> 
    extends ListFormPresenter<V, E, S, F> { 
 
  public BatchRoleListFormPresenter(Place place, F clientFactory) {
    super(place, clientFactory);
  }

  /*@Override
  public void onSearch(SearchEvent event) {
    Storage storage = Storage.getLocalStorageIfSupported();
    event.getPagingConfig().getTemplateRecord().set("data_source", storage.getItem("CURRENT_DATA_SOURCE"));
    super.onSearch(event);
  }*/
}
