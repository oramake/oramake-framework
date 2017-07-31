package com.technology.oracle.scheduler.batch.client;
 
import com.google.gwt.core.client.GWT;
import com.google.gwt.place.shared.Place;
import com.google.gwt.user.client.ui.IsWidget;
import com.technology.jep.jepria.client.ui.JepPresenter;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactoryImpl;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.BatchEventBus;
import com.technology.oracle.scheduler.batch.client.ui.form.BatchFormContainerPresenter;
import com.technology.oracle.scheduler.batch.client.ui.form.detail.BatchDetailFormPresenter;
import com.technology.oracle.scheduler.batch.client.ui.form.detail.BatchDetailFormViewImpl;
import com.technology.oracle.scheduler.batch.client.ui.form.list.BatchListFormPresenter;
import com.technology.oracle.scheduler.batch.client.ui.form.list.BatchListFormViewImpl;
import com.technology.oracle.scheduler.batch.client.ui.toolbar.BatchToolBarPresenter;
import com.technology.oracle.scheduler.batch.client.ui.toolbar.BatchToolBarViewImpl;
import com.technology.oracle.scheduler.batch.shared.record.BatchRecordDefinition;
import com.technology.oracle.scheduler.batch.shared.service.BatchService;
import com.technology.oracle.scheduler.batch.shared.service.BatchServiceAsync;
 
public class BatchClientFactoryImpl<E extends BatchEventBus, S extends BatchServiceAsync>
    extends com.technology.jep.jepria.client.ui.plain.StandardClientFactoryImpl<E, S> {
 
  private static final IsWidget batchDetailFormView = new BatchDetailFormViewImpl();
  private static final IsWidget batchToolBarView = new BatchToolBarViewImpl();
  private static final IsWidget batchListFormView = new BatchListFormViewImpl();
 
  public static PlainClientFactoryImpl<PlainEventBus, JepDataServiceAsync> instance = null;
  
  public BatchClientFactoryImpl() {
    super(BatchRecordDefinition.instance);
    initActivityMappers(this);
  }
 
  static public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getInstance() {
    if(instance == null) {
      instance = GWT.create(BatchClientFactoryImpl.class);
    }
    return instance;
  }
  
  public S getService() {
    if(dataService == null) {
      dataService = (S) GWT.create(BatchService.class);
    }
    return dataService;
  }
  
  @Override
  public E getEventBus() {
    if(eventBus == null) {
      eventBus = new BatchEventBus(this);
    }
    return (E) eventBus;
  }  
  
  public IsWidget getToolBarView() {
    return batchToolBarView;
  }

  @Override
  public IsWidget getDetailFormView() {
    return batchDetailFormView;
  }

  @Override
  public IsWidget getListFormView() {
    return batchListFormView;
  }
  
  @Override
  public JepPresenter createToolBarPresenter(Place place) {
    return new BatchToolBarPresenter(place, this);
  }

  @Override
  public JepPresenter createDetailFormPresenter(Place place) {
    return new BatchDetailFormPresenter(place, this);
  }

  @Override
  public JepPresenter createListFormPresenter(Place place) {
    return new BatchListFormPresenter(place, this);
  }

  @Override
  public JepPresenter createPlainModulePresenter(Place place) {
    return new BatchFormContainerPresenter(place, this);
  }
}
