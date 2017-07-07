package com.technology.oracle.scheduler.schedule.client.ui.form.detail;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.CREATE;
import static com.technology.oracle.scheduler.schedule.client.ScheduleClientConstant.scopeModuleIds;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.DATA_SOURCE;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.SCHEDULE_ID;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.SCHEDULE_NAME;

import java.util.List;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.async.FirstTimeUseAsyncCallback;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.DoGetRecordEvent;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.client.widget.event.JepEventType;
import com.technology.jep.jepria.client.widget.event.JepListener;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.main.client.history.scope.SchedulerScope;
import com.technology.oracle.scheduler.schedule.shared.service.ScheduleServiceAsync;
 
public class ScheduleDetailFormPresenter<E extends PlainEventBus, S extends ScheduleServiceAsync> 
    extends DetailFormPresenter<DetailFormView, E, S, StandardClientFactory<E, S>> { 
 
  public ScheduleDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
    super(scopeModuleIds, place, clientFactory);
  }
  
  public void bind() {
    super.bind();
    
    fields.addFieldListener(DATA_SOURCE, JepEventType.FIRST_TIME_USE_EVENT, new JepListener() {
      @Override
      public void handleEvent(final JepEvent event) {
        service.getDataSource(new FirstTimeUseAsyncCallback<List<JepOption>>(event) {
          public void onSuccessLoad(List<JepOption> result){
            fields.setFieldOptions(DATA_SOURCE, result);
          }
        });
      }
    });
  }
  
  
  public void onDoGetRecord(DoGetRecordEvent event) {
  
    //для корректной работы табов (ScopeModules)
    final PagingConfig pagingConfig = event.getPagingConfig();
    JepRecord record = pagingConfig.getTemplateRecord();
    record.set(DATA_SOURCE, SchedulerScope.instance.getDataSource());

    super.onDoGetRecord(event);
  }
 
  protected void adjustToWorkstate(WorkstateEnum workstate) {
    fields.setFieldVisible(SCHEDULE_ID, !CREATE.equals(workstate));
    fields.setFieldEditable(SCHEDULE_ID, false);
    fields.setFieldEditable(DATA_SOURCE, false);
    fields.setFieldValue(DATA_SOURCE, SchedulerScope.instance.getDataSource());
 
    fields.setFieldAllowBlank(SCHEDULE_NAME, false);
 
  }
 
}
