package com.technology.oracle.optionasria.option.client.ui.form.list;
 
import com.google.gwt.place.shared.Place;
import com.google.gwt.storage.client.Storage;
import com.technology.jep.jepria.client.history.place.JepWorkstatePlace;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SetCurrentRecordEvent;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.optionasria.main.client.history.scope.OptionAsRiaScope;
import com.technology.oracle.optionasria.option.shared.service.OptionServiceAsync;

import static com.technology.oracle.optionasria.main.shared.OptionAsRiaConstant.CURRENT_DATA_SOURCE;

public class OptionListFormPresenter<V extends OptionListFormViewImpl,E extends PlainEventBus, S extends OptionServiceAsync, F extends StandardClientFactory<E, S>>
	extends ListFormPresenter<V, E, S, F> {
 
	public OptionListFormPresenter(Place place, F clientFactory) {
		super(place, clientFactory);
	}
	
	@Override
	public void onSetCurrentRecord(SetCurrentRecordEvent event) {
		Storage storage = Storage.getSessionStorageIfSupported();
		JepRecord currentRecord = event.getCurrentRecord();
		currentRecord.set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
		OptionAsRiaScope.instance.setCurruntValueOption(currentRecord);
		super.onSetCurrentRecord(event);
		//setCurrentRecord(currentRecord);
	} 
}
