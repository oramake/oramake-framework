package com.technology.oracle.scheduler.option.client;

import static com.technology.oracle.scheduler.main.client.SchedulerClientConstant.*;
import com.google.gwt.core.client.GWT;
import com.google.gwt.place.shared.Place;
import com.google.gwt.user.client.ui.IsWidget;
import com.technology.jep.jepria.client.ui.JepPresenter;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactoryImpl;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactoryImpl;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.oracle.scheduler.option.client.ui.form.OptionFormContainerPresenter;
import com.technology.oracle.scheduler.option.client.ui.form.detail.OptionDetailFormPresenter;
import com.technology.oracle.scheduler.option.client.ui.form.detail.OptionDetailFormViewImpl;
import com.technology.oracle.scheduler.option.client.ui.form.list.OptionListFormPresenter;
import com.technology.oracle.scheduler.option.client.ui.form.list.OptionListFormViewImpl;
import com.technology.oracle.scheduler.option.client.ui.toolbar.OptionToolBarPresenter;
import com.technology.oracle.scheduler.option.client.ui.toolbar.OptionToolBarViewImpl;
import com.technology.oracle.scheduler.option.shared.record.OptionRecordDefinition;
import com.technology.oracle.scheduler.option.shared.service.OptionService;
import com.technology.oracle.scheduler.option.shared.service.OptionServiceAsync;

public class OptionClientFactoryImpl
extends StandardClientFactoryImpl<PlainEventBus, OptionServiceAsync> {

  private static final IsWidget optionDetailFormView = new OptionDetailFormViewImpl();
  private static final IsWidget optionToolBarView = new OptionToolBarViewImpl();
  private static final IsWidget optionListFormView = new OptionListFormViewImpl();

  public static PlainClientFactoryImpl<PlainEventBus, JepDataServiceAsync> instance = null;

  private OptionClientFactoryImpl() {
    super(OPTION_MODULE_ID, OptionRecordDefinition.instance);
  }

  static public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getInstance() {
    if(instance == null) {
      instance = GWT.create(OptionClientFactoryImpl.class);
    }
    return instance;
  }

  public JepPresenter createPlainModulePresenter(Place place) {
    return new OptionFormContainerPresenter(place, this);
  }

  public JepPresenter createDetailFormPresenter(Place place) {
    return new OptionDetailFormPresenter(place, this);
  }

  public JepPresenter createListFormPresenter(Place place) {
    return new OptionListFormPresenter(place, this);
  }

  public JepPresenter createToolBarPresenter(Place place) {
    return new OptionToolBarPresenter(place, this);
  }

  public IsWidget getToolBarView() {
    return optionToolBarView;
  }

  public IsWidget getDetailFormView() {
    return optionDetailFormView;
  }

  public IsWidget getListFormView() {
    return optionListFormView;
  }

  @Override
  public OptionServiceAsync createService() {
    return GWT.create(OptionService.class);
  }
}
