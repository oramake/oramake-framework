package com.technology.oracle.scheduler.moduleroleprivilege.client.ui.toolbar;
 
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.EDIT_BUTTON_ID;

import com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl;
 
public class ModuleRolePrivilegeToolBarViewImpl extends ToolBarViewImpl {
  
	public ModuleRolePrivilegeToolBarViewImpl() {
		super();
		
		removeItem(EDIT_BUTTON_ID);
	}
}
