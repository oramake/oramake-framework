package com.technology.oracle.scheduler.interval.client.ui.toolbar;
 
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.FIND_BUTTON_ID;
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.SEARCH_BUTTON_ID;

import com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl;
 
public class IntervalToolBarViewImpl extends ToolBarViewImpl {
  
	public IntervalToolBarViewImpl() {
		super();
		
		removeItem(SEARCH_BUTTON_ID);
		removeItem(FIND_BUTTON_ID);
	}
}
