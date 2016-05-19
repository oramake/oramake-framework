package com.technology.oracle.optionasria.main.client.ui.module;
 
import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.*;
import static com.technology.jep.jepria.client.security.JepClientSecurity.CHECK_ROLES_BY_OR;
import java.util.HashSet;
import java.util.Set;
import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.main.MainView;
import com.technology.jep.jepria.client.ui.eventbus.main.JepMainEventBus;
import com.technology.jep.jepria.client.ui.main.JepMainClientFactory;
import com.technology.jep.jepria.client.ui.main.JepMainModulePresenter;
import com.technology.jep.jepria.shared.service.JepMainServiceAsync;
 
public class OptionAsRiaMainModulePresenter<E extends JepMainEventBus, S extends JepMainServiceAsync>
			extends JepMainModulePresenter<MainView, E, JepMainClientFactory<E>> {
 
	public OptionAsRiaMainModulePresenter(Place place, JepMainClientFactory<E> clientFactory) {
		super(place, clientFactory);
		addModuleProtection(OPTION_MODULE_ID, "OptShowOption", CHECK_ROLES_BY_OR);
		addModuleProtection(VALUE_MODULE_ID, "OptShowOption", CHECK_ROLES_BY_OR);
	}
 
}
