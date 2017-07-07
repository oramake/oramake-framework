package com.technology.oracle.scheduler.batch.client.ui.eventbus;
 
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.event.AbortBatchEvent;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.event.ActivateBatchEvent;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.event.DeactivateBatchEvent;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.event.ExecuteBatchEvent;
 
public class BatchEventBus extends PlainEventBus {
 
  public BatchEventBus(PlainClientFactory<?, ?> clientFactory) {
    super(clientFactory);
  }
 
  
  public void activateBatch() { 
    fireEvent(new ActivateBatchEvent());
  }
 
  public void deactivateBatch() { 
    fireEvent(new DeactivateBatchEvent());
  }
 
  public void executeBatch() { 
    fireEvent(new ExecuteBatchEvent());
  }
 
  public void abortBatch() { 
    fireEvent(new AbortBatchEvent());
  }
 
}
