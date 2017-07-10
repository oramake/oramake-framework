package com.technology.oracle.scheduler.interval.client.ui.form.detail;
 
import static com.technology.jep.jepria.client.ui.WorkstateEnum.CREATE;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.EDIT;
import static com.technology.jep.jepria.client.ui.WorkstateEnum.VIEW_DETAILS;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.INTERVAL_ID;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.INTERVAL_TYPE_CODE;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.MAX_VALUE;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.MIN_VALUE;

import java.util.List;

import com.google.gwt.place.shared.Place;
import com.technology.jep.jepria.client.async.FirstTimeUseAsyncCallback;
import com.technology.jep.jepria.client.ui.WorkstateEnum;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormPresenter;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormView;
import com.technology.jep.jepria.client.ui.plain.StandardClientFactory;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.client.widget.event.JepEventType;
import com.technology.jep.jepria.client.widget.event.JepListener;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.oracle.scheduler.interval.shared.service.IntervalServiceAsync;
 
public class IntervalDetailFormPresenter<E extends PlainEventBus, S extends IntervalServiceAsync> 
    extends DetailFormPresenter<DetailFormView, E, S, StandardClientFactory<E, S>> { 
  
  public IntervalDetailFormPresenter(Place place, StandardClientFactory<E, S> clientFactory) {
    super(place, clientFactory);
  }
 
  public void bind() {
    super.bind();
    // Здесь размещается код связывания presenter-а и view 
    fields.addFieldListener(INTERVAL_TYPE_CODE, JepEventType.FIRST_TIME_USE_EVENT, new JepListener() {
      @Override
      public void handleEvent(final JepEvent event) {
        service.getIntervalType(new FirstTimeUseAsyncCallback<List<JepOption>>(event) {
          public void onSuccessLoad(List<JepOption> result){
            fields.setFieldOptions(INTERVAL_TYPE_CODE, result);
          }
        });
      }
    });
  }

  protected void adjustToWorkstate(WorkstateEnum workstate) {
    fields.setFieldVisible(INTERVAL_ID, VIEW_DETAILS.equals(workstate));
 
    fields.setFieldAllowBlank(INTERVAL_TYPE_CODE, !(EDIT.equals(workstate) || CREATE.equals(workstate)));
    fields.setFieldAllowBlank(MIN_VALUE, !(EDIT.equals(workstate) || CREATE.equals(workstate)));
    fields.setFieldAllowBlank(MAX_VALUE, !(EDIT.equals(workstate) || CREATE.equals(workstate)));
 
  }
 
}
