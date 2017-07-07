package com.technology.oracle.scheduler.option.client.ui.form;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SetCurrentRecordEvent;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.ui.plain.StandardModulePresenter;
import com.technology.jep.jepria.client.ui.plain.StandardModuleView;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.option.client.history.scope.OptionScope;
import com.technology.oracle.scheduler.option.shared.service.OptionServiceAsync;

import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.OPTION_MODULE_ID;
 
public class OptionFormContainerPresenter <E extends PlainEventBus, S extends OptionServiceAsync, F extends StandardClientFactory<E,S>> 
  extends StandardModulePresenter<StandardModuleView, E, S, F> {
 
  public OptionFormContainerPresenter(Place place, F clientFactory) {
    super(OPTION_MODULE_ID, place, clientFactory);
  }
  
  public void onSetCurrentRecord(SetCurrentRecordEvent event) {

    JepRecord currentRecord = event.getCurrentRecord();
    OptionScope.instance.setCurruntValueOption(currentRecord);
    
    super.onSetCurrentRecord(event);
  } 
}
