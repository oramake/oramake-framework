package com.technology.oracle.scheduler.batchrole.client.ui.form.detail;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.CREATE;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.EDIT;
import static com.technology.oracle.scheduler.batchrole.shared.field.BatchRoleFieldNames.*;
import static com.technology.oracle.scheduler.main.shared.SchedulerConstant.CURRENT_DATA_SOURCE;

import java.awt.*;
import java.util.List;

import com.google.gwt.place.shared.Place;
import com.google.gwt.storage.client.Storage;
import com.google.gwt.user.client.Window;
import com.technology.jep.jepria.client.async.FirstTimeUseAsyncCallback;
import com.technology.jep.jepria.client.async.TypingTimeoutAsyncCallback;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SearchEvent;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.client.widget.event.JepEventType;
import com.technology.jep.jepria.client.widget.event.JepListener;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.scheduler.batchrole.shared.service.BatchRoleServiceAsync;
 
public class BatchRoleDetailFormPresenter<E extends PlainEventBus, S extends BatchRoleServiceAsync> 
  extends DetailFormPresenter<DetailFormView, E, S, StandardClientFactory<E, S>>  { 

  private Storage storage = Storage.getSessionStorageIfSupported();

  public BatchRoleDetailFormPresenter(Place place, StandardClientFactory<E,S> clientFactory) {
    super(place, clientFactory);
  }
 
  public void bind() {
    super.bind();
    // Здесь размещается код связывания presenter-а и view
    fields.addFieldListener(PRIVILEGE_CODE, JepEventType.FIRST_TIME_USE_EVENT, new JepListener() {
      @Override
      public void handleEvent(final JepEvent event) {
        service.getPrivilege(storage.getItem(CURRENT_DATA_SOURCE), new FirstTimeUseAsyncCallback<List<JepOption>>(event) {
          public void onSuccessLoad(List<JepOption> result){
            fields.setFieldOptions(PRIVILEGE_CODE, result);
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
  
  private void setRole() {
    
    JepComboBoxField roleField = (JepComboBoxField) fields.get(ROLE_ID);
    roleField.setLoadingImage(true);
    String rawValue = roleField.getRawValue();
    Window.alert(storage.getItem(CURRENT_DATA_SOURCE));
    service.getRole(rawValue + "%", storage.getItem(CURRENT_DATA_SOURCE), new TypingTimeoutAsyncCallback<List<JepOption>>(new JepEvent(roleField)) {
      
        @Override
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

  @Override
  public void onSearch(SearchEvent event) {
    event.getPagingConfig().getTemplateRecord().set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
    super.onSearch(event);
  }
 
  protected void adjustToWorkstate(WorkstateEnum workstate) {
    fields.setFieldAllowBlank(PRIVILEGE_CODE, !CREATE.equals(workstate));
    fields.setFieldAllowBlank(ROLE_ID, !CREATE.equals(workstate));
    
    if (EDIT.equals(workstate)) {
      setRole();
    }
  }
}
