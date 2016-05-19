package com.technology.oracle.optionasria.main.client;
 
import com.google.gwt.core.client.GWT;
import com.technology.oracle.optionasria.main.shared.text.OptionAsRiaText;
import com.technology.jep.jepria.shared.JepRiaConstant;
 
public class OptionAsRiaClientConstant extends JepRiaConstant {
	public static final String OPTION_MODULE_ID = "Option";
	public static final String VALUE_MODULE_ID = "Value";
	public static OptionAsRiaText optionText = (OptionAsRiaText) GWT.create(OptionAsRiaText.class);
}
