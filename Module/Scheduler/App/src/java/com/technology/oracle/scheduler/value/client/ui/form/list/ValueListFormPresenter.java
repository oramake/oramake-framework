package com.technology.oracle.scheduler.value.client.ui.form.list;
 
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.value.shared.field.ValueFieldNames.DATA_SOURCE;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.history.place.JepEditPlace;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SearchEvent;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.form.list.ListFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.batch.client.history.scope.BatchScope;
import com.technology.oracle.scheduler.main.client.history.scope.SchedulerScope;
import com.technology.oracle.scheduler.value.shared.service.ValueServiceAsync;
public class ValueListFormPresenter<V extends ListFormView, E extends PlainEventBus, S extends ValueServiceAsync, F extends StandardClientFactory<E, S>> 
  extends ListFormPresenter<V, E, S, F> {   
 
  public ValueListFormPresenter(Place place, F clientFactory) {
    super(place, clientFactory);
  }
 
  @Override
  public void onSearch(SearchEvent event) {
    
    searchTemplate = event.getPagingConfig(); // Запомним поисковый шаблон.
    JepRecord record = searchTemplate.getTemplateRecord();
    record.set(DATA_SOURCE, SchedulerScope.instance.getDataSource());
    record.set(BATCH_ID, BatchScope.instance.getBatchId());
    
    super.onSearch(event);
  };
  
  @Override
  public void rowDoubleClick(JepEvent event) {
    placeController.goTo(new JepEditPlace());
  };
}
