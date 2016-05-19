package com.technology.oracle.scheduler.rootlog.client.ui.toolbar;
 
import static com.technology.jep.jepria.client.JepRiaClientConstant.JepImages;
import static com.technology.jep.jepria.client.JepRiaClientConstant.JepTexts;
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.UP_BUTTON_ID;

import com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl;
 
public class RootLogToolBarViewImpl extends ToolBarViewImpl {
  
	public RootLogToolBarViewImpl() {
		super();
	
		removeAll();
		
		addButton(
				UP_BUTTON_ID,
				JepImages.up(),
				JepTexts.button_up_alt());
	}
}
