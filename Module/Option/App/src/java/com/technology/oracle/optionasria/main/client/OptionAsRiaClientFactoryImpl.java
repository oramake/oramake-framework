package com.technology.oracle.optionasria.main.client;

import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.OPTION_MODULE_ID;
import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.VALUE_MODULE_ID;
import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.optionText;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.activity.shared.Activity;
import com.google.gwt.core.client.GWT;
import com.technology.jep.jepria.client.ModuleItem;
import com.technology.jep.jepria.client.async.LoadAsyncCallback;
import com.technology.jep.jepria.client.async.LoadPlainClientFactory;
import com.technology.jep.jepria.client.ui.eventbus.main.MainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.main.MainClientFactory;
import com.technology.jep.jepria.client.ui.main.MainClientFactoryImpl;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.jep.jepria.shared.service.JepMainServiceAsync;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;
import com.technology.oracle.optionasria.main.client.ui.module.OptionAsRiaMainModulePresenter;
import com.technology.oracle.optionasria.option.client.OptionClientFactoryImpl;
import com.technology.oracle.optionasria.value.client.ValueClientFactoryImpl;

public class OptionAsRiaClientFactoryImpl<E extends MainEventBus, S extends JepMainServiceAsync>
	extends MainClientFactoryImpl<E, S> implements MainClientFactory<E, S> {

	public static MainClientFactory<MainEventBus, JepMainServiceAsync> getInstance() {
    if(instance == null) {
      instance = GWT.create(OptionAsRiaClientFactoryImpl.class);
    }
    return instance;
  }

	private OptionAsRiaClientFactoryImpl() {
    super(
        new ModuleItem(OPTION_MODULE_ID, optionText.submodule_option_title())
        , new ModuleItem(VALUE_MODULE_ID, optionText.submodule_value_title())
    );

    initActivityMappers(this);
  }

	@Override
	public Activity createMainModulePresenter() {
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
}
