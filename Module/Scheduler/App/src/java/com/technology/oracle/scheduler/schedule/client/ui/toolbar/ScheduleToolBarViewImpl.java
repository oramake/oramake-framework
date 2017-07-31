package com.technology.oracle.scheduler.schedule.client.ui.toolbar;
 
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.FIND_BUTTON_ID;
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.SEARCH_BUTTON_ID;

import com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl;

public class ScheduleToolBarViewImpl extends ToolBarViewImpl {
  
  public ScheduleToolBarViewImpl() {
    super();
    
    removeItem(SEARCH_BUTTON_ID);
    removeItem(FIND_BUTTON_ID);
  }
}
