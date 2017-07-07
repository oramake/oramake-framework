package com.technology.oracle.scheduler.batch.client.ui.form;
 
import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SetCurrentRecordEvent;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.ui.plain.StandardModulePresenter;
import com.technology.jep.jepria.client.ui.plain.StandardModuleView;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.batch.client.history.scope.BatchScope;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.BatchEventBus;
import com.technology.oracle.scheduler.batch.shared.service.BatchServiceAsync;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_ID;

import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.BATCH_MODULE_ID;
 
public class BatchFormContainerPresenter<E extends BatchEventBus, S extends BatchServiceAsync, F extends StandardClientFactory<E,S>> 
  extends StandardModulePresenter<StandardModuleView, E, S, F> {
  
  public BatchFormContainerPresenter(Place place, F clientFactory) {
    super(BATCH_MODULE_ID, place, clientFactory);
  }
  
  public void onSetCurrentRecord(SetCurrentRecordEvent event) {

    JepRecord currentRecord = event.getCurrentRecord();
    BatchScope.instance.setBatchId((Integer) currentRecord.get(BATCH_ID));
    super.onSetCurrentRecord(event);
  } 
}
