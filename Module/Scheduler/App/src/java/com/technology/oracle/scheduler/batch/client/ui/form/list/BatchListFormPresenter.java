package com.technology.oracle.scheduler.batch.client.ui.form.list;

import static com.technology.jep.jepria.client.JepRiaClientConstant.JepTexts;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.SELECTED;
import static com.technology.oracle.scheduler.batch.shared.field.BatchFieldNames.BATCH_ID;
import static com.technology.oracle.scheduler.main.shared.SchedulerConstant.CURRENT_DATA_SOURCE;

import java.util.Set;

import com.google.gwt.event.shared.EventBus;
import com.google.gwt.place.shared.Place;
import com.google.gwt.storage.client.Storage;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.technology.jep.jepria.client.async.JepAsyncCallback;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SearchEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SetCurrentRecordEvent;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.client.widget.field.multistate.JepTextField;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.BatchEventBus;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.event.AbortBatchEvent;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.event.ActivateBatchEvent;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.event.DeactivateBatchEvent;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.event.ExecuteBatchEvent;
import com.technology.oracle.scheduler.batch.shared.service.BatchServiceAsync;

public class BatchListFormPresenter<V extends BatchListFormView, E extends BatchEventBus, S extends BatchServiceAsync, F extends StandardClientFactory<E, S>> 
  extends ListFormPresenter<V, E, S, F> 
    implements ActivateBatchEvent.Handler, DeactivateBatchEvent.Handler, ExecuteBatchEvent.Handler, AbortBatchEvent.Handler {

  public BatchListFormPresenter(Place place, F clientFactory) {
    super(place, clientFactory);
  }

  private Storage storage = Storage.getSessionStorageIfSupported();
  
  @Override
  public void start(AcceptsOneWidget container, EventBus eventBus) {
    super.start(container, eventBus);
 
    eventBus.addHandler(ActivateBatchEvent.TYPE, this);
    eventBus.addHandler(DeactivateBatchEvent.TYPE, this);
    eventBus.addHandler(ExecuteBatchEvent.TYPE, this);
    eventBus.addHandler(AbortBatchEvent.TYPE, this);
  }
  
  public class ListUpdaterCallback extends JepAsyncCallback<JepRecord>{

    @Override
    public void onSuccess(JepRecord result) {
      @SuppressWarnings("unchecked")
      Set<JepRecord> selectedRecords  = (Set<JepRecord>) list.getSelectionModel().getSelectedSet();
      for(JepRecord record: selectedRecords){
        record.update(result);
        list.update(record);
      }
      
      list.unmask();
    }
    
    @Override
    public void onFailure(Throwable caught) {
      super.onFailure(caught);
      list.unmask();
    }
    
  }
  
  public void onActivateBatchEvent(ActivateBatchEvent event) {
    
    if(!SELECTED.equals(_workstate))
      return;
//    Storage storage = Storage.getLocalStorageIfSupported();
    list.mask(JepTexts.loadingPanel_dataLoading());

    service.activateBatch(
        (Integer) currentRecord.get(BATCH_ID),
        storage.getItem(CURRENT_DATA_SOURCE),
        new ListUpdaterCallback());
  }
  public void onDeactivateBatchEvent(DeactivateBatchEvent event) {
    
    if(!SELECTED.equals(_workstate))
      return;
    
    list.mask(JepTexts.loadingPanel_dataLoading());
//    Storage storage = Storage.getLocalStorageIfSupported();
    service.deactivateBatch(
        (Integer) currentRecord.get(BATCH_ID),
        storage.getItem(CURRENT_DATA_SOURCE),
        new ListUpdaterCallback());
  }
  public void onExecuteBatchEvent(ExecuteBatchEvent event) {
    
    if(!SELECTED.equals(_workstate))
      return;
    
    list.mask(JepTexts.loadingPanel_dataLoading());
//    Storage storage = Storage.getLocalStorageIfSupported();
    service.executeBatch(
        (Integer) currentRecord.get(BATCH_ID),
        storage.getItem(CURRENT_DATA_SOURCE),
        new ListUpdaterCallback());
  }
  public void onAbortBatchEvent(AbortBatchEvent event) {
    
    if(!SELECTED.equals(_workstate))
      return;
//    Storage storage = Storage.getLocalStorageIfSupported();
    list.mask(JepTexts.loadingPanel_dataLoading());

    service.abortBatch(
        (Integer) currentRecord.get(BATCH_ID),
        storage.getItem(CURRENT_DATA_SOURCE),
        new ListUpdaterCallback());
  }

//  public void onSetCurrentRecord(SetCurrentRecordEvent event){
//    Window.alert(searchTemplate.toString());
//    searchTemplate.getTemplateRecord().set(CURRENT_DATA_SOURCE, Storage.getLocalStorageIfSupported().getItem(CURRENT_DATA_SOURCE));
//    super.onSetCurrentRecord(event);
//  }
}
