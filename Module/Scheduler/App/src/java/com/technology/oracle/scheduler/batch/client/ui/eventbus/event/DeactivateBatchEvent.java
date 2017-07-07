package com.technology.oracle.scheduler.batch.client.ui.eventbus.event;
 
import com.google.gwt.event.shared.EventHandler;
import com.technology.jep.jepria.client.ui.eventbus.BusEvent;
 
public class DeactivateBatchEvent extends BusEvent<DeactivateBatchEvent.Handler> {
 
  public interface Handler extends EventHandler {
    void onDeactivateBatchEvent(DeactivateBatchEvent event);
  }
 
  public static final Type<Handler> TYPE = new Type<Handler>();
 
  @Override
  public Type<Handler> getAssociatedType() {
    return TYPE;
  }
 
  @Override
  protected void dispatch(Handler handler) {
    handler.onDeactivateBatchEvent(this);
  }
}
