package com.technology.oracle.scheduler.moduleroleprivilege.client.ui.form.detail;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.CREATE;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.SEARCH;
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import static com.technology.oracle.scheduler.main.shared.SchedulerConstant.*;
import static com.technology.oracle.scheduler.moduleroleprivilege.shared.field.ModuleRolePrivilegeFieldNames.*;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.place.shared.Place;
import com.google.gwt.storage.client.Storage;
import com.technology.jep.jepria.client.async.FirstTimeUseAsyncCallback;
import com.technology.jep.jepria.client.async.JepAsyncCallback;
import com.technology.jep.jepria.client.async.TypingTimeoutAsyncCallback;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.DoDeleteEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.DoGetRecordEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SearchEvent;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.client.widget.event.JepEventType;
import com.technology.jep.jepria.client.widget.event.JepListener;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.JepRiaUtil;
import com.technology.oracle.scheduler.moduleroleprivilege.shared.service.ModuleRolePrivilegeServiceAsync;
 
public class ModuleRolePrivilegeDetailFormPresenter<E extends PlainEventBus, S extends ModuleRolePrivilegeServiceAsync> 
    extends DetailFormPresenter<DetailFormView, E, S, StandardClientFactory<E, S>> { 

  public ModuleRolePrivilegeDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
    super(place, clientFactory);
  }
 
  public void bind() {
    super.bind();
    // Здесь размещается код связывания presenter-а и view
    Storage storage = Storage.getLocalStorageIfSupported();
    fields.addFieldListener(DATA_SOURCE, JepEventType.FIRST_TIME_USE_EVENT, new JepListener() {
      @Override
      public void handleEvent(final JepEvent event) {
        service.getDataSource(new FirstTimeUseAsyncCallback<JepRecord>(event) {
          public void onSuccessLoad(JepRecord result){
            fields.setFieldOptions(DATA_SOURCE, result.get(DATA_SOURCE_LIST));
          }
        });
      }
    });
    
    fields.addFieldListener(DATA_SOURCE, JepEventType.CHANGE_SELECTION_EVENT, new JepListener() {
      @Override
      public void handleEvent(JepEvent event) {
        final JepOption dataSource = (JepOption) event.getParameter();
        storage.setItem(CURRENT_DATA_SOURCE, (String) dataSource.getValue());
//        service.setCurrentDataSource(JepOption.<String>getValue(event.getParameter()), new JepAsyncCallback<Void>() {
//          @Override
//          public void onSuccess(Void result) {
//            setDataSourceDependFields();
//            changeModules();
//          }
//        });
      }
    });
    
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
  
  private void changeModules() {

    fields.clearField(MODULE_ID);
    
    String dataSource = JepOption.<String>getValue(fields.getFieldValue(DATA_SOURCE));
    final JepComboBoxField moduleComboBoxField = (JepComboBoxField)fields.get(MODULE_ID);
    Storage storage = Storage.getLocalStorageIfSupported();
    if(!JepRiaUtil.isEmpty(dataSource)) {
      
      moduleComboBoxField.setLoadingImage(true);
      fields.setFieldEnabled(MODULE_ID, false);
      
      service.getModule(storage.getItem(CURRENT_DATA_SOURCE),new JepAsyncCallback<List<JepOption>>() {
        
        @Override
        public void onSuccess(List<JepOption> result){
          moduleComboBoxField.setLoadingImage(false);
          fields.setFieldOptions(MODULE_ID, result);
          fields.setFieldEnabled(MODULE_ID, true);
        }
        
        @Override
        public void onFailure(Throwable caught) {
          moduleComboBoxField.setLoadingImage(false);
          fields.setFieldOptions(MODULE_ID, new ArrayList<JepOption>());
          super.onFailure(caught);
        }
      });
      
    }
  }

  private void setRole() {
    
    JepComboBoxField roleField = (JepComboBoxField) fields.get(ROLE_ID);
    roleField.setLoadingImage(true);
    String rawValue = roleField.getRawValue();
    Storage storage = Storage.getLocalStorageIfSupported();
    service.getRole(rawValue + "%", storage.getItem(CURRENT_DATA_SOURCE),  new TypingTimeoutAsyncCallback<List<JepOption>>(new JepEvent(roleField)) {
        
        @Override
        public void onSuccessLoad(List<JepOption> result) {
          JepComboBoxField roleField = (JepComboBoxField) fields.get(ROLE_ID);
          roleField.setOptions(result);
        }
        
        @Override
        public void onFailure(Throwable caught) {
          super.onFailure(caught);
        }
    });
    
  }
  
  private void setDataSourceDependFields() {
    
    Boolean enabled = false;
    if(!JepRiaUtil.isEmpty(
        JepOption.<String>getValue(
            fields.getFieldValue(DATA_SOURCE)))) {
      enabled = true;
    }
    
    fields.setFieldEnabled(MODULE_ROLE_PRIVILEGE_ID, enabled);
    fields.setFieldEnabled(MODULE_ID, enabled);
    fields.setFieldEnabled(PRIVILEGE_CODE, enabled);
    fields.setFieldEnabled(ROLE_ID, enabled);
  }

  @Override
  protected void saveOnEdit(JepRecord currentRecord) {
    service.setCurrentDataSource(Storage.getLocalStorageIfSupported().getItem(CURRENT_DATA_SOURCE), new JepAsyncCallback<Void>() {
      @Override
      public void onSuccess(Void result) {
      }
    });
    Storage storage = Storage.getLocalStorageIfSupported();
    currentRecord.set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
    super.saveOnEdit(currentRecord);
  }

  @Override
  protected void saveOnCreate(JepRecord currentRecord) {
    service.setCurrentDataSource(Storage.getLocalStorageIfSupported().getItem(CURRENT_DATA_SOURCE), new JepAsyncCallback<Void>() {
      @Override
      public void onSuccess(Void result) {
      }
    });
    Storage storage = Storage.getLocalStorageIfSupported();
    currentRecord.set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
    super.saveOnCreate(currentRecord);
  }

  public void onDoDelete(DoDeleteEvent event){
    service.setCurrentDataSource(Storage.getLocalStorageIfSupported().getItem(CURRENT_DATA_SOURCE), new JepAsyncCallback<Void>() {
      @Override
      public void onSuccess(Void result) {
      }
    });
    super.onDoDelete(event);
  }

  @Override
  public void onSearch(SearchEvent event) {
    Storage storage = Storage.getLocalStorageIfSupported();
    event.getPagingConfig().getTemplateRecord().set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
    searchTemplate = event.getPagingConfig().getTemplateRecord();
    /*saveSearchTemplate(event.getPagingConfig().getTemplateRecord());*/
    super.onSearch(event);
  }

  @Override
  public void onDoGetRecord(DoGetRecordEvent event) {
    Storage storage = Storage.getLocalStorageIfSupported();
    event.getPagingConfig().getTemplateRecord().set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
    super.onDoGetRecord(event);
  }
  
 
  protected void adjustToWorkstate(WorkstateEnum workstate) {
    
    setDataSourceDependFields();
    
    fields.setFieldVisible(MODULE_ROLE_PRIVILEGE_ID, SEARCH.equals(workstate));
 
    fields.setFieldAllowBlank(DATA_SOURCE, !(CREATE.equals(workstate) || SEARCH.equals(workstate)));
    fields.setFieldAllowBlank(MODULE_ID, !CREATE.equals(workstate));
    fields.setFieldAllowBlank(PRIVILEGE_CODE, !CREATE.equals(workstate));
    fields.setFieldAllowBlank(ROLE_ID, !CREATE.equals(workstate));
 
    fields.setFieldVisible(MAX_ROW_COUNT, SEARCH.equals(workstate));
    fields.setFieldAllowBlank(MAX_ROW_COUNT, !SEARCH.equals(workstate));
    fields.setFieldValue(MAX_ROW_COUNT, 25);
  }
 
}
