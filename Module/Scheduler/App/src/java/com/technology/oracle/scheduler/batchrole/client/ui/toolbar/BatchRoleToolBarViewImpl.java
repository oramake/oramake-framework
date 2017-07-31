package com.technology.oracle.scheduler.batchrole.client.ui.toolbar;
 
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.EDIT_BUTTON_ID;
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.FIND_BUTTON_ID;
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.SEARCH_BUTTON_ID;

import com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl;
 
public class BatchRoleToolBarViewImpl extends ToolBarViewImpl {
  
  public BatchRoleToolBarViewImpl() {
    super();
    
    removeItem(EDIT_BUTTON_ID);
    
    removeItem(SEARCH_BUTTON_ID);
    removeItem(FIND_BUTTON_ID);
  }
}
