package com.technology.oracle.optionasria.value.client.ui.toolbar;
 
import com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl;
import static com.technology.jep.jepria.client.JepRiaClientConstant.JepTexts;
 
public class ValueToolBarViewImpl extends ToolBarViewImpl {
  
	public ValueToolBarViewImpl() {
		super();
		
		removeItem(VIEW_DETAILS_BUTTON_ID);
//		removeItem(SEARCH_SEPARATOR_ID);
//		removeItem(LIST_BUTTON_ID);
		removeItem(SEARCH_BUTTON_ID);
		removeItem(DO_SEARCH_BUTTON_ID);
	}
}
