package com.technology.oracle.optionasria.value.client;
 
import com.google.gwt.core.client.GWT;
import com.technology.oracle.optionasria.value.shared.ValueConstant;
import com.technology.oracle.optionasria.value.shared.text.ValueText;
 
public class ValueClientConstant extends ValueConstant {
 
	public static ValueText valueText = (ValueText) GWT.create(ValueText.class);
}
