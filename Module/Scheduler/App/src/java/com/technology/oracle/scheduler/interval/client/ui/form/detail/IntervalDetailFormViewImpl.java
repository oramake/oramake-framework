package com.technology.oracle.scheduler.interval.client.ui.form.detail;
 
import static com.technology.oracle.scheduler.interval.client.IntervalClientConstant.intervalText;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.INTERVAL_ID;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.INTERVAL_TYPE_CODE;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.MAX_VALUE;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.MIN_VALUE;
import static com.technology.oracle.scheduler.interval.shared.field.IntervalFieldNames.STEP;

import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.user.client.ui.ScrollPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.technology.jep.jepria.client.ui.form.detail.DetailFormViewImpl;
import com.technology.jep.jepria.client.widget.field.FieldManager;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.client.widget.field.multistate.JepNumberField;
 
public class IntervalDetailFormViewImpl extends DetailFormViewImpl {  
 
  public IntervalDetailFormViewImpl() {
    super(new FieldManager());

    ScrollPanel scrollPanel = new ScrollPanel();
    scrollPanel.setSize("100%", "100%");
    
    VerticalPanel panel = new VerticalPanel();
    panel.getElement().getStyle().setMarginTop(5, Unit.PX);
    scrollPanel.add(panel);
 
    JepNumberField intervalIdNumberField = new JepNumberField(intervalText.interval_detail_interval_id());
    JepComboBoxField intervalTypeCodeComboBoxField = new JepComboBoxField(intervalText.interval_detail_interval_type_code());
    JepNumberField minValueNumberField = new JepNumberField(intervalText.interval_detail_min_value());
    JepNumberField maxValueNumberField = new JepNumberField(intervalText.interval_detail_max_value());
    JepNumberField stepNumberField = new JepNumberField(intervalText.interval_detail_step());
    
    panel.add(intervalIdNumberField);
    panel.add(intervalTypeCodeComboBoxField);
    panel.add(minValueNumberField);
    panel.add(maxValueNumberField);
    panel.add(stepNumberField);
    
    setWidget(scrollPanel);
 
    fields.put(INTERVAL_ID, intervalIdNumberField);
    fields.put(INTERVAL_TYPE_CODE, intervalTypeCodeComboBoxField);
    fields.put(MIN_VALUE, minValueNumberField);
    fields.put(MAX_VALUE, maxValueNumberField);
    fields.put(STEP, stepNumberField);
  }
 
}
