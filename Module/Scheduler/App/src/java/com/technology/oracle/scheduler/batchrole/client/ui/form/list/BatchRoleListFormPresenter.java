package com.technology.oracle.scheduler.batchrole.client.ui.form.list;
 
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.DATA_SOURCE;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SearchEvent;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.form.list.ListFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.batchrole.shared.service.BatchRoleServiceAsync;
import com.technology.oracle.scheduler.main.client.history.scope.SchedulerScope;

public class BatchRoleListFormPresenter<V extends ListFormView, E extends PlainEventBus, S extends BatchRoleServiceAsync, F extends StandardClientFactory<E, S>> 
  extends ListFormPresenter<V, E, S, F> { 
 
  public BatchRoleListFormPresenter(Place place, F clientFactory) {
    super(place, clientFactory);
  }
 
  @Override
  public void onSearch(SearchEvent event) {
    
    searchTemplate = event.getPagingConfig(); // Запомним поисковый шаблон.
    JepRecord record = searchTemplate.getTemplateRecord();
    record.set(DATA_SOURCE, SchedulerScope.instance.getDataSource());
    super.onSearch(event);
  };
}
