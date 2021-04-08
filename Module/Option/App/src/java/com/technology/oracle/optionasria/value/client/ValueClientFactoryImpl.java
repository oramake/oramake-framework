package com.technology.oracle.optionasria.value.client;
 
import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.VALUE_MODULE_ID;

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
import com.technology.oracle.optionasria.value.client.ui.form.detail.ValueDetailFormPresenter;
import com.technology.oracle.optionasria.value.client.ui.form.detail.ValueDetailFormViewImpl;
import com.technology.oracle.optionasria.value.client.ui.form.list.ValueListFormPresenter;
import com.technology.oracle.optionasria.value.client.ui.form.list.ValueListFormViewImpl;
import com.technology.oracle.optionasria.value.client.ui.toolbar.ValueToolBarPresenter;
import com.technology.oracle.optionasria.value.client.ui.toolbar.ValueToolBarViewImpl;
import com.technology.oracle.optionasria.value.shared.record.ValueRecordDefinition;
import com.technology.oracle.optionasria.value.shared.service.ValueService;
import com.technology.oracle.optionasria.value.shared.service.ValueServiceAsync;
 
public class ValueClientFactoryImpl
		extends StandardClientFactoryImpl<PlainEventBus, ValueServiceAsync> {
 
	private static final IsWidget valueDetailFormView = new ValueDetailFormViewImpl();
	private static final IsWidget valueToolBarView = new ValueToolBarViewImpl();
	private static final IsWidget valueListFormView = new ValueListFormViewImpl();
 
	private static PlainClientFactoryImpl<PlainEventBus, JepDataServiceAsync> instance = null;
	 
  public ValueClientFactoryImpl() {
    super(VALUE_MODULE_ID, ValueRecordDefinition.instance);
  }
 
  static public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getInstance() {
    if(instance == null) {
      instance = GWT.create(ValueClientFactoryImpl.class);
    }
    return instance;
  }
 
  public JepPresenter createPlainModulePresenter(Place place) {
    return new StandardModulePresenter(VALUE_MODULE_ID, place, this);
  }
 
  public JepPresenter createDetailFormPresenter(Place place) {
    return new ValueDetailFormPresenter(place, this);
  }
 
  public JepPresenter createListFormPresenter(Place place) {
    return new ValueListFormPresenter(place, this);
  }
  
  public JepPresenter createToolBarPresenter(Place place) {
    return new ValueToolBarPresenter(place, this);
  }
   
  public IsWidget getToolBarView() {
    return valueToolBarView;
  }
   
  public IsWidget getDetailFormView() {
    return valueDetailFormView;
  }
 
  public IsWidget getListFormView() {
    return valueListFormView;
  }

  @Override
  public ValueServiceAsync createService() {
    return GWT.create(ValueService.class);
  }
}
