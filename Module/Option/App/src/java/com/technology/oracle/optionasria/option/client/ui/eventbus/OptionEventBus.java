package com.technology.oracle.optionasria.option.client.ui.eventbus;

import com.technology.jep.jepria.client.ui.eventbus.plain.JepEventBus;
import com.technology.jep.jepria.client.ui.module.JepBaseClientFactory;
import com.technology.jep.jepria.client.ui.module.JepClientFactory;

public class OptionEventBus extends JepEventBus {

	public OptionEventBus(JepClientFactory<?, ?> clientFactory) {
		super(clientFactory);
	}
}
