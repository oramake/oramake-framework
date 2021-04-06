package com.technology.oracle.optionasria.option.client;

import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.OPTION_MODULE_ID;

import com.google.gwt.core.client.GWT;
import com.google.gwt.place.shared.Place;
import com.google.gwt.user.client.ui.IsWidget;
import com.technology.jep.jepria.client.ui.JepPresenter;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.form.list.ListFormPresenter;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactoryImpl;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactoryImpl;
import com.technology.jep.jepria.client.ui.plain.StandardModulePresenter;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.oracle.optionasria.option.client.ui.eventbus.OptionEventBus;
import com.technology.oracle.optionasria.option.client.ui.form.detail.OptionDetailFormPresenter;
import com.technology.oracle.optionasria.option.client.ui.form.detail.OptionDetailFormViewImpl;
import com.technology.oracle.optionasria.option.client.ui.form.list.OptionListFormPresenter;
import com.technology.oracle.optionasria.option.client.ui.form.list.OptionListFormViewImpl;
import com.technology.oracle.optionasria.option.client.ui.toolbar.OptionToolBarPresenter;
import com.technology.oracle.optionasria.option.client.ui.toolbar.OptionToolBarViewImpl;
import com.technology.oracle.optionasria.option.shared.record.OptionRecordDefinition;
import com.technology.oracle.optionasria.option.shared.service.OptionService;
import com.technology.oracle.optionasria.option.shared.service.OptionServiceAsync;
import com.technology.oracle.optionasria.option.client.ui.OptionFormContainerPresenter;

public class OptionClientFactoryImpl< S extends OptionServiceAsync>
		extends StandardClientFactoryImpl<OptionEventBus, S> {

	private static final IsWidget optionDetailFormView = new OptionDetailFormViewImpl();
	private static final IsWidget optionToolBarView = new OptionToolBarViewImpl();
	private static final IsWidget optionListFormView = new OptionListFormViewImpl();

	private static PlainClientFactoryImpl<PlainEventBus, JepDataServiceAsync> instance = null;

  public OptionClientFactoryImpl() {
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

  protected OptionEventBus createEventBus() {
    return new OptionEventBus();
  }


  public S getService() {
    if(dataService == null) {
      dataService = (S) GWT.create(OptionService.class);
    }
    return dataService;
  }
}
