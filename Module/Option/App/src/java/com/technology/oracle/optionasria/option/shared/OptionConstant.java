package com.technology.oracle.optionasria.option.shared;
 
import com.google.gwt.core.client.GWT;
import com.technology.jep.jepria.shared.JepRiaConstant;
import com.technology.oracle.optionasria.option.shared.text.OptionText;
 
public class OptionConstant extends JepRiaConstant  {
	
	public static OptionText optionText = (OptionText) GWT.create(OptionText.class);
	final public static String dateValueTypeCode = "DATE";
	final public static String numberValueTypeCode = "NUM";
	final public static String stringValueTypeCode = "STR";
}
