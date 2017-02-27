package com.technology.rfi.calendar.day.client.ui.toolbar;
 
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.EDIT_BUTTON_ID;

import com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl;

public class DayToolBarViewImpl extends ToolBarViewImpl {
  
	public DayToolBarViewImpl() {
		super();
		removeItem(EDIT_BUTTON_ID);
	}
}
