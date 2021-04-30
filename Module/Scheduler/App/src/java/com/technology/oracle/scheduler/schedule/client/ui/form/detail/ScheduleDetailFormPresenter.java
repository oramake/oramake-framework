package com.technology.oracle.scheduler.schedule.client.ui.form.detail;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.CREATE;
import static com.technology.oracle.scheduler.main.shared.SchedulerConstant.CURRENT_DATA_SOURCE;
import static com.technology.oracle.scheduler.schedule.client.ScheduleClientConstant.scopeModuleIds;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.SCHEDULE_ID;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.SCHEDULE_NAME;

import com.google.gwt.place.shared.Place;
import com.google.gwt.storage.client.Storage;
import com.technology.jep.jepria.client.async.JepAsyncCallback;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.DoDeleteEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SearchEvent;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.main.client.ui.form.detail.SchedulerMainDetailFormPresenter;
import com.technology.oracle.scheduler.schedule.shared.service.ScheduleServiceAsync;
 
public class ScheduleDetailFormPresenter<E extends PlainEventBus, S extends ScheduleServiceAsync> 
    extends SchedulerMainDetailFormPresenter<DetailFormView, E, S, StandardClientFactory<E, S>> {

  private Storage storage = Storage.getSessionStorageIfSupported();

  public ScheduleDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
    super(scopeModuleIds, place, clientFactory);
  }
 
  protected void adjustToWorkstate(WorkstateEnum workstate) {
    fields.setFieldVisible(SCHEDULE_ID, !CREATE.equals(workstate));
    fields.setFieldEditable(SCHEDULE_ID, false);

    fields.setFieldAllowBlank(SCHEDULE_NAME, false);
 
  }

  @Override
  protected void saveOnEdit(JepRecord currentRecord) {
    service.setCurrentDataSource(storage.getItem(CURRENT_DATA_SOURCE), new JepAsyncCallback<Void>() {
      @Override
      public void onSuccess(Void result) {
      }
    });
    currentRecord.set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
    super.saveOnEdit(currentRecord);
  }

  @Override
  protected void saveOnCreate(JepRecord currentRecord) {
    service.setCurrentDataSource(storage.getItem(CURRENT_DATA_SOURCE), new JepAsyncCallback<Void>() {
      @Override
      public void onSuccess(Void result) {
      }
    });
    currentRecord.set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
    super.saveOnCreate(currentRecord);
  }

  public void onDoDelete(DoDeleteEvent event){
    service.setCurrentDataSource(storage.getItem(CURRENT_DATA_SOURCE), new JepAsyncCallback<Void>() {
      @Override
      public void onSuccess(Void result) {
      }
    });
    super.onDoDelete(event);
  }


}
