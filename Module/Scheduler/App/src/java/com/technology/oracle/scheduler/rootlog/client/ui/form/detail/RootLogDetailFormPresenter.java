package com.technology.oracle.scheduler.rootlog.client.ui.form.detail;
 
import static com.technology.oracle.scheduler.rootlog.client.RootLogClientConstant.scopeModuleIds;

import com.google.gwt.place.shared.Place;
import com.google.gwt.storage.client.Storage;
import com.google.gwt.user.client.Window;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.DoGetRecordEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.DoSearchEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SearchEvent;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.oracle.scheduler.main.client.ui.form.detail.SchedulerMainDetailFormPresenter;
import com.technology.oracle.scheduler.rootlog.shared.service.RootLogServiceAsync;
 
public class RootLogDetailFormPresenter<E extends PlainEventBus, S extends RootLogServiceAsync> 
    extends SchedulerMainDetailFormPresenter<RootLogDetailFormView, E, S, StandardClientFactory<E, S>> {
 
  public RootLogDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
    super(scopeModuleIds, place, clientFactory);
  }
  
  protected void adjustToWorkstate(WorkstateEnum workstate) {}

}
