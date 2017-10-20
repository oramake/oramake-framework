package com.technology.oracle.optionasria.option.client.ui.eventbus;

import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;

public class OptionEventBus extends PlainEventBus {

	public OptionEventBus(PlainClientFactory<?, ?> clientFactory) {
		super(clientFactory);
	}
}
