package com.technology.oracle.scheduler.main.client.ui.form.detail;

import com.google.gwt.place.shared.Place;
import com.google.gwt.storage.client.Storage;
import com.google.gwt.user.client.Window;
import com.technology.jep.jepria.client.async.JepAsyncCallback;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.DoGetRecordEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SaveEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.SearchEvent;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.shared.load.FindConfig;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.oracle.scheduler.batch.client.ui.form.detail.BatchDetailFormView;
import com.technology.oracle.scheduler.main.server.DataSourceServiceImpl;
import com.technology.oracle.scheduler.main.shared.service.DataSourceService;
import com.technology.oracle.scheduler.main.shared.service.DataSourceServiceAsync;

import static com.technology.oracle.scheduler.main.shared.SchedulerConstant.CURRENT_DATA_SOURCE;

public class SchedulerMainDetailFormPresenter <V extends DetailFormView, E extends PlainEventBus, S extends JepDataServiceAsync,
    F extends StandardClientFactory<E, S>> extends DetailFormPresenter<V, E, S, F>{


  public SchedulerMainDetailFormPresenter(Place place, F clientFactory) {
    super(place, clientFactory);
  }

  public SchedulerMainDetailFormPresenter(String[] scopeModuleIds, Place place, F clientFactory) {
    super(scopeModuleIds, place, clientFactory);
  }

  @Override
  public void onSearch(SearchEvent event) {
    Storage storage = Storage.getSessionStorageIfSupported();
    event.getPagingConfig().getTemplateRecord().set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
    searchTemplate = event.getPagingConfig().getTemplateRecord();
    /*saveSearchTemplate(event.getPagingConfig().getTemplateRecord());*/
    super.onSearch(event);
  }

  @Override
  public void onDoGetRecord(DoGetRecordEvent event) {
    Storage storage = Storage.getSessionStorageIfSupported();
    event.getPagingConfig().getTemplateRecord().set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
    super.onDoGetRecord(event);
  }

  /*@Override
  protected void sa(SaveEvent event) {
    Window.alert("onDoGetRecord");
    Storage storage = Storage.getLocalStorageIfSupported();
    searchTemplate
    event.getPagingConfig().getTemplateRecord().set("data_source", storage.getItem("CURRENT_DATA_SOURCE"));
    super.onSave(event);
  }*/

  @Override
  protected void saveOnCreate(JepRecord currentRecord) {
    Storage storage = Storage.getSessionStorageIfSupported();
    currentRecord.set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
    super.saveOnCreate(currentRecord);
  }

//  @Override
//  protected void saveOnEdit(JepRecord currentRecord) {
//    Storage storage = Storage.getLocalStorageIfSupported();
//    currentRecord.set(CURRENT_DATA_SOURCE, storage.getItem(CURRENT_DATA_SOURCE));
//    super.saveOnEdit(currentRecord);
//  }

}
