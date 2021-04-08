package com.technology.oracle.optionasria.main.client;

import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.OPTION_MODULE_ID;
import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.VALUE_MODULE_ID;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.ui.IsWidget;
import com.technology.jep.jepria.client.async.LoadAsyncCallback;
import com.technology.jep.jepria.client.async.LoadPlainClientFactory;
import com.technology.jep.jepria.client.ui.eventbus.main.MainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.main.MainClientFactory;
import com.technology.jep.jepria.client.ui.main.MainClientFactoryImpl;
import com.technology.jep.jepria.client.ui.main.MainModulePresenter;
import com.technology.jep.jepria.client.ui.main.MainView;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.jep.jepria.shared.service.JepMainServiceAsync;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.oracle.optionasria.main.client.ui.module.OptionAsRiaMainModulePresenter;
import com.technology.oracle.optionasria.main.client.ui.module.OptionAsRiaMainViewImpl;
import com.technology.oracle.optionasria.option.client.OptionClientFactoryImpl;
import com.technology.oracle.optionasria.value.client.ValueClientFactoryImpl;


public class OptionAsRiaClientFactoryImpl extends MainClientFactoryImpl<MainEventBus, JepMainServiceAsync> {

  private static final IsWidget mainView = new OptionAsRiaMainViewImpl() ;

	public static MainClientFactory<MainEventBus, JepMainServiceAsync> getInstance() {
    if(instance == null) {
      instance = GWT.create(OptionAsRiaClientFactoryImpl.class);
    }
    return instance;
  }

	private OptionAsRiaClientFactoryImpl() {
    super(
        OPTION_MODULE_ID,
        VALUE_MODULE_ID
    );
  }

	@Override
	public MainModulePresenter<? extends MainView, MainEventBus,JepMainServiceAsync, ? extends MainClientFactory<MainEventBus, JepMainServiceAsync>> createMainModulePresenter() {
		return new OptionAsRiaMainModulePresenter(this);
	}

	public void getPlainClientFactory(String moduleId, final LoadAsyncCallback<PlainClientFactory<PlainEventBus, JepDataServiceAsync>> callback) {
    if(VALUE_MODULE_ID.equals(moduleId)) {
      GWT.runAsync(new LoadPlainClientFactory(callback) {
        public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getPlainClientFactory() {
          Log.trace(OptionAsRiaClientFactoryImpl.this.getClass() + ".getPlainClientFactory: moduleId = " + VALUE_MODULE_ID);
          return ValueClientFactoryImpl.getInstance();
        }
      });
    }
    else if(OPTION_MODULE_ID.equals(moduleId)) {
      GWT.runAsync(new LoadPlainClientFactory(callback) {
        public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getPlainClientFactory() {
          Log.trace(OptionAsRiaClientFactoryImpl.this.getClass() + ".getPlainClientFactory: moduleId = " + OPTION_MODULE_ID);
          return OptionClientFactoryImpl.getInstance();
        }
      });
    }
  }

  @Override
  public IsWidget getMainView() {
    return mainView;
  }
}
