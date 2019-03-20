package com.technology.oracle.scheduler.schedule.client;

import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.SCHEDULE_MODULE_ID;

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
import com.technology.oracle.scheduler.schedule.client.ui.form.detail.ScheduleDetailFormPresenter;
import com.technology.oracle.scheduler.schedule.client.ui.form.detail.ScheduleDetailFormViewImpl;
import com.technology.oracle.scheduler.schedule.client.ui.form.list.ScheduleListFormPresenter;
import com.technology.oracle.scheduler.schedule.client.ui.form.list.ScheduleListFormViewImpl;
import com.technology.oracle.scheduler.schedule.client.ui.toolbar.ScheduleToolBarViewImpl;
import com.technology.oracle.scheduler.schedule.shared.record.ScheduleRecordDefinition;
import com.technology.oracle.scheduler.schedule.shared.service.ScheduleService;
import com.technology.oracle.scheduler.schedule.shared.service.ScheduleServiceAsync;

public class ScheduleClientFactoryImpl
extends StandardClientFactoryImpl<PlainEventBus, ScheduleServiceAsync> {

  private static final IsWidget scheduleDetailFormView = new ScheduleDetailFormViewImpl();
  private static final IsWidget scheduleToolBarView = new ScheduleToolBarViewImpl();
  private static final IsWidget scheduleListFormView = new ScheduleListFormViewImpl();

  public static PlainClientFactoryImpl<PlainEventBus, JepDataServiceAsync> instance = null;

  private ScheduleClientFactoryImpl() {
    super(SCHEDULE_MODULE_ID, ScheduleRecordDefinition.instance);
  }

  static public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getInstance() {
    if(instance == null) {
      instance = GWT.create(ScheduleClientFactoryImpl.class);
    }
    return instance;
  }

public JepPresenter createPlainModulePresenter(Place place) {
  return new StandardModulePresenter(SCHEDULE_MODULE_ID, place, this);
}

  public JepPresenter createDetailFormPresenter(Place place) {
    return new ScheduleDetailFormPresenter(place, this);
  }

  public JepPresenter createListFormPresenter(Place place) {
    return new ScheduleListFormPresenter(place, this);
  }

  public JepPresenter createToolBarPresenter(Place place) {
    return new ToolBarPresenter(place, this);
  }

  public IsWidget getToolBarView() {
    return scheduleToolBarView;
  }

  public IsWidget getDetailFormView() {
    return scheduleDetailFormView;
  }

  public IsWidget getListFormView() {
    return scheduleListFormView;
  }

  @Override
  public ScheduleServiceAsync createService() {
    return GWT.create(ScheduleService.class);
  }
}
