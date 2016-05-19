package com.technology.oracle.scheduler.rootlog.client.ui.form.detail;
 
import static com.technology.oracle.scheduler.rootlog.client.RootLogClientConstant.scopeModuleIds;
import static com.technology.oracle.scheduler.rootlog.shared.field.RootLogFieldNames.DATA_SOURCE;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.DoGetRecordEvent;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.main.client.history.scope.SchedulerScope;
import com.technology.oracle.scheduler.rootlog.shared.service.RootLogServiceAsync;
 
public class RootLogDetailFormPresenter<E extends PlainEventBus, S extends RootLogServiceAsync> 
		extends DetailFormPresenter<RootLogDetailFormView, E, S, StandardClientFactory<E, S>> { 
 
	public RootLogDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
		super(scopeModuleIds, place, clientFactory);
	}
 
	/* public void bind() {
		super.bind();
		// Здесь размещается код связывания presenter-а и view 
	}
	*/ 

	@Override
	public void onDoGetRecord(DoGetRecordEvent event) {
		
		//для корректной работы табов (ScopeModules)
		final PagingConfig pagingConfig = event.getPagingConfig();
		JepRecord record = pagingConfig.getTemplateRecord();
		record.set(DATA_SOURCE, SchedulerScope.instance.getDataSource());
		eventBus.list();
	}
	
	protected void adjustToWorkstate(WorkstateEnum workstate) {
	}
 
}
