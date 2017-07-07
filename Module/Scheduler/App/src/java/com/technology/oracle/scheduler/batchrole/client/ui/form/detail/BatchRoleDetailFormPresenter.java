package com.technology.oracle.scheduler.batchrole.client.ui.form.detail;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.CREATE;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.EDIT;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.DATA_SOURCE;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.PRIVILEGE_CODE;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.ROLE_ID;

import java.util.List;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.async.FirstTimeUseAsyncCallback;
import com.technology.jep.jepria.client.async.TypingTimeoutAsyncCallback;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.DoGetRecordEvent;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.client.widget.event.JepEventType;
import com.technology.jep.jepria.client.widget.event.JepListener;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.batchrole.shared.service.BatchRoleServiceAsync;
import com.technology.oracle.scheduler.main.client.history.scope.SchedulerScope;
 
public class BatchRoleDetailFormPresenter<E extends PlainEventBus, S extends BatchRoleServiceAsync> 
  extends DetailFormPresenter<DetailFormView, E, S, StandardClientFactory<E, S>>  { 
 
  public BatchRoleDetailFormPresenter(Place place, StandardClientFactory<E,S> clientFactory) {
    super(place, clientFactory);
  }
 
  public void bind() {
    super.bind();
    // Здесь размещается код связывания presenter-а и view 
    fields.addFieldListener(PRIVILEGE_CODE, JepEventType.FIRST_TIME_USE_EVENT, new JepListener() {
      @Override
      public void handleEvent(final JepEvent event) {
        service.getPrivilege(SchedulerScope.instance.getDataSource().getName(), new FirstTimeUseAsyncCallback<List<JepOption>>(event) {
          public void onSuccessLoad(List<JepOption> result){
            fields.setFieldOptions(PRIVILEGE_CODE, result);
          }
        });
      }
    });
    
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
    
    fields.addFieldListener(ROLE_ID, JepEventType.TYPING_TIMEOUT_EVENT, new JepListener() {
      @Override
      public void handleEvent(final JepEvent event) {
        setRole();
      }
      
    });
  }
  
  private void setRole(){
    
    JepComboBoxField roleField = (JepComboBoxField) fields.get(ROLE_ID);
    roleField.setLoadingImage(true);
    String rawValue = roleField.getRawValue();
    service.getRole(SchedulerScope.instance.getDataSource().getName(), rawValue + "%",  
        new TypingTimeoutAsyncCallback<List<JepOption>>(new JepEvent(roleField)
      ) {
        @SuppressWarnings("unchecked")
        public void onSuccessLoad(List<JepOption> result){
  
          JepComboBoxField roleField = (JepComboBoxField) fields.get(ROLE_ID);
          roleField.setOptions(result);
        }
        @Override
        public void onFailure(Throwable caught) {
          super.onFailure(caught);
        }
    });
    
  }
  
 
  protected void adjustToWorkstate(WorkstateEnum workstate) {
    fields.setFieldAllowBlank(PRIVILEGE_CODE, !CREATE.equals(workstate));
    fields.setFieldAllowBlank(ROLE_ID, !CREATE.equals(workstate));
 
    fields.setFieldEditable(DATA_SOURCE, false);
    fields.setFieldValue(DATA_SOURCE, SchedulerScope.instance.getDataSource());
    
    if (EDIT.equals(workstate)){

      setRole();
    }
  }
 
  
  public void onDoGetRecord(DoGetRecordEvent event) {
    
    //для корректной работы табов (ScopeModules)
    final PagingConfig pagingConfig = event.getPagingConfig();
    JepRecord record = pagingConfig.getTemplateRecord();
    record.set(DATA_SOURCE, SchedulerScope.instance.getDataSource());
    fields.setFieldEditable(DATA_SOURCE, false);
    fields.setFieldValue(DATA_SOURCE, SchedulerScope.instance.getDataSource());

    super.onDoGetRecord(event);
  }
}
