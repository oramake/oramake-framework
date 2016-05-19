package com.technology.oracle.scheduler.detailedlog.client.ui.form.detail;
 
import static com.technology.oracle.scheduler.detailedlog.shared.field.DetailedLogFieldNames.*;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.*;
 
import com.google.gwt.place.shared.Place;
 
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.oracle.scheduler.detailedlog.shared.service.DetailedLogServiceAsync;
 
public class DetailedLogDetailFormPresenter<E extends PlainEventBus, S extends DetailedLogServiceAsync> 
		extends DetailFormPresenter<DetailedLogDetailFormView, E, S, StandardClientFactory<E, S>> { 
 
	public DetailedLogDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
		super(place, clientFactory);
	}
 
	/* public void bind() {
		super.bind();
		// Здесь размещается код связывания presenter-а и view 
	}
	*/ 
 
	protected void adjustToWorkstate(WorkstateEnum workstate) {
	}
 
}
