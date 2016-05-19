package com.technology.oracle.optionasria.option.client;

import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.*;

import com.google.gwt.core.client.GWT;
import com.technology.oracle.optionasria.option.shared.OptionConstant;
import com.technology.oracle.optionasria.option.shared.text.OptionText;
 
public class OptionClientConstant extends OptionConstant {
 
	public static String[] scopeModuleIds = {OPTION_MODULE_ID, VALUE_MODULE_ID}; 
	public static OptionText optionText = (OptionText) GWT.create(OptionText.class);
}
