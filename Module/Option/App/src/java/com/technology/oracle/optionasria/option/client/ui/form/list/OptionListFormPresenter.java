package com.technology.oracle.optionasria.option.client.ui.form.list;
 
import static com.technology.oracle.optionasria.option.shared.field.OptionFieldNames.*;
 
import com.technology.jep.jepria.client.widget.event.JepListener;
import com.technology.jep.jepria.client.widget.event.JepEventType;
import com.technology.jep.jepria.client.ui.eventbus.plain.JepEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SetCurrentRecordEvent;
import com.technology.jep.jepria.client.history.place.JepWorkstatePlace;
import com.technology.jep.jepria.client.ui.module.JepClientFactory;
import com.technology.oracle.optionasria.main.client.history.scope.OptionAsRiaScope;
import com.technology.oracle.optionasria.option.shared.service.OptionServiceAsync;
import com.technology.jep.jepria.client.ui.form.list.JepListFormPresenter; 
import com.technology.jep.jepria.shared.record.JepRecord;
public class OptionListFormPresenter<E extends JepEventBus, S extends OptionServiceAsync> 
	extends JepListFormPresenter<E, OptionListFormViewImpl, S, JepClientFactory<E, S>> { 
 
	public OptionListFormPresenter(JepWorkstatePlace place, JepClientFactory<E, S> clientFactory) {
		super(place, clientFactory);
	}
	
	@Override
	public void onSetCurrentRecord(SetCurrentRecordEvent event) {
		
		JepRecord currentRecord = event.getCurrentRecord();
		OptionAsRiaScope.instance.setCurruntValueOption(currentRecord);
		setCurrentRecord(currentRecord);
	} 
}
