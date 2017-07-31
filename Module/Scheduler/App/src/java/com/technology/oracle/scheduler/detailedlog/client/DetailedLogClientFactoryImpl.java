package com.technology.oracle.scheduler.detailedlog.client;
 
import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.DETAILEDLOG_MODULE_ID;
import com.google.gwt.core.client.GWT;
import com.google.gwt.place.shared.Place;
import com.google.gwt.user.client.ui.IsWidget;
 
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.jep.jepria.client.ui.JepPresenter;
import com.technology.jep.jepria.client.ui.form.list.ListFormView;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactoryImpl;
import com.technology.jep.jepria.client.ui.plain.StandardModulePresenter;
import com.technology.jep.jepria.client.history.place.JepWorkstatePlace;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarPresenter;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarView;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl;
import com.technology.oracle.scheduler.detailedlog.client.ui.toolbar.DetailedLogToolBarViewImpl;
 
import com.technology.oracle.scheduler.detailedlog.client.ui.form.detail.DetailedLogDetailFormPresenter;
import com.technology.oracle.scheduler.detailedlog.client.ui.form.detail.DetailedLogDetailFormViewImpl;
import com.technology.oracle.scheduler.detailedlog.client.ui.form.list.DetailedLogListFormViewImpl;
import com.technology.oracle.scheduler.detailedlog.client.ui.form.list.DetailedLogListFormPresenter;
import com.technology.oracle.scheduler.detailedlog.shared.service.DetailedLogService;
import com.technology.oracle.scheduler.detailedlog.shared.service.DetailedLogServiceAsync;
import com.technology.oracle.scheduler.detailedlog.shared.record.DetailedLogRecordDefinition;
 
public class DetailedLogClientFactoryImpl<E extends PlainEventBus, S extends DetailedLogServiceAsync>
  extends com.technology.jep.jepria.client.ui.plain.StandardClientFactoryImpl<E, S> {
 
  private static final IsWidget detailedLogDetailFormView = new DetailedLogDetailFormViewImpl();
  private static final IsWidget detailedLogToolBarView = new DetailedLogToolBarViewImpl();
  private static final IsWidget detailedLogListFormView = new DetailedLogListFormViewImpl();
 
  public static PlainClientFactoryImpl<PlainEventBus, JepDataServiceAsync> instance = null;
 
  public DetailedLogClientFactoryImpl() {
    super(DetailedLogRecordDefinition.instance);
    initActivityMappers(this);
  }
 
  static public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getInstance() {
    if(instance == null) {
      instance = GWT.create(DetailedLogClientFactoryImpl.class);
    }
    return instance;
  }
 
public JepPresenter createPlainModulePresenter(Place place) {
  return new StandardModulePresenter(DETAILEDLOG_MODULE_ID, place, this);
}
 
  public JepPresenter createDetailFormPresenter(Place place) {
    return new DetailedLogDetailFormPresenter(place, this);
  }
 
  public JepPresenter createListFormPresenter(Place place) {
    return new DetailedLogListFormPresenter(place, this);
  }
 
  public JepPresenter createToolBarPresenter(Place place) {
    return new ToolBarPresenter(place, this);
  }
 
  public IsWidget getToolBarView() {
    return detailedLogToolBarView;
  }
 
  public IsWidget getDetailFormView() {
    return detailedLogDetailFormView;
  }
 
  public IsWidget getListFormView() {
    return detailedLogListFormView;
  }
 
  public S getService() {
    if(dataService == null) {
      dataService = (S) GWT.create(DetailedLogService.class);
    }
    return dataService;
  }
}
