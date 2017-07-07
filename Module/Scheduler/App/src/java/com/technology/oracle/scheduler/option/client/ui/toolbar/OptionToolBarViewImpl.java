package com.technology.oracle.scheduler.option.client.ui.toolbar;
 
import com.google.gwt.core.client.GWT;
import com.technology.jep.jepria.client.ui.toolbar.ToolBarViewImpl;
import com.technology.oracle.scheduler.option.client.ui.toolbar.images.OptionImages;
import static com.technology.oracle.scheduler.option.client.OptionClientConstant.optionText;
import static com.technology.jep.jepria.client.ui.toolbar.ToolBarConstant.*;

public class OptionToolBarViewImpl extends ToolBarViewImpl {
    
  public final static String OPTION_CURRENT_VALUE = "option_current_value"; 
  public static final OptionImages optionImages = GWT.create(OptionImages.class);
    
  public OptionToolBarViewImpl() {
    super();
    
    removeItem(SEARCH_BUTTON_ID);
    removeItem(FIND_BUTTON_ID);
    
    addButton(
        OPTION_CURRENT_VALUE, 
        optionImages.optionValue(),
        optionText.option_current_value()
    );
  }
}
