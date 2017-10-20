package com.technology.oracle.optionasria.option.client.ui.toolbar;
 
import com.google.gwt.core.client.GWT;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl;
import com.technology.oracle.optionasria.option.client.ui.toolbar.images.OptionImages;

import static com.technology.jep.jepria.client.JepRiaClientConstant.JepTexts;
import static com.technology.oracle.optionasria.option.shared.OptionConstant.*;
 
public class OptionToolBarViewImpl extends ToolBarViewImpl {
  
	public final static String OPTION_CURRENT_VALUE = "option_current_value"; 
	public static final OptionImages optionImages = GWT.create(OptionImages.class);
	
	public OptionToolBarViewImpl() {
		super();
		
		addButton(
				OPTION_CURRENT_VALUE, 
				optionImages.option_value(),
				optionText.option_current_value()
		);
	}

}
