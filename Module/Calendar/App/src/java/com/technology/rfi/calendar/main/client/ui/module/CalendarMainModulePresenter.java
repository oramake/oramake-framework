package com.technology.rfi.calendar.main.client.ui.module;
 
import static com.technology.jep.jepria.client.security.ClientSecurity.CHECK_ROLES_BY_OR;
import static com.technology.rfi.calendar.main.client.CalendarClientConstant.DAY_MODULE_ID;

import com.technology.jep.jepria.client.ui.eventbus.main.MainEventBus;
import com.technology.jep.jepria.client.ui.main.MainClientFactory;
import com.technology.jep.jepria.client.ui.main.MainModulePresenter;
import com.technology.jep.jepria.client.ui.main.MainView;
import com.technology.jep.jepria.shared.service.JepMainServiceAsync;

public class CalendarMainModulePresenter<E extends MainEventBus, S extends JepMainServiceAsync>
			extends MainModulePresenter<MainView, E, S, MainClientFactory<E, S>> {
 
	public CalendarMainModulePresenter(MainClientFactory<E, S> clientFactory) {
		super(clientFactory);
		addModuleProtection(DAY_MODULE_ID, "CdrUser, CdrAdministrator", CHECK_ROLES_BY_OR);
	}
 
}
