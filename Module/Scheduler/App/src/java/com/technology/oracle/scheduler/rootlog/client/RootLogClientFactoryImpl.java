package com.technology.oracle.scheduler.rootlog.client;

import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.ROOTLOG_MODULE_ID;

import com.google.gwt.core.client.GWT;
import com.google.gwt.place.shared.Place;
import com.google.gwt.user.client.ui.IsWidget;
import com.technology.jep.jepria.client.ui.JepPresenter;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactoryImpl;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactoryImpl;
import com.technology.jep.jepria.client.ui.plain.StandardModulePresenter;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarPresenter;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.oracle.scheduler.rootlog.client.ui.form.detail.RootLogDetailFormPresenter;
import com.technology.oracle.scheduler.rootlog.client.ui.form.detail.RootLogDetailFormViewImpl;
import com.technology.oracle.scheduler.rootlog.client.ui.form.list.RootLogListFormPresenter;
import com.technology.oracle.scheduler.rootlog.client.ui.form.list.RootLogListFormViewImpl;
import com.technology.oracle.scheduler.rootlog.client.ui.toolbar.RootLogToolBarViewImpl;
import com.technology.oracle.scheduler.rootlog.shared.record.RootLogRecordDefinition;
import com.technology.oracle.scheduler.rootlog.shared.service.RootLogService;
import com.technology.oracle.scheduler.rootlog.shared.service.RootLogServiceAsync;

public class RootLogClientFactoryImpl
extends StandardClientFactoryImpl<PlainEventBus, RootLogServiceAsync> {

  private static final IsWidget rootLogDetailFormView = new RootLogDetailFormViewImpl();
  private static final IsWidget rootLogToolBarView = new RootLogToolBarViewImpl();
  private static final IsWidget rootLogListFormView = new RootLogListFormViewImpl();

  public static PlainClientFactoryImpl<PlainEventBus, JepDataServiceAsync> instance = null;

  private RootLogClientFactoryImpl() {
    super(ROOTLOG_MODULE_ID, RootLogRecordDefinition.instance);
  }

  static public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getInstance() {
    if(instance == null) {
      instance = GWT.create(RootLogClientFactoryImpl.class);
    }
    return instance;
  }

public JepPresenter createPlainModulePresenter(Place place) {
  return new StandardModulePresenter(ROOTLOG_MODULE_ID, place, this);
}

  public JepPresenter createDetailFormPresenter(Place place) {
    return new RootLogDetailFormPresenter(place, this);
  }

  public JepPresenter createListFormPresenter(Place place) {
    return new RootLogListFormPresenter(place, this);
  }

  public JepPresenter createToolBarPresenter(Place place) {
    return new ToolBarPresenter(place, this);
  }

  public IsWidget getToolBarView() {
    return rootLogToolBarView;
  }

  public IsWidget getDetailFormView() {
    return rootLogDetailFormView;
  }

  public IsWidget getListFormView() {
    return rootLogListFormView;
  }

  @Override
  public RootLogServiceAsync createService() {
    return GWT.create(RootLogService.class);
  }
}
