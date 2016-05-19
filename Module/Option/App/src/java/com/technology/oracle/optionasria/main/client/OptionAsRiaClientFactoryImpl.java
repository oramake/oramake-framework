package com.technology.oracle.optionasria.main.client;
 
import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.*;

import com.google.gwt.core.client.GWT;
import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.main.MainView;
import com.technology.jep.jepria.client.ui.eventbus.main.JepMainEventBus;
import com.technology.jep.jepria.client.ui.main.JepMainClientFactory;
import com.technology.jep.jepria.client.ui.main.JepMainClientFactoryImpl;
import com.technology.jep.jepria.client.ui.main.JepMainModulePresenter;
import com.technology.jep.jepria.client.async.LoadAsyncCallback;
import com.technology.jep.jepria.client.async.LoadPlainClientFactory;
import com.technology.oracle.optionasria.main.client.ui.module.OptionAsRiaMainModulePresenter;
import com.technology.oracle.optionasria.option.client.OptionClientFactoryImpl;
import com.technology.oracle.optionasria.value.client.ValueClientFactoryImpl;
import com.technology.jep.jepria.client.ui.module.JepBaseClientFactory;
import com.technology.jep.jepria.client.ui.eventbus.plain.JepEventBus;
import com.technology.jep.jepria.shared.service.JepMainServiceAsync;
 
public class OptionAsRiaClientFactoryImpl<E extends JepMainEventBus, S extends JepMainServiceAsync>
	extends JepMainClientFactoryImpl<E>
		implements JepMainClientFactory<E> {
	public static JepMainClientFactory<JepMainEventBus> getInstance() {
		if(instance == null) {
			instance = new OptionAsRiaClientFactoryImpl<JepMainEventBus, JepMainServiceAsync>();
		}
		return instance;
	}
 
	private OptionAsRiaClientFactoryImpl() {
		super(new String[]{
			OPTION_MODULE_ID
			, VALUE_MODULE_ID
		},new String[]{
			optionText.submodule_option_title()
			, optionText.submodule_value_title()
		});
	}
 
	@Override
	public JepMainModulePresenter<MainView, E, JepMainClientFactory<E>> getMainModulePresenter(Place place) {
		return new OptionAsRiaMainModulePresenter(place, this);
	}
 
	public void getPlainClientFactory(String moduleId, final LoadAsyncCallback<JepBaseClientFactory<JepEventBus>> callback) {
		if(OPTION_MODULE_ID.equals(moduleId)) {
			GWT.runAsync(new LoadPlainClientFactory(callback) {
				public JepBaseClientFactory<JepEventBus> getPlainClientFactory() {
					return  OptionClientFactoryImpl.getInstance();
				}
			});
		}
		else if(VALUE_MODULE_ID.equals(moduleId)) {
			GWT.runAsync(new LoadPlainClientFactory(callback) {
				public JepBaseClientFactory<JepEventBus> getPlainClientFactory() {
					return ValueClientFactoryImpl.getInstance();
				}
			});
		}
	}
}
