package com.technology.oracle.scheduler.schedule.client.ui.form.detail;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.CREATE;
import static com.technology.oracle.scheduler.schedule.client.ScheduleClientConstant.scopeModuleIds;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.SCHEDULE_ID;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.SCHEDULE_NAME;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.oracle.scheduler.schedule.shared.service.ScheduleServiceAsync;
 
public class ScheduleDetailFormPresenter<E extends PlainEventBus, S extends ScheduleServiceAsync> 
    extends DetailFormPresenter<DetailFormView, E, S, StandardClientFactory<E, S>> { 
 
  public ScheduleDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
    super(scopeModuleIds, place, clientFactory);
  }
 
  protected void adjustToWorkstate(WorkstateEnum workstate) {
    fields.setFieldVisible(SCHEDULE_ID, !CREATE.equals(workstate));
    fields.setFieldEditable(SCHEDULE_ID, false);

    fields.setFieldAllowBlank(SCHEDULE_NAME, false);
 
  }
 
}
