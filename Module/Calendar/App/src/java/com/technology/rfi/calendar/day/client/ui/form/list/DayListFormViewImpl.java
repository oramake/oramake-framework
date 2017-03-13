package com.technology.rfi.calendar.day.client.ui.form.list;
 
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.rfi.calendar.day.client.DayClientConstant.dayText;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DAY;
import static com.technology.rfi.calendar.day.shared.field.DayFieldNames.DAY_TYPE_NAME;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.cell.client.DateCell;
import com.google.gwt.i18n.client.DateTimeFormat;
import com.technology.jep.jepria.client.ui.form.list.StandardListFormViewImpl;
import com.technology.jep.jepria.client.widget.list.JepColumn;
 
public class DayListFormViewImpl extends StandardListFormViewImpl {
 
	public DayListFormViewImpl() {
		super(DayListFormViewImpl.class.getCanonicalName());
	}
 
	private static DateTimeFormat defaultDateFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT);
 
	@SuppressWarnings({ "rawtypes", "unchecked" })
  @Override
  protected List<JepColumn> getColumnConfigurations() {
	  return new ArrayList<JepColumn>() {
      private static final long serialVersionUID = 1L;
    {
	    add(new JepColumn(DAY_TYPE_NAME, dayText.day_list_day_type_name(), 250));
	    add(new JepColumn(DAY, dayText.day_list_day(), 80, new DateCell(defaultDateFormatter)));
	  }};
	}
}
