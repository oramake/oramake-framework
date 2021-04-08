package com.technology.oracle.optionasria.option.client.ui;

import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.OPTION_MODULE_ID;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SetCurrentRecordEvent;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.ui.plain.StandardModulePresenter;
import com.technology.jep.jepria.client.ui.plain.StandardModuleView;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.optionasria.main.client.history.scope.OptionAsRiaScope;
import com.technology.oracle.optionasria.option.client.ui.eventbus.OptionEventBus;
import com.technology.oracle.optionasria.option.shared.service.OptionServiceAsync;

public class OptionFormContainerPresenter <E extends OptionEventBus, S extends OptionServiceAsync, F extends StandardClientFactory<E,S>>
  extends StandardModulePresenter<StandardModuleView, E, S, F> {

  public OptionFormContainerPresenter(Place place, F clientFactory) {
    super(OPTION_MODULE_ID, place, clientFactory);
  }

  public void onSetCurrentRecord(SetCurrentRecordEvent event) {
    JepRecord currentRecord = event.getCurrentRecord();
    OptionAsRiaScope.instance.setCurruntValueOption(currentRecord);
    super.onSetCurrentRecord(event);
  }
}
