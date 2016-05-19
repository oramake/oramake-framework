package com.technology.oracle.scheduler.batch.client.ui.eventbus.event;
 
import com.google.gwt.event.shared.EventHandler;
import com.technology.jep.jepria.client.ui.eventbus.BusEvent;
 
public class ActivateBatchEvent extends BusEvent<ActivateBatchEvent.Handler> {
 
	public interface Handler extends EventHandler {
		void onActivateBatchEvent(ActivateBatchEvent event);
	}
 
	public static final Type<Handler> TYPE = new Type<Handler>();
 
	@Override
	public Type<Handler> getAssociatedType() {
		return TYPE;
	}
 
	@Override
	protected void dispatch(Handler handler) {
		handler.onActivateBatchEvent(this);
	}
}
