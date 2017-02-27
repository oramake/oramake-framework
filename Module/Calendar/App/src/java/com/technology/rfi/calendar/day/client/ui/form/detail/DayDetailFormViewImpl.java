package com.technology.rfi.calendar.day.client.ui.form.detail;
 
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import static com.technology.rfi.calendar.day.client.DayClientConstant.dayText;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DATE_BEGIN;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DATE_END;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DAY;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DAY_TYPE_ID;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DAY_TYPE_NAME;

import com.technology.jep.jepria.client.ui.form.detail.StandardDetailFormViewImpl;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.client.widget.field.multistate.JepDateField;
import com.technology.jep.jepria.client.widget.field.multistate.JepIntegerField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTextField;
 
public class DayDetailFormViewImpl extends StandardDetailFormViewImpl {	
 
	public DayDetailFormViewImpl() {
 
		JepComboBoxField dayTypeIdComboBoxField = new JepComboBoxField(dayText.day_detail_day_type_id());
		JepTextField dayTypeNameTextField = new JepTextField(dayText.day_detail_day_type_id());
		JepDateField dayDateField = new JepDateField(dayText.day_detail_day());
		JepDateField dateBeginDateField = new JepDateField(dayText.day_detail_date_begin());
		JepDateField dateEndDateField = new JepDateField(dayText.day_detail_date_end());
		JepIntegerField maxRowCountField = new JepIntegerField(dayText.day_detail_row_count());
		maxRowCountField.setMaxLength(4);
		maxRowCountField.setFieldWidth(55);
 
		panel.add(dayTypeIdComboBoxField);
		panel.add(dayTypeNameTextField);
		panel.add(dayDateField);
		panel.add(dateBeginDateField);
		panel.add(dateEndDateField);
		panel.add(maxRowCountField);
 
		
		fields.put(DAY_TYPE_ID, dayTypeIdComboBoxField);
		fields.put(DAY_TYPE_NAME, dayTypeNameTextField);
		fields.put(DAY, dayDateField);
		fields.put(DATE_BEGIN, dateBeginDateField);
		fields.put(DATE_END, dateEndDateField);
		fields.put(MAX_ROW_COUNT, maxRowCountField);
	}
 
}
