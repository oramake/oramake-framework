package com.technology.oracle.scheduler.batch.client.ui.toolbar;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.SELECTED;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.VIEW_DETAILS;
import static com.technology.oracle.scheduler.batch.client.ui.toolbar.BatchToolBarViewImpl.ABORT_BATCH;
import static com.technology.oracle.scheduler.batch.client.ui.toolbar.BatchToolBarViewImpl.ACTIVATE_BATCH;
import static com.technology.oracle.scheduler.batch.client.ui.toolbar.BatchToolBarViewImpl.DEACTIVATE_BATCH;
import static com.technology.oracle.scheduler.batch.client.ui.toolbar.BatchToolBarViewImpl.EXECUTE_BATCH;

import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarPresenter;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarView;
import com.technology.oracle.scheduler.batch.client.ui.eventbus.BatchEventBus;
import com.technology.oracle.scheduler.batch.shared.service.BatchServiceAsync;
 
public class BatchToolBarPresenter<V extends ToolBarView, E extends BatchEventBus, S extends BatchServiceAsync, F extends StandardClientFactory<E, S>> 
  extends ToolBarPresenter<V, E, S, F> {
 
   public BatchToolBarPresenter(Place place, F clientFactory) {
    super(place, clientFactory);
  }

  protected void bind() {
    super.bind();
    
    bindButton(
      ACTIVATE_BATCH, 
      new WorkstateEnum[]{SELECTED, VIEW_DETAILS},
      new ClickHandler() {
        public void onClick(ClickEvent event) {
          eventBus.activateBatch();
        }
      });
    
    bindButton(
      DEACTIVATE_BATCH, 
      new WorkstateEnum[]{SELECTED, VIEW_DETAILS},
      new ClickHandler() {
        public void onClick(ClickEvent event) {
          eventBus.deactivateBatch();
        }
      });
    
    bindButton(
      EXECUTE_BATCH, 
      new WorkstateEnum[]{SELECTED, VIEW_DETAILS},
      new ClickHandler() {
        public void onClick(ClickEvent event) {
          eventBus.executeBatch();
        }
      });
   
    bindButton(
      ABORT_BATCH, 
      new WorkstateEnum[]{SELECTED, VIEW_DETAILS},
      new ClickHandler() {
        public void onClick(ClickEvent event) {
          eventBus.abortBatch();
        }
      });
  }
}
