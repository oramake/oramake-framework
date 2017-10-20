package com.technology.oracle.optionasria.option.client.ui.form.list;
 
import com.technology.jep.jepria.client.history.place.JepWorkstatePlace;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SetCurrentRecordEvent;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.optionasria.main.client.history.scope.OptionAsRiaScope;
import com.technology.oracle.optionasria.option.shared.service.OptionServiceAsync;

public class OptionListFormPresenter<E extends PlainEventBus, S extends OptionServiceAsync> 
	extends ListFormPresenter<OptionListFormViewImpl, E, S, StandardClientFactory<E, S>> { 
 
	public OptionListFormPresenter(JepWorkstatePlace place, StandardClientFactory<E, S> clientFactory) {
		super(place, clientFactory);
	}
	
	@Override
	public void onSetCurrentRecord(SetCurrentRecordEvent event) {
		JepRecord currentRecord = event.getCurrentRecord();
		OptionAsRiaScope.instance.setCurruntValueOption(currentRecord);
		super.onSetCurrentRecord(event);
		//setCurrentRecord(currentRecord);
	} 
}
