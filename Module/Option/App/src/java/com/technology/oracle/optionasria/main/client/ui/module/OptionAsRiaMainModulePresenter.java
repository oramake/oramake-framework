package com.technology.oracle.optionasria.main.client.ui.module;
 
import static com.technology.jep.jepria.client.security.ClientSecurity.CHECK_ROLES_BY_OR;
import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.OPTION_MODULE_ID;
import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.VALUE_MODULE_ID;

import com.technology.jep.jepria.client.ui.eventbus.main.MainEventBus;
import com.technology.jep.jepria.client.ui.main.MainClientFactory;
import com.technology.jep.jepria.client.ui.main.MainModulePresenter;
import com.technology.jep.jepria.client.ui.main.MainView;
import com.technology.jep.jepria.shared.service.JepMainServiceAsync;
 
public class OptionAsRiaMainModulePresenter<E extends MainEventBus, S extends JepMainServiceAsync>
			extends MainModulePresenter<MainView, E, S, MainClientFactory<E,S>> {
 
	public OptionAsRiaMainModulePresenter(MainClientFactory<E, S> clientFactory) {
		super(clientFactory);
		addModuleProtection(OPTION_MODULE_ID, "OptShowOption", CHECK_ROLES_BY_OR);
		addModuleProtection(VALUE_MODULE_ID, "OptShowOption", CHECK_ROLES_BY_OR);
	}
 
}
