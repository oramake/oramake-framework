package com.technology.oracle.scheduler.value.client.ui.form.list;

import com.google.gwt.place.shared.Place;
import com.google.gwt.storage.client.Storage;
import com.google.gwt.user.client.Window;
import com.technology.jep.jepria.client.history.place.JepEditPlace;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.DoGetRecordEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SearchEvent;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.form.list.ListFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.value.shared.service.ValueServiceAsync;

import static com.technology.oracle.scheduler.main.shared.SchedulerConstant.CURRENT_DATA_SOURCE;

public class ValueListFormPresenter<V extends ListFormView, E extends PlainEventBus, S extends ValueServiceAsync, F extends StandardClientFactory<E, S>>
    extends ListFormPresenter<V, E, S, F> {

  public ValueListFormPresenter(Place place, F clientFactory) {
    super(place, clientFactory);
  }


  @Override
  public void onSearch(SearchEvent event) {
    Storage storage = Storage.getSessionStorageIfSupported();
    event.getPagingConfig().getTemplateRecord().set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
    super.onSearch(event);
  }

 /* @Override
  public void onSearch(SearchEvent event) {

    searchTemplate = event.getPagingConfig(); // Запомним поисковый шаблон.
    JepRecord record = searchTemplate.getTemplateRecord();
    record.set(DATA_SOURCE, SchedulerScope.instance.getDataSource());
    record.set(BATCH_ID, BatchScope.instance.getBatchId());

    super.onSearch(event);
  };

  @Override
  public void onRowDoubleClick(JepEvent event) {
    placeController.goTo(new JepEditPlace());
  };*/
}
