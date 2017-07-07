package com.technology.oracle.scheduler.value.client.ui.toolbar;
 
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.FIND_BUTTON_ID;
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.SEARCH_BUTTON_ID;
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.VIEW_DETAILS_BUTTON_ID;

import com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl;
 
public class ValueToolBarViewImpl extends ToolBarViewImpl {
  
  public ValueToolBarViewImpl() {
    super();
    
    removeItem(VIEW_DETAILS_BUTTON_ID);
    removeItem(SEARCH_BUTTON_ID);
    removeItem(FIND_BUTTON_ID);
  }
}
