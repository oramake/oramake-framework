package com.technology.oracle.scheduler.schedule.client.ui.form.detail;
 
import static com.technology.oracle.scheduler.schedule.client.ScheduleClientConstant.scheduleText;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.SCHEDULE_ID;
import static com.technology.oracle.scheduler.schedule.shared.field.ScheduleFieldNames.SCHEDULE_NAME;

import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.user.client.ui.ScrollPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormViewImpl;
import com.technology.jep.jepria.client.widget.field.FieldManager;
import com.technology.jep.jepria.client.widget.field.multistate.JepNumberField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTextField;
 
public class ScheduleDetailFormViewImpl extends DetailFormViewImpl {  
 
  public ScheduleDetailFormViewImpl() {
    super(new FieldManager());
     
    ScrollPanel scrollPanel = new ScrollPanel();
    scrollPanel.setSize("100%", "100%");
    VerticalPanel panel = new VerticalPanel();
    panel.getElement().getStyle().setMarginTop(5, Unit.PX);
    scrollPanel.add(panel);
 
    JepNumberField scheduleIdNumberField = new JepNumberField(scheduleText.schedule_detail_schedule_id());
    JepTextField scheduleNameTextField = new JepTextField(scheduleText.schedule_detail_schedule_name());
    
    panel.add(scheduleIdNumberField);
    panel.add(scheduleNameTextField);
    
    setWidget(scrollPanel);
 
    fields.put(SCHEDULE_ID, scheduleIdNumberField);
    fields.put(SCHEDULE_NAME, scheduleNameTextField);
  }
 
}
