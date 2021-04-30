package com.technology.oracle.scheduler.interval.client.ui.form.detail;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.CREATE;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.EDIT;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.VIEW_DETAILS;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.*;
import static com.technology.oracle.scheduler.main.shared.SchedulerConstant.CURRENT_DATA_SOURCE;

import java.util.List;

import com.google.gwt.place.shared.Place;
import com.google.gwt.storage.client.Storage;
import com.technology.jep.jepria.client.async.FirstTimeUseAsyncCallback;
import com.technology.jep.jepria.client.async.JepAsyncCallback;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.DoDeleteEvent;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.client.widget.event.JepEventType;
import com.technology.jep.jepria.client.widget.event.JepListener;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.interval.shared.service.IntervalServiceAsync;
import com.technology.oracle.scheduler.main.client.ui.form.detail.SchedulerMainDetailFormPresenter;

public class IntervalDetailFormPresenter<E extends PlainEventBus, S extends IntervalServiceAsync> 
    extends SchedulerMainDetailFormPresenter<DetailFormView, E, S, StandardClientFactory<E, S>> {

  private Storage storage = Storage.getSessionStorageIfSupported();

  public IntervalDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
    super(place, clientFactory);
  }
 
  public void bind() {
    super.bind();
    // Здесь размещается код связывания presenter-а и view
    fields.addFieldListener(INTERVAL_TYPE_CODE, JepEventType.FIRST_TIME_USE_EVENT, new JepListener() {
      @Override
      public void handleEvent(final JepEvent event) {
        service.getIntervalType(storage.getItem(CURRENT_DATA_SOURCE), new FirstTimeUseAsyncCallback<List<JepOption>>(event) {
          public void onSuccessLoad(List<JepOption> result){
            fields.setFieldOptions(INTERVAL_TYPE_CODE, result);
          }
        });
      }
    });
  }

  protected void adjustToWorkstate(WorkstateEnum workstate) {
    fields.setFieldVisible(INTERVAL_ID, VIEW_DETAILS.equals(workstate));
 
    fields.setFieldAllowBlank(INTERVAL_TYPE_CODE, !(EDIT.equals(workstate) || CREATE.equals(workstate)));
    fields.setFieldAllowBlank(MIN_VALUE, !(EDIT.equals(workstate) || CREATE.equals(workstate)));
    fields.setFieldAllowBlank(MAX_VALUE, !(EDIT.equals(workstate) || CREATE.equals(workstate)));
 
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
